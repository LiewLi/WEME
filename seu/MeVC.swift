//
//  MeVC.swift
//  牵手东大
//
//  Created by liewli on 12/2/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit


class ProfileVC:UIViewController, UITableViewDataSource, UITableViewDelegate,QRCodeReaderViewControllerDelegate {
    var tableView:UITableView!
    
    let items1 = ["好友", "消息", "活动", "扫码", "附近"]
    let items2 = ["附近", "发现", "美食"]//, "心声", "发现"]
    let imgs1 = ["follow", "message", "time", "qrcode_scan", "location"]
    let imgs2 = [ "location", "discovery","discover_food"]//, "audio", "discovery"]
    var more = ["设置"]
    
    var personInfo:PersonModel?
    
    var unreadMessage:String?
    
    lazy var reader: QRCodeReaderViewController = {
        let builder = QRCodeViewControllerBuilder { builder in
            builder.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
            builder.showTorchButton = true
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    func reader(reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        self.dismissViewControllerAnimated(true, completion: { [weak self] in
            if let url = NSURL(string: result.value) where url.scheme == "weme"{
                if let h = url.host where h == "user",
                    let com = url.pathComponents where com.count == 2 {
                        //self?.validateUser(com[1])
                        let vc = InfoVC()
                        vc.id = com[1]
                        self?.navigationController?.pushViewController(vc, animated: true)
                }
                else if let h = url.host where h == "activity",
                    let com = url.pathComponents where com.count == 2 {
                        if let vc = (UIApplication.sharedApplication().delegate as! AppDelegate).window?.rootViewController as? HomeVC {
                            vc.selectedIndex = 1
                            if let nav = vc.viewControllers?[1] as? UINavigationController {
                                let vc = ActivityInfoVC()
                                vc.activityID = com[1]
                                nav.pushViewController(vc, animated: true)
                            }
                            
                        }
                }
                else {
                    self?.messageAlert("无效WEME用户二维码")
                }
            }
            else {
                if let url = NSURL(string: result.value) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            })
        
    }
    
    
    func readerDidCancel(reader: QRCodeReaderViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "个人"
        tableView = UITableView(frame: view.frame)
        view.addSubview(tableView)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        tableView.registerClass(MeTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(MeTableViewCell))
        tableView.registerClass(MeItemTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(MeItemTableViewCell))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.colorFromRGB(0xefeff4)
        navigationController?.navigationBar.barStyle = .Black
        tableView.separatorStyle = .None
        fetchNameInfo()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "editInfo:", name: EDIT_INFO_NOTIFICATION, object: nil)
    }
    

    
   
    
    func editInfo(sender:AnyObject) {
        fetchNameInfo()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
      
        
        fetchUnreadMessage()
        
        tabBarController?.tabBar.hidden = false
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.alpha = 1.0
        
    }
    
    func fetchUnreadMessage() {
        if let t = token {
            request(.POST, GET_UNREAD_MESSAGE_URL, parameters: ["token":t], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" && json["number"] != .null else {
                        return
                    }
                    
                    S.unreadMessage = json["number"].stringValue
                    S.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: .None)
                }
               
            })
        }
    }
    
    
    func fetchNameInfo() {
        if let t = token {
            request(.POST, GET_PROFILE_INFO_URL, parameters: ["token":t], encoding: .JSON).responseJSON{ [weak self](response) -> Void in
                if let d = response.result.value,S = self {
                    let json = JSON(d)
                    guard json["state"] == "successful" && json["name"] != .null else{
                        return
                    }
                    do {
                        S.personInfo = try MTLJSONAdapter.modelOfClass(PersonModel.self, fromJSONDictionary: json.dictionaryObject) as? PersonModel
                        S.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
                        ProfileCache.sharedCache.saveProfile(S.personInfo)
                    }
                    catch {
                        print(error)
                    }
                   
                }
                else if let S = self {
                     ProfileCache.sharedCache.loadProfileWithCompletionBlock({ [weak S](info) -> Void in
                        if let p = info , SS = S{
                            SS.personInfo = p
                            SS.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
                        }
                     })
                    
                }
            }

        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MeTableViewCell), forIndexPath: indexPath) as! MeTableViewCell
            cell.avatar.sd_setImageWithURL(thumbnailAvatarURL(), placeholderImage: UIImage(named: "avatar"))
            cell.nameLabel.text = personInfo?.name ?? " "
            cell.accessoryType = .DisclosureIndicator
            cell.selectionStyle = .None
            cell.qrcode.addTarget(self, action: "qrcodeTapped:", forControlEvents: .TouchUpInside)
            return cell
        }
        else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MeItemTableViewCell), forIndexPath: indexPath) as! MeItemTableViewCell
            
                cell.icon.image = UIImage(named: imgs1[indexPath.row])?.imageWithRenderingMode(.AlwaysTemplate)
                cell.icon.tintColor = THEME_COLOR_BACK
                cell.itemLabel.text = items1[indexPath.row]
                if indexPath.row == 1 {
                    if let _ = unreadMessage {
                        if let num = Int(unreadMessage!) where num > 0 {
                            let badge = CustomBadge(string: "\(num)")
                            badge.badgeStyle.badgeFontType = BadgeStyleFontType.init(rawValue: 1)
                            badge.badgeScaleFactor = 1.2
                            cell.accessoryView = badge
                        }
                        else {
                            cell.accessoryView = nil
                        }
                    }
                    else {
                        cell.accessoryView = nil
                    }
                }
                
                if indexPath.row == items1.count - 1 {
                    cell.seperator.hidden = true
                }
            cell.accessoryType = .DisclosureIndicator
            cell.selectionStyle = .None
            cell.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0)
            
            return cell
                
        }
//        else if indexPath.section == 2 {
//            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MeItemTableViewCell), forIndexPath: indexPath) as! MeItemTableViewCell
//            
//            cell.icon.image = UIImage(named: imgs2[indexPath.row])?.imageWithRenderingMode(.AlwaysTemplate)
//            cell.icon.tintColor = THEME_COLOR_BACK
//            cell.itemLabel.text = items2[indexPath.row]
//            if indexPath.row == items2.count - 1 {
//                cell.seperator.hidden = true
//            }
//            cell.accessoryType = .DisclosureIndicator
//            cell.selectionStyle = .None
//            cell.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0)
//            
//            return cell
//
//        }
        else {
             let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MeItemTableViewCell), forIndexPath: indexPath) as! MeItemTableViewCell
              cell.icon.image = UIImage(named: "setting")?.imageWithRenderingMode(.AlwaysTemplate)
               cell.itemLabel.text = "设置"
                cell.seperator.hidden = true
            
            cell.accessoryType = .DisclosureIndicator
            cell.selectionStyle = .None
            cell.separatorInset = UIEdgeInsetsMake(0, 50, 0, 0)
            return cell
        }
    }
    
    func qrcodeTapped(sender:AnyObject) {
        let vc = MyQRCodeVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return  1
        }
        else if section == 1{
            return items1.count
        }
//        else if section == 2{
//            return items2.count
//        }
        else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if  indexPath.section == 0 {
            return 70
        }
        else {
            return 46
        }
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section < 2 ? 20 : 1
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRectZero)
        return v
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0  {
            if let id = myId {
                let vc = InfoVC()
                vc.id = id
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.section == 2 {
            navigationController?.pushViewController(SettingVC(), animated: true)
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            navigationController?.pushViewController(ContactsVC(), animated: true)
        }
        else if indexPath.section == 1 && indexPath.row == 1 {
            navigationController?.pushViewController(NotificationVC(), animated: true)
        }
        else if indexPath.section == 1 && indexPath.row == 2 {
            navigationController?.pushViewController(MyActivityVC(), animated: true)
        }
        else if indexPath.section == 1 && indexPath.row == 3 {
            scanCode()
        }
        else if indexPath.section == 1 && indexPath.row == 4{
            navigationController?.pushViewController(NearByVC(), animated: true)
        }
//        else if indexPath.section == 2 && indexPath.row == 1 {
//            navigationController?.pushViewController(CardPeopleVC(), animated: true)
//        }
//        else if indexPath.section == 2 && indexPath.row == 2 {
//            navigationController?.pushViewController(CardFoodVC(), animated: true)
//        }
    }
    
    func scanCode() {
        if QRCodeReader.supportsMetadataObjectTypes() {
            self.reader.modalPresentationStyle = .FormSheet
            self.reader.delegate               = self
            
            self.reader.completionBlock = { (result: QRCodeReaderResult?) in
                if let result = result {
                    print("Completion with result: \(result.value) of type \(result.metadataType)")
                }
            }
            
            self.presentViewController(self.reader, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "提示", message: "这台设备不支持二维码扫描", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
}



class MeTableViewCell:UITableViewCell {
    var avatar:UIImageView!
    var nameLabel:UILabel!
    var qrcode:UIButton!
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    func initialize() {
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 25
        avatar.layer.masksToBounds = true
        contentView.addSubview(avatar)
        
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
           // make.top.equalTo(contentView.snp_topMargin)
            make.centerY.equalTo(contentView.snp_centerY)
            make.height.width.equalTo(50)
        }
        
        nameLabel = UILabel()
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = UIColor.colorFromRGB(0x636363)
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(10)
            make.right.equalTo(contentView.snp_rightMargin)
            make.centerY.equalTo(avatar.snp_centerY)
        }
        
        qrcode = UIButton()
        qrcode.setBackgroundImage(UIImage(named: "qrcode")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        qrcode.tintColor = THEME_COLOR

        qrcode.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(qrcode)
        qrcode.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(contentView.snp_rightMargin)
            make.centerY.equalTo(contentView.snp_centerY)
            make.height.width.equalTo(25)
        }
    }
}

class MeItemTableViewCell:UITableViewCell {
    var icon:UIImageView!
    var itemLabel:UILabel!
    var seperator:UIView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    func initialize() {
        icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        //icon.layer.cornerRadius = 15
        icon.layer.masksToBounds = true
        icon.tintColor = THEME_COLOR_BACK
        contentView.addSubview(icon)
        
        itemLabel = UILabel()
        itemLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(itemLabel)
        itemLabel.textColor = UIColor.colorFromRGB(0x636363)
        
        seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(seperator)
        seperator.backgroundColor = BACK_COLOR
        
        icon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            // make.top.equalTo(contentView.snp_topMargin)
            make.centerY.equalTo(contentView.snp_centerY)
            make.height.width.equalTo(22)
        }
        

        itemLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(icon.snp_right).offset(10)
            make.right.equalTo(contentView.snp_rightMargin)
            make.centerY.equalTo(icon.snp_centerY)
        }
        
        seperator.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(itemLabel.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(contentView.snp_bottom).offset(-1)
            make.height.equalTo(1)
        }

    }
    
}