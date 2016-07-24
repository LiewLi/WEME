//
//  AppDelegate.swift
//  seu
//
//  Created by liewli on 9/9/15.
//  Copyright (c) 2015 li liew. All rights reserved.
//

import UIKit
import CoreSpotlight

var token:String?
var myId:String?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func handleNotification(notification:[NSObject : AnyObject]) {
        switch UIApplication.sharedApplication().applicationState {
        case .Background, .Inactive:
            let json = JSON(notification)
            if json["type"].stringValue == "follow" {
                let userid = json["userid"].stringValue
                if let vc = window?.rootViewController as? HomeVC {
                    vc.selectedIndex = 3
                    let info = InfoVC()
                    info.id = userid
                    (vc.viewControllers?[3] as? UINavigationController)?.pushViewController(info, animated: true)
                }
            }
            else if json["type"].stringValue == "message" {
                let userid = json["userid"].stringValue
                if let vc = window?.rootViewController as? HomeVC {
                    vc.selectedIndex = 3
                    let msg = MessageVC()
                    msg.sendID = userid
                    (vc.viewControllers?[3] as? UINavigationController)?.pushViewController(msg, animated: true)
                }

            }

        default:
            break
        }
       
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window  = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.tintAdjustmentMode = .Normal
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        let defaults = NSUserDefaults.standardUserDefaults();
        if let t = defaults.stringForKey(TOKEN),
           let Id = defaults.stringForKey(ID){
            token = t
            myId = Id
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-400, 0), forBarMetrics: UIBarMetrics.Default)
            let vc = HomeVC()
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
            
            if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [NSObject:AnyObject] {
                self.handleNotification(notification)
            }
            
            
        }
        else {
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-400, 0), forBarMetrics: UIBarMetrics.Default)
            window?.rootViewController = LoginRegisterVC()
            window?.makeKeyAndVisible();
        }
        
     
        
        MobClick.startWithAppkey("566aacab67e58ec3410021a6", reportPolicy: ReportPolicy.init(1), channelId: "")
        let infoDict = (NSBundle.mainBundle().infoDictionary)!
        let currentVersion = infoDict["CFBundleShortVersionString"] as! String
        MobClick.setAppVersion(currentVersion)
        
        WXApi.registerApp("wx04e7630d122580c1", withDescription: "WeMe")
        
        AMapSearchServices.sharedServices().apiKey = "2b79be11eacfede90da2098bda7b5e04"
        
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
       return WXApi.handleOpenURL(url, delegate: WXApiManager.sharedManager())
    }
    
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        if shortcutItem.type == "weme.qrcode" {
            if let vc = window?.rootViewController as? HomeVC {
                vc.selectedIndex = 3
                let qr = MyQRCodeVC()
                (vc.viewControllers?[3] as? UINavigationController)?.pushViewController(qr, animated: true)
            }
        }
        else if shortcutItem.type == "weme.scan" {
            if let vc = window?.rootViewController as? HomeVC {
                vc.selectedIndex = 3
                let builder = QRCodeViewControllerBuilder { builder in
                    builder.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
                    builder.showTorchButton = true
                }
                
                let reader = QRCodeReaderViewController(builder: builder)
                let vc = (vc.viewControllers?[3] as? UINavigationController)?.viewControllers[0] as? ProfileVC
                reader.delegate = vc
                vc?.presentViewController(reader, animated: true, completion: nil)
    
            }
        }
    }
    
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if #available(iOS 9.0, *) {
            if userActivity.activityType == CSSearchableItemActionType {
                if let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                    if let url = NSURL(string: identifier) where url.scheme == "weme"{
                        if let h = url.host where h == "activity",
                            let com = url.pathComponents where com.count == 2 {
                                if let vc = window?.rootViewController as? HomeVC {
                                    vc.selectedIndex = 1
                                    let vc = vc.viewControllers?[1] as? UINavigationController
                                    let ac = ActivityInfoVC()
                                    ac.activityID = com[1]
                                    vc?.pushViewController(ac, animated: true)
                                }
                        }
                        
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
        return true
    }

    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var deviceToken = String(format: "%@", deviceToken)
        deviceToken = deviceToken.stringByReplacingOccurrencesOfString(" ", withString: "")
        deviceToken = deviceToken.stringByReplacingOccurrencesOfString("<", withString: "")
        deviceToken = deviceToken.stringByReplacingOccurrencesOfString(">", withString: "")
        if let t = token {
            request(.POST, UPLOAD_DEVICE_TOKEN_URL, parameters: ["token":t, "devicetoken":deviceToken], encoding: .JSON).responseJSON(completionHandler: { (response) -> Void in
                if let d = response.result.value {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        print(json["reason"].stringValue)
                        return
                    }
                }
            })
        }
        
    }
    
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    


    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        handleNotification(userInfo)
    }
}

