//
//  QZStretchableOverlayView.m
//  QZTabBarController
//
//  Created by vicxia on 6/7/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import "QZStretchableOverlayView.h"

@interface QZStretchableOverlayView()

@property (nonatomic, strong) CAShapeLayer *contentMask;
//@property (nonatomic, strong) CAShapeLayer *contentM;

@end

@implementation QZStretchableOverlayView

+ (instancetype)instantiate
{
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self qzso_setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self qzso_setupView];
    }
    return self;
}

- (void)qzso_setupView
{
    _contentMask = [CAShapeLayer layer];
    _contentMask.frame = self.bounds;
    _contentMask.backgroundColor = [UIColor whiteColor].CGColor;
    self.layer.mask = self.contentMask;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *targetView = [super hitTest:point withEvent:event];
    if (!targetView) {
        return nil;
    }
    
    NSArray *interactiveSubviews = [self interactiveSubviews];
    if (interactiveSubviews.count == 0) {
        return nil;
    }
    
    if ([interactiveSubviews containsObject:targetView]) {
        CGRect maskRect = self.contentMask.frame;
        if (CGRectContainsPoint(maskRect, point)) {
            return targetView;
        }
    }
    
    // Recursive search interactive view in children.
    //    __block BOOL isFound = NO;
    //    UIView *checkView = targetView;
    //    while (checkView != self) {
    //        [interactiveSubviews enumerateObjectsUsingBlock:^(UIView *interactiveSubview, NSUInteger idx, BOOL *stop) {
    //            if (checkView == interactiveSubview) {
    //                isFound = YES;
    //                *stop = YES;
    //            }
    //        }];
    //        if (isFound) {
    //            return targetView;
    //        }
    //        checkView = [checkView superview];
    //    }
    
    return nil;
}

- (NSArray<UIView *> *)interactiveSubviews
{
    return nil;
}

- (void)setContentMaskHeight:(CGFloat)contentMaskHeight
{
    contentMaskHeight = MAX(contentMaskHeight, 0);
    
    if (_contentMaskHeight == contentMaskHeight) return;//会导致infoview显示异常
    
    _contentMaskHeight = contentMaskHeight;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.contentMask.bounds = CGRectMake(0, 0, CGRectGetWidth(self.bounds), contentMaskHeight);
    self.contentMask.position = CGPointMake(CGRectGetMidX(self.bounds), contentMaskHeight / 2);
    [CATransaction commit];
}

@end
