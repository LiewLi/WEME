//
//  QZStretchableHeaderView.h
//  QZTabBarController
//
//  Created by vicxia on 6/7/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import "QZStretchableOverlayView.h"

@interface QZStretchableHeaderView : QZStretchableOverlayView

@property (nonatomic, strong) UIView *contentView;;//<!实际展示的内容，外部指定
@property (nonatomic, assign) CGFloat maxBlurRadius;//<!模糊算法的最大模糊半径
@property (nonatomic, assign) CGFloat blurRadius;//<!取值范围[0, 1]
@property (nonatomic, strong) UIColor *maskColor;//<!颜色遮罩

- (void)setMaskImage:(UIImage *)maskImage alpha:(CGFloat)alpha;

/**
 *  内容发生更新时调用此方法，内部重新生成对应的blur层
 */
- (void)contentDidUpdated;

@end
