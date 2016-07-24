//
//  UIImage+Blur.h
//  Group
//
//  Created by Liu Zhen on 7/28/14.
//  Copyright (c) 2014 qzone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Blur)
- (UIImage *)blurWithRadius:(CGFloat)radius;

- (UIImage *)applyLigthEffect;
- (UIImage *)applyExtralLigthEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;
@end
