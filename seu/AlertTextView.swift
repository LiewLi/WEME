//
//  AlertTextView.swift
//  牵手
//
//  Created by liewli on 12/12/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit


protocol AlertTextViewDelegate:class{

    func alertTextView(alertView:AlertTextView, doneWithText:String?)
}

class AlertTextView:UIView, UITextViewDelegate {

    var overlay:UIView!
    var title:String!
    var placeHolder:String!
    
    var textView:UITextView!
    weak var delegate:AlertTextViewDelegate?
    
    init(title t:String, placeHolder p:String) {
        title = t
        placeHolder = p
        overlay = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT))
        overlay.backgroundColor = UIColor.blackColor()
        overlay.alpha = 0
        super.init(frame: CGRectZero)
        setUI()
    }
    
    func tap(sender:AnyObject) {
        dismiss()
    }
    
    func dismiss() {
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.0, options:UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.overlay.alpha = 0
            self.center = CGPointMake(self.center.x, SCREEN_HEIGHT + CGRectGetHeight(self.frame)/2)
            }) { (finished) -> Void in
                self.overlay.removeFromSuperview()
                self.removeFromSuperview()
        }

    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        var info = notification.userInfo!
        let keyFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        if CGRectGetMinY(keyFrame) < CGRectGetMaxY(self.frame) {
            UIView.animateWithDuration(0.1) { () -> Void in
                self.center = CGPointMake(self.center.x, self.center.y + (CGRectGetMinY(keyFrame) - CGRectGetMaxY(self.frame)) - 10)
            }
        }
    }
    
    func keyboardWillHide(notification:NSNotification) {
        UIView.animateWithDuration(0.1) { () -> Void in
            self.center = CGPointMake(self.center.x, SCREEN_HEIGHT / 2)
        }
    }
    
    func setUI() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        overlay.addGestureRecognizer(tap)
        
        frame = CGRectMake(0, 0, SCREEN_WIDTH*4/5, (SCREEN_WIDTH*4/5)*10/16)
        backgroundColor = UIColor.whiteColor()
        
        let titleView = UILabel()
        titleView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        titleView.textColor = UIColor.colorFromRGB(0x4c566c)//THEME_COLOR
        titleView.text = title
        titleView.textAlignment = .Center
        titleView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleView)
        
        textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius =  4.0
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 1
        textView.layer.borderColor = BACK_COLOR.CGColor
        textView.tintColor = THEME_COLOR
        textView.delegate = self
        textView.textColor = UIColor.lightGrayColor()
        textView.text = placeHolder
        textView.becomeFirstResponder()
        textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
        self.addSubview(textView)
        
        let cancelButton = UIButton()
        cancelButton.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("取消", forState: .Normal)
        cancelButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        cancelButton.setTitleColor(UIColor.colorFromRGB(0xa8a8a8), forState: .Normal)
        //cancelButton.backgroundColor = BACK_COLOR
        self.addSubview(cancelButton)
        
        let doneButton = UIButton()
        doneButton.addTarget(self, action: "done:", forControlEvents: .TouchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("确认", forState: .Normal)
        doneButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        doneButton.setTitleColor(THEME_COLOR, forState: .Normal)
       // doneButton.backgroundColor = BACK_COLOR
        doneButton.tintColor = THEME_COLOR
        self.addSubview(doneButton)
        
        titleView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(snp_top)
            make.centerX.equalTo(snp_centerX)
            make.left.equalTo(snp_left)
            //make.height.equalTo(20)
        }
        
        textView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(titleView.snp_bottom)
            make.left.equalTo(snp_left).offset(10)
            make.right.equalTo(snp_right).offset(-10)
            //make.height.equalTo(110)
        }
        
        cancelButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.height.equalTo(titleView.snp_height)
            make.top.equalTo(textView.snp_bottom)
            make.width.equalTo(snp_width).multipliedBy(0.5)
            make.bottom.equalTo(snp_bottom)
        }
        
        doneButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(snp_right)
            make.centerY.equalTo(cancelButton.snp_centerY)
            make.width.equalTo(cancelButton.snp_width)
            make.height.equalTo(cancelButton.snp_height)
        }
        
        
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text
        let updatedText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: text)
        if updatedText.isEmpty {
            textView.text = placeHolder
            textView.textColor = UIColor.lightGrayColor()
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            return false
        }
            
        else if textView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        
        return true
        
    }
    
    func cancel(sender:AnyObject?) {
        dismiss()
    }
    
    func done(sender:AnyObject?) {
        dismiss()
        delegate?.alertTextView(self, doneWithText: self.textView.text)
    }
    
    func showInView(theView:UIView) {
        theView.addSubview(self)
        theView.insertSubview(self.overlay, belowSubview: self)
        
        self.center = CGPointMake(CGRectGetMidX(theView.frame), SCREEN_HEIGHT+CGRectGetHeight(self.frame)/2)
        
        let x = CGRectGetMidX(theView.frame)
        let y = CGRectGetMidY(theView.frame) - 60
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.0, options:UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                self.overlay.alpha = 0.4
                self.center = CGPointMake(x, y)
            }) { (finished) -> Void in
                
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
