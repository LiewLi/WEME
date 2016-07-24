//
//  UIColor+Sugar.h
//  QZTabBarController
//
//  Created by vicxia on 5/11/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Sugar)
/**
 * 通过十六进制颜色字符串生成对应的UIColor对象
 *
 * 支持RGB、ARGB、RRGGBB、AARRGGBB这四种格式，前面的#不可以省略
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

/**
 * 通过int生成对应的UIColor对象, alpha 默认为1
 *
 * int颜色的生成规则为：(OxFF<<24) | (red<<16) | (green<<8) | blue
 */
+ (UIColor *)colorWithIntValue:(int)intValue;

/**
 *  通过带有alpha信息的int生成对应的UIColor对象，
 *  int颜色的生成规则为：(OxFF<<24) | (red<<16) | (green<<8) | blue
 *
 *  @param intValue 包含color信息的int值
 *
 *  @return UIColor对象
 */
+ (UIColor *)colorWithIntValueAlpha:(int)intValue;

/**
 *  通过int生成UIColor对象，自定义alpha
 *
 *  @param intValue 包含color信息alpha值
 *  @param alpha    alpha，取值为[0, 1]
 *
 *  @return UIColor对象
 */
+ (UIColor *)colorWithIntValue:(int)intValue alpha:(CGFloat)alpha;

-(int)intValue;
@end
