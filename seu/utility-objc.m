//
//  utility-objc.m
//  牵手
//
//  Created by liewli on 12/11/15.
//  Copyright © 2015 li liew. All rights reserved.
//
#import "utility-objc.h"


@implementation UIImage (MASK)

-(UIImage *) maskWithColor:(UIColor *)color
{
    CGImageRef maskImage = self.CGImage;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    CGRect bounds = CGRectMake(0,0,width,height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL, width, height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextClipToMask(bitmapContext, bounds, maskImage);
    CGContextSetFillColorWithColor(bitmapContext, color.CGColor);
    CGContextFillRect(bitmapContext, bounds);
    
    CGImageRef cImage = CGBitmapContextCreateImage(bitmapContext);
    UIImage *coloredImage = [UIImage imageWithCGImage:cImage];
    
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cImage);
    
    return coloredImage;
}

@end


@implementation DLLabel
- (void)drawTextInRect:(CGRect)rect {
    CGSize offset = CGSizeMake(2, -2);
    CGFloat color[] = {0, 0, 0, .9};
    CGContextRef currentContex = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContex);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorRef = CGColorCreate(colorSpace, color);
    CGContextSetShadowWithColor(currentContex, offset, 4, colorRef);
    [super drawTextInRect:rect];
    CGColorRelease(colorRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRestoreGState(currentContex);
}

@end


@implementation Utility

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end

