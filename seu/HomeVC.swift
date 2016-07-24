//
//  HomeVC.swift
//  seu
//
//  Created by liewli on 9/13/15.
//  Copyright (c) 2015 li liew. All rights reserved.
//

import UIKit
import RSKImageCropper


class HomeVC: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        loadUI()
        checkForUpdates()
        updateDeviceToken()
    }
    
    func updateDeviceToken() {
        let setting = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(setting)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    func checkForUpdates() {
        let infoDict = (NSBundle.mainBundle().infoDictionary)!
        let currentVersion = infoDict["CFBundleShortVersionString"] as! String
        request(.GET, APP_INFO_URL).responseJSON { (response) -> Void in
            if let d = response.result.value {
                let json = JSON(d)
                if json["results"].array?.count > 0 {
                    let info = json["results"][0]
                    if info["version"].stringValue.compare(currentVersion) == NSComparisonResult.OrderedDescending {
                        let alert = UIAlertController(title: "发现新版本", message: info["releaseNotes"].stringValue, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "下次再说", style: .Default, handler: { (action) -> Void in
                            
                        }))
                        alert.addAction(UIAlertAction(title: "马上去更新", style: .Default, handler: { (action) -> Void in
                            let url = info["trackViewUrl"].stringValue
                            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
                        }))
                        alert.view.tintColor = THEME_COLOR
                        let paraghStyle = NSMutableParagraphStyle()
                        paraghStyle.alignment = .Left
                        let attr = NSAttributedString(string: info["releaseNotes"].stringValue, attributes: [NSParagraphStyleAttributeName:paraghStyle,NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)])
                        alert.setValue(attr, forKey: "attributedMessage")
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                }
            }
        }
        
        
    }

    
    func loadUI() {
        let navHand = UINavigationController(rootViewController: ActivityVC())
        let navSocial = UINavigationController(rootViewController: SocialVC())
        let Me =  UINavigationController(rootViewController: ProfileVC())
        let discover = UINavigationController(rootViewController: FindVC())

        
        setViewControllers([discover, navHand, navSocial, Me], animated: true)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:THEME_COLOR_BACK], forState: UIControlState.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:ICON_THEME_COLOR], forState: UIControlState.Selected)
        tabBar.tintColor = ICON_THEME_COLOR
        tabBar.backgroundColor = UIColor.whiteColor()
        UINavigationBar.appearance().barTintColor =  THEME_COLOR
        UINavigationBar.appearance().tintColor = THEME_FOREGROUND_COLOR//UIColor.whiteColor()
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : THEME_FOREGROUND_COLOR]
        selectedIndex = 0
        
        
        navHand.tabBarItem = UITabBarItem(title: "活动", image: UIImage(named: "hand")?.imageWithRenderingMode(.AlwaysOriginal), selectedImage: UIImage(named: "hand")?.imageWithRenderingMode(.AlwaysTemplate))
    
        navSocial.tabBarItem = UITabBarItem(title: "社区", image: UIImage(named: "social")?.imageWithRenderingMode(.AlwaysOriginal), selectedImage: UIImage(named: "social")?.imageWithRenderingMode(.AlwaysTemplate))
        
        Me.tabBarItem = UITabBarItem(title: "我", image: UIImage(named: "me")?.imageWithRenderingMode(.AlwaysOriginal), selectedImage: UIImage(named: "me")?.imageWithRenderingMode(.AlwaysTemplate))

        discover.tabBarItem = UITabBarItem(title: "发现", image: UIImage(named: "discovery")?.imageWithRenderingMode(.AlwaysOriginal), selectedImage: UIImage(named: "discovery")?.imageWithRenderingMode(.AlwaysTemplate))

        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}






class SettingVC :UITableViewController {
    private let setting = ["清除缓存", "允许推荐你给其他用户","关于\(APP)", "反馈意见", "申请认证"]
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        //tabBarController?.tabBar.hidden = true
        title = "设置"
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CELL")
        let footer = UIView(frame: CGRectMake(0, 0, view.frame.size.width, 60))
        tableView.tableFooterView = footer

        
        let logout = UIButton()
        footer.addSubview(logout)
        logout.translatesAutoresizingMaskIntoConstraints = false
        let constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[logout]-20-|", options: NSLayoutFormatOptions.AlignAllLastBaseline, metrics: nil, views: ["logout":logout])
        footer.addConstraints(constraints)
        let constraint = NSLayoutConstraint(item: logout, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: footer, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
        footer.addConstraint(constraint)
        logout.layer.cornerRadius = 5.0
        logout.backgroundColor = THEME_COLOR//UIColor.redColor()
        logout.setTitle("退出登录", forState: UIControlState.Normal)
        logout.addTarget(self, action: "logout:", forControlEvents: UIControlEvents.TouchUpInside)
       
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        
       // tabBarController?.tabBar.hidden = false
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.alpha = 1.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.hidden = true
    }
    
    func logout(sender : AnyObject) {
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(ID)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TOKEN)
        
        let cacheManager = SDImageCache.sharedImageCache()
        cacheManager.clearMemory()
        cacheManager.clearDisk()
        
        
        let appDelegate = UIApplication.sharedApplication().delegate
        appDelegate?.window??.rootViewController = LoginRegisterVC()

    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return setting.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CELL", forIndexPath: indexPath)
        cell.textLabel?.text = setting[indexPath.row]

        if indexPath.row == 2 {
            if let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String {
                let text =  "\(setting[indexPath.row])(v\(version))"
                let att = NSMutableAttributedString(string: text)
                att.addAttributes([NSForegroundColorAttributeName:UIColor.lightGrayColor(), NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)], range: NSMakeRange(setting[indexPath.row].characters.count, 3+version.characters.count))
                cell.textLabel?.attributedText = att
            }
        }
        cell.textLabel?.textColor = UIColor.colorFromRGB(0x636363)
        if indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4{
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        else if indexPath.row == 0 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
            label.textAlignment = .Right
            label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
            label.textColor = UIColor.lightGrayColor()
            label.text = "\(Double(SDImageCache.sharedImageCache().getSize()/10000)/100.0)M"
            cell.accessoryView = label
        }
        else {
            let toggle = UISwitch(frame: CGRectZero)
            toggle.onTintColor = THEME_COLOR
            cell.accessoryView = toggle
            toggle.setOn(true, animated: false)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                if let v = NSUserDefaults.standardUserDefaults().stringForKey(CARD_SETTING_KEY) {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if v == "yes" {
                            toggle.on = true
                        }
                        else if v == "no" {
                            toggle.on = false
                        }

                    })
                }
                
            })
            toggle.addTarget(self, action: "changeCardSetting:", forControlEvents: UIControlEvents.ValueChanged)
            cell.accessoryView = toggle
        }
        cell.selectionStyle = .None
        return cell
    }
    
    func changeCardSetting(sender:UISwitch) {
        let v = sender.on ? "0" : "1"
        if let t = token {
            request(.POST, EDIT_CARD_SETTING_URL, parameters: ["token":t, "cardflag":v], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                       // S.messageAlert("修改设定失败")
                        return
                    }
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                        NSUserDefaults.standardUserDefaults().setValue(v == "0" ? "yes" : "no", forKey: CARD_SETTING_KEY)
                        NSUserDefaults.standardUserDefaults().synchronize()
                    })
                    let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                    hud.labelText = (v == "0" ? "您将出现在发现列表中" : "您将不会出现在发现列表中" )
                    hud.mode = .CustomView
                    hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                    hud.hide(true, afterDelay: 1)

                }
            })
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
        if indexPath.row == 0 {
            let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud.mode = .Indeterminate
            hud.labelText = "正在清除..."
            hud.showAnimated(true, whileExecutingBlock: { () -> Void in
                let imgcache = SDImageCache.sharedImageCache()
                imgcache.clearMemory()
                imgcache.clearDisk()
                let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
                dispatch_after(delay, dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .None)
                    let hudFinished = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                    hudFinished.mode = .CustomView
                    hudFinished.labelText = "清除成功"
                    hudFinished.customView = UIImageView(image: UIImage(named: "checkmark"))
                    hudFinished.hide(true, afterDelay: 1)
                })
               })
        }
        else if indexPath.row == 2{
            navigationController?.pushViewController(AboutVC(), animated: true)
        }
        
        else if indexPath.row == 3 {
            let vc = ComposeMessageVC()
            vc.recvID = "2"
            navigationController?.pushViewController(vc, animated: true)
        }
        
        else if indexPath.row == 4 {
            let vc = VerifyVC()
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}


class VerifyVC:UIViewController {
    var infoLabel:UILabel!
    override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = UIColor.whiteColor()
         title = "申请认证"
         setupUI()
    }
    
    func setupUI() {
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoLabel)
        
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .ByWordWrapping
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_leftMargin)
            make.top.equalTo(snp_topLayoutGuideBottom)
            make.right.equalTo(view.snp_rightMargin)
        }
        
        infoLabel.text = "申请认证，请将学生证信息以照片形式发送至邮箱:\nwemespace@gmail.com"
        
    }
}






