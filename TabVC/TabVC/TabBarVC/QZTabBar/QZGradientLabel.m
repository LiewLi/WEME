//
//  QZGradientLabel.m
//  QZTabBarController
//
//  Created by vicxia on 5/11/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import "QZGradientLabel.h"
#import "UIView+Sugar.h"

@implementation QZGradientLabel


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [_fillColor set];
    
    rect.size.width = rect.size.width * _progress;
    
    UIRectFillUsingBlendMode(rect, kCGBlendModeSourceIn);
}
@end
