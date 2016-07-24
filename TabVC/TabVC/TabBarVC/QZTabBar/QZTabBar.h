//
//  QZTabBar.h
//  QZTabBarController
//
//  Created by vicxia on 4/13/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Sugar.h"

@class QZTabBar;

// 颜色渐变样式
typedef NS_ENUM(NSInteger, QZTabBarTitleGradientStyle) {
     QZTabBarTitleGradientStyleFade,
     QZTabBarTitleGradientStylePush,
};

@protocol QZTabBarDelegate <NSObject>

- (BOOL)QZTabBar:(QZTabBar *)tabBar shouldSelectIndex:(NSUInteger)index;
- (void)QZTabBar:(QZTabBar *)tabBar didSelectIndex:(NSUInteger)index byScrolling:(BOOL)byScrolling;

@end

@interface QZTabBar : UIView <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

+ (Class)cellClass;

/**************************************基本属性************************************/
@property (nonatomic, weak) id<QZTabBarDelegate> delegate;
@property (nonatomic, copy) NSArray<NSAttributedString *> *barAttributedTitles;
@property (nonatomic, assign) UIEdgeInsets barContentInset;
@property (nonatomic, strong) UIImage *barBackgroundImage;
@property (nonatomic, strong) UIColor *barBottomSplitLineColor;
/**************************************基本属性************************************/

/************************************子类继承***********************************/
//- (NSArray *)calculateTitleWidth;
//- (void)configureCollectionCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
/************************************子类继承***********************************/

/**************************************index************************************/
@property (nonatomic, readonly) NSUInteger currentIndex;
/**
 *  collectionview reload数据完成之前会异步设置index，否则会使用同步设置index，
 *
 *  @param index 要选择的index；
 */
- (void)selectIndex:(NSUInteger)index;

- (void)contentScrollViewWillDrag:(UIScrollView *)contentScrollView;
- (void)contentScrollViewDidScroll:(UIScrollView *)contentScrollView;
- (void)contentScrollViewEndScroll:(UIScrollView *)contentScrollView;
/**************************************index************************************/

/************************************红点计数**********************************/
@property (nonatomic, strong) UIColor *badgeBackgroundColor;
@property (nonatomic, strong) UIColor *badgeBorderColor;
@property (nonatomic, assign) CGFloat badgeBorderWidth;

- (void)showRedDotAtIndex:(NSUInteger)index;
- (void)removeRedDotAtIndex:(NSUInteger)index;

- (void)showBadgeNumber:(NSInteger)number atIndex:(NSUInteger)index;
- (void)removeBadgeNumberAtIndex:(NSUInteger)index;
/************************************红点计数**********************************/

/**************************************标题************************************/
/*
 * |---------------------------------------------------------------------------------------|
 * |<-margin->|<-padding--title--padding->|<-space->|<-padding--title--padding->|<-margin->|
 * |---------------------------------------------------------------------------------------|
 */

@property (nonatomic, assign) CGFloat titleHorizontalPadding;
@property (nonatomic, assign) CGFloat titleHorizontalMargin;
@property (nonatomic, assign) CGFloat titleHorizontalSpace;
@property (nonatomic, assign) CGFloat titleWidth;//<!标题固定宽度，未指定时自动根据标题内容计算宽度
/**
 *  使用带透明度的颜色时，在QZTabBarTitleGradientStylePush风格时会使用到该alpha值
 */
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;
/**************************************标题************************************/


/**************************************下划线************************************/
@property (nonatomic, assign, getter=isShowUnderline) BOOL showUnderline;
@property (nonatomic, strong) UIColor *underlineColor;
@property (nonatomic, assign) CGFloat underlineH;
@property (nonatomic, assign) CGFloat underlineW;
@property (nonatomic, assign) CGFloat underlineTitleWidthRatio;//<!underLine 宽度和title标题的宽度，默认为1.0
/**************************************下划线************************************/


/**********************************字体缩放************************************/
@property (nonatomic, assign, getter=isShowTitleScale) BOOL showTitleScale;
@property (nonatomic, assign) CGFloat titleScale;
/**********************************字体缩放************************************/


/**********************************颜色渐变************************************/
@property (nonatomic, assign, getter=isShowTitleGradient) BOOL showTitleGradient;
@property (nonatomic, assign) QZTabBarTitleGradientStyle titleGradientStyle;
/**********************************颜色渐变************************************/

/**********************************遮盖************************************/
@property (nonatomic, assign, getter=isShowTitleMask) BOOL showTitleMask;
@property (nonatomic, strong) UIColor *titleMaskColor;
@property (nonatomic, assign) CGFloat titleMaskCornerRadius;
@property (nonatomic, assign) UIEdgeInsets titleMaskInset;// <!蒙层和title的位置关系, 例如(-5, -5, -5 ,-5)表示蒙层在title大小的基础上各个方向向外扩展5
/**********************************遮盖************************************/

@end
