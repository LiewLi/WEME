//
//  QZStretchableTabBarController.m
//  QZTabBarController
//
//  Created by vicxia on 6/7/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import "QZStretchableTabBarController.h"
#import <objc/runtime.h>

typedef enum {
    MVStretchableHeaderBlurState_None,//无毛玻璃
    MVStretchableHeaderBlurState_RealtimeBlur,//实时毛玻璃
    MVStretchableHeaderBlurState_FixBulr,//固定毛玻璃值
}MVStretchableHeaderBlurState;

static char kMVStretchabletabObserverContext = 0;

@interface QZStretchableTabBarController ()<QZTabBarControllerDelegate>

@property (nonatomic, strong, readwrite) QZStretchableHeaderView *headerView;
@property (nonatomic, strong, readwrite) QZStretchableOverlayView *infoView;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *targetScrollView;
@property (nonatomic, assign) CGFloat defaultOffsetY;

@property (nonatomic, assign) CGFloat titleInterpolateA;
@property (nonatomic, assign) CGFloat titleInterpolateB;
@property (nonatomic, assign) CGFloat titleScaleFactor;

@property (nonatomic, assign) CGFloat infoInterpolateA;
@property (nonatomic, assign) CGFloat infoInterpolateB;
@property (nonatomic, assign) CGFloat infoScaleFactor;

@property (nonatomic, assign) CGFloat blurRadius;
@property (nonatomic, strong) dispatch_source_t blurSource;

@property (nonatomic, assign) MVStretchableHeaderBlurState blurState;

@property (nonatomic, assign) CGFloat lastOffsetY;

@end

@implementation QZStretchableTabBarController

+ (Class)headerViewClass
{
    return [QZStretchableHeaderView class];
}

+ (Class)infoViewClass
{
    return [QZStretchableOverlayView class];
}

- (void)dealloc
{
    [self st_stopProcessHeaderViewBlur];
}

- (void)viewDidLoad {
    [self initialization];
    [self st_createOverlayView];
    [super viewDidLoad];
    [self st_setupOverlayView];
    
    self.defaultOffsetY = -self.headerHeight - self.qzTabBarHight;
    self.qzTabBar.top = self.headerHeight;
    
    self.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self st_removeTargetScrollView];
}

- (void)layout
{
    //    [super layout];
    CGRect titleFrame = self.titleLabelFrame;
    self.titleLabel.center = CGPointMake(CGRectGetMidX(titleFrame), CGRectGetMidY(titleFrame));
    self.titleLabel.bounds = CGRectMake(0, 0, titleFrame.size.width, titleFrame.size.height);
    
    CGRect infoFrame = self.infoViewFrame;
    self.infoView.center = CGPointMake(CGRectGetMidX(infoFrame), CGRectGetMidY(infoFrame));
    self.infoView.bounds = CGRectMake(0, 0, infoFrame.size.width, infoFrame.size.height);
}

#pragma mark- 初始化
- (void)initialization
{
    self.qzTabBarVerticalPostionStyle = QZTabBarVerticalPositionStyleCustom;
    self.qzTabBarHight = 40.0f;
    self.qzTabBar.showUnderline = YES;
    self.qzTabBar.underlineColor = [UIColor redColor];
    self.qzTabBar.underlineH = 1.0;
    self.qzTabBar.underlineW = 69.0f;
    self.qzTabBar.backgroundColor = [UIColor whiteColor];
    self.qzTabBar.normalColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    self.qzTabBar.selectedColor = [UIColor colorWithIntValue:0xfc0053];
    self.headerHeight = self.view.width*2/3.0;
    CGFloat top = (CGRectGetWidth([UIScreen mainScreen].bounds) - self.headerHeight) / 2;
    self.headerInset = UIEdgeInsetsMake(top, 0, top, 0);
}

#pragma mark- 创建view
- (void)st_createOverlayView
{
    [self st_createHeaderView];
    [self st_createInfoView];
    [self st_createTitleView];
}

- (void)st_createHeaderView
{
    if(self.headerView) return;
    
    Class headerViewClass = [self.class headerViewClass];
    NSAssert([headerViewClass isSubclassOfClass:[QZStretchableHeaderView class]],@"headerViewClass must be subclass of QZStretchableHeaderView");
    self.headerView = [headerViewClass instantiate];
    self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), self.headerHeight);
}

- (void)st_createInfoView
{
    if (self.infoView) return;
    
    Class infoViewClass = [self.class infoViewClass];
    NSAssert([infoViewClass conformsToProtocol:@protocol(QZStretchableOverlayViewProtocol)], @"InfoViewClass must confirm QZStretchableOverlayViewProtocol");
    self.infoView = [infoViewClass instantiate];
}

- (void)st_createTitleView
{
    if (self.titleLabel) return;
    
    _titleLabel = [[UILabel alloc] init];
}

#pragma mark- setup view
- (void)st_setupOverlayView
{
    [self st_setupHeaderView];
    [self st_setupInfoView];
    [self st_setupTitleView];
}

- (void)st_setupHeaderView
{
    self.headerView.frame = CGRectMake(0, -self.headerInset.top, self.view.width, self.headerInset.top + self.headerHeight + self.headerInset.bottom);
    self.headerView.layer.anchorPoint = CGPointMake(0.5, 0);
    self.headerView.centerY = -self.headerInset.top;
    self.headerView.contentMaskHeight = self.headerHeight + self.headerInset.top;
    self.headerView.maskColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.view addSubview:self.headerView];
    
    if (self.needRealTimeBlur) {
        //[self.headerView contentDidUpdated];
        [self st_processHeaderViewBlur];
    }
}

- (void)st_setupInfoView
{
    self.infoView.frame = self.infoViewFrame;
    [self.view addSubview:self.infoView];
}

- (void)st_setupTitleView
{
    _titleLabel.font = [UIFont systemFontOfSize:28];
    _titleLabel.numberOfLines = 1;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
//    _titleLabel.marqueeType = MLContinuous;
//    _titleLabel.animationDelay = 2;
//    _titleLabel.trailingBuffer = 100;
//    _titleLabel.fadeLength = 20;
//    _titleLabel.rate = 50;
    _titleLabel.frame = self.titleLabelFrame;
    
    [self.view addSubview:_titleLabel];
    
    [self st_calcTitleTransformParams];
}

- (void)st_calcTitleTransformParams
{
    self.titleScaleFactor = CGRectGetHeight(self.titleLabelPinFrame) / CGRectGetHeight(self.titleLabelFrame);
    CGFloat startOffsetY = 0;
    CGFloat endOffsetY = self.headerHeight - 64;
    
    CGFloat nameLabelStart = 0;
    CGFloat nameLabelEnd = 20 + CGRectGetMidY(self.titleLabelPinFrame) - CGRectGetMidY(self.titleLabelFrame);
    self.titleInterpolateA = (nameLabelEnd - nameLabelStart) / (endOffsetY - startOffsetY);
    self.titleInterpolateB = nameLabelStart - self.titleInterpolateA * startOffsetY;
//    NSLog(@"title: factorA = %f, factorB = %f", self.titleInterpolateA, self.titleInterpolateB);
}

#pragma mark- QZTabBarControllerDelegate
- (void)QZTabBarControllerChildViewControllerWillChange:(QZTabBarController *)tabBarController
{
    [self st_removeTargetScrollView];
}

- (void)QZTabBarControllerChildViewControllerDidChange:(QZTabBarController *)tabBarController
{
    id<QZTabBarControllerChildControllerProtocol> currChildVC = (id<QZTabBarControllerChildControllerProtocol>)self.currentViewController;
    if ([currChildVC respondsToSelector:@selector(targetScrollView)]) {
        UIScrollView *scrollView = [currChildVC targetScrollView];
        [self st_addTargetScrollView:scrollView];
    }
}

- (void)QZTabBarController:(QZTabBarController *)tabBarController
willShowChildViewController:(UIViewController<QZTabBarControllerChildControllerProtocol> *)childVC
{
    UIScrollView *scrollView = nil;
    if ([childVC respondsToSelector:@selector(targetScrollView)]) {
        scrollView = [childVC targetScrollView];
        CGFloat minTop = self.headerView.contentMaskHeight - self.headerInset.top + self.qzTabBarHight;
        [self st_setContentInsetTop:minTop ofScrollView:scrollView];
        [self st_checkOffsetOfScrollView:scrollView];
    }
    [self st_updateViewContentInsetOfChildVC:(UIViewController *)childVC];
}

- (void)QZTabBarController:(QZTabBarController *)tabBarController willRemoveChildViewController:(UIViewController *)childVC
{
    [self st_checkOffsetOfScrollView:self.targetScrollView];
}

- (void)st_checkOffsetOfScrollView:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGFloat minOffsetY = -self.headerView.contentMaskHeight + self.headerInset.top - self.qzTabBarHight;
    if (offset.y != minOffsetY) {
        if (offset.y < minOffsetY || self.headerView.contentMaskHeight - self.headerInset.top > 64) {
            offset.y = minOffsetY;
            [scrollView setContentOffset:offset animated:NO];
        }
    }
}

- (void)st_setContentInsetTop:(CGFloat)top ofScrollView:(UIScrollView *)scrollView
{
    UIEdgeInsets inset = scrollView.contentInset;
    if(inset.top != top) {
        inset.top = top;
        scrollView.contentInset = inset;
    }
}

- (BOOL)QZTabBar:(QZTabBar *)tabBar shouldSelectIndex:(NSUInteger)index
{
    return index != self.qzTabBar.currentIndex;
}

#pragma mark- targent scrollView
- (void)st_addTargetScrollView:(UIScrollView *)scrollView
{
    [self st_removeTargetScrollView];
    
    [self st_setContentInsetTop:-self.defaultOffsetY ofScrollView:scrollView];
    [self st_checkOffsetOfScrollView:scrollView];
    self.targetScrollView = scrollView;
    
    [self st_targetScrollViewContentSizeChange];
    [self.targetScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:&kMVStretchabletabObserverContext];
    [self.targetScrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:&kMVStretchabletabObserverContext];
}

- (void)st_removeTargetScrollView
{
    [self.targetScrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.targetScrollView removeObserver:self forKeyPath:@"contentSize"];
    
    self.targetScrollView = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (context != &kMVStretchabletabObserverContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if (object != self.targetScrollView) return;
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self st_targetScrollViewContentOffsetChange];
    } else if ([keyPath isEqualToString:@"contentSize"]){
        [self st_targetScrollViewContentSizeChange];
    }
}

- (void)st_targetScrollViewContentSizeChange
{
    CGSize contentSize = self.targetScrollView.contentSize;
    CGFloat minContentSizeHeight = self.view.height - self.qzTabBarHight - 64;
    CGFloat minIntsetBottomThreshold = minContentSizeHeight - contentSize.height;
    
    UIEdgeInsets contentInset = self.targetScrollView.contentInset;
    if (contentSize.height < minContentSizeHeight) {
        //inset.bottom => [minIntsetBottomThreshold, minIntsetBottomThreshold + 10]
        if(contentInset.bottom < minIntsetBottomThreshold
           || contentInset.bottom > minIntsetBottomThreshold + 10
           || contentInset.bottom < self.minContentInsetBottom) {
            contentInset.bottom = MAX(minIntsetBottomThreshold + 5, self.minContentInsetBottom);
            self.targetScrollView.contentInset = contentInset;
            [self st_checkOffsetOfScrollView:self.targetScrollView];
        }
    } else {
        if(contentInset.bottom > 0 && contentInset.bottom > minIntsetBottomThreshold && contentInset.bottom > self.minContentInsetBottom) {
            contentInset.bottom = MAX(0, self.minContentInsetBottom);
            self.targetScrollView.contentInset = contentInset;
        }
    }
}

- (void)st_targetScrollViewContentOffsetChange
{
    CGFloat offsetY = self.targetScrollView.contentOffset.y;
    [self st_updateHeaderViewWithOffsetY:offsetY];
    [self st_updateInfoViewWithOffsetY:offsetY];
    [self st_updateTitleViewWithOffsetY:offsetY];
    [self st_updateTabBarViewWithOffsetY:offsetY];
    [self st_updateHeaderViewBlurWithOffsetY:offsetY];
    [self st_updateViewContentInsetOfChildVC:self.currentViewController];
    
    [self targetScrollViewContentOffsetChange:self.targetScrollView];
}

- (void)targetScrollViewContentOffsetChange:(UIScrollView *)targetScrollView
{
}

- (void)st_updateHeaderViewWithOffsetY:(CGFloat)offsetY
{
    if (offsetY <= self.defaultOffsetY) {
        CGFloat factor = (-offsetY - self.qzTabBarHight) / self.headerHeight;
        self.headerView.transform = CGAffineTransformMakeScale(factor, factor);
        self.headerView.contentMaskHeight = (-offsetY - self.qzTabBarHight + self.headerInset.top) / factor;
    } else if (offsetY <= -64 - self.qzTabBarHight) {
        self.headerView.contentMaskHeight = -offsetY - self.qzTabBarHight + self.headerInset.top;
        self.headerView.transform = CGAffineTransformIdentity;
    } else {
        self.headerView.contentMaskHeight = 64 + self.headerInset.top;
        self.headerView.transform = CGAffineTransformIdentity;
    }
}

- (void)st_updateInfoViewWithOffsetY:(CGFloat)offsetY
{
    if (offsetY <= self.defaultOffsetY) {
        self.infoView.contentMaskHeight = self.infoView.height;
        CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -offsetY + self.defaultOffsetY);
        self.infoView.transform = translateTransform;
    } else if (offsetY <= -64 - self.qzTabBarHight) {
        self.infoView.contentMaskHeight = self.headerView.contentMaskHeight - self.headerInset.top - CGRectGetMinY(self.infoViewFrame);
        self.infoView.transform = CGAffineTransformIdentity;
    } else {
        self.infoView.contentMaskHeight = 0;
    }
}

- (void)st_updateTabBarViewWithOffsetY:(CGFloat)offsetY
{
    if (offsetY <= -64 - self.qzTabBarHight) {
        CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -offsetY + self.defaultOffsetY);
        self.qzTabBar.transform = translateTransform;
    } else {
        CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -self.headerHeight + 64);
        self.qzTabBar.transform = translateTransform;
    }
}

- (void)st_updateTitleViewWithOffsetY:(CGFloat)offsetY
{
    if (offsetY <= self.defaultOffsetY) {
        CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0, -offsetY + self.defaultOffsetY);
        self.titleLabel.transform = translateTransform;
    } else if (offsetY <= -64 - self.qzTabBarHight) {
        CGFloat delta = offsetY - self.defaultOffsetY;
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0, [self st_translateForTitleWithOffsetY:offsetY]);
        CGFloat titleScale = 1 - (1 - self.titleScaleFactor) * delta / (self.headerHeight - 64);
        self.titleLabel.transform = CGAffineTransformScale(translate, titleScale, titleScale);
    } else {
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0, [self st_translateForTitleWithOffsetY:-64 - self.qzTabBarHight]);
        self.titleLabel.transform = CGAffineTransformScale(translate, self.titleScaleFactor, self.titleScaleFactor);
    }
}

- (CGFloat)st_translateForTitleWithOffsetY:(CGFloat)offsetY
{
    CGFloat delta = offsetY - self.defaultOffsetY;
    return self.titleInterpolateA * delta + self.titleInterpolateB;
}

- (void)st_updateHeaderViewBlurWithOffsetY:(CGFloat)offsetY
{
    if (!self.needRealTimeBlur) return;
    
    if (offsetY <= self.defaultOffsetY) {
        if (self.blurState != MVStretchableHeaderBlurState_None) {
            self.blurState = MVStretchableHeaderBlurState_None;
            self.blurRadius = 0;
            [self st_doHeaderViewBlurForcibly:YES offsetY:offsetY];
        }
    } else if (offsetY <= -64 - self.qzTabBarHight) {
        self.blurState = MVStretchableHeaderBlurState_RealtimeBlur;
        CGFloat delta = offsetY - self.defaultOffsetY;
        self.blurRadius = 0.3 * delta / (self.headerHeight - 64);
        [self st_doHeaderViewBlurForcibly:NO offsetY:offsetY];
        //        NSLog(@"blurRadius = %f, delte = %f", self.blurRadius, delta);
    } else {
        self.blurRadius = 0.3;
        if (self.blurState != MVStretchableHeaderBlurState_FixBulr) {
            self.blurState = MVStretchableHeaderBlurState_FixBulr;
            [self st_doHeaderViewBlurForcibly:YES offsetY:offsetY];
        }
    }
}

- (void)st_doHeaderViewBlurForcibly:(BOOL)forcibly offsetY:(CGFloat)offsetY
{
    if (self.lastOffsetY == 0) {
        self.lastOffsetY = offsetY;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if (forcibly || fabs(offsetY - self.lastOffsetY) > 8) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_source_merge_data(strongSelf.blurSource, 1);
        });
        self.lastOffsetY = offsetY;
        //        NSLog(@"send updateCoverBlur source, offset - lastOffset = %f", fabs(offsetY - lastOffset));
    }
}

- (void)st_processHeaderViewBlur
{
    self.blurSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.blurSource, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.headerView.blurRadius = strongSelf.blurRadius;
    });
    dispatch_resume(self.blurSource);
}

- (void)st_stopProcessHeaderViewBlur
{
    if (self.blurSource) {
        dispatch_source_cancel(self.blurSource);
    }
    self.blurSource = nil;
}

- (void)st_updateViewContentInsetOfChildVC:(UIViewController *)childVC
{
    BOOL impViewContentInset = NO;
    NSNumber *impViewContentInsetObj = objc_getAssociatedObject(childVC, @selector(setViewContentInset:));
    if (impViewContentInsetObj) {
        impViewContentInset = [impViewContentInsetObj boolValue];
    } else {
        if ([childVC respondsToSelector:@selector(setViewContentInset:)]) {
            impViewContentInset = YES;
        }
        objc_setAssociatedObject(childVC, @selector(setViewContentInset:), @(impViewContentInset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if (impViewContentInset) {
        [(id<QZTabBarControllerChildControllerProtocol>)childVC setViewContentInset:UIEdgeInsetsMake(self.headerView.contentMaskHeight + self.qzTabBarHight - self.headerInset.top, 0, 0, 0)];
    }
}
@end