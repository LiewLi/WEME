//
//  QZStretchableTabBarController.h
//  QZTabBarController
//
//  Created by vicxia on 6/7/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import "QZTabBarController.h"
#import "QZStretchableHeaderView.h"
#import "UIColor+Sugar.h"

@interface QZStretchableTabBarController : QZTabBarController

+ (Class)headerViewClass;//<!需要继承QZStretchableOverlayView
+ (Class)infoViewClass;//<!需要继承QZStretchableOverlayView

@property (nonatomic, assign) CGFloat minContentInsetBottom;

@property (nonatomic, readonly) QZStretchableHeaderView *headerView;
@property (nonatomic, assign) CGFloat headerHeight;//<!提供cover默认显示的高度信息
@property (nonatomic, assign) UIEdgeInsets headerInset;
@property (nonatomic, assign) BOOL needRealTimeBlur;

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, assign) CGRect titleLabelFrame;//<!提供title的frame信息
@property (nonatomic, assign) CGRect titleLabelPinFrame;//<!title固定时的frame,在titleLabelFrame的基础上经过transform变换而来，忽略宽度信息。
@property (nonatomic, assign) BOOL holdTitlePosition;//<!是否随scrollView向上滚动而移动，Yes表示不随scrollView滚动，默认为NO

@property (nonatomic, readonly) QZStretchableOverlayView *infoView;
@property (nonatomic, assign) CGRect infoViewFrame;//<!提供infoView的frame信息
//@property (nonatomic, assign) CGRect infoViewPinFrame;//<!infoView固定时的frame,在infoViewFrame的基础上经过transform变换而来，忽略宽度信息。
//@property (nonatomic, assign) BOOL holdInfoPosition;//<!是否随scrollView向上滚动而移动，Yes表示不随scrollView滚动，默认为YES

- (void)initialization;//各个view添加到view树之前会被调用

- (void)targetScrollViewContentOffsetChange:(UIScrollView *)targetScrollView;
@end
