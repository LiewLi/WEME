//
//  UIColor+Sugar.m
//  QZTabBarController
//
//  Created by vicxia on 5/11/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import "UIColor+Sugar.h"

@implementation UIColor (Sugar)
+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length
{
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    return hexComponent / 255.0;
}

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue  = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red   = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue  = [self colorComponentFrom:colorString start:3 length:1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue  = [self colorComponentFrom:colorString start:4 length:2];
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red   = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue  = [self colorComponentFrom:colorString start:6 length:2];
            break;
        default:
            return [UIColor clearColor];
    }
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)colorWithIntValue:(int)intValue
{
    return [UIColor colorWithIntValue:intValue alpha:1];
}

+ (UIColor *)colorWithIntValue:(int)intValue alpha:(CGFloat)alpha
{
    int b = 0xFF & intValue;
    int g = 0xFF00 & intValue;
    g >>= 8;
    int r = 0xFF0000 & intValue;
    r >>= 16;
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha];
}

+ (UIColor *)colorWithIntValueAlpha:(int)intValue
{
    unsigned int value = *((unsigned int*)&intValue);
    return [UIColor colorWithRed:((0x00FF0000 & value)>>16)/255.0 green:((0x0000FF00 & value)>>8)/255.0 blue:(0x000000FF & value)/255.0 alpha:((0xFF000000 & value)>>24)/255.0];
}


-(int)intValue
{
    NSInteger n = CGColorGetNumberOfComponents(self.CGColor);
    const CGFloat *colors = CGColorGetComponents(self.CGColor);
    CGFloat r,g,b,a;
    if (n==2)
    {
        r=g=b=colors[0];
        a=colors[1];
    }
    else if (n==3)
    {
        r=colors[0];
        g=colors[1];
        b=colors[2];
        a=1;
    }
    else if (n==4)
    {
        r=colors[0];
        g=colors[1];
        b=colors[2];
        a=colors[3];
    }
    else
    {
        [self getRed:&r green:&g blue:&b alpha:&a];
    }
    unsigned int result = (((unsigned int)(a*255))<<24)|(((unsigned int)(r*255))<<16)|(((unsigned int)(g*255))<<8)|((unsigned int)(b*255));
    return *((int*)&result);
}
@end
