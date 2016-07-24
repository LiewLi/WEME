//
//  Notification.swift
//  WEME
//
//  Created by liewli on 4/10/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

class NotificationVC:UIViewController {
    private var pageMenuController:CAPSPageMenu!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        automaticallyAdjustsScrollViewInsets = false
        title = "消息"
        setupUI()
    }
    
    func setupUI() {
        setupPageMenu()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        
    }
    
    
    func setupPageMenu() {
        let vc1 = MessageConversationVC()
        vc1.title = "私信"
        let vc2 = SystemNotificationVC()
        vc2.title = "回复"
        vc2.view.backgroundColor = BACK_COLOR

        let parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .SelectedMenuItemLabelColor(THEME_COLOR),
            .UnselectedMenuItemLabelColor(THEME_COLOR_BACK),
            .SelectionIndicatorColor(UIColor.colorFromRGB(0xa198d1)),
            .UseMenuLikeSegmentedControl(true),
            .SelectionIndicatorHeight(2),
            ]
        pageMenuController = CAPSPageMenu(viewControllers: [vc1, vc2], frame: CGRectMake(0, 0, view.frame.width, view.frame.height), pageMenuOptions: parameters)
        pageMenuController.view.translatesAutoresizingMaskIntoConstraints = false
        pageMenuController.view.backgroundColor = BACK_COLOR
        view.addSubview(pageMenuController.view)
        addChildViewController(pageMenuController)
        
        pageMenuController.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.bottom.equalTo(view.snp_bottom)
            make.top.equalTo(snp_topLayoutGuideBottom)
        }
        
    }

}


class SystemNotificationVC:UITableViewController {
    var notifications = [CommunityNotificationModel]()
    var refreshCont:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        tableView.backgroundColor = BACK_COLOR
        tableView.tableFooterView = UIView()
        tableView.registerClass(MessageConversationCell.self, forCellReuseIdentifier: NSStringFromClass(MessageConversationCell))
        refreshCont = UIRefreshControl()
        refreshCont.backgroundColor = BACK_COLOR
        refreshCont.addTarget(self, action: #selector(self.pullRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshCont)

        loadNotifications()
    }
    
    func pullRefresh(sender:AnyObject) {
        loadNotifications()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1*Int64(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.refreshCont.endRefreshing()
        }
    }
    
    func loadNotifications() {
        if let t = token {
            request(.POST, GET_SYSTEM_NOTIFICATIONS_URL, parameters: ["token":t], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) in
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" && json["data"] != .null else {
                        return
                    }
                    var n = [CommunityNotificationModel]()
                    if let notis = json["data"].array where notis.count > 0 {
                        for j in notis {
                            guard j["type"].stringValue == "community" else {
                                continue
                            }
                            do {
                                let c = try MTLJSONAdapter.modelOfClass(CommunityNotificationModel.self, fromJSONDictionary: j["content"].dictionaryObject) as!CommunityNotificationModel
                                n.append(c)
                            }
                            catch {
                                
                            }
                        }
                        
                        if n.count > 0 {
                            S.notifications = n
                            S.tableView.reloadData()
                        }
                    }
                }
            })
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return notifications.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == notifications.count - 1 ? 10 : 5
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 10 : 5
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRectZero)
        return v
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MessageConversationCell), forIndexPath: indexPath) as! MessageConversationCell
        let data = notifications[indexPath.section]
        let url = thumbnailAvatarURLForID(data.author.ID)
        cell.avatar.sd_setImageWithURL(url, placeholderImage: UIImage(named: "avatar"))
        cell.nameLabel.text = data.author.name
        cell.infoLabel.text = data.comment
        
        if data.author.gender == "男" {
            cell.gender.image  = UIImage(named: "male")
        }
        else if data.author.gender == "女" {
            cell.gender.image = UIImage(named: "female")
        }
        cell.schoolLabel.text = data.author.school
  
        
        let time = data.timestamp
        let dateFormat = NSDateFormatter(withUSLocaleAndFormat: "EE, d LLLL yyyy HH:mm:ss zzzz")
        if let date = dateFormat.dateFromString(time) {
            cell.timeLabel.text = date.hunmanReadableString()
        }
        cell.selectionStyle = .None
        cell.backgroundColor = tableView.backgroundColor
        cell.verifiedIcon.hidden = !data.author.verified
        
        cell.delegate = self
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = notifications[indexPath.section]
        readComment(data.commentID)
        let vc = PostVC()
        vc.postID = data.postID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func readComment(commentid:String) {
        if let t = token {
            request(.POST, READ_COMMUNITY_NOTIFICATION_URL, parameters: ["token":t, "commentid":commentid], encoding: .JSON).responseJSON(completionHandler: { (response) in
                
            })
        }
    }


}

extension SystemNotificationVC:MessageConversationCellDelegate {
    func didTapAvatarAtCell(cell: MessageConversationCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let data = notifications[indexPath.section]
            let vc = InfoVC()
            vc.id = data.author.ID
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


