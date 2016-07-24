//
//  STInputBar.h
//  STEmojiKeyboard
//
//  Created by zhenlintie on 15/5/29.
//  Copyright (c) 2015年 sTeven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STInputBar : UIView

//+ (instancetype)inputBar;

@property (assign, nonatomic) BOOL fitWhenKeyboardShowOrHide;
@property (assign, nonatomic)CGFloat adjust;
@property (strong, nonatomic) UITextView *textView;
- (void)setDidSendClicked:(void(^)(NSString *text))handler;
- (void)setDidPhotoClicked:(void (^)(NSString *text))handler;
@property (copy, nonatomic) NSString *placeHolder;
@property (assign, nonatomic)BOOL enablePhoto;

@end
