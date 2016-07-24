//
//  QZStretchableHeaderView.m
//  QZTabBarController
//
//  Created by vicxia on 6/7/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import "QZStretchableHeaderView.h"
#import "UIImage+Blur.h"
#import "UIColor+Sugar.h"
#import "QZTabConstant.h"

@interface QZStretchableHeaderView()

@property (nonatomic, strong) CALayer *blurLayer;
@property (nonatomic, strong) CALayer *maskLayer;
@property (nonatomic, strong) UIImage *bgImage;

@property (nonatomic, strong) UIImage *maskImage;

@end

@implementation QZStretchableHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self qzsh_setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self qzsh_setupView];
    }
    return self;
}

- (void)qzsh_setupView
{
    self.maxBlurRadius = 40;
    self.backgroundColor = [UIColor colorWithIntValue:QZTabBarBadgeBorderColorValue];
    self.clipsToBounds = YES;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
    self.blurLayer.frame = self.bounds;
    self.maskLayer.frame = self.bounds;
}

#pragma mark- getter & setter
- (void)setContentView:(UIView *)contentView
{
    if (_contentView == contentView) {
        return;
    }
    
    if (_contentView) {
        [_contentView removeFromSuperview];
    }
    
    _contentView = contentView;
    _contentView.frame = self.bounds;
    [self insertSubview:_contentView atIndex:0];
}

- (void)setBlurRadius:(CGFloat)blurRadius
{
    blurRadius = MIN(MAX(0, blurRadius), 1);
//    if (_blurRadius == blurRadius) return;
    _blurRadius = blurRadius;
    __weak typeof(self) weakSelf = self;
    if (self.blurRadius > 0) {
        self.blurLayer.hidden = NO;
        if (self.blurLayer) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [self.bgImage applyBlurWithRadius:blurRadius * self.maxBlurRadius
                                                         tintColor:nil
                                             saturationDeltaFactor:1
                                                         maskImage:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    strongSelf.blurLayer.contents = (__bridge id)(image.CGImage);
                });
            });
        }
    } else {
        self.blurLayer.hidden = YES;
    }
}

- (void)setMaskColor:(UIColor *)maskColor
{
    _maskColor = maskColor;
    self.maskLayer.backgroundColor = maskColor.CGColor;
}

- (void)setMaskImage:(UIImage *)maskImage alpha:(CGFloat)alpha
{
    _maskImage = maskImage;
    self.maskLayer.contents = (__bridge id)maskImage.CGImage;
    self.maskLayer.opacity = alpha;
}

- (CALayer *)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [[CALayer alloc] init];
//        _maskLayer.contentsGravity =  kCAGravityResizeAspectFill;
        _maskLayer.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_maskLayer];
    }
    return _maskLayer;
}

#pragma mark- blur layer
- (void)contentDidUpdated
{
    if (self.contentView.bounds.size.width <= 0.5 && self.bounds.size.width > 10) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    UIGraphicsBeginImageContext(self.contentView.bounds.size);
    
    [self.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    self.bgImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self createBlurLayer];
}

- (void)createBlurLayer
{
    if (!self.blurLayer) {
        self.blurLayer = [CALayer layer];
        self.blurLayer.frame = self.bounds;
        self.blurLayer.contentsScale = [UIScreen mainScreen].scale;
        self.blurLayer.contentsGravity = kCAGravityResizeAspect;
        //        self.blurLayer.magnificationFilter = kCAFilterTrilinear;
        //        self.blurLayer.minificationFilter = kCAFilterTrilinear;
        [self.layer insertSublayer:self.blurLayer below:self.maskLayer];
        
        //        UIImage *image = [self.bgImgView image];
        //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //            CGFloat scale = 0.7;//100 / image.size.width;
        
        //            self.smallBgImg = [UIImage imageByScalingToSize:image Size:CGSizeMake(image.size.width * scale, image.size.height * scale)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setBlurRadius:self.blurRadius];
            //                self.bgImgView.image = self.smallBgImg;
        });
        //        });
    }
}

//#pragma mark- QZImageView Delegat
//- (void)QZImageViewImageDidLoad:(QZImageView *)imageView isCache:(BOOL)isCache error:(NSError *)error
//{
//    [self createBlurLayer];
//}

@end