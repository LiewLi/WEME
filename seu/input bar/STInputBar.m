//
//  STInputBar.m
//  STEmojiKeyboard
//
//  Created by zhenlintie on 15/5/29.
//  Copyright (c) 2015年 sTeven. All rights reserved.
//

#import "STInputBar.h"
#import "STEmojiKeyboard.h"
#import "WEME-Swift.h"

#define kSTIBDefaultHeight 44
#define kSTLeftButtonWidth 44
#define kSTLeftButtonHeight 30
#define kSTRightButtonWidth 55
#define kSTTextviewDefaultHeight 34
#define kSTTextviewMaxHeight 80



@interface STInputBar () <UITextViewDelegate>

@property (strong, nonatomic) UIButton *keyboardTypeButton;

@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) STEmojiKeyboard *keyboard;
@property (strong, nonatomic) UILabel *placeHolderLabel;

@property (strong, nonatomic)UIButton *photoButton;

@property (strong, nonatomic) void (^sendDidClickedHandler)(NSString *);
@property (strong, nonatomic) void (^photoDidClickedHandler)(NSString *);
@end

@implementation STInputBar{
    BOOL _isRegistedKeyboardNotif;
    BOOL _isDefaultKeyboard;
    NSArray *_switchKeyboardImages;
}

+ (instancetype)inputBar{
    return [self new];
}

- (void)dealloc{
    if (_isRegistedKeyboardNotif){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kSTIBDefaultHeight)]){
        _isRegistedKeyboardNotif = NO;
        _isDefaultKeyboard = YES;
        _switchKeyboardImages = @[@"btn_expression",@"btn_keyboard"];
        [self loadUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kSTIBDefaultHeight)]){
        _isRegistedKeyboardNotif = NO;
        _isDefaultKeyboard = YES;
        _switchKeyboardImages = @[@"btn_expression",@"btn_keyboard"];
        [self loadUI];
    }
    return self;
}

- (void)loadUI{
    self.backgroundColor = [UIColor colorFromRGB:0xefeff4];//[UIColor whiteColor];
//[UIColor colorWithWhite:0 alpha:0.7];
    self.layer.cornerRadius = 4.0;
    self.layer.masksToBounds = YES;
    _keyboard = [STEmojiKeyboard keyboard];
    _enablePhoto = YES;
    
    self.keyboardTypeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, (kSTIBDefaultHeight-kSTLeftButtonHeight)/2, kSTLeftButtonWidth, kSTLeftButtonHeight)];
    [_keyboardTypeButton addTarget:self action:@selector(keyboardTypeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _keyboardTypeButton.tag = 0;
    UIImage *keyboard = [[UIImage imageNamed:_switchKeyboardImages[_keyboardTypeButton.tag]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _keyboardTypeButton.tintColor = [UIColor colorFromRGB:0x3e5d9e];//[UIColor whiteColor];
    [_keyboardTypeButton setImage: keyboard forState:UIControlStateNormal];
    
    self.photoButton = [[UIButton alloc] initWithFrame:CGRectMake(kSTLeftButtonWidth, (kSTIBDefaultHeight-kSTLeftButtonHeight)/2, kSTLeftButtonWidth, kSTLeftButtonHeight)];
    [self.photoButton addTarget:self action:@selector(photoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.photoButton setImage:[[UIImage imageNamed:@"photoButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.photoButton.tintColor = [UIColor colorFromRGB:0x3e5d9e];//[UIColor whiteColor];
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(2*kSTLeftButtonWidth, (kSTIBDefaultHeight-kSTTextviewDefaultHeight)/2, CGRectGetWidth(self.frame)-2*kSTLeftButtonWidth-kSTRightButtonWidth, kSTTextviewDefaultHeight)];
    //self.textView.backgroundColor = [UIColor clearColor];
    //    self.textView.textContainerInset = UIEdgeInsetsMake(5.0f, 0.0f, 5.0f, 0.0f);
    //self.textView.textColor = [UIColor whiteColor];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.returnKeyType = UIReturnKeyDefault;//UIReturnKeyDone;
    self.textView.delegate = self;
    self.textView.tintColor = [UIColor colorFromRGB:0x3e5d9e];//[UIColor darkGrayColor];//[UIColor whiteColor];
    self.textView.scrollEnabled = NO;
    self.textView.layer.cornerRadius = 6;
    self.textView.showsVerticalScrollIndicator = NO;
    
    _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(2*kSTLeftButtonWidth+5, CGRectGetMinY(_textView.frame), CGRectGetWidth(_textView.frame), kSTTextviewDefaultHeight)];
    _placeHolderLabel.adjustsFontSizeToFitWidth = YES;
    _placeHolderLabel.minimumScaleFactor = 0.9;
    _placeHolderLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
    _placeHolderLabel.font = _textView.font;
    _placeHolderLabel.userInteractionEnabled = NO;
    
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendButton.frame = CGRectMake(self.frame.size.width-kSTRightButtonWidth, 0, kSTRightButtonWidth, kSTIBDefaultHeight);
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor colorFromRGB:0x3e5d9e] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor colorWithRed:197/255.0 green:197/255.0 blue:218/255.0 alpha:1.0] forState:UIControlStateDisabled];
    [self.sendButton setTitleEdgeInsets:UIEdgeInsetsMake(2.50f, 0.0f, 0.0f, 0.0f)];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:19];
    [self.sendButton addTarget:self action:@selector(sendTextCommentTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.sendButton.enabled = NO;
    
    [self addSubview:_keyboardTypeButton];
    [self addSubview:self.photoButton];
    [self addSubview:_textView];
    [self addSubview:_placeHolderLabel];
    [self addSubview:self.sendButton];
}

- (void)layout{
    
    self.sendButton.enabled = ![@"" isEqualToString:self.textView.text];
    _placeHolderLabel.hidden = self.sendButton.enabled;
    
    CGRect textViewFrame = self.textView.frame;
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(textViewFrame), 1000.0f)];
    
    CGFloat offset = 10;
    self.textView.scrollEnabled = (textSize.height > kSTTextviewMaxHeight-offset);
    textViewFrame.size.height = MAX(kSTTextviewDefaultHeight, MIN(kSTTextviewMaxHeight, textSize.height));
    self.textView.frame = textViewFrame;
    
    CGRect addBarFrame = self.frame;
    CGFloat maxY = CGRectGetMaxY(addBarFrame);
    addBarFrame.size.height = textViewFrame.size.height+offset;
    addBarFrame.origin.y = maxY-addBarFrame.size.height;
    self.frame = addBarFrame;
    
    self.keyboardTypeButton.center = CGPointMake(CGRectGetMidX(self.keyboardTypeButton.frame), CGRectGetHeight(addBarFrame)/2.0f);
    self.photoButton.center = CGPointMake(CGRectGetMidX(self.photoButton.frame), CGRectGetHeight(addBarFrame)/2.0f);
    self.sendButton.center = CGPointMake(CGRectGetMidX(self.sendButton.frame), CGRectGetHeight(addBarFrame)/2.0f);
}

#pragma mark - public

- (void)setPlaceHolder:(NSString *)placeHolder{
    _placeHolderLabel.text = placeHolder;
    _placeHolder = [placeHolder copy];
}

- (BOOL)resignFirstResponder{
    [super resignFirstResponder];
    return [_textView resignFirstResponder];
}

- (void)registerKeyboardNotif{
    _isRegistedKeyboardNotif = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setDidSendClicked:(void (^)(NSString *))handler{
    _sendDidClickedHandler = handler;
}

- (void)setDidPhotoClicked:(void (^)())handler {
    _photoDidClickedHandler = handler;
}

- (void)setFitWhenKeyboardShowOrHide:(BOOL)fitWhenKeyboardShowOrHide{
    if (fitWhenKeyboardShowOrHide){
        [self registerKeyboardNotif];
    }
    if (!fitWhenKeyboardShowOrHide && _fitWhenKeyboardShowOrHide){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    _fitWhenKeyboardShowOrHide = fitWhenKeyboardShowOrHide;
}

#pragma mark - notif

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:([info[UIKeyboardAnimationCurveUserInfoKey] integerValue]<<16)
                     animations:^{
                         CGRect newInputBarFrame = self.frame;
                         newInputBarFrame.origin.y = [UIScreen mainScreen].bounds.size.height-CGRectGetHeight(self.frame)-kbSize.height-self.adjust;
                         self.frame = newInputBarFrame;
                     }
                     completion:nil];
}

- (void)keyboardWillHidden:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    [UIView animateWithDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0
                        options:([info[UIKeyboardAnimationCurveUserInfoKey] integerValue]<<16)
                     animations:^{
                         self.center = CGPointMake(self.bounds.size.width/2.0f, height-CGRectGetHeight(self.frame)/2.0-self.adjust);
                     }
                     completion:nil];
}


#pragma mark - action

- (void)sendTextCommentTaped:(UIButton *)button{
    if (self.sendDidClickedHandler){
        self.sendDidClickedHandler(self.textView.text);
        self.textView.text = @"";
        [self layout];
    }
}

- (void)keyboardTypeButtonClicked:(UIButton *)button{
    if (button.tag == 1){
        self.textView.inputView = nil;
    }
    else{
        [_keyboard setTextView:self.textView];
    }
    [self.textView reloadInputViews];
    button.tag = (button.tag+1)%2;
    [_keyboardTypeButton setImage:[[UIImage imageNamed:_switchKeyboardImages[_keyboardTypeButton.tag]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
    [_textView becomeFirstResponder];
}

- (void)setEnablePhoto:(BOOL)enablePhoto{
    _enablePhoto = enablePhoto;
    if (_enablePhoto) {
        self.photoButton.hidden = false;
        CGRect frame = self.placeHolderLabel.frame;
        frame.origin.x = 2*kSTLeftButtonWidth+5;
        frame.size.width = CGRectGetWidth(self.frame)-2*kSTLeftButtonWidth-kSTRightButtonWidth;
        self.placeHolderLabel.frame = frame;
        frame = self.placeHolderLabel.frame;
        frame.origin.x  = 2*kSTLeftButtonWidth;
        self.textView.frame = frame;
        [self layout];
    }
    else {
        CGRect frame = self.placeHolderLabel.frame;
        frame.origin.x = kSTLeftButtonWidth+5;
        self.placeHolderLabel.frame = frame;
        frame = self.placeHolderLabel.frame;
        frame.origin.x  = kSTLeftButtonWidth;
        frame.size.width = CGRectGetWidth(self.frame)-kSTLeftButtonWidth-kSTRightButtonWidth;
        self.textView.frame = frame;
        self.photoButton.hidden = true;
        [self layout];
    }
}

- (void)photoButtonClicked:(UIButton *)sender {
    if (self.photoDidClickedHandler) {
        self.photoDidClickedHandler(self.textView.text);
        self.textView.text = @"";
        [self layout];
    }
}

#pragma mark - text view delegate

- (void)textViewDidChange:(UITextView *)textView{
    self.sendButton.enabled = ![@"" isEqualToString:textView.text];
    [self layout];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

@end