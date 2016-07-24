//
//  QZTabBarCell.m
//  QZTabBarController
//
//  Created by vicxia on 5/11/16.
//  Copyright © 2016 com.tencent.tab. All rights reserved.
//

#import "QZTabBarCell.h"
#import "QZGradientLabel.h"
#import "QZTabConstant.h"
#import "UIView+Sugar.h"
#import "UIColor+Sugar.h"

static const CGFloat kRedDotViewSideLength = 8;
static const CGFloat kBadgeFontSize = 12;
static const CGFloat kBadgeLabelHeight = 15;

@interface QZTabBarCell()

@property (nonatomic, strong) QZGradientLabel *label;
@property (nonatomic, strong) UIView *redDotView;
@property (nonatomic, strong) UILabel *badgeLabel;

@end

@implementation QZTabBarCell

#pragma mark- initialize
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self qzt_initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self qzt_initialize];
    }
    return self;
}

- (void)qzt_initialize
{
    _label = [[QZGradientLabel alloc] init];
    _label.textColor = [UIColor blackColor];
    [self.contentView addSubview:_label];
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark- layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.label.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.label.frame = CGRectIntegral(self.label.frame);
   
    CGPoint badgeCenter = CGPointMake(self.label.right, self.label.top + 1);
    if (_redDotView && !_redDotView.hidden) {
        _redDotView.center = badgeCenter;
    }
    
    if (_badgeLabel && !_badgeLabel.hidden) {
        [_badgeLabel sizeToFit];
        _badgeLabel.height = kBadgeLabelHeight;
        if (_badgeInfo.badgeNumber < 10) {
            _badgeLabel.width = kBadgeLabelHeight;
        } else {
            _badgeLabel.width += 10;
        }
        _badgeLabel.center = badgeCenter;
    }
}

#pragma mark- reuse
- (void)prepareForReuse
{
    [super prepareForReuse];
    _redDotView.hidden = YES;
    _badgeLabel.hidden = YES;
}

#pragma mark- setters
- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.label.textColor = selected ? self.selectedColor : self.normalColor;
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
    self.label.textColor = normalColor;
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    if (self.isSelected) {
        self.label.textColor = selectedColor;
    }
}

- (void)setFillColor:(UIColor *)fillColor
{
    self.label.fillColor = fillColor;
}

- (void)setProgress:(CGFloat)progress
{
    self.label.progress = progress;
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle
{
    _attributedTitle = attributedTitle;
    if (!attributedTitle) return;
    
    self.label.attributedText = attributedTitle;
    [self.label sizeToFit];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setBadgeInfo:(QZTabBarBadgeInfo *)badgeInfo
{
    _badgeInfo = badgeInfo;
    
    if (badgeInfo.showRedDot) {
        if (!self.redDotView) {
            [self qzt_createRedDotView];
        }
        _redDotView.hidden = NO;
        [self setNeedsLayout];
    } else {
        _redDotView.hidden = YES;
    }
    
    if (badgeInfo.badgeNumber > 0) {
        if (!self.badgeLabel) {
            [self qzt_createBadgeLabel];
        }
        self.badgeLabel.text = [NSString stringWithFormat:@"%ld", badgeInfo.badgeNumber];
        self.badgeLabel.hidden = NO;
        self.redDotView.hidden = YES;
        [self setNeedsLayout];
    } else {
        self.badgeLabel.hidden = YES;
    }
    
    [self layoutIfNeeded];
}

#pragma mark- getter
- (void)qzt_createRedDotView
{
    if (!_redDotView) {
        _redDotView = [UIView new];
        _redDotView.backgroundColor = _badgeBackgroundColor ?: [UIColor colorWithIntValue:QZTabBarBadgeBackgoroundColorValue];
        _redDotView.frame = CGRectMake(0, 0, kRedDotViewSideLength, kRedDotViewSideLength);
        _redDotView.clipsToBounds = YES;
        _redDotView.layer.cornerRadius = kRedDotViewSideLength / 2.0f;
        _redDotView.layer.borderWidth = self.badgeBorderWidth;
        UIColor *borderColor = _badgeBorderColor ?: [UIColor colorWithIntValue:QZTabBarBadgeBorderColorValue];
        _redDotView.layer.borderColor = borderColor.CGColor;
        [self addSubview:_redDotView];
        _redDotView.center = CGPointMake(self.label.right, self.label.top);
    }
}

- (void)qzt_createBadgeLabel
{
    if (!_badgeLabel) {
        _badgeLabel = [UILabel new];
        _badgeLabel.font = [UIFont systemFontOfSize:kBadgeFontSize];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.backgroundColor = _badgeBackgroundColor ?: [UIColor colorWithIntValue:QZTabBarBadgeBackgoroundColorValue];
        _badgeLabel.textColor = _badgeForegroundColor ?: [UIColor colorWithIntValue:QZTabBarBadgeForegoroundColorValue];
        _badgeLabel.clipsToBounds = YES;
        _badgeLabel.layer.cornerRadius = kBadgeLabelHeight / 2.0f;
        _badgeLabel.layer.borderWidth = self.badgeBorderWidth;
        UIColor *borderColor = _badgeBorderColor ?: [UIColor colorWithIntValue:QZTabBarBadgeBorderColorValue];
        _badgeLabel.layer.borderColor = borderColor.CGColor;
        [self addSubview:_badgeLabel];
        _badgeLabel.center = CGPointMake(self.label.right, self.label.top);
    }
}

#pragma mark- static methods
//+ (NSString *)identifier
//{
//    return @"RUID_QZTabBarCell";
//}

+ (CGFloat)widthForAttributedTitle:(NSAttributedString *)attributedtitle
{
    CGRect titleBounds = [attributedtitle boundingRectWithSize:CGSizeMake(MAXFLOAT, 0)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                             context:nil];
    
    return ceilf(titleBounds.size.width);
}

@end


#pragma mark-
#pragma mark- badgeInfo
@implementation QZTabBarBadgeInfo

@end

