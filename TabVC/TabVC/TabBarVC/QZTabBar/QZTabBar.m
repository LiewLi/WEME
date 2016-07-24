//
//  QZTabBar.m
//  QZTabBarController
//
//  Created by vicxia on 4/13/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import "QZTabBar.h"
#import "QZGradientLabel.h"
#import "QZTabConstant.h"
#import "QZTabBarCell.h"
#import "UIView+Sugar.h"

static NSString *kQZTabBarCollectionCellIdentifiler = @"kQZTabBarCollectionCellIdentifiler";
static NSString *kQZTabBarException = @"kQZTabBarException";
static CGFloat   kQZTabBarAnimationDuration = 0.3;

@interface QZTabBar()

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, weak) UIScrollView *contentScrollView;

/** 标题滚动视图背景View */
@property (nonatomic, strong) UIImageView *backgroundImgView;
@property (nonatomic, strong) UIView *bottomSplitView;//底部分割线
@property (nonatomic, strong) UIView *underlineView;
@property (nonatomic, strong) UIView *titleMaskView;

//标题cell对应的宽度
//@property (nonatomic, strong) NSMutableArray *itemWidths;
@property (nonatomic, strong) NSMutableArray<NSValue *> *itemFrames;
@property (nonatomic, assign) CGAffineTransform itemScaleTransform;
// 标题间距
//@property (nonatomic, assign) CGFloat titleMargin;

// 记录是否在动画
@property (nonatomic, assign) BOOL isContentDragging;

@property (nonatomic, assign, readwrite) NSUInteger currentIndex;

@property (nonatomic, strong) NSMutableDictionary *badgeDict;

@property (nonatomic, assign) CGFloat barLastOffsetX;
@property (nonatomic, assign) CGFloat aGradientRange;
@property (nonatomic, assign) CGFloat rGradientRange;
@property (nonatomic, assign) CGFloat bGradientRange;
@property (nonatomic, assign) CGFloat gGradientRange;

@end

@implementation QZTabBar

+ (Class)cellClass
{
    return [QZTabBarCell class];
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        [self qzt_setupView];
//    }
//    return self;
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self qzt_initialization];
        [self qzt_setupView];
    }
    return self;
}

- (void)qzt_initialization
{
    _badgeDict = [NSMutableDictionary dictionary];
    _normalColor = [UIColor blackColor];
    _selectedColor = [UIColor redColor];
    _underlineH = QZTabBarUnderlineHeight;
    _underlineTitleWidthRatio = 1.0f;
    _underlineColor = _selectedColor;
    _titleScale = QZTabBarTitleTransformScale;
    _titleGradientStyle = QZTabBarTitleGradientStyleFade;
    _titleMaskColor = [UIColor colorWithWhite:0 alpha:0.2];
}

- (void)qzt_setupView
{
    self.backgroundColor = [UIColor whiteColor];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.scrollsToTop = NO;
    _collectionView.allowsMultipleSelection = NO;
//    _collectionView.alwaysBounceVertical = NO;
//    _collectionView.bounces = NO;
//    _collectionView.backgroundColor = [UIColor greenColor];
    
    [self qzt_registerCellToCollectionView:_collectionView];
    
    [self addSubview:_collectionView];
    
    _bottomSplitView = [UIView new];
    _bottomSplitView.backgroundColor = [UIColor clearColor];
    [self insertSubview:_bottomSplitView belowSubview:_collectionView];
}

- (void)qzt_registerCellToCollectionView:(UICollectionView *)collectionView
{
    if (![[self.class cellClass] isSubclassOfClass:[UICollectionViewCell class]]) {
        NSException *excp = [NSException exceptionWithName:kQZTabBarException
                                                    reason:@"cellClass 必须是 UICollectionViewCell的子类。"
                                                  userInfo:nil];
        [excp raise];
    }
    [collectionView registerClass:[self.class cellClass] forCellWithReuseIdentifier:kQZTabBarCollectionCellIdentifiler];
}

- (NSString *)qzt_collectionCellIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    return kQZTabBarCollectionCellIdentifiler;
}

- (void)qzt_configureCollectionCell:(QZTabBarCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.attributedTitle = self.barAttributedTitles[indexPath.item];
    cell.normalColor = self.normalColor;
    cell.selectedColor = self.selectedColor;
    cell.badgeBackgroundColor = self.badgeBackgroundColor;
    cell.badgeBorderColor = self.badgeBorderColor;
    cell.badgeBorderWidth = self.badgeBorderWidth;
    cell.badgeInfo = self.badgeDict[@(indexPath.item)];
    if (indexPath.item == self.currentIndex) {
        cell.selected = YES;
        [self qzt_updateUnderlineAnimated:NO];
    } else {
        cell.selected = NO;
    }
    if (self.isShowTitleScale) {
        cell.transform = indexPath.item == self.currentIndex ? self.itemScaleTransform : CGAffineTransformIdentity;
    }
    
    if (self.isShowTitleGradient) {
        [self qzt_resetCellColor:cell];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.collectionView.frame = CGRectMake(self.barContentInset.left,
                                           self.barContentInset.top,
                                           self.width - self.barContentInset.left - self.barContentInset.right,
                                           self.height - self.barContentInset.top - self.barContentInset.bottom);
    
    CGFloat singlePx = 1.0f / [UIScreen mainScreen].scale;
    self.bottomSplitView.frame = CGRectMake(0, self.height - singlePx, self.width, singlePx);
    
    if (_underlineView) {
        //留1px间隙
        _underlineView.bottom = self.collectionView.height - singlePx;
    }
    
    if (_backgroundImgView) {
        self.backgroundImgView.frame = self.bounds;
    }
}

#pragma mark- 标题宽度
- (void)qzt_setupTitleFrame
{
    if (self.barAttributedTitles.count == 0) return;
    
    NSArray *titleWidthList = nil;
    if (self.titleWidth > 0) {//设置固定标题宽度
        titleWidthList = [self qzt_calculateWidthFixedTitleWidthList];
    } else { //自主计算标题宽度
        titleWidthList = [self qzt_calculateWidthAdaptivelyTitleWidthList];
    }
    
    self.itemFrames = [NSMutableArray array];
    CGFloat offsetX = self.titleHorizontalMargin;
    CGFloat height = CGRectGetHeight(self.bounds) - self.barContentInset.top - self.barContentInset.bottom;
    
    for (NSNumber *widthValue in titleWidthList) {
        CGFloat width = [widthValue floatValue];
        [self.itemFrames addObject:[NSValue valueWithCGRect:CGRectMake(offsetX, 0, width, height)]];
        
        offsetX += width + self.titleHorizontalSpace;
    }
//    NSLog(@"self.itemframes = %@", self.itemFrames);
}

- (NSArray<NSNumber *> *)qzt_calculateWidthFixedTitleWidthList
{
    CGFloat contentWidth = self.width - self.barContentInset.left - self.barContentInset.right;
    
    CGFloat totalWidth = (self.titleWidth + self.titleHorizontalPadding * 2) * self.barAttributedTitles.count//title占用宽度
                         + self.titleHorizontalSpace * (self.barAttributedTitles.count - 1);//手动设置的间距
    
    //内容不能填满空间，自动设置titleHorizontalMargin
    if (totalWidth < contentWidth) {
        self.titleHorizontalMargin = (contentWidth - totalWidth) / 2;
    }
    NSMutableArray *titleWidthList = [NSMutableArray array];
    for (int i = 0; i < self.barAttributedTitles.count; i++) {
        [titleWidthList addObject:@(self.titleWidth)];
    }
    return titleWidthList;
}

- (NSArray<NSNumber *> *)qzt_calculateWidthAdaptivelyTitleWidthList
{
    NSArray *titleWidthList = [self calculateTitleWidth];
    CGFloat totalWidth = 0;
    for (NSNumber *width in titleWidthList) {
        totalWidth += [width floatValue];
    }
    totalWidth = totalWidth + self.titleHorizontalSpace * (self.barAttributedTitles.count - 1);
    
    CGFloat contentWidth = self.width - self.barContentInset.left - self.barContentInset.right;
    //内容不能填满空间，自动等分
    if (totalWidth < contentWidth) {
        self.titleHorizontalMargin = 0;
        self.titleHorizontalSpace = 0;
        self.titleHorizontalPadding = 0;
        
        CGFloat defaultWidth = contentWidth / self.barAttributedTitles.count;
        
        NSMutableArray *mutableTitleWidthList = [NSMutableArray new];
        for (int i = 0; i < self.barAttributedTitles.count; i++)
        {
            [mutableTitleWidthList addObject:@(defaultWidth)];
        }
        return mutableTitleWidthList;
    }
    return titleWidthList;
}

- (CGRect)qzt_frameForItemAtIndex:(NSUInteger)index
{
    NSAssert(index < self.barAttributedTitles.count, @"index out of bounds");
    return [self.itemFrames[index] CGRectValue];
}

#pragma mark- attributedTitles
- (void)setBarAttributedTitles:(NSArray<NSAttributedString *> *)barAttributedTitles
{
    if (barAttributedTitles.count == 0) {
        return;
    }
    
    _barAttributedTitles = [barAttributedTitles copy];
    [self qzt_setupTitleFrame];
    [self qzt_reloadCollectionData];
    [self qzt_setupIndicatorView];
    [self qzt_updateIndicatorViewAnimated:NO];
}

// 计算标题宽度
- (NSArray *)calculateTitleWidth
{
    NSMutableArray *titleWidths = [NSMutableArray arrayWithCapacity:self.barAttributedTitles.count];
    // 计算所有标题的宽度
    CGFloat horPadding = self.titleHorizontalPadding * 2;
    for (NSAttributedString *attributedTitle in self.barAttributedTitles)
    {
        CGFloat width = [QZTabBarCell widthForAttributedTitle:attributedTitle] + horPadding;
        [titleWidths addObject:@(width)];
    }
    return titleWidths;
}

- (void)qzt_reloadCollectionData
{
    [self.collectionView reloadData];
}


#pragma mark-collectionview datasource

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return self.titleHorizontalSpace;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, self.titleHorizontalMargin, 0, self.titleHorizontalMargin);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.barAttributedTitles.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect frame = [self.itemFrames[indexPath.item] CGRectValue];
    return frame.size;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QZTabBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self qzt_collectionCellIdentifierAtIndexPath:indexPath]
                                                        forIndexPath:indexPath];
    
    if (indexPath.item >= self.barAttributedTitles.count) {
        return cell;
    }
    
    [self qzt_configureCollectionCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark- collection delegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(QZTabBar:shouldSelectIndex:)]) {
        return [self.delegate QZTabBar:self shouldSelectIndex:indexPath.item];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectIndex:indexPath.item animated:YES byScrolling:NO];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isShowTitleScale) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        if (cell) {
            cell.transform = CGAffineTransformIdentity;
        }
    }
}

#pragma mark- scroll delegate
- (void)contentScrollViewWillDrag:(UIScrollView *)contentScrollView
{
    self.isContentDragging = YES;
}

- (void)contentScrollViewDidScroll:(UIScrollView *)contentScrollView
{
    // 点击和动画的时候不需要设置
    if (self.barAttributedTitles.count == 0) return;
    
    self.contentScrollView = contentScrollView;
    
    // 获取偏移量
    CGFloat offsetX = contentScrollView.contentOffset.x;
   
    if (contentScrollView.width == 0) return;
    
    // 获取左边index
    NSUInteger leftIndex = offsetX / contentScrollView.width;
    
    if (leftIndex >= self.barAttributedTitles.count) {
        if (self.barAttributedTitles.count > 0) {
            leftIndex = self.barAttributedTitles.count  - 1;
        } else {
            return;
        }
    }
    
    NSIndexPath *leftIndexPath = [NSIndexPath indexPathForItem:leftIndex inSection:0];
    
    // 左侧cell attributes
    UICollectionViewLayoutAttributes *leftAttr = [self.collectionView layoutAttributesForItemAtIndexPath:leftIndexPath];
    
    // 右边index
    NSInteger rightIndex = leftIndex + 1;
    
    UICollectionViewLayoutAttributes *rightAttr = nil;
    
    if (rightIndex < self.barAttributedTitles.count) {
        NSIndexPath *rightIndexPath = [NSIndexPath indexPathForItem:rightIndex inSection:0];
        rightAttr = [self.collectionView layoutAttributesForItemAtIndexPath:rightIndexPath];
    }
    
     //字体放大
    if (self.isShowTitleScale) {
        [self qzt_setupTitleScaleWithOffset:offsetX leftIndex:leftIndex rigthIndex:rightIndex];
    }
    
    // 设置下标偏移
    if (self.isShowUnderline) {
        [self qzt_setupUnderlineOffset:offsetX leftAttr:leftAttr rightAttr:rightAttr];
    }
    
    // 设置遮盖偏移
    if (self.isShowTitleMask) {
        [self qzt_setupMaskOffset:offsetX leftAttr:leftAttr rightAttr:rightAttr];
    }
    
    // 设置标题渐变
    if (self.isShowTitleGradient) {
        [self qzt_setupTitleColorGradientWithOffset:offsetX rigthIndex:rightIndex leftIndex:leftIndex];
    }
}

- (void)contentScrollViewEndScroll:(UIScrollView *)contentScrollView
{
    _isContentDragging = NO;
    
    CGPoint offset = contentScrollView.contentOffset;
    CGFloat offsetX = offset.x;
    
    NSInteger offsetXInt = offsetX;
    NSInteger screenWInt = contentScrollView.width;
    
    NSInteger extre = offsetXInt % screenWInt;
    if (extre > contentScrollView.width * 0.5) {
        // 往右边移动
        offsetX = offsetX + (contentScrollView.width - extre);
    }else if (extre < contentScrollView.width * 0.5 && extre > 0){
        // 往左边移动
        offsetX =  offsetX - extre;
    }
    
    // 获取角标
    NSInteger i = offsetX / contentScrollView.width;
    
    // 选中标题
    [self selectIndex:i animated:NO byScrolling:YES];
}

#pragma mark- Gradient
// 设置标题颜色渐变
- (void)qzt_setupTitleColorGradientWithOffset:(CGFloat)offsetX rigthIndex:(NSInteger)rightIdx leftIndex:(NSInteger)leftIdx
{
    // cell
    QZTabBarCell *rightCell = (QZTabBarCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:rightIdx inSection:0]];
    QZTabBarCell *leftCell = (QZTabBarCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:leftIdx inSection:0]];
    
    // 获取颜色填充度
    CGFloat rightOpaque = offsetX / self.width - leftIdx;
    CGFloat leftOpaque = 1 - rightOpaque;
    
    // RGB渐变
    if (_titleGradientStyle == QZTabBarTitleGradientStyleFade) {
        // 右边颜色
        rightCell.normalColor = [self qzt_gradientColorForProgress:rightOpaque];
        // 左边颜色
        leftCell.normalColor = [self qzt_gradientColorForProgress:leftOpaque];
    }
    else if (_titleGradientStyle == QZTabBarTitleGradientStylePush)
    {
        if (self.barLastOffsetX == 0) {
            self.barLastOffsetX = offsetX;
        }
        // 获取移动距离
        BOOL isScrollRight = offsetX - self.barLastOffsetX > 0;
        
        UIColor *opacityNormalColor = [self.normalColor colorWithAlphaComponent:1.0f];
        UIColor *opacitySelectedColor = [self.selectedColor colorWithAlphaComponent:1.0f];
        if (isScrollRight)
        { // 往右边
            rightCell.fillColor = opacitySelectedColor;
            rightCell.normalColor = self.normalColor;
            rightCell.progress = rightOpaque;
            
            leftCell.fillColor = opacityNormalColor;
            leftCell.normalColor = self.selectedColor;
            leftCell.progress = rightOpaque;
        }
        else
        { // 往左边
            rightCell.normalColor = self.normalColor;
            rightCell.fillColor = opacitySelectedColor;
            rightCell.progress = rightOpaque;
            
            leftCell.normalColor = self.selectedColor;
            leftCell.fillColor = opacityNormalColor;
            leftCell.progress = rightOpaque;
        }
        self.barLastOffsetX = offsetX;
    }
}

- (UIColor *)qzt_gradientColorForProgress:(CGFloat)progess
{
    if (self.aGradientRange < 0.001) {
        CGFloat startR, startG, startB;
        CGFloat endR, endG, endB;
        [self.normalColor getRed:&startR green:&startG blue:&startB alpha:NULL];
        
        [self.selectedColor getRed:&endR green:&endG blue:&endB alpha:NULL];
        
        self.rGradientRange = endR - startR;
        self.gGradientRange = endG - startG;
        self.bGradientRange = endB - endB;
        self.aGradientRange = 1;
    }
    
    return [UIColor colorWithRed:self.rGradientRange * progess green:self.gGradientRange * progess blue:self.bGradientRange * progess alpha:self.aGradientRange];
}


#pragma mark- scale
- (void)qzt_setupTitleScaleWithOffset:(CGFloat)offsetX leftIndex:(NSInteger)leftIdx rigthIndex:(NSInteger)rightIdx
{
    CGFloat targetScale = _titleScale ? _titleScale : QZTabBarTitleTransformScale;
    CGFloat pageWidth = self.contentScrollView.width;
    
    CGFloat leftScale = [self qzt_valueAtOffsetX:offsetX - leftIdx * pageWidth
                                      startPoint:CGPointMake(0, targetScale)
                                        endPoint:CGPointMake(pageWidth, 1)];
    
    UICollectionViewCell *leftCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:leftIdx inSection:0]];
    leftCell.transform = CGAffineTransformMakeScale(leftScale, leftScale);
    
    CGFloat rightScale = [self qzt_valueAtOffsetX:offsetX - leftIdx * pageWidth
                                       startPoint:CGPointMake(0, 1)
                                         endPoint:CGPointMake(pageWidth, targetScale)];
    
    UICollectionViewCell *rightCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:rightIdx inSection:0]];
    rightCell.transform = CGAffineTransformMakeScale(rightScale, rightScale);
}

#pragma mark- Underline
- (void)qzt_setupUnderlineOffset:(CGFloat)offsetX leftAttr:(UICollectionViewLayoutAttributes *)leftAttr rightAttr:(UICollectionViewLayoutAttributes *)rightAttr
{
    CGFloat leftUnderlinePadding;
    CGFloat rightUnderlinePadding;
    
    if (self.underlineW) {
        leftUnderlinePadding = (CGRectGetWidth(leftAttr.frame) - self.underlineW) / 2.0f;
        rightUnderlinePadding = (CGRectGetWidth(rightAttr.frame) - self.underlineW) / 2.0f;
    } else {
        leftUnderlinePadding = (1 - self.underlineTitleWidthRatio) / 2 * CGRectGetWidth(leftAttr.frame);
        rightUnderlinePadding = (1 - self.underlineTitleWidthRatio) / 2 * CGRectGetWidth(rightAttr.frame);
    }
    
    CGFloat leftUnderlineStart = CGRectGetMinX(leftAttr.frame) + leftUnderlinePadding;
    CGFloat leftunderlineEnd = CGRectGetMaxX(leftAttr.frame) - leftUnderlinePadding;
    
    
    CGFloat rightUnderlineStart = CGRectGetMinX(rightAttr.frame) + rightUnderlinePadding;
    CGFloat rightUnderlineEnd = CGRectGetMaxX(rightAttr.frame) - rightUnderlinePadding;
    
    CGFloat pageWidth = self.contentScrollView.width;
    NSInteger index = (int)(offsetX / pageWidth);
    
    CGFloat underlineStartOffSetX = [self qzt_valueAtOffsetX:offsetX - index * pageWidth
                                                  startPoint:CGPointMake(0, leftUnderlineStart)
                                                    endPoint:CGPointMake(pageWidth, rightUnderlineStart)];
    CGFloat underlineEndOffSetX = [self qzt_valueAtOffsetX:offsetX - index * pageWidth
                                                startPoint:CGPointMake(0, leftunderlineEnd)
                                                  endPoint:CGPointMake(pageWidth, rightUnderlineEnd)];
    underlineEndOffSetX = [self qzt_quarticEaseOutInterpolateForOffsetX:underlineEndOffSetX];
    self.underlineView.width = underlineEndOffSetX - underlineStartOffSetX;
    self.underlineView.left = underlineStartOffSetX;
}

- (CGFloat)qzt_quarticEaseOutInterpolateForOffsetX:(CGFloat)offsetX
{
//    CGFloat p = offsetX / self.collectionView.contentSize.width;
//    CGFloat f = (p - 1);
//    CGFloat result = f * f * f * (1 - p) + 1;
//    return result * self.collectionView.contentSize.width;
    return offsetX;
}

- (CGFloat)qzt_valueAtOffsetX:(CGFloat)offsetX startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGFloat factorA = (endPoint.y - startPoint.y) / (endPoint.x - startPoint.x);
    CGFloat transformB = startPoint.y -  factorA * startPoint.x;
    
    return factorA * offsetX + transformB;
}

#pragma mark- title mask
- (void)qzt_setupMaskOffset:(CGFloat)offsetX leftAttr:(UICollectionViewLayoutAttributes *)leftAttr rightAttr:(UICollectionViewLayoutAttributes *)rightAttr
{
    CGFloat leftMaskStart = CGRectGetMinX(leftAttr.frame) + self.titleMaskInset.left;
    CGFloat leftMaskEnd = CGRectGetMaxX(leftAttr.frame) - self.titleMaskInset.right;
    
    
    CGFloat rightMaskStart = CGRectGetMinX(rightAttr.frame) + self.titleMaskInset.left;
    CGFloat rightMaskEnd = CGRectGetMaxX(rightAttr.frame) - self.titleMaskInset.right;
    
    CGFloat pageWidth = self.contentScrollView.width;
    NSInteger index = (int)(offsetX / pageWidth);
    
    CGFloat maskStartOffSetX = [self qzt_valueAtOffsetX:offsetX - index * pageWidth
                                         startPoint:CGPointMake(0, leftMaskStart)
                                           endPoint:CGPointMake(pageWidth, rightMaskStart)];
    CGFloat maskEndOffSetX = [self qzt_valueAtOffsetX:offsetX - index * pageWidth
                                       startPoint:CGPointMake(0, leftMaskEnd)
                                         endPoint:CGPointMake(pageWidth, rightMaskEnd)];
    maskEndOffSetX = [self qzt_quarticEaseOutInterpolateForOffsetX:maskEndOffSetX];
    self.titleMaskView.width = maskEndOffSetX - maskStartOffSetX;
    self.titleMaskView.left = maskStartOffSetX;
}

#pragma mark- select index
- (void)selectIndex:(NSUInteger)index
{
    if (self.collectionView.contentSize.width > 0) {
        [self selectIndex:index animated:NO byScrolling:YES];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self selectIndex:index animated:NO byScrolling:YES];
        });
    }
}

- (void)selectIndex:(NSUInteger)index animated:(BOOL)animated byScrolling:(BOOL)byScrolling
{
    if (self.currentIndex == index && !byScrolling) { return; }
    
    if (self.isShowTitleScale) {
        [self qzt_resetScaleAtIndex:self.currentIndex];
    }
    
    if (index >= self.barAttributedTitles.count) return;
   
    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:oldIndexPath];
    cell.selected = NO;
//    [self.collectionView deselectItemAtIndexPath:oldIndexPath animated:animated];
    
    self.currentIndex = index;
    [self.delegate QZTabBar:self didSelectIndex:self.currentIndex byScrolling:byScrolling];
    
    NSIndexPath *targetIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.collectionView selectItemAtIndexPath:targetIndexPath
                                      animated:animated
                                scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];

    [self qzt_updateIndicatorViewAnimated:animated];
}

- (void)qzt_updateIndicatorViewAnimated:(BOOL)animated
{
    //渐变
    if (self.isShowTitleGradient) {
        [self qzt_updateGradientAnimated:animated];
    }
    
    //下划线
    if (self.isShowUnderline) {
        [self qzt_updateUnderlineAnimated:animated];
    }
    
    //蒙层
    if (self.isShowTitleMask) {
        [self qzt_updateTitleMaskViewAnimated:animated];
    }
    
    //标题缩放
    if (self.isShowTitleScale) {
        [self qzt_updateTitleScaleAnimated:animated];
    }
}

- (void)qzt_resetScaleAtIndex:(NSUInteger)index
{
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    cell.transform = CGAffineTransformIdentity;
}

- (void)qzt_updateTitleScaleAnimated:(BOOL)animated
{
    if (self.isContentDragging) return;
    
    if (self.currentIndex >= self.barAttributedTitles.count)  {
        self.currentIndex = self.barAttributedTitles.count - 1;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (animated) {
        // 点击时候需要动画
        [UIView animateWithDuration:0.25 animations:^{
            cell.transform = self.itemScaleTransform;
        }];
    } else {
        cell.transform = self.itemScaleTransform;
    }
}

// 设置蒙版
- (void)qzt_updateTitleMaskViewAnimated:(BOOL)animated
{
    if (self.isContentDragging) return;
    
    if (self.currentIndex >= self.barAttributedTitles.count)  {
        self.currentIndex = self.barAttributedTitles.count - 1;
    }
    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    
    // 选中cell attributes
//    UICollectionViewLayoutAttributes *currAttr = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect itemFrame = [self qzt_frameForItemAtIndex:self.currentIndex];
    
    CGRect maskFrame = CGRectMake(CGRectGetMinX(itemFrame) + self.titleMaskInset.left,
                                  CGRectGetMinY(itemFrame) + self.titleMaskInset.top,
                                  CGRectGetWidth(itemFrame) - self.titleMaskInset.left - self.titleMaskInset.right,
                                  CGRectGetHeight(itemFrame) - self.titleMaskInset.top - self.titleMaskInset.bottom);
    
    if (animated) {
        // 点击时候需要动画
        [UIView animateWithDuration:kQZTabBarAnimationDuration animations:^{
            self.titleMaskView.frame = maskFrame;
        }];
    } else {
        self.titleMaskView.frame = maskFrame;
    }
}

- (void)qzt_updateGradientAnimated:(BOOL)animated
{
    QZTabBarCell *cell = (QZTabBarCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
    [self qzt_resetCellColor:cell];
}

- (void)qzt_resetCellColor:(QZTabBarCell *)cell
{
    cell.normalColor = self.normalColor;
    cell.selectedColor = self.selectedColor;
}

// 设置下标的位置
- (void)qzt_updateUnderlineAnimated:(BOOL)animted
{
    if (self.isContentDragging || !self.isShowUnderline) return;
    
    if (self.currentIndex >= self.barAttributedTitles.count)  {
        self.currentIndex = self.barAttributedTitles.count - 1;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    
    // 选中cell attributes
    UICollectionViewLayoutAttributes *currAttr = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    
    CGFloat underlinePadding;
    if (self.underlineW) {
        underlinePadding = (CGRectGetWidth(currAttr.frame) - self.underlineW) / 2.0f;
    } else {
        underlinePadding = (1 - self.underlineTitleWidthRatio) / 2 * CGRectGetWidth(currAttr.frame);
    }
    
    CGFloat underlineStart = CGRectGetMinX(currAttr.frame) + underlinePadding;
    CGFloat underlineEnd = CGRectGetMaxX(currAttr.frame) - underlinePadding;
    if (animted) {
        // 点击时候需要动画
        [UIView animateWithDuration:0.3 animations:^{
            self.underlineView.width = underlineStart - underlineEnd;
            self.underlineView.left = underlineStart;
        }];
    } else {
        self.underlineView.width = underlineEnd - underlineStart;
        self.underlineView.left = underlineStart;
    }
    self.underlineView.backgroundColor = _underlineColor;
}

#pragma mark-
#pragma mark- 红点计数
- (void)showRedDotAtIndex:(NSUInteger)index
{
    QZTabBarBadgeInfo *badgeInfo = [self badgeInfoAtIndex:index];
    badgeInfo.showRedDot = YES;
    
    [self qzt_updateBadgeInfoAtIndex:index];
}

- (void)removeRedDotAtIndex:(NSUInteger)index
{
    QZTabBarBadgeInfo *info = self.badgeDict[@(index)];
    info.showRedDot = NO;
    
    [self qzt_updateBadgeInfoAtIndex:index];
}

- (void)showBadgeNumber:(NSInteger)number atIndex:(NSUInteger)index
{
    QZTabBarBadgeInfo *badgeInfo = [self badgeInfoAtIndex:index];
    badgeInfo.badgeNumber = number;
    
    [self qzt_updateBadgeInfoAtIndex:index];
}

- (void)removeBadgeNumberAtIndex:(NSUInteger)index
{
    QZTabBarBadgeInfo *info = self.badgeDict[@(index)];
    info.badgeNumber = 0;
    
    [self qzt_updateBadgeInfoAtIndex:index];
}

- (QZTabBarBadgeInfo *)badgeInfoAtIndex:(NSUInteger)index
{
    QZTabBarBadgeInfo *badgeInfo = self.badgeDict[@(index)];
    if (!badgeInfo) {
        badgeInfo = [QZTabBarBadgeInfo new];
        self.badgeDict[@(index)] = badgeInfo;
    }
    return badgeInfo;
}

- (void)qzt_updateBadgeInfoAtIndex:(NSUInteger)index
{
    QZTabBarCell *cell = (QZTabBarCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if ([cell isKindOfClass:[QZTabBarCell class]]) {
        cell.badgeInfo = self.badgeDict[@(index)];
    }
}

#pragma mark-
#pragma mark- createView
- (void)qzt_setupIndicatorView
{
    if (_showUnderline) {
        CGFloat singlePX = 1.0f / [UIScreen mainScreen].scale;
        //留1px间隙
        _underlineView.frame = CGRectMake(0, self.collectionView.height - _underlineH - singlePX, _underlineW, _underlineH);
        _underlineView.backgroundColor = _underlineColor;
    }
    
    if (_showTitleScale) {
        _itemScaleTransform = CGAffineTransformMakeScale(_titleScale, _titleScale);
    }
    
    if (_showTitleMask) {
        if (!_titleMaskCornerRadius) {
            _titleMaskCornerRadius = (CGRectGetHeight(self.bounds) - _barContentInset.top - _barContentInset.bottom - _titleMaskInset.top - _titleMaskInset.bottom) / 2;
        }
        _titleMaskView.layer.cornerRadius = _titleMaskCornerRadius;
        _titleMaskView.backgroundColor = _titleMaskColor;
    }
}

- (void)qzt_createBackgroundImageView
{
    if (_backgroundImgView) { return; }
    
    _backgroundImgView = [[UIImageView alloc] init];
    _backgroundImgView.frame = self.bounds;
    [self insertSubview:_backgroundImgView atIndex:0];
}

- (void)qzt_createTitleMaskView
{
    if (_titleMaskView) { return; }
    
    _titleMaskView = [[UIView alloc] init];
    [self.collectionView insertSubview:_titleMaskView atIndex:0];
}

- (void)qzt_createUnderlineView
{
    if (_underlineView) { return; }
    
    _underlineView = [UIView new];
    [self.collectionView addSubview:_underlineView];
}

#pragma mark-
#pragma mark- getter
// 设置背景图片
- (void)setBarBackgroundImage:(UIImage *)barBackgroundImage
{
    _barBackgroundImage = barBackgroundImage;
    if (!self.backgroundImgView) {
        [self qzt_createBackgroundImageView];
    }
    self.backgroundImgView.image = barBackgroundImage;
}

//标题缩放
- (void)setShowTitleScale:(BOOL)showTitleScale
{
    _showTitleScale = showTitleScale;
    if (showTitleScale) {
        self.itemScaleTransform = CGAffineTransformMakeScale(_titleScale, _titleScale);
    } else {
        self.itemScaleTransform = CGAffineTransformIdentity;
    }
}

//下划线
- (void)setShowUnderline:(BOOL)showUnderline
{
    _showUnderline = showUnderline;
    if (showUnderline) {
        if (!_underlineView) {
            [self qzt_createUnderlineView];
        }
    } else {
        if (_underlineView) {
            [_underlineView removeFromSuperview];
            _underlineView = nil;
        }
    }
}

//titleMask
- (void)setShowTitleMask:(BOOL)showTitleMask
{
    _showTitleMask = showTitleMask;
    if (showTitleMask) {
        if (!_titleMaskView) {
            [self qzt_createTitleMaskView];
        }
    } else {
        if (_titleMaskView) {
            [_titleMaskView removeFromSuperview];
            _titleMaskView = nil;
        }
    }
}

//分割线
- (void)setBarBottomSplitLineColor:(UIColor *)barBottomSplitLineColor
{
    _barBottomSplitLineColor = barBottomSplitLineColor;
    _bottomSplitView.backgroundColor = barBottomSplitLineColor;
}
@end