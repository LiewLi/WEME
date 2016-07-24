//
//  QZTabBarController.h
//  QZTabBarController
//
//  Created by vicxia on 4/13/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZTabBar.h"

typedef NS_ENUM(NSInteger, QZTabBarVerticalPositionStyle)
{
    QZTabBarVerticalPositionStyleTop,
    QZTabBarVerticalPositionStyleBottom,
    QZTabBarVerticalPositionStyleCustom,
};

@protocol QZTabBarControllerDataSource, QZTabBarControllerDelegate, QZTabBarControllerChildControllerProtocol;

#pragma mark- class MVTabBaseController
@interface QZTabBarController : UIViewController<UICollectionViewDelegate, QZTabBarDelegate>

+ (Class _Nonnull)QZTabBarclass;

@property (nonatomic, weak) id<QZTabBarControllerDataSource> _Nullable dataSource;
@property (nonatomic, weak) id<QZTabBarControllerDelegate> _Nullable delegate;

@property (nonatomic, readonly) QZTabBar * _Nonnull qzTabBar;
@property (nonatomic, readonly) UIViewController<QZTabBarControllerChildControllerProtocol> * _Nullable currentViewController;

@property (nonatomic, assign) CGFloat qzTabBarHight;
@property (nonatomic, strong) UIFont *_Nullable qzTabBarTitleFont;
@property (nonatomic, assign) QZTabBarVerticalPositionStyle qzTabBarVerticalPostionStyle;
@property (nonatomic, assign) UIEdgeInsets contentInset;//<!QZTabBarVerticalPositionStyleCustom时控制tabbar的位置
@property (nonatomic, assign, getter=isScrollEnabled) BOOL scrollEnabled;

- (void)setViewControllers:(NSArray<UIViewController<QZTabBarControllerChildControllerProtocol> *> * _Nonnull)viewControllers
                    titles:(NSArray * _Nonnull)titles;
- (void)setViewControllerTitles:(NSArray * _Nonnull)titles;

/**
 *  子Controller实际显示之前，不会被触发viewDidLoad行为。
 *  子Controller个数必须要和title个数保持一致
 *
 *  @param viewControllers  子Controller
 *  @param attributedTitles 对应标题
 */
- (void)setViewControllers:(NSArray<UIViewController<QZTabBarControllerChildControllerProtocol> *> * _Nonnull)viewControllers
          attributedTitles:(NSArray<NSAttributedString *> * _Nonnull)attributedTitles;
/**
 *  单独更新title时调用此方法，title个数必须与上述方法中设置的Controller个数相同
 *
 *  @param attributedTitles 标题
 */
- (void)setViewControllerAttributedTitles:(NSArray<NSAttributedString *> * _Nonnull)attributedTitles;
/**************************************内容************************************/
/*
 内容是否需要全屏展示
 YES :  全屏：内容占据整个屏幕，会有穿透导航栏效果，需要手动设置额外滚动区域
 NO  :  内容从导航栏下展示
 */
@property (nonatomic, assign, getter=isFullscreen) BOOL fullscreen;

/**************************************内容************************************/

/*
 刷新标题和整个界面
 */
- (void)refreshDisplay;

@end

#pragma mark- 
#pragma mark- UICollectionViewCell+QZTab

@interface UICollectionViewCell (QZTab)

@property (nonatomic, weak) UIViewController * _Nullable contentViewController;

@end


#pragma mark- Protocol
#pragma mark- QZTabBarController dataSource
@protocol QZTabBarControllerDataSource <NSObject>

@required
- (UIViewController * _Nonnull)QZTabBarController:(QZTabBarController * _Nonnull)tabBarController childControllerAtIndex:(NSInteger)index;

@end

#pragma mark
#pragma mark- delegate
@protocol QZTabBarControllerDelegate <NSObject>

@optional
- (BOOL)QZTabBarController:(QZTabBarController * _Nonnull)tabBarController
    shouldSelectController:(UIViewController * _Nullable)controller
                   atIndex:(NSInteger)index;

- (void)QZTabBarController:(QZTabBarController * _Nonnull)tabBarController
       didSelectController:(UIViewController  * _Nullable)childViewController
                   atIndex:(NSInteger)index
               byScrolling:(BOOL)byScrolling;


/**
 * childVC即将显示出来,不代表是滑动结束之后最终的展示的childVC
 * 会在didShowChildViewController之前调用，和willRemoveChildViewController的调用顺序不确定
 *
 *  @param chiledVC 即将被展示的childVC
 */
- (void)QZTabBarController:(QZTabBarController * _Nonnull)tabBarController willShowChildViewController:(UIViewController * _Nonnull)childVC;

/**
 * childVC已经显示出来，用户可以看到,不代表是滑动结束之后最终的展示的childVC
 * 会在willShowChildViewController之后调用
 *
 *  @param chiledVC 被展示的childVC
 */
- (void)QZTabBarController:(QZTabBarController * _Nonnull)tabBarController didShowChildViewController:(UIViewController * _Nonnull)childVC;

/**
 * childVC即将被移除，此VC对用户已不可见
 * 会在didRemoveChildViewController之前调用，和willShowChildViewController的调用顺序不确定
 *
 *  @param chiledVC 即将被移除的childVC
 */
- (void)QZTabBarController:(QZTabBarController * _Nonnull)tabBarController willRemoveChildViewController:(UIViewController * _Nonnull)childVC;

/**
 * childVC已经被移除，此VC对用户已不可见
 * 会在willRemoveChildViewController之后调用
 *
 *  @param chiledVC 被移除的childVC
 */
- (void)QZTabBarController:(QZTabBarController * _Nonnull)tabBarController didRemoveChildViewController:(UIViewController * _Nonnull)childVC;

/**
 * 当前展示的childVC将发生变化，比如用户滑动，
 * 在willShowChildViewController和willRemoveChildViewController之前调用
 */
- (void)QZTabBarControllerChildViewControllerWillChange:(QZTabBarController * _Nonnull)tabBarController;

/**
 * 当前展示的childVC变化完成
 * 在didShowChildViewController和didRemoveChildViewController之后调用
 */
- (void)QZTabBarControllerChildViewControllerDidChange:(QZTabBarController * _Nonnull)tabBarController;

@end

#pragma mark- child viewcontroller
@protocol QZTabBarControllerChildControllerProtocol <NSObject>

@optional
- (UIScrollView * _Nonnull)targetScrollView;
//viewContentInset代表controller实际展示的区域
- (void)setViewContentInset:(UIEdgeInsets)viewContentInset;

- (void)QZTabBarController:(QZTabBarController * _Nonnull)tabBaseController
       didSelectController:(UIViewController * _Nullable)childViewController
                   atIndex:(NSInteger)index
               byScrolling:(BOOL)byScrolling;
@end