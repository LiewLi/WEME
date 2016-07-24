//
//  MyActivity.swift
//  WE
//
//  Created by liewli on 12/27/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit

class MyActivityVC:UIViewController{
    
    private var pageMenuController:CAPSPageMenu!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        automaticallyAdjustsScrollViewInsets = false
        title = "活动"
        setupUI()
    }
    
    func setupUI() {
        setupPageMenu()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = true
        
        // navigationController?.navigationBar.setBackgroundImage(barBG, forBarMetrics: .Default)
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR//UIColor.colorFromRGB(0x104E8B)//UIColor.blackColor()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        
    }
    
    
    func setupPageMenu() {
        let vc1 = ActivityRegisteredVC()
        vc1.title = "我报名的活动"
        let vc2 = ActivityLikeVC()
        vc2.title = "我关注的活动"
        vc2.view.backgroundColor = BACK_COLOR
        let vc3 = ActivityPublishedVC()
        vc3.title = "我发布的活动"
        vc3.view.backgroundColor = BACK_COLOR
        
        let parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .SelectedMenuItemLabelColor(THEME_COLOR),
            .UnselectedMenuItemLabelColor(THEME_COLOR_BACK),
            .SelectionIndicatorColor(UIColor.colorFromRGB(0xa198d1)),
            .UseMenuLikeSegmentedControl(true),
            .SelectionIndicatorHeight(2),
            ]
        pageMenuController = CAPSPageMenu(viewControllers: [vc3, vc2, vc1], frame: CGRectMake(0, 0, view.frame.width, view.frame.height), pageMenuOptions: parameters)
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

class ActivityLikeVC:UITableViewController {
   // private var tableView:UITableView!
    
    var URL = GET_LIKED_ACTIVITY_URL
    
 
    
    private var activities = [ActivityModel]()
    
    private var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // tableView = UITableView(frame: view.frame)
        //view.addSubview(tableView)
       // tableView.delegate = self
       // tableView.dataSource = self
        tableView.backgroundColor = BACK_COLOR
        tableView.registerClass(ActivityCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityCell))
        tableView.tableFooterView = UIView()
        fetchActivityInfo()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return activities.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == activities.count - 1{
            fetchActivityInfo()
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return  section == 0 ? 10 : 5
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRectZero)
        return v
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRectZero)
        return v
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityCell), forIndexPath: indexPath) as! ActivityCell
        let data = activities[indexPath.section]
        cell.titleLabel.text = data.title
        cell.timeLabel.text = data.time
        cell.locationLabel.text = data.location
        cell.infoLabel.text = " \(data.signnumber)/\(data.capacity) "
        cell.statusLabel.text = data.passState
        cell.hostIcon.sd_setImageWithURL(thumbnailAvatarURLForID(data.authorID ?? ""), placeholderImage: UIImage(named: "avatar"))
        
        cell.selectionStyle = .None

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = activities[indexPath.section]
        let vc = ActivityInfoVC()
        vc.activityID = data.activityID
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func fetchActivityInfo() {
        if let t = token {
            request(.POST, URL, parameters: ["token":t, "page":"\(page)"], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" else {
                        return
                    }
                    do {
                        let ac = try MTLJSONAdapter.modelsOfClass(ActivityModel.self, fromJSONArray: json["result"].arrayObject) as? [ActivityModel]
                        if let a = ac {
                            let indexSets = NSMutableIndexSet()
                            var k = S.activities.count
                            for _ in a {
                                indexSets.addIndex(k++)
                            }
                            
                            if indexSets.count > 0 {
                                S.page++
                                S.activities.appendContentsOf(a)
                                S.tableView.insertSections(indexSets, withRowAnimation: .Fade)
                            }
                        }
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
            })
        }
    }
    
}

class ActivityRegisteredVC:ActivityLikeVC {
    override var URL:String {
        get {
           return GET_REGISTERED_ACTIVITY_URL
        }
        set {
            self.URL = newValue
        }
    }

}

class ActivityPublishedVC:ActivityLikeVC {
    override var URL:String {
        get {
            return GET_PUBLISHED_ACTIVITY_URL
        }
        set {
            self.URL = newValue
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityCell), forIndexPath: indexPath) as! ActivityCell
        let data = activities[indexPath.section]
        cell.titleLabel.text = data.title
        cell.timeLabel.text = data.time
        cell.locationLabel.text = data.location
        cell.infoLabel.text = " \(data.signnumber)/\(data.capacity) "
        
        cell.hostIcon.sd_setImageWithURL(thumbnailAvatarURLForID(data.authorID ?? ""), placeholderImage: UIImage(named: "avatar"))
        cell.statusLabel.text = data.status
        cell.selectionStyle = .None
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = activities[indexPath.section]
        let vc = ActivityAdminVC()
        vc.activityID = data.activityID
        navigationController?.pushViewController(vc, animated: true)
        
    }

}
