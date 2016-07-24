//
//  QZTabBarCell.h
//  QZTabBarController
//
//  Created by vicxia on 5/11/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import <UIKit/UIKit.h>

/**************************************badgeInfo************************************/
#pragma mark- class QZTabBarBadgeInfo
@interface QZTabBarBadgeInfo : NSObject

@property (nonatomic, assign) BOOL showRedDot;//<! 优先级低
@property (nonatomic, assign) NSUInteger badgeNumber;//<!优先级高

@end
/**************************************badgeInfo************************************/

/*********************************QZTabBarCell ******************************/
#pragma mark- class QZTabBarCell
@interface QZTabBarCell : UICollectionViewCell

@property (nonatomic, strong) NSAttributedString *attributedTitle;

@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, strong) QZTabBarBadgeInfo *badgeInfo;
@property (nonatomic, strong) UIColor *badgeBackgroundColor;
@property (nonatomic, strong) UIColor *badgeForegroundColor;
@property (nonatomic, strong) UIColor *badgeBorderColor;
@property (nonatomic, assign) CGFloat badgeBorderWidth;

//+ (NSString *)identifier;
+ (CGFloat)widthForAttributedTitle:(NSAttributedString *)attributedtitle;
@end
/********************************MVTabBarCollectionCell******************************/
