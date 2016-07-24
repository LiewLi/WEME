//
//  utility.swift
//  seu
//
//  Created by liewli on 10/14/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import Foundation
import UIKit

//MARK: - RESTFUL API
let DOMAIN_BASE_URL = "http://www.weme.space:8080/"
let BASE_URL = "http://218.244.147.240:8080/"
//let BASE_URL = "http://121.249.1.129:8080/"

let BASE_URL_NGINX = "http://218.244.147.240/"

let REGISTER_URL = BASE_URL + "register"

let EDIT_SCHOOLINFO_URL = BASE_URL + "editprofile/editschoolinformation"

let LOGIN_URL = BASE_URL + "login"

let EDIT_PERSONAL_INFO_URL = BASE_URL + "editprofile/editpersonalinformation"

let EDIT_PREFER_INFO_URL = BASE_URL + "editprofile/editpreferinformation"

let EDIT_CARD_SETTING_URL = BASE_URL + "editprofile/editcardsetting"

let EDIT_PROFILE_INFO_URL = BASE_URL + "editprofileinfo"

let GET_PROFILE_INFO_URL = BASE_URL + "getprofile"

let UPLOAD_AVATAR_URL =  BASE_URL_NGINX + "uploadavatar"

let GET_AVATAR = BASE_URL_NGINX + "avatar/"

let GET_PROFILE_BACKGROUND = BASE_URL_NGINX + "background/"

let GET_FOLLOWERS_URL = BASE_URL + "followview"

let UNFOLLOW_URL = BASE_URL + "unfollow"

let FOLLOW_URL = BASE_URL + "follow"

let GET_RECOMMENDED_FRIENDS_URL = BASE_URL + "getrecommenduser"

let GET_FRIEND_PROFILE_URL = BASE_URL + "getprofilebyid"

let SEARCH_USER_URL = BASE_URL + "searchuser"

let SEND_MESSAGE = BASE_URL + "sendmessage"

let GET_MESSGE_USER_LIST = BASE_URL + "getSendUserList"

let GET_MESSAGE_DETAIL_LIST = BASE_URL + "getMessageDetailList"

let READ_MESSAGE = BASE_URL + "readmessage"

let MESSAGE_APPENDIX_URL = UPLOAD_AVATAR_URL//BASE_URL + "messageAppendix"


//MARK: - Social API

let TOP_BOARD_URL = BASE_URL + "topofficial"
let GET_TOPIC_LIST = BASE_URL + "gettopiclist"

let GET_TOPIC_SLOGAN = BASE_URL + "gettopicslogan"
let GET_POST_LIST = BASE_URL + "getpostlist"

let SEND_POST = BASE_URL + "publishpost"

let GET_POST_DETAIL = BASE_URL + "getpostdetail"

let GET_POST_COMMENT = BASE_URL + "getpostcomment"

let LIKE_POST = BASE_URL + "likepost"

let LIKE_COMMENT = BASE_URL + "likecomment"

let COMMENT_POST = BASE_URL + "commenttopost"

let REPLY_COMMENT = BASE_URL + "commenttocomment"

let GET_COMMENT_BY_COMMENTID = BASE_URL + "getcommentbycommentid"

let GET_POST_LIKE_USERS = BASE_URL + "getpostlikeusers"
//MARK: - KEY CONSTANT

let GET_ACTIVITY_INFO_URL = BASE_URL + "getactivityinformation"

let SIGNUP_ACTIVITY_URL = BASE_URL + "signup"
let LIKE_ACTIVITY_URL = BASE_URL + "likeactivity"

let GET_USER_TIMELINE = BASE_URL + "getusertimeline"
let GET_USER_TIMELINE_IMAGES = BASE_URL + "getuserimages"

let GET_UNREAD_MESSAGE_URL = BASE_URL + "unreadmessagenum"

let GET_VISIT_INFO_URL = BASE_URL + "visitinfo"
let VISIT_URL = BASE_URL + "visit"

//MARK: Phone Register
let SEND_SMS_CODE_URL = BASE_URL + "sendsmscode"
let REGISTER_PHONE_URL = BASE_URL + "registerphone"
let RESET_PASSWORD_URL = BASE_URL + "resetpassword"



//MARK: Activity
let GET_TOP_ACTIVITY_URL = BASE_URL + "activitytopofficial"
let GET_ACTIVITY_DETAIL_URL = BASE_URL + "getactivitydetail"
let GET_LIKED_ACTIVITY_URL = BASE_URL + "getlikeactivity"
let GET_REGISTERED_ACTIVITY_URL = BASE_URL + "getattentactivity"
let SEARCH_ACTIVITY_URL = BASE_URL + "searchactivity"
let GET_PUBLISHED_ACTIVITY_URL = BASE_URL + "getpublishactivity"
let PUBLISH_ACTIVITY_URL = BASE_URL + "publishactivity"
let CANCEL_REGISTER_ACTIVITY_URL = BASE_URL + "deletesignup"
let CANCEL_LIKE_ACTIVITY_URL = BASE_URL + "unlikeactivity"
let GET_REGISTERED_USER_URL = BASE_URL + "getactivityattentuser"
let ALLOW_USER_ACTIVITY_URL = BASE_URL + "setpassuser"
let DENY_USER_ACTIVITY_URL = BASE_URL + "deletepassuser"
let GET_ACTIVITY_STATISTIC_URL = BASE_URL + "getactivitystatistic"
let VALIDATE_ACTIVITY_USER_URL = BASE_URL + "validateactivityuser"

//MARK: Food
let GET_RECOMMENDED_FOOD_URL = BASE_URL + "getfoodcard"
let PUBLISH_FOOD_CARD_URL = BASE_URL + "publishcard"
let LIKE_FOOD_URL = BASE_URL + "likefoodcard"

let REPORT_URL = BASE_URL + "publishreport"

//MARK: PUSH

let UPLOAD_DEVICE_TOKEN_URL = BASE_URL + "uploadiosdevicetoken"

let COMMENT_TO_ACTIVITY_URL = BASE_URL + "commenttoactivity"
let GET_ACTIVITY_COMMENT_URL = BASE_URL + "getactivitycomment"
let LIKE_ACTIVITY_COMMENT_URL = BASE_URL + "likecommentact"

let LIKE_USER_URL = BASE_URL + "likeusercard"
let UNLIKE_USER_URL = BASE_URL + "unlikeusercard"
let GET_LIKED_NUMBER_URL = BASE_URL + "getlikeusernumber"

let GET_PERSONAL_IMAGES_URL = BASE_URL + "getpersonalimages"
let DELETE_POST_URL = BASE_URL + "deletepost"


let SET_TAGS_URL = BASE_URL + "settags"

let GET_TAGS_URL = BASE_URL + "gettagsbyid"


let GET_SYSTEM_NOTIFICATIONS_URL = BASE_URL + "systemnotification"
let READ_COMMUNITY_NOTIFICATION_URL = BASE_URL + "readcommunitynotification"

let ID = "ID"
let TOKEN = "TOKEN"
let APP = "WEME"

let SCREEN_HEIGHT = UIScreen.mainScreen().bounds.size.height
let SCREEN_WIDTH = UIScreen.mainScreen().bounds.size.width

//MARK - iTunes App Store
let APP_INFO_URL = "http://itunes.apple.com/cn/lookup?id=1052455890"

func sharePostURLStringForPostID(id:String) -> String{
    return DOMAIN_BASE_URL + "post_share/\(id)"
}

func thumbnailAvatarURL() -> NSURL? {
    if let id = myId {
        let url = GET_AVATAR + "\(id)_thumbnail.jpg"
        return NSURL(string: url)
    }
    else {
        return nil
    }
}

func avatarURL() -> NSURL? {
    if let id = myId {
        let url = GET_AVATAR + "\(id)"
        return NSURL(string: url)
    }
    else {
        return nil
    }
}

func thumbnailAvatarURLForID(id:String) -> NSURL {

    let url = GET_AVATAR + "\(id)_thumbnail.jpg"
    return NSURL(string: url)!
   
}

func avatarURLForID(id:String) -> NSURL {
    let url = GET_AVATAR + "\(id)"
    return NSURL(string: url)!

}

func profileBackgroundURL() -> NSURL? {
    if let id = myId {
        let url = GET_PROFILE_BACKGROUND + "\(id)"
        return NSURL(string: url)
    }
    else {
        return nil
    }

}

func profileBackgroundURLForID(id:String)->NSURL {
    let url = GET_PROFILE_BACKGROUND + "\(id)"
    return NSURL(string: url)!
}

let BACK_COLOR = UIColor.colorFromRGB(0xf0eff5)
let ICON_THEME_COLOR = UIColor.colorFromRGB(0x325eba)
let THEME_COLOR = UIColor.colorFromRGB(0x272e3c)//UIColor.colorFromRGB(0x3e5d9e)
let THEME_FOREGROUND_COLOR = UIColor.whiteColor()//UIColor.colorFromRGB(0xdcbb6e)
let THEME_COLOR_BACK = UIColor(red: 197/255.0, green: 197/255.0, blue: 218/255.0, alpha: 1.0)
let SECONDAY_COLOR =   UIColor(red: 255/255.0, green: 127/255.0, blue: 36/255.0, alpha: 1.0)
let TEXT_COLOR = UIColor(red: 81/255.0, green: 87/255.0, blue: 113/255.0, alpha: 1.0)
let PLACEHOLDER_COLOR = UIColor.colorFromRGB(0xC7C7CD)

let FEMALE_COLOR = UIColor.colorFromRGB(0xff6b8e)
let MALE_COLOR = UIColor.colorFromRGB(0x4dc3ff)

let USER_VERIFIED_COLOR = UIColor.colorFromRGB(0x90B44B)
let USER_UNVERIFIED_COLOR = UIColor.colorFromRGB(0xD0104C)


extension UIImage {
    func crop(rect:CGRect) -> UIImage{
        let rect = CGRectMake(rect.origin.x*self.scale, rect.origin.y*self.scale, rect.size.width*self.scale, rect.size.height*self.scale)
        
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, rect)
        let result = UIImage(CGImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return result
        
    }
    
    func scaleImage(size:CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}



extension UITextView {
    func resizeHeightToFit(heightConstraint: NSLayoutConstraint) {
        let attributes = [NSFontAttributeName: font!]
        
        let rect = (text! as NSString).boundingRectWithSize(CGSizeMake(frame.size.width-20, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
        heightConstraint.constant = rect.height + 20
        setNeedsLayout()
    }
}

extension UILabel {
    func resizeHeightToFit(heightConstraint: NSLayoutConstraint) {
        if let font = font{
            let attributes = [NSFontAttributeName: font]
            
            let rect = (text! as NSString).boundingRectWithSize(CGSizeMake(frame.size.width-20, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
            heightConstraint.constant = rect.height + 20
        //setNeedsLayout()
        }
    }
    
    func resizeMessageBodyLabelHeightWithSnapKit() {
        if let font = font,
            let text = text,
            let superview = superview{
            let attributes = [NSFontAttributeName: font]
            
            let rect = (text as NSString).boundingRectWithSize(CGSizeMake((superview.frame.size.width)-60, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
            //print(rect.height+20)
           // print(frame.width)
            //print(superview?.frame.width)
            snp_updateConstraints { (make) -> Void in
                make.height.equalTo(rect.height+20)
            }
        }
        //setNeedsLayout()

    }
    
    func resizeHeightWithSnapKit() {
        if let font = font {
            let attributes = [NSFontAttributeName: font]
            let rect = (text! as NSString).boundingRectWithSize(CGSizeMake(frame.size.width-20, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes, context: nil)
            snp_updateConstraints { (make) -> Void in
                make.height.equalTo(rect.height+20)
            }
        }
    }
}

extension UIImageView {
    func resizeMessageImageViewSizeWithSnapKit() {
        if
        let width = image?.size.width,
        let height = image?.size.height {
           // print("called")
        if max(width, height) > MessageSingleImageCell.IMAGE_SIZE {
           if width > height {
                    let newHeight = MessageSingleImageCell.IMAGE_SIZE
                    let newWidth = min(width * newHeight / height, (superview?.frame.size.width)! - 100)
                    snp_updateConstraints(closure: { (make) -> Void in
                        make.width.equalTo(newWidth).priorityMedium()
                        make.height.equalTo(newHeight).priorityHigh()
                    })
                
           }
            else {
                let newWidth = MessageSingleImageCell.IMAGE_SIZE
                let newHeight = height * newWidth / width
                snp_updateConstraints(closure: { (make) -> Void in
                    make.width.equalTo(newWidth).priorityHigh()
                    make.height.equalTo(newHeight).priorityMedium()
                })

            }
        }
        else {
            snp_updateConstraints(closure: { (make) -> Void in
                make.width.equalTo(width).priorityHigh()
                make.height.equalTo(height).priorityHigh()
            })

        }
    }
        else {
            snp_updateConstraints(closure: { (make) -> Void in
                make.width.equalTo(0).priorityHigh()
                make.height.equalTo(0).priorityHigh()
            })

        }
        
        
    }
}

extension UIColor {
    static func colorFromRGB(rgb:Int) -> UIColor {
        return UIColor(red: CGFloat((rgb & 0xFF0000)>>16)/255.0, green: CGFloat((rgb & 0x00FF00)>>8)/255.0, blue: CGFloat((rgb & 0x0000FF))/255.0, alpha: 1.0)
    }
    
    var red: CGFloat {
        get {
            var v:CGFloat = 0
            getRed(&v, green: nil, blue: nil, alpha: nil)
            return v
        }
    }
    
    var green: CGFloat {
        get {
            var v:CGFloat = 0
            getRed(nil, green: &v, blue: nil, alpha: nil)
            return v
        }
    }
    
    var blue: CGFloat {
        get {
            var v:CGFloat = 0
            getRed(nil, green: &v, blue: &v, alpha: nil)
            return v
        }
    }
    
    var alpha: CGFloat {
        get {
            var v:CGFloat = 0
            getRed(nil, green: nil, blue: nil, alpha: &v)
            return v
        }
    }
    
    func alpha(alpha: CGFloat) -> UIColor {
        return UIColor(red: self.red, green: self.green, blue: self.blue, alpha: alpha)
    }
    
    func white(scale: CGFloat) -> UIColor {
        return UIColor(
            red: self.red + (1.0 - self.red) * scale,
            green: self.green + (1.0 - self.green) * scale,
            blue: self.blue + (1.0 - self.blue) * scale,
            alpha: 1.0
        )
    }
    
    
}

extension CALayer {
    func appendShadow() {
        shadowColor = UIColor.blackColor().CGColor
        shadowRadius = 2.0
        shadowOpacity = 0.1
        shadowOffset = CGSize(width: 4, height: 4)
        masksToBounds = false
    }
    
    func eraseShadow() {
        shadowRadius = 0.0
        shadowColor = UIColor.clearColor().CGColor
    }
}

extension UIViewController {
    func messageAlert(msg:String) {
        let alert = UIAlertController(title: "提示", message: msg, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
        alert.view.tintColor = THEME_COLOR
        presentViewController(alert, animated: true, completion: nil)

    }
}

extension NSDate {
    func hunmanReadableString()->String {
        let d = NSDate()
        let localTimeZone = NSTimeZone.localTimeZone()
        let td = localTimeZone.secondsFromGMT
        let delta =  Int(d.timeIntervalSince1970 - timeIntervalSince1970) + td
        if delta < 3600{
            return "\(min(59, max(1,(delta/60))))分钟前"
        }
        else if delta < 24*60*60 {
            return "\(min(23,max(1,delta/(60*60))))小时前"
        }
        else if delta < 7*24*60*60 {
            return "\(min(6, max(1,delta/(24*60*60))))天前"
        }
        else if delta < 30*24*60*60 {
            return "\(min(4, max(1,delta/(7*24*60*60))))周前"
        }
        else if delta < 365*24*60*60 {
            return "\(min(11, max(1,delta/(30*24*60*60))))个月前"
        }
        else {
            return "\(delta/(365*24*60*60))年前"
        }
        
    }
}

extension NSDateFormatter {

    convenience init(withUSLocaleAndFormat format:String) {
        self.init()
        let locale = NSLocale(localeIdentifier: "en_US")
        self.locale = locale
        self.dateFormat = format

    }
    
}

extension Character
{
    func unicodeScalarCodePoint() -> UInt32
    {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
}

//
var PixelScale:CGFloat = min((UIScreen.mainScreen().bounds.width), (UIScreen.mainScreen().bounds.height))/375.0

func DP(f:CGFloat) -> CGFloat {
    return PixelScale * f
}
