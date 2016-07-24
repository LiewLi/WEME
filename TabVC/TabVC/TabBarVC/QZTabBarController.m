//
//  QZTabBarController.m
//  QZTabBarController
//
//  Created by vicxia on 4/13/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import "QZTabBarController.h"
#import <objc/runtime.h>
#import "UIView+Sugar.h"
#import "QZTabConstant.h"

static NSString *kQZTabBarControllerException = @"kQZTabBarControllerException";

#pragma mark- containerView
@interface QZTabBarContainerView : UIView

@property (nonatomic, weak) QZTabBarController *vc;

@end

#pragma mark-
#pragma mark- QZTabBarController

NSString * const kCellInentifier = @"kQZTabCellInentifier";

@interface QZTabBarController() <UICollectionViewDataSource>

@property (nonatomic, strong, readwrite) QZTabBarContainerView *containerView;
@property (nonatomic, strong, readwrite) QZTabBar *qzTabBar;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSArray<NSAttributedString *> *viewControllerAttributedTitles;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllers;

@property (nonatomic, assign) NSInteger targetIndex;

@property (nonatomic, copy) void (^onChildViewControllerDidChange)();//<!点击tabBarView会导致tabBarView的回调提前出发，通知childVC完成变化的时机要延后

@end

@implementation QZTabBarController

@dynamic scrollEnabled;

+ (Class)QZTabBarclass
{
    return [QZTabBar class];
}

#pragma mark- life cycle
- (instancetype)init
{
    if (self = [super init]) {
        [self qzt_initialization];
    }
    return self;
}

- (void)awakeFromNib
{
    [self qzt_initialization];
}

- (void)qzt_initialization
{
    _containerView = [QZTabBarContainerView new];
    _qzTabBarHight = QZTabBarHeight;
    _qzTabBar = [[[self.class QZTabBarclass] alloc] init];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.bounces = NO;
    _collectionView.scrollsToTop = NO;
    _collectionView.clipsToBounds = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    
    [self.view addSubview:_containerView];
    _containerView.frame = self.view.bounds;
    _containerView.vc = self;
    
    //设置顶部标签滚动视图
    [self qzt_setupQZTabBar];
    [self qzt_updateQZTabBarTitles];
    
    //设置底部内容滚动视图
    [self qzt_setupCollectionView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellInentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self qzt_childViewControllerWillChange];
    __weak typeof(self) weakSelf = self;
    self.onChildViewControllerDidChange = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.onChildViewControllerDidChange = nil;
        [strongSelf qzt_childViewControllerDidChange];
    };
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshDisplay];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _containerView.frame = self.view.bounds;
    [self layout];
}

-(void)layout
{
    CGFloat viewWidth = self.view.width;
    CGFloat viewHight = self.view.height;
    CGFloat naviHeight = 0;
    if ([self.navigationController.viewControllers containsObject:self] && !self.isFullscreen) {//有可能是作为子controller
        naviHeight = 64;
    }
    
    CGFloat titleH = self.qzTabBarHight;
    if (self.qzTabBarVerticalPostionStyle == QZTabBarVerticalPositionStyleTop)
    {
        self.qzTabBar.frame = CGRectMake(0, naviHeight, viewWidth, titleH);
        [self.collectionView.collectionViewLayout invalidateLayout];
        self.collectionView.frame = CGRectMake(0, titleH + naviHeight, viewWidth, viewHight - titleH - naviHeight);
    } else if (self.qzTabBarVerticalPostionStyle == QZTabBarVerticalPositionStyleBottom) {
        self.qzTabBar.frame = CGRectMake(0, viewHight - titleH, viewWidth, titleH);
        self.collectionView.frame = CGRectMake(0, naviHeight, viewWidth, viewHight - titleH - naviHeight);
    } else {
        CGFloat posY = self.contentInset.top;
        self.qzTabBar.frame = CGRectMake(0, posY, viewWidth, titleH);
        self.collectionView.frame = self.view.bounds;
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

//#pragma mark- orientation
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.collectionView reloadData];
//        [self.collectionView setContentOffset:CGPointMake(self.qzTabBar.currentIndex * self.collectionView.width, self.collectionView.contentOffset.y)
//                                     animated:NO];
//    });
//}

#pragma mark- gesture
- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (self.navigationController.interactivePopGestureRecognizer) {
        [self.collectionView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
}

#pragma mark - tabbar view
// 1.添加标题滚动视图
- (void)qzt_setupQZTabBar
{
    if (!self.isViewLoaded) return;
    
    _qzTabBar.delegate = self;
    // 计算尺寸
    _qzTabBar.frame = CGRectMake(0, self.contentInset.top, self.view.width, self.qzTabBarHight);
    
    [self.containerView addSubview:_qzTabBar];
}

- (void)qzt_updateQZTabBarTitles
{
    if (!self.isViewLoaded) return;
    
    self.qzTabBar.barAttributedTitles = self.viewControllerAttributedTitles;
}

#pragma mark- collectionView
// 2.添加内容滚动视图
- (void)qzt_setupCollectionView
{
    if (!self.isViewLoaded) return;
    
    _collectionView.frame = self.view.bounds;
    
    [self.containerView insertSubview:_collectionView belowSubview:_qzTabBar];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
//    [_collectionView reloadData];
}

#pragma mark- add view controllers

- (void)setViewControllers:(NSArray<UIViewController<QZTabBarControllerChildControllerProtocol> *> * _Nonnull)viewControllers
                    titles:(NSArray * _Nonnull)titles
{
    [self setViewControllers:viewControllers attributedTitles:[self qzt_generateAttributedStringsFromStrings:titles]];
}

- (void)setViewControllerTitles:(NSArray * _Nonnull)titles
{
    [self setViewControllerAttributedTitles:[self qzt_generateAttributedStringsFromStrings:titles]];
}

- (void)setViewControllers:(NSArray<UIViewController<QZTabBarControllerChildControllerProtocol> *> * _Nonnull)viewControllers
          attributedTitles:(NSArray<NSAttributedString *> * _Nonnull)attributedTitles
{
    if(attributedTitles.count != viewControllers.count) {
        NSException *excp = [NSException exceptionWithName:@"MVTabBaseController" reason:@"标题个数必须和controller个数相同" userInfo:nil];
        [excp raise];
    }
    
    self.viewControllers = viewControllers;
    self.viewControllerAttributedTitles = attributedTitles;
    
    [self refreshDisplay];
}

- (void)setViewControllerAttributedTitles:(NSArray<NSAttributedString *> * _Nonnull)attributedTitles
{
    _viewControllerAttributedTitles = [attributedTitles copy];
    [self qzt_updateQZTabBarTitles];
}

- (NSArray<NSAttributedString *> *)qzt_generateAttributedStringsFromStrings:(NSArray<NSString *> *)stringList
{
    NSMutableArray<NSAttributedString *> *attrStringList = [NSMutableArray array];
    for (NSString *tmpString in stringList) {
        [attrStringList addObject:[[NSAttributedString alloc] initWithString:tmpString
                                                                  attributes:@{NSFontAttributeName : self.qzTabBarTitleFont ?: [UIFont systemFontOfSize:QZTabBarTitleFontSize]}]];
    }
    return attrStringList;
}

- (UIViewController *)currentViewController
{
    NSInteger index = self.qzTabBar.currentIndex;
    if( index >= 0 && index < self.viewControllers.count) {
        return self.viewControllers[index];
    }
    return nil;
}

#pragma mark- refresh UI
- (void)refreshDisplay
{
    if (!self.isViewLoaded) return;
    
    // 重新设置标题
    [self qzt_updateQZTabBarTitles];
    
    [self qzt_childViewControllerWillChange];
    [self.collectionView reloadData];
    __weak typeof(self) weakSelf = self;
    self.onChildViewControllerDidChange = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.onChildViewControllerDidChange = nil;
        [strongSelf qzt_childViewControllerDidChange];
    };
}

#pragma mark- collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewControllerAttributedTitles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellInentifier
                                                                           forIndexPath:indexPath];
    cell.contentViewController = [self qzt_viewControllerForIndex:indexPath.item];
    
    NSString *msg1 = [NSString stringWithFormat:@"%@: cell contentViewController cannot be nil", kQZTabBarControllerException];
    NSAssert(cell.contentViewController != nil, msg1);
    NSString *msg2 = [NSString stringWithFormat:@"%@: cell contentViewController must be a UIViewController!", kQZTabBarControllerException];
    NSAssert([cell.contentViewController isKindOfClass:[UIViewController class]], msg2);
    
    [self mv_hostViewController:cell.contentViewController withHostView:cell];
    return cell;
}

- (UIViewController *)qzt_viewControllerForIndex:(NSInteger)index
{
    if (self.dataSource) {
        return [self.dataSource QZTabBarController:self childControllerAtIndex:index];
    } else if (index >= 0 && index < self.viewControllers.count) {
        UIViewController *controller = self.viewControllers[index];
        return controller;
    }
    return nil;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *controller = cell.contentViewController;
    [self mv_unhostViewController:controller];
    cell.contentViewController = nil;
}

#pragma mark - Private
- (void)mv_hostViewController:(UIViewController *)controller
                 withHostView:(UIView *)superview {
    
    
    [self addChildViewController:controller];
    controller.view.frame = superview.bounds;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [controller viewWillAppear:NO];
    
    [self qzt_willShowChildViewController:controller];
    
    [superview addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    
    [self qzt_didShowChildViewController:controller];
    
    if (self.onChildViewControllerDidChange) {
        self.onChildViewControllerDidChange();
    }
}

- (void)mv_unhostViewController:(UIViewController *)controller {
    [self qzt_willRemoveChildViewController:controller];
    
    [controller willMoveToParentViewController:nil];
    [controller.view removeFromSuperview];
    [controller removeFromParentViewController];
    
    [self qzt_didRemoveChildViewController:controller];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.qzTabBar contentScrollViewWillDrag:scrollView];
    [self qzt_childViewControllerWillChange];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.qzTabBar contentScrollViewDidScroll:scrollView];
}

// 监听滚动动画是否完成
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self.qzTabBar contentScrollViewEndScroll:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    self.targetIndex = (NSInteger)((*targetContentOffset).x / self.collectionView.width + 0.5f);
}

//// 减速完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.qzTabBar contentScrollViewEndScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self.qzTabBar contentScrollViewEndScroll:scrollView];
    }
}

#pragma mark- MVTabBarBaseViewDelegate
- (BOOL)QZTabBar:(QZTabBar *)tabBar shouldSelectIndex:(NSUInteger)index
{
    if (self.viewControllers.count > 0 && index >= self.viewControllers.count) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(QZTabBar:shouldSelectIndex:)]) {
        if (self.viewControllers.count > 0) {
            return [self.delegate QZTabBarController:self shouldSelectController:self.viewControllers[index] atIndex:index];
        } else {
            return [self.delegate QZTabBarController:self shouldSelectController:nil atIndex:index];
        }
    }
    return YES;
}

- (void)QZTabBar:(QZTabBar *)tabBar didSelectIndex:(NSUInteger)index byScrolling:(BOOL)byScrolling
{
    if (!byScrolling) {
        [self qzt_childViewControllerWillChange];
    }
    
    index = MIN(index, self.viewControllerAttributedTitles.count - 1);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self notiftDelegateSlectedIndexDidChangeScrolling:byScrolling];
    
    if (byScrolling) {
        [self qzt_childViewControllerDidChange];
    } else {
        __weak typeof(self) weakSelf = self;
        self.onChildViewControllerDidChange = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.onChildViewControllerDidChange = nil;
            [strongSelf qzt_childViewControllerDidChange];
        };
    }
}

- (void)notiftDelegateSlectedIndexDidChangeScrolling:(BOOL)byScrolling
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(QZTabBarController:didSelectController:atIndex:byScrolling:)]) {
            if (!strongSelf.dataSource) {
                [strongSelf.delegate QZTabBarController:strongSelf
                                    didSelectController:[strongSelf qzt_viewControllerForIndex:strongSelf.qzTabBar.currentIndex]
                                                atIndex:strongSelf.qzTabBar.currentIndex
                                            byScrolling:byScrolling];
            } else {
                [strongSelf.delegate QZTabBarController:strongSelf
                                    didSelectController:nil
                                                atIndex:strongSelf.qzTabBar.currentIndex
                                            byScrolling:byScrolling];
            }
        }
        for (id<QZTabBarControllerChildControllerProtocol> childVC in strongSelf.viewControllers) {
            if ([childVC respondsToSelector:@selector(QZTabBarController:didSelectController:atIndex:byScrolling:)]) {
                [childVC QZTabBarController:strongSelf
                        didSelectController:[strongSelf qzt_viewControllerForIndex:strongSelf.qzTabBar.currentIndex]
                                    atIndex:strongSelf.qzTabBar.currentIndex
                                byScrolling:byScrolling];
            }
        }
    });
}

- (void)qzt_childViewControllerWillChange
{
//    NSLog(@"qzt_childViewControllerWillChange");
    if ([self.delegate respondsToSelector:@selector(QZTabBarControllerChildViewControllerWillChange:)]) {
        [self.delegate QZTabBarControllerChildViewControllerWillChange:self];
    }
}

- (void)qzt_childViewControllerDidChange
{
//    NSLog(@"qzt_childViewControllerDidChange");
    if ([self.delegate respondsToSelector:@selector(QZTabBarControllerChildViewControllerDidChange:)]) {
        [self.delegate QZTabBarControllerChildViewControllerDidChange:self];
    }
}

- (void)qzt_willShowChildViewController:(UIViewController *)childVC
{
//    NSLog(@"qzt_willShowChildViewController");
    if ([self.delegate respondsToSelector:@selector(QZTabBarController:willShowChildViewController:)]) {
        [self.delegate QZTabBarController:self willShowChildViewController:childVC];
    }
}

- (void)qzt_didShowChildViewController:(UIViewController *)childVC
{
//    NSLog(@"qzt_didShowChildViewController");
    if ([self.delegate respondsToSelector:@selector(QZTabBarController:didShowChildViewController:)]) {
        [self.delegate QZTabBarController:self didShowChildViewController:childVC];
    }
}

- (void)qzt_willRemoveChildViewController:(UIViewController *)childVC
{
//    NSLog(@"qzt_willRemoveChildViewController");
    if ([self.delegate respondsToSelector:@selector(QZTabBarController:willRemoveChildViewController:)]) {
        [self.delegate QZTabBarController:self willRemoveChildViewController:childVC];
    }
}

- (void)qzt_didRemoveChildViewController:(UIViewController *)childVC
{
//    NSLog(@"qzt_didRemoveChildViewController");
    if ([self.delegate respondsToSelector:@selector(QZTabBarController:didRemoveChildViewController:)]) {
        [self.delegate QZTabBarController:self didRemoveChildViewController:childVC];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

#pragma mark- scroll enable
- (BOOL)isScrollEnabled
{
    return self.collectionView.isScrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    self.collectionView.scrollEnabled = scrollEnabled;
}

@end


#pragma mark-
#pragma mark- UICollectionViewCell (MVTab)
@implementation UICollectionViewCell (QZTab)

@dynamic contentViewController;

- (UIViewController *)contentViewController
{
    return objc_getAssociatedObject(self, @selector(contentViewController));
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    objc_setAssociatedObject(self, @selector(contentViewController), contentViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation QZTabBarContainerView


@end
