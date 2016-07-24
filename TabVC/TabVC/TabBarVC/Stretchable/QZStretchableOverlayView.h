//
//  QZStretchableOverlayView.h
//  QZTabBarController
//
//  Created by vicxia on 6/7/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark- QZStretchableOverlayViewProtocol

@protocol QZStretchableOverlayViewProtocol <NSObject>

@property (nonatomic, assign) CGFloat contentMaskHeight;

+ (instancetype)instantiate;

- (NSArray<UIView *> *)interactiveSubviews;

@end

#pragma mark- QZStretchableOverlayView

@interface QZStretchableOverlayView : UIView<QZStretchableOverlayViewProtocol>

@property (nonatomic, assign, readwrite) CGFloat contentMaskHeight;

@end
