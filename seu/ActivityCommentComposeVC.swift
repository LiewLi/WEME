//
//  ActivityCommentComposeVC.swift
//  WEME
//
//  Created by liewli on 2/2/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

class ActivityCommentComposeVC:ComposeMessageVC {
    
    static let COMMENT_ACTIVITY_NOTIFICATION = "COMMENT_ACTIVITY_NOTIFICATION"
    
    var activityID:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "发表活动评论"
    }
    
    override func send(sender: AnyObject?) {
        guard textView.textColor != UIColor.lightGrayColor() && textView.text.characters.count > 0  else {
            messageAlert("内容不能为空")
            return
        }
        guard self.images.count <= 9 else {
            messageAlert("请最多选择9张照片")
            return
        }
        
        if let token = token {
                request(.POST, COMMENT_TO_ACTIVITY_URL, parameters: ["token":token, "body":textView.text, "activityid":activityID], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                    if let StrongSelf = self {
                        if let d = response.result.value {
                            let json = JSON(d)
                            if json["state"].stringValue == "successful" {
                                let id = json["id"].stringValue
                                if (StrongSelf.images.count > 0) {
                                    for k in 1...StrongSelf.images.count {
                                        upload(.POST, UPLOAD_AVATAR_URL, multipartFormData: { multipartFormData in
                                            let dd = "{\"token\":\"\(token)\", \"type\":\"\(-14)\", \"commentid\":\"\(id)\", \"number\":\"\(k)\"}"
                                            let jsonData = dd.dataUsingEncoding(NSUTF8StringEncoding)
                                            let data = UIImageJPEGRepresentation((self?.imageCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: k-1, inSection: 0)) as! ImageCollectionViewCell).imageView.image!, 0.5)
                                            multipartFormData.appendBodyPart(data:jsonData!, name:"json")
                                            multipartFormData.appendBodyPart(data:data!, name:"avatar", fileName:"avatar.jpg", mimeType:"image/jpeg")
                                            }, encodingCompletion:{
                                                encodingResult in
                                                switch encodingResult {
                                                case .Success(let upload, _ , _):
                                                    upload.responseJSON { response in
                                                        if let d = response.result.value {
                                                            let j = JSON(d)
                                                            if j["state"].stringValue  == "successful" {
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                case .Failure:
                                                    break
                                                    
                                                }
                                                
                                                
                                                
                                        })
                                    }
                                }
                           
                                self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                                
                                NSNotificationCenter.defaultCenter().postNotificationName(ActivityCommentComposeVC.COMMENT_ACTIVITY_NOTIFICATION, object: nil)
                                
                            }
                            else {
                                self?.messageAlert(json["reason"].stringValue)
                            }
                        }
                        else if let _ = response.result.error {
                            self?.messageAlert("发表评论失败")
                        }
                    }
                    })
        }
    }
}
