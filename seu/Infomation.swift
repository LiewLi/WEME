//
//  Infomation.swift
//  WEME
//
//  Created by liewli on 7/23/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import Foundation

class InfomationVC:UITableViewController, QZTabBarControllerChildControllerProtocol {
    var id:String!
    private let infos = ["姓名", "年龄", "学校", "学历", "专业", "家乡", "QQ", "微信", "标签"]
    private let sectionRows = [2, 3, 1, 2, 1]
    
    
    var tags = [String]()
    var info:PersonModel?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        tableView.registerClass(InfoTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(InfoTableViewCell))
        tableView.registerClass(TagTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TagTableViewCell))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .None
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(editInfo(_:)), name: EDIT_INFO_NOTIFICATION, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.editTags(_:)), name: EditTagViewController.EDIT_TAG_NOTIFICATION, object: nil)

        
        self.fetchInfo()
        self.fetchTags()

    }
    
    func editTags(sender:NSNotification) {
        fetchTags()
    }
    
    func editInfo(sender:NSNotification) {
        if let ID = myId where ID == id {
            fetchInfo()
        }
    }
    

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.item == infos.count-1 {
            let b = ("历" as NSString).boundingRectWithSize(CGSizeMake(self.tableView.frame.size.width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)], context: nil)
            return b.height + cellHeight(self.tags, inBoundingSize:CGSizeMake(self.tableView.frame.size.width, CGFloat.max)) + 10
        }
        else {
            let rect = ("历" as NSString).boundingRectWithSize(CGSizeMake(tableView.frame.width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)], context: nil)
            return ( indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 5 || indexPath.row == 6) ? rect.height + 40 : 40
            
        }

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ID = myId where ID != id {
            return infos.count + 1
        }
        else {
            return infos.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < infos.count {
            if (indexPath.row == infos.count-1) {
                let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TagTableViewCell), forIndexPath: indexPath) as! TagTableViewCell
                if cell.tagManager == nil {
                    cell.tagManager = TagManager()
                }
                cell.titleLabel.text = "#我的标签"
                cell.tagManager?.tags = self.tags
                cell.selectionStyle = .None
                return cell
            }
            let  cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(InfoTableViewCell), forIndexPath: indexPath) as! InfoTableViewCell
            cell.titleLabel.text = title
            cell.infoLabel.text = infos[indexPath.row]
            if indexPath.row == 0 {
                cell.titleLabel.text = "  基本信息"
                let name = info?.name ?? ""
                if let v = info?.verified where v == true{
                    let attr = "\(name)(已认证)"
                    let attrStr = NSMutableAttributedString(string: attr)
                    attrStr.addAttributes([NSForegroundColorAttributeName:USER_VERIFIED_COLOR, NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)], range: NSMakeRange(name.characters.count, 5))
                    cell.detailLabel.attributedText = attrStr
                }
                else if let v = info?.verified where v == false {
                    let attr = "\(name)(未认证)"
                    let attrStr = NSMutableAttributedString(string: attr)
                    attrStr.addAttributes([NSForegroundColorAttributeName:USER_UNVERIFIED_COLOR, NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)], range: NSMakeRange(name.characters.count, 5))
                    cell.detailLabel.attributedText = attrStr
                }
            }
            else if indexPath.row == 1 {
                cell.titleLabel.text = ""
                if let id = myId, pid = info?.ID where id == pid {
                    cell.infoLabel.text = "生日"
                    cell.detailLabel.text = info?.birthday ?? ""
                }
                else {
                    cell.detailLabel.text = info?.birthFlag ?? ""
                }
                
            }
                
            else  if indexPath.row == 2 {
                cell.titleLabel.text = "  学校信息"
                cell.detailLabel.text = info?.school ?? ""
            }
            else if indexPath.row == 3 {
                cell.titleLabel.text = ""
                cell.detailLabel.text = info?.degree ?? ""
            }
            else if indexPath.row == 4 {
                cell.titleLabel.text = ""
                cell.detailLabel.text = info?.department ?? ""
            }
                
            else if indexPath.row ==  5{
                cell.titleLabel.text = "  家乡信息"
                cell.detailLabel.text = info?.hometown ?? ""
            }
                
            else if indexPath.row == 6 {
                cell.titleLabel.text = "  联系方式"
                cell.detailLabel.text = info?.qq ?? ""
            }
            else {
                cell.titleLabel.text = ""
                cell.detailLabel.text = info?.wechat ?? ""
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
            let addFriendButton = UIButton()
            cell.backgroundColor = BACK_COLOR
            addFriendButton.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(addFriendButton)
            addFriendButton.snp_makeConstraints(closure: { (make) -> Void in
                //make.centerX.equalTo(cell.contentView.snp_centerX)
                make.centerY.equalTo(cell.contentView.snp_centerY)
                make.height.equalTo(cell.contentView.snp_height).offset(-10)
                make.left.equalTo(cell.contentView.snp_leftMargin)
            })
            
            let messageButton = UIButton()
            messageButton.backgroundColor = THEME_COLOR
            messageButton.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(messageButton)
            messageButton.snp_makeConstraints(closure: { (make) -> Void in
                make.centerY.equalTo(cell.contentView.snp_centerY)
                make.right.equalTo(cell.contentView.snp_rightMargin)
                make.left.equalTo(addFriendButton.snp_right).offset(5)
                make.width.equalTo(addFriendButton.snp_width).multipliedBy(0.5)
                make.height.equalTo(addFriendButton.snp_height)
            })
            messageButton.layer.cornerRadius = 4.0
            messageButton.layer.masksToBounds = true
            
            messageButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            messageButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
            messageButton.addTarget(self, action: #selector(message(_:)), forControlEvents: .TouchUpInside)
            
            var gg = ""
            if let g = info?.gender {
                if g == "男" {
                    gg = "他"
                }
                else if g == "女" {
                    gg = "她"
                }
            }
            
            messageButton.setTitle("私信\(gg)", forState: .Normal)
            
            if let p = info?.followFlag where p == "1" {
                addFriendButton.addTarget(self, action: #selector(unfollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                addFriendButton.setTitle("已关注\(gg), 取消关注", forState: .Normal)
            }
            else if let p = info?.followFlag where p == "2" {
                addFriendButton.setTitle("\(gg)已关注你, 去关注\(gg)吧", forState: .Normal)
                addFriendButton.addTarget(self, action: #selector(addFriend(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
            else if let p = info?.followFlag where p == "3" {
                addFriendButton.addTarget(self, action: #selector(unfollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                addFriendButton.setTitle("已互相关注, 取消关注", forState: .Normal)
            }
            else {
                addFriendButton.addTarget(self, action: #selector(addFriend(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                addFriendButton.setTitle("添加关注", forState: .Normal)
            }
            
            addFriendButton.layer.cornerRadius = 4.0
            addFriendButton.layer.masksToBounds = true
            
            addFriendButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            addFriendButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
            addFriendButton.backgroundColor = THEME_COLOR
            return cell
        }

    }
    
    func message(sender:AnyObject) {
        let vc = ComposeMessageVC()
        vc.recvID = self.id
        let nav = UINavigationController(rootViewController: vc)
        self.presentViewController(nav, animated: true, completion: nil)
    }

    
    func addFriend(sender:AnyObject) {
        if let t = token, id = info?.ID{
            request(.POST, FOLLOW_URL, parameters: ["token":t, "id":id], encoding: .JSON).responseJSON{ [weak self](response) -> Void in
                //debugprint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" else{
                        let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                        hud.mode = .Text
                        hud.labelText = "提示"
                        hud.detailsLabelText = json["reason"].stringValue
                        hud.hide(true, afterDelay: 1)
                        return
                    }
                    
                    let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                    hud.labelText = "添加关注成功"
                    hud.mode = .CustomView
                    hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                    hud.hide(true, afterDelay: 1)

                    S.fetchInfo()
                    
                }
            }
            
        }
        
    }
    
    func unfollow(sender: AnyObject) {
        let alert = UIAlertController(title: "提示", message: "确定取消关注么？", preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (action) -> Void in
            if let token = token, id = self.info?.ID {
                request(.POST, UNFOLLOW_URL, parameters: ["token":token, "id":id], encoding: .JSON).responseJSON{ [weak self](response) -> Void in
                    //debugprint(response)
                    if let d = response.result.value, S = self {
                        let json = JSON(d)
                        if json["state"].stringValue == "successful"{
                            let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                            hud.labelText = "取消关注成功"
                            hud.mode = .CustomView
                            hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                            hud.hide(true, afterDelay: 1)
                            

                            S.fetchInfo()
                            
                        }
                        else {
                            S.messageAlert("取消关注失败")
                            return
                        }
                    }
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) -> Void in
            
        }))
        alert.view.tintColor = THEME_COLOR
        presentViewController(alert, animated: true, completion: nil)
        
    }

    
    private func cellHeight(tags:[String], inBoundingSize S:CGSize)->CGFloat {
        var hx:CGFloat = 0
        var hy:CGFloat = 0
        var tmp:CGFloat = 0
        for t in tags {
            let b = (t as NSString).boundingRectWithSize(CGSizeMake(S.width-30, S.height), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)], context: nil)

            if hx + b.size.width + 10   > (S.width-20) {
                hx = b.size.width + 10 + 10
                hy += tmp == 0 ? 0 : tmp + 10 + 10

            }
            else {
                hx += b.size.width + 10 + 10
            }
            tmp = b.size.height
        }
        return hy + tmp + 10 + 20
    }
    
    
    
    private func fetchInfo() {
        if let t = token {
            request(.POST, GET_FRIEND_PROFILE_URL, parameters: ["token": t, "id":id], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" && json.dictionaryObject != nil else {
                        return
                    }
                    
                    do {
                        let p = try MTLJSONAdapter.modelOfClass(PersonModel.self, fromJSONDictionary: json.dictionaryObject!) as! PersonModel
                        S.info = p
                        S.tableView.reloadData()
                        
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
                else if let S = self {
                    ProfileCache.sharedCache.loadProfileWithCompletionBlock({ [weak S](info) -> Void in
                        if let p = info, SS = S {
                            SS.info = p
                            SS.tableView.reloadData()

                        }
                    })
                }
                })
        }
        
        
    }
    
    private func fetchTags() {
        if let t = token{
            let dic = ["token":t, "userid":id]
            request(.POST, GET_TAGS_URL, parameters: dic, encoding: .JSON).responseJSON(completionHandler: { [weak self](response) in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" && json["result"]["tags"]["custom"] != .null else {
                        return
                    }
                    if let tt = json["result"]["tags"]["custom"].array {
                        var s = [String]()
                        for ttt in tt {
                            s.append(ttt.stringValue)
                        }
                        S.tags = s
                        
                        S.tableView.reloadData()
                        
                    }
                }
                })
        }
    }
    
    func targetScrollView() -> UIScrollView {
        return self.tableView
    }

}