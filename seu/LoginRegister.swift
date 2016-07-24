//
//  ViewController.swift
//  seu
//
//  Created by liewli on 9/9/15.
//  Copyright (c) 2015 li liew. All rights reserved.
//

import UIKit
import RSKImageCropper



private func md5(string string: String) -> String {
    var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
    if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
        CC_MD5(data.bytes, CC_LONG(data.length), &digest)
    }
    
    var digestHex = ""
    for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
        digestHex += String(format: "%02x", digest[index])
    }
    
    return digestHex
}

class LoginRegisterVC: UIViewController, UIViewControllerTransitioningDelegate {
    
    private var _view:UIScrollView!
    private var contentView:UIView!
    private var overlay:UIView!
    
    private var accountIcon:UIImageView!
    private var passwordIcon:UIImageView!
    private var accountBack:UIView!
    private var passwordBack:UIView!
    private var accountTextField:UITextField!
    private var passwordTextField:UITextField!
    
    private var loginButton:UIButton!
    private var registerButton:UIButton!
    private var forgetButton:UIButton!
    
    var inputing = false

    
    private func applyBlurEffect(image: UIImage?) -> UIImage! {
        let imageToBlur = CIImage(image:image!)
        let blurfilter = CIFilter(name: "CIGaussianBlur")!
        blurfilter.setValue(imageToBlur, forKey: "inputImage")
        blurfilter.setValue(2, forKey: kCIInputRadiusKey)
        let resultImage = blurfilter.valueForKey("outputImage") as! CIImage
        let blurredImage = UIImage(CIImage: resultImage)
        return blurredImage
    }
    
    func setupScrollView() {
        //view.backgroundColor =UIColor.colorFromRGB(0x1874CD)//UIColor.blackColor()
        _view = UIScrollView()
        _view.backgroundColor = UIColor.whiteColor()
        view.addSubview(_view)
        _view.translatesAutoresizingMaskIntoConstraints = false
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[_view]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["_view":_view])
        view.addConstraints(constraints)
        var constraint = NSLayoutConstraint(item: _view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: _view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal , toItem:view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        contentView = UIView()
        //contentView.backgroundColor = BACK_COLOR
        _view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[contentView]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["contentView":contentView])
        _view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[contentView]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["contentView":contentView])
        _view.addConstraints(constraints)
        
        constraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if _view.contentSize.height < view.frame.height {
            contentView.snp_makeConstraints { (make) -> Void in
                make.height.greaterThanOrEqualTo(view.snp_height).priorityHigh()
                
            }
           _view.layoutIfNeeded()
        }
       
        var maskPath = UIBezierPath(roundedRect: accountBack.bounds, byRoundingCorners: [UIRectCorner.TopLeft,UIRectCorner.TopRight], cornerRadii: CGSizeMake(3, 3))
        var shape = CAShapeLayer()
        shape.frame = accountBack.bounds
        shape.path = maskPath.CGPath
        accountBack.layer.mask = shape
        
        maskPath = UIBezierPath(roundedRect: accountBack.bounds, byRoundingCorners: [UIRectCorner.BottomLeft,UIRectCorner.BottomRight], cornerRadii: CGSizeMake(3, 3))
        shape = CAShapeLayer()
        shape.frame = accountBack.bounds
        shape.path = maskPath.CGPath
        passwordBack.layer.mask = shape
    }

    
    func setupUI() {
        setupScrollView()
        _view.backgroundColor = UIColor.colorFromRGB(0x3460b5)
       
        let background = UIImageView(image: UIImage(named: "screen"))
        background.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(background)
        background.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(contentView.snp_top)
            make.height.equalTo(view.snp_height)
        }
        
        
        background.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        background.addGestureRecognizer(tap)
        
        
       
        
        accountBack = UIView()
        accountBack.translatesAutoresizingMaskIntoConstraints = false
        accountBack.backgroundColor = UIColor.whiteColor()
        //accountBack.layer.cornerRadius = 4.0
        accountBack.layer.masksToBounds = true
        contentView.addSubview(accountBack)
        
        passwordBack = UIView()
        passwordBack.translatesAutoresizingMaskIntoConstraints = false
        passwordBack.backgroundColor = UIColor.whiteColor()
        //passwordBack.layer.cornerRadius = 4.0
        passwordBack.layer.masksToBounds = true
        contentView.addSubview(passwordBack)
        
        accountIcon = UIImageView(image: UIImage(named: "account"))
        accountIcon.translatesAutoresizingMaskIntoConstraints = false
        accountBack.addSubview(accountIcon)
        
        passwordIcon = UIImageView(image: UIImage(named: "password"))
        passwordIcon.translatesAutoresizingMaskIntoConstraints = false
        passwordBack.addSubview(passwordIcon)
        
        accountTextField = UITextField()
        accountTextField.translatesAutoresizingMaskIntoConstraints = false
        accountTextField.keyboardType = .Alphabet
        accountTextField.tintColor = THEME_COLOR
        accountTextField.textColor = THEME_COLOR
        accountBack.addSubview(accountTextField)
        
        passwordTextField = UITextField()
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.secureTextEntry = true
        passwordTextField.keyboardType = .Alphabet
        passwordTextField.tintColor = THEME_COLOR
        passwordTextField.textColor = THEME_COLOR
        passwordBack.addSubview(passwordTextField)
        
        loginButton = UIButton()
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.backgroundColor = UIColor.colorFromRGB(0x5278c3)
        loginButton.setTitle("登录", forState: .Normal)
        loginButton.addTarget(self, action: "login:", forControlEvents: .TouchUpInside)
        loginButton.layer.cornerRadius = 4.0
        loginButton.layer.masksToBounds = true
        contentView.addSubview(loginButton)
        
        registerButton = UIButton()
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.backgroundColor = UIColor.clearColor()
        registerButton.setTitle("注册 \(APP) 用户", forState: .Normal)
        registerButton.addTarget(self, action: "register:", forControlEvents: .TouchUpInside)
        registerButton.setTitleColor( UIColor.colorFromRGB(0x8da7e1), forState: .Normal)
        registerButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        contentView.addSubview(registerButton)
        
        forgetButton = UIButton()
        forgetButton = UIButton()
        forgetButton.translatesAutoresizingMaskIntoConstraints = false
        forgetButton.backgroundColor = UIColor.clearColor()
        forgetButton.setTitle("忘记密码?", forState: .Normal)
        forgetButton.addTarget(self, action: "forget:", forControlEvents: .TouchUpInside)
        forgetButton.setTitleColor( UIColor.colorFromRGB(0x8da7e1), forState: .Normal)
        forgetButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        contentView.addSubview(forgetButton)

        
        
        accountBack.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(contentView.snp_centerY).offset(-20)
            make.centerX.equalTo(contentView.snp_centerX)
            make.height.equalTo(44)
            make.width.equalTo(contentView.snp_width).multipliedBy(2/3.0)
        }
        
        passwordBack.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(accountBack.snp_bottom).offset(1)
            make.centerX.equalTo(contentView.snp_centerX)
            make.height.equalTo(accountBack.snp_height)
            make.width.equalTo(accountBack.snp_width)
        }
        
        accountIcon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(accountBack.snp_leftMargin)
            make.centerY.equalTo(accountBack.snp_centerY)
            make.width.height.equalTo(20)
        }
        
        accountTextField.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(accountIcon.snp_right).offset(10)
            make.right.equalTo(accountBack.snp_right)
            make.centerY.equalTo(accountBack.snp_centerY)
        }
        
        passwordIcon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(passwordBack.snp_leftMargin)
            make.centerY.equalTo(passwordBack.snp_centerY)
            make.width.height.equalTo(20)
        }
        
        passwordTextField.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(passwordIcon.snp_right).offset(10)
            make.right.equalTo(passwordBack.snp_right)
            make.centerY.equalTo(passwordBack.snp_centerY)
        }
        
        loginButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(passwordBack.snp_bottom).offset(20)
            make.centerX.equalTo(contentView.snp_centerX)
            make.width.equalTo(accountBack.snp_width)
            make.height.equalTo(passwordBack.snp_height)
        }
        
        registerButton.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(contentView.snp_centerX)
            //make.top.equalTo(loginButton.snp_bottom).offset(60)
        }
        forgetButton.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(contentView.snp_centerX)
            make.top.equalTo(registerButton.snp_bottom)
        }
        
        contentView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(registerButton.snp_bottom).offset(view.frame.size.height/8).priorityLow()
        }
        
        
        
    }
    

    
    func login(sender:AnyObject) {
        //let navigation = UINavigationController(rootViewController: HomeVC())
        if accountTextField?.text?.characters.count == 0 || passwordTextField?.text?.characters.count == 0 {
            let alert = UIAlertController(title: "提示", message: "帐号和密码不能为空", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
            
        }
        
        let pwdmd5 = md5(string: (passwordTextField?.text)!)
        print(pwdmd5)
        request(.POST, LOGIN_URL, parameters: ["username":(accountTextField?.text)!, "password":pwdmd5], encoding: .JSON).responseJSON { (response) -> Void in
            //debugprint(response)
            if let d = response.result.value {
                let json  = JSON(d)
                if json["state"].stringValue == "successful" {
                    
                    token = json["token"].stringValue
                    myId = json["id"].stringValue
                    NSUserDefaults.standardUserDefaults().setValue(token, forKey: TOKEN)
                    NSUserDefaults.standardUserDefaults().setValue(myId, forKey: ID)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    
                    let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    hud.labelText = "登陆成功"
                    hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                    hud.mode = .CustomView
                    
                    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
                    dispatch_after(delay, dispatch_get_main_queue(), { () -> Void in
                        hud.hide(true)
                        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
                        appDelegate?.window?.rootViewController = HomeVC()
                    })
                    
                }
                else {
                    let alert = UIAlertController(title: "提示", message: json["reason"].stringValue, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                    
                }
            }
            else if let error = response.result.error {
                let alert = UIAlertController(title: "提示", message: error.localizedFailureReason ?? error.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
                
            }
        }
        
        
    }
    
    func register(sender:AnyObject?) {
        
        let navigation = UINavigationController(rootViewController: RegisterUserVC())
        navigation.view.backgroundColor = UIColor.whiteColor()
        navigation.navigationBar.barTintColor = THEME_COLOR
        navigation.navigationBar.tintColor = UIColor.whiteColor()
        navigation.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-200, 0), forBarMetrics: UIBarMetrics.Default)
        navigation.modalPresentationStyle = .Custom
        navigation.transitioningDelegate = self
        
        presentViewController(navigation, animated: true, completion: nil)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let animator = FlipTransitionAnimator()
        animator.presenting = false
        return animator
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = FlipTransitionAnimator()
        animator.presenting = true
        return animator
    }
    
    func forget(sender:AnyObject) {
        let navigation = UINavigationController(rootViewController: ForgetPasswordVC())
        navigation.view.backgroundColor = UIColor.whiteColor()
        navigation.navigationBar.barTintColor = THEME_COLOR
        navigation.navigationBar.tintColor = UIColor.whiteColor()
        navigation.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-200, 0), forBarMetrics: UIBarMetrics.Default)
        navigation.modalPresentationStyle = .Custom
        navigation.transitioningDelegate = self
        self.presentViewController(navigation, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification:NSNotification) {
        if inputing == false {
            inputing = true
            //var info = notification.userInfo!
            //let keyFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            _view.setContentOffset(CGPointMake(_view.contentOffset.x, 80), animated: true)
        }
    }
    
    func keyboardWillHide(sender:AnyObject?) {
        inputing = false
        _view.setContentOffset(CGPointMake(_view.contentOffset.x, 0), animated: true)

    }
    
    func tap(sender:AnyObject) {
        if accountTextField.isFirstResponder() {
            accountTextField.resignFirstResponder()
        }
        else if passwordTextField.isFirstResponder() {
            passwordTextField.resignFirstResponder()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}


class ForgetPasswordVC:UIViewController {
    
    var phoneTextField:UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.alpha = 1.0
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BACK_COLOR
        title = "重置密码"
        
        let back = UIBarButtonItem(image: UIImage(named: "activity_more"), style: .Plain, target: self, action: "back:")
        navigationItem.leftBarButtonItem = back
        
        let next = UIBarButtonItem(title: "下一步", style: .Plain, target: self, action: "next:")
        navigationItem.rightBarButtonItem = next
        
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        view.addGestureRecognizer(tap)
        
        setupUI()
    }
    
    func tap(sender:AnyObject) {
        phoneTextField.resignFirstResponder()
    }
    
    func isPhone(phone:String) -> Bool {
        guard phone.characters.count == 11 else {
            return false
        }
        let c0:Character = "0"
        let c9:Character = "9"
        for c in phone.unicodeScalars {
            if c.value < c0.unicodeScalarCodePoint() || c.value > c9.unicodeScalarCodePoint() {
                return false
            }
        }
        return true
    }
    
    func next(sender:AnyObject) {
        if let phone = phoneTextField.text {
            guard isPhone(phone) else {
                self.messageAlert("请检查号码输入是否正确")
                return
            }
            
            let vc = ResetPasswordVC()
            vc.phone = phone
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setupUI() {
        phoneTextField = UITextField()
        phoneTextField.placeholder = "输入你的手机号来重置密码"
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(phoneTextField)
        phoneTextField.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(snp_topLayoutGuideBottom).offset(10)
            make.left.equalTo(view.snp_leftMargin)
            make.right.equalTo(view.snp_rightMargin)
        }
        //passwordTextField.layer.cornerRadius = 4.0
        phoneTextField.layer.masksToBounds = true
        phoneTextField.tintColor = THEME_COLOR
        phoneTextField.borderStyle = .RoundedRect
        phoneTextField.keyboardType = .NumberPad
        
    }
    
    
    func back(sender:AnyObject) {
        view.endEditing(true)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}

class ResetPasswordVC:UIViewController {
    var phone:String!
    var codeTextField:UITextField!
    var newPasswordTextField:UITextField!
    var infoLabel:UILabel!
    var resendButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "重置密码"
        view.backgroundColor = BACK_COLOR
        
        
        let reset = UIBarButtonItem(title: "重置", style: .Plain, target: self, action: "reset:")
        navigationItem.rightBarButtonItem = reset
        
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        view.addGestureRecognizer(tap)

        
        setupUI()
        
        sendCode()
    }
    
    func sendCode() {
        request(.POST, SEND_SMS_CODE_URL, parameters: ["phone":phone, "type":2], encoding: .JSON).responseJSON { [weak self](response) -> Void in
            if let d = response.result.value, S = self {
                let json = JSON(d)
                guard json["state"].stringValue == "successful" else {
                    S.messageAlert("请求发送验证码失败")
                    return
                }
            }
            else {
                self?.messageAlert("请求发送验证码失败")
            }
        }
    }
    
    
    func reset(sender:AnyObject) {
        view.endEditing(true)
        guard let password = newPasswordTextField.text, code = codeTextField.text where password.characters.count > 0 && code.characters.count > 0 else {
            self.messageAlert("密码与验证码不能为空")
            return
        }
        let pwdmd5 = md5(string: password)

        request(.POST, RESET_PASSWORD_URL, parameters: ["phone":phone, "password":pwdmd5,"code":code], encoding: .JSON).responseJSON { [weak self](response) -> Void in
            print(response)
            if let S = self, d = response.result.value {
                let json = JSON(d)
                guard json["state"].stringValue == "successful" else {
                    S.messageAlert("重置密码失败")
                    return
                }
                token = json["token"].stringValue
                myId = json["id"].stringValue
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setValue(token, forKey: TOKEN)
                userDefaults.setValue(myId, forKey: ID)
                userDefaults.synchronize()
                S.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = HomeVC()
                
            }
            else {
                self?.messageAlert("重置密码失败")
            }
        }
    }
    
    func tap(sender:AnyObject) {
        view.endEditing(true)
    }

    
    
    func setupUI() {
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        infoLabel.textColor = TEXT_COLOR
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .ByWordWrapping
        infoLabel.text = "短信验证码已经发到您的手机\(phone)上, 请输入短信验证码和新的密码"
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(snp_topLayoutGuideBottom).offset(10)
            make.left.equalTo(view.snp_leftMargin)
            make.right.equalTo(view.snp_rightMargin)
        }
        
        codeTextField = UITextField()
        codeTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(codeTextField)
        codeTextField.placeholder = "输入短信验证码"
        codeTextField.tintColor = THEME_COLOR
        codeTextField.borderStyle = .RoundedRect
        codeTextField.keyboardType = .NumberPad
        
        newPasswordTextField = UITextField()
        newPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newPasswordTextField)
        newPasswordTextField.placeholder = "输入新的密码"
        newPasswordTextField.tintColor = THEME_COLOR
        newPasswordTextField.borderStyle = .RoundedRect
        newPasswordTextField.keyboardType = .ASCIICapable
        newPasswordTextField.secureTextEntry = true
        
        codeTextField.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_leftMargin)
            make.right.equalTo(view.snp_rightMargin)
            make.top.equalTo(infoLabel.snp_bottom).offset(10)
        }
        
        newPasswordTextField.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_leftMargin)
            make.right.equalTo(view.snp_rightMargin)
            make.top.equalTo(codeTextField.snp_bottom).offset(10)
        }
        
        resendButton = UIButton()
        resendButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resendButton)
        resendButton.setTitle("没收到验证码？重新发送", forState: .Normal)
        resendButton.setTitleColor(THEME_COLOR, forState: .Normal)
        resendButton.addTarget(self, action: "resend:", forControlEvents: .TouchUpInside)
        resendButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_leftMargin)
            make.right.equalTo(view.snp_rightMargin)
            make.top.equalTo(newPasswordTextField.snp_bottom).offset(10)
        }
        resendButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        
        
    }
    
    func resend(sender:AnyObject) {
        sendCode()
    }
}

class ContractVC:UIViewController {
    
    var textContentView:UITextView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.alpha = 1.0
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        title = "用户协议"
        let left = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: "close:")
        navigationItem.leftBarButtonItem = left
        automaticallyAdjustsScrollViewInsets = false
        setupUI()
        
        let contract = NSBundle.mainBundle().URLForResource("contract", withExtension: "rtf")!
        if let attributedtext = try? NSAttributedString(fileURL: contract, options: [NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType], documentAttributes: nil) {
            textContentView.attributedText = attributedtext
        }
    }
    
    func close(sender:AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setupUI() {
        textContentView = UITextView()
        textContentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textContentView)
        textContentView.editable = false
        textContentView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(snp_topLayoutGuideBottom)
            make.bottom.equalTo(view.snp_bottom)
        }
    }
}

class RegisterUserVC:UITableViewController {
    
    let sections = ["帐号", "验证码", "密码", "用户协议", "注册"]
    let placeholder = ["手机号", "", "密码(至少6位)", "", "" ]
    
    var account = ""
    var password = ""
    var code = ""
    //var rightButton:UIBarButtonItem!
    var isSending = false
    var timeCount = 0
    
    var succeed = false
    var timer:NSTimer!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.alpha = 1.0
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BACK_COLOR
        tableView.registerClass(RegisterTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(RegisterTableViewCell))
        tableView.registerClass(RegisterTableActionViewCell.self, forCellReuseIdentifier: NSStringFromClass(RegisterTableActionViewCell))
        
        tableView.registerClass(RegisterTableCodeCell.self, forCellReuseIdentifier: NSStringFromClass(RegisterTableCodeCell))
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .None
        title = "注册\(APP)用户"
        let back = UIBarButtonItem(image: UIImage(named: "activity_more"), style: .Plain, target: self, action: "back:")
        navigationItem.leftBarButtonItem = back
        
        //rightButton = UIBarButtonItem(title: "跳过", style: UIBarButtonItemStyle.Plain, target: self, action: "skip:")
        //navigationItem.rightBarButtonItem = rightButton
       // rightButton.enabled = false
       // rightButton.title = ""
    }
    
    func skip(sender:AnyObject) {
        self.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = HomeVC()
    }
    
    func back(sender:AnyObject) {
        view.endEditing(true)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == sections.count - 1{
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(RegisterTableActionViewCell), forIndexPath: indexPath) as! RegisterTableActionViewCell
            cell.action.backgroundColor = THEME_COLOR
            if succeed {
                cell.action.setTitle("注册成功, 完善个人信息吧", forState: .Normal)
            }
            else {
                cell.action.setTitle("注册", forState: .Normal)
            }
            cell.action.addTarget(self, action: "register:", forControlEvents: .TouchUpInside)
            if !self.succeed {
                cell.action.backgroundColor = UIColor.lightGrayColor()
                cell.action.enabled = false
            }
            else {
                cell.action.backgroundColor = THEME_COLOR
                cell.action.enabled = true
            }
            cell.selectionStyle = .None
            return cell
        }
        else if indexPath.row == sections.count - 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
            let button = UIButton(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
            button.setTitle("注册表示您同意 \"WEME用户协议\", 请先阅读 >>", forState: .Normal)
            button.titleLabel?.textAlignment = .Center
            button.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
            button.setTitleColor(THEME_COLOR, forState: .Normal)
            button.addTarget(self, action: "contract:", forControlEvents: .TouchUpInside)
            cell.accessoryView = button
            cell.backgroundColor = BACK_COLOR
            cell.selectionStyle = .None
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(RegisterTableCodeCell), forIndexPath: indexPath) as! RegisterTableCodeCell
            cell.selectionStyle = .None
            cell.codeButton.addTarget(self, action: "sendCode:", forControlEvents: .TouchUpInside)
            cell.codeButton.backgroundColor = UIColor.lightGrayColor()
            cell.codeButton.enabled = false
            cell.codeTextField.addTarget(self, action: "textChange:", forControlEvents: .EditingChanged)
            cell.codeTextField.tag = indexPath.row
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(RegisterTableViewCell), forIndexPath: indexPath) as! RegisterTableViewCell
            cell.titleInfoLabel.text = sections[indexPath.row]
            if indexPath.row == 2 {
                cell.textContentField.secureTextEntry = true
                cell.textContentField.keyboardType = .ASCIICapable
            }
            else if indexPath.row == 0 {
                cell.textContentField.keyboardType = .NumberPad
            }
            cell.textContentField.placeholder = placeholder[indexPath.row]
            cell.textContentField.tag = indexPath.row
            cell.textContentField.addTarget(self, action: "textChange:", forControlEvents: .EditingChanged)
            cell.selectionStyle = .None
            return cell
        }
    }
    
    func contract(sender:AnyObject) {
        let vc = UINavigationController(rootViewController: ContractVC())
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func sendCode(sender:AnyObject) {
        if !isSending {
            isSending = true
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tick:", userInfo: nil, repeats: true)
            timeCount = 60
            timer.fire()
            if let codeButton = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? RegisterTableCodeCell)?.codeButton {
                codeButton.backgroundColor = UIColor.lightGrayColor()
                codeButton.enabled = false
                codeButton.setTitle(" \(timeCount)秒后重发 ", forState: .Normal)
            }

            request(.POST, SEND_SMS_CODE_URL, parameters: ["phone":account, "type":1], encoding: .JSON).responseJSON { [weak self](response) -> Void in
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        S.messageAlert("请求发送验证码失败")
                        return
                    }
                }
                else {
                    self?.messageAlert("请求发送验证码失败")
                }
            }
        }
    }
    
    func tick(sender:AnyObject) {
        if isSending {
            timeCount--
            if timeCount == 0 {
                timer.invalidate()
                isSending = false
                if let codeButton = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? RegisterTableCodeCell)?.codeButton {
                    codeButton.backgroundColor = THEME_COLOR
                    codeButton.enabled = true
                    codeButton.setTitle(" 发送验证码 ", forState: .Normal)
                }

            }
            else {
                if let codeButton = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? RegisterTableCodeCell)?.codeButton {
                    codeButton.backgroundColor = UIColor.lightGrayColor()
                    codeButton.enabled = false
                    codeButton.setTitle(" \(timeCount)秒后重发 ", forState: .Normal)
                }
 
            }

        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == sections.count - 1 {
            return 60
        }
        else if indexPath.row == sections.count - 2 {
            return 30
        }
        else if indexPath.row == 1 {
            return 40
        }
        else {
            return 70
        }
    }
    
    func textChange(sender:UITextField) {
        switch sender.tag {
        case 0:
            account = sender.text ?? ""
            if account.characters.count == 11 && !isSending {
                if let codeButton = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? RegisterTableCodeCell)?.codeButton {
                    codeButton.backgroundColor = THEME_COLOR
                    codeButton.enabled = true
                }
            }
            else {
                if let codeButton = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as? RegisterTableCodeCell)?.codeButton {
                    codeButton.backgroundColor = UIColor.lightGrayColor()
                    codeButton.enabled = false
                }

            }
        case 1:
            code = sender.text ?? ""
        case 2:
            password = sender.text ?? ""
        
        default:
            break
        }
        
        if account.characters.count > 0 && password.characters.count > 0 && code.characters.count > 0 {
            if let registerButton = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)) as? RegisterTableActionViewCell)?.action {
                registerButton.enabled = true
                registerButton.backgroundColor = THEME_COLOR
            }
        }
        else {
            if let registerButton = (tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0)) as? RegisterTableActionViewCell)?.action {
                registerButton.enabled = false
                registerButton.backgroundColor = UIColor.lightGrayColor()
            }

        }
    }
    
    func register(sender:AnyObject) {
        if succeed {
            let vc = EditInfoVC()
            vc.isRegistering = true
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            if (account.characters.count == 0 || password.characters.count == 0 || code.characters.count == 0) {
                self.messageAlert("用户名或密码或验证码不能为空")
                return
            }
            
            if (password.characters.count < 6) {
                self.messageAlert("请输入至少6位密码")
                return
                
            }
         
            let pwdmd5 = md5(string: password)
            
            request(.POST, REGISTER_PHONE_URL, parameters: ["phone":account, "password":pwdmd5, "code":code], encoding:.JSON).responseJSON { [weak self](response) -> Void in
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    if json["state"].stringValue == "successful" {
                        token = json["token"].stringValue
                        myId = json["id"].stringValue
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        userDefaults.setValue(token, forKey: TOKEN)
                        userDefaults.setValue(myId, forKey: ID)
                        userDefaults.synchronize()
                        //S.rightButton.enabled = true
                        //S.rightButton.title = "跳过"
                        S.succeed = true
                        S.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 4, inSection: 0)], withRowAnimation: .None)
                    }
                    else {
                        S.messageAlert(json["reason"].stringValue)
                        
                    }
                }
                    
                else if let _ = response.result.error {
                    self?.messageAlert("注册失败")
                }
                
                
            }
        }
        

    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        tableView.endEditing(true)
    }
    
}

class RegisterTableViewCell:UITableViewCell {
    var titleInfoLabel:UILabel!
    var textContentField:UITextField!
    var backView:UIView!
    
    func initialize() {
        
        contentView.backgroundColor = BACK_COLOR
        titleInfoLabel = UILabel()
        titleInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInfoLabel.backgroundColor = BACK_COLOR
        titleInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        titleInfoLabel.textColor = TEXT_COLOR
        contentView.addSubview(titleInfoLabel)
        
        backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = UIColor.whiteColor()
        contentView.addSubview(backView)
        
        backView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(titleInfoLabel.snp_bottom).offset(5)
            make.bottom.equalTo(contentView.snp_bottom)
            backView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            backView.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            
        }
        
        
        //contentView.backgroundColor = UIColor.whiteColor()
        textContentField = UITextField()
        textContentField.translatesAutoresizingMaskIntoConstraints = false
        textContentField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        textContentField.textColor = THEME_COLOR
        textContentField.backgroundColor = UIColor.whiteColor()
        textContentField.tintColor = THEME_COLOR
        textContentField.borderStyle = .RoundedRect
        backView.addSubview(textContentField)
        
        titleInfoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left).offset(5)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(contentView.snp_top).offset(5)
            titleInfoLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            titleInfoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        }
        
        textContentField.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left).offset(2)
            make.right.equalTo(contentView.snp_right).offset(-2)
            make.top.equalTo(backView.snp_top).offset(2)
            make.bottom.equalTo(contentView.snp_bottom).offset(-2)
            textContentField.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            textContentField.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
}
class RegisterTableActionViewCell:UITableViewCell {
    var titleInfoLabel:UILabel!
    var action:UIButton!
    var backView:UIView!
    
    func initialize() {
        
        contentView.backgroundColor = BACK_COLOR
        titleInfoLabel = UILabel()
        titleInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInfoLabel.backgroundColor = BACK_COLOR
        titleInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        titleInfoLabel.textColor = UIColor.lightGrayColor()
        contentView.addSubview(titleInfoLabel)
        
        backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(backView)
        
        backView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(titleInfoLabel.snp_bottom).offset(5)
            make.bottom.equalTo(contentView.snp_bottom)
            backView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            backView.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            
        }
        
       action = UIButton()
       action.translatesAutoresizingMaskIntoConstraints = false
       action.layer.cornerRadius = 4.0
        action.layer.masksToBounds = true
       backView.addSubview(action)
        
        titleInfoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left).offset(5)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(contentView.snp_top).offset(5)
            titleInfoLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            titleInfoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        }
        
        action.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.centerY.equalTo(backView.snp_centerY)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
}
class RegisterTableCodeCell:UITableViewCell {
    var codeButton:UIButton!
    var codeTextField:UITextField!
    
    func initialize() {
        codeButton = UIButton()
        codeButton.translatesAutoresizingMaskIntoConstraints = false
        codeButton.backgroundColor = THEME_COLOR
        codeButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        codeButton.setTitle(" 发送验证码 ", forState: .Normal)
        codeButton.layer.cornerRadius = 4
        codeButton.layer.masksToBounds = true
        contentView.addSubview(codeButton)
        
        codeTextField = UITextField()
        codeTextField.translatesAutoresizingMaskIntoConstraints = false
        codeTextField.tintColor = THEME_COLOR
        codeTextField.placeholder = "验证码"
        contentView.addSubview(codeTextField)
        codeTextField.keyboardType = .NumberPad
        codeTextField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        codeTextField.borderStyle = .RoundedRect

        
        codeTextField.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp_top).offset(2)
            make.bottom.equalTo(contentView.snp_bottom).offset(-2)
            make.left.equalTo(contentView.snp_left).offset(2)
            //make.centerY.equalTo(contentView.snp_centerY)
            make.right.equalTo(codeButton.snp_left).offset(-5)
            //codeTextField.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        }
        codeButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(contentView.snp_right).offset(-2)
            make.centerY.equalTo(contentView.snp_centerY)
            make.height.equalTo(codeTextField.snp_height)
            make.width.equalTo(codeTextField.snp_width).multipliedBy(0.4)
            //codeButton.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}