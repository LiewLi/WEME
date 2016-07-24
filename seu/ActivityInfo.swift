//
//  ActivityInfo.swift
//  WE
//
//  Created by liewli on 12/28/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit

class ActivityInfoVC:UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    var activityID:String!
    private var tableView:UITableView!
    
    private let sections = ["主办方", "活动评论", "活动详情", "人数", "时间", "地点", "备注", "报名"]
    
    private var content:[String] = ["活动评论，去留言吧"," ", " ", " ", " ", " "]
    
    private var poster:UIImageView!
    
    private var activity:ActivityModel?
    
    var sheet:IBActionSheet?
    
    let sloganLabel = DLLabel()
    var visualView:UIVisualEffectView?
    
    static let TOPIC_IMAGE_WIDTH = SCREEN_WIDTH
    static let TOPIC_IMAGE_HEIGHT = SCREEN_WIDTH * 1/2
    let imgBG = UIImageView(frame: CGRectMake(0, -ActivityInfoVC.TOPIC_IMAGE_HEIGHT, ActivityInfoVC.TOPIC_IMAGE_WIDTH, ActivityInfoVC.TOPIC_IMAGE_HEIGHT))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.whiteColor()
        tableView = UITableView(frame: view.frame)
        view.addSubview(tableView)
        tableView.backgroundColor = BACK_COLOR
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(ActivityInfoAvatarTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityInfoAvatarTableViewCell))
        tableView.registerClass(ActivityInfoTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityInfoTableViewCell))
        tableView.registerClass(ActivityInfoActionTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityInfoActionTableViewCell))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(ActivityInfoVC.TOPIC_IMAGE_HEIGHT, 0, 0, 0)
        imgBG.image = UIImage(named: "profile_background")
        tableView.addSubview(imgBG)
        
        
        sloganLabel.translatesAutoresizingMaskIntoConstraints = false
        sloganLabel.numberOfLines = 0
        sloganLabel.lineBreakMode = .ByWordWrapping
        sloganLabel.textColor = UIColor.whiteColor()
        sloganLabel.textAlignment = .Center
        sloganLabel.font = UIFont.systemFontOfSize(16)
        imgBG.addSubview(sloganLabel)
      
        sloganLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(imgBG.snp_left)
            make.right.equalTo(imgBG.snp_right)
            make.bottom.equalTo(imgBG.snp_bottom).offset(-20)
        }
        
        let action = UIBarButtonItem(image: UIImage(named: "more")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: "action:")
        action.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = action


        fetchActivityInfo()
    }
    
    func hiddenVisualView() {
        if let bounds = self.navigationController?.navigationBar.bounds {
            self.visualView?.frame = CGRectMake(0, (bounds.height - 64)-64, SCREEN_WIDTH, 64)
        }
        
        
    }
    
    func showVisualView() {
        if let bounds = self.navigationController?.navigationBar.bounds {
            self.visualView?.frame = CGRectMake(0, (bounds.height - 64), SCREEN_WIDTH, 64)
        }
       
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        visualView?.removeFromSuperview()
        sheet?.removeFromView()
    }

    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        
        if yOffset <= -ActivityInfoVC.TOPIC_IMAGE_HEIGHT{
            hiddenVisualView()
            let xOffset = (yOffset + ActivityInfoVC.TOPIC_IMAGE_HEIGHT)/2
            var rect = imgBG.frame
            rect.origin.y = yOffset
            rect.size.height = -yOffset
            rect.origin.x = xOffset
            rect.size.width = ActivityInfoVC.TOPIC_IMAGE_WIDTH + fabs(xOffset)*2
            imgBG.frame = rect
            let ratio = max(0, min((-yOffset-ActivityInfoVC.TOPIC_IMAGE_HEIGHT)/ActivityInfoVC.TOPIC_IMAGE_HEIGHT,1.0))
            
            sloganLabel.transform = CGAffineTransformMakeScale( 1+ratio, 1+ratio)
        }
            
        else if yOffset <= -64 {
            showVisualView()
            sloganLabel.transform = CGAffineTransformIdentity

            imgBG.frame = CGRectMake(0, -ActivityInfoVC.TOPIC_IMAGE_HEIGHT, ActivityInfoVC.TOPIC_IMAGE_WIDTH, ActivityInfoVC.TOPIC_IMAGE_HEIGHT)
        
            
            
        }
        else {
            showVisualView()
            sloganLabel.transform = CGAffineTransformIdentity
            imgBG.frame = CGRectMake(0, yOffset-(ActivityInfoVC.TOPIC_IMAGE_HEIGHT-64), ActivityInfoVC.TOPIC_IMAGE_WIDTH, ActivityInfoVC.TOPIC_IMAGE_HEIGHT)
            
        }
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if yOffset <= -ActivityInfoVC.TOPIC_IMAGE_HEIGHT+10{
            hiddenVisualView()
        }
        else {
            showVisualView()
        }
        
        
    }

    
    func configUI() {
        if let a = activity {
            imgBG.sd_setImageWithURL(a.poster, placeholderImage: UIImage(named: "profile_background"))
            sloganLabel.text = a.advertise
            title = a.title
            content = ["活动评论，去留言吧", a.detail, a.capacity, a.time, a.location, a.remark]
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        
        let bounds = self.navigationController?.navigationBar.bounds as CGRect!
        let blurEffect = UIBlurEffect(style: .Light)
        visualView = UIVisualEffectView(effect: blurEffect)
        visualView?.frame = CGRectMake(0, bounds.height - 64, SCREEN_WIDTH, 64)
        visualView?.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        visualView?.userInteractionEnabled = false
        navigationController?.navigationBar.insertSubview(visualView!, atIndex: 0)

        if tableView.contentOffset.y <= -ActivityInfoVC.TOPIC_IMAGE_HEIGHT {
            hiddenVisualView()
        }
        else {
            showVisualView()
        }


    }
    
    
    
    func fetchActivityInfo() {
        if let t = token {
            request(.POST, GET_ACTIVITY_DETAIL_URL, parameters: ["token":t, "activityid":activityID], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self  {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" && json["result"] != .null else {
                        return
                    }
                    
                    do {
                        S.activity = try MTLJSONAdapter.modelOfClass(ActivityModel.self, fromJSONDictionary: json["result"].dictionaryObject) as? ActivityModel
                        S.configUI()
                    }
                    catch let error as NSError{
                        print(error.localizedDescription)
                    }
                }
                })
        }
    }
    
  
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 80
        }
        else if (indexPath.section == sections.count-1) {
            return 60
        }
        else {
            let data = content[indexPath.section-1]
            let rect = (data as NSString).boundingRectWithSize(CGSizeMake(tableView.frame.size.width-40, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)], context: nil)

            return rect.height+40
        }
        
    }
 

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityInfoAvatarTableViewCell), forIndexPath: indexPath) as! ActivityInfoAvatarTableViewCell
            cell.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(activity?.authorID ?? ""), placeholderImage: UIImage(named: "avatar"))
            cell.nameLabel.text = activity?.author
            cell.infoLabel.text = activity?.school
            cell.selectionStyle = .None
            //cell.accessoryType = .DisclosureIndicator
            cell.titleInfoLabel.text = sections[indexPath.section]
            return cell
        }
        else if indexPath.section == sections.count - 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityInfoActionTableViewCell), forIndexPath: indexPath) as! ActivityInfoActionTableViewCell
         
            if let s = activity?.state where s == true {
                cell.registerButton.setTitle("取消报名[\(activity?.signnumber ?? "0")]", forState: .Normal)
                cell.registerButton.backgroundColor = THEME_COLOR_BACK
                cell.registerButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
                cell.registerButton.addTarget(self, action: "unregister:", forControlEvents: .TouchUpInside)
            }
            else {
                cell.registerButton.backgroundColor = THEME_COLOR
                cell.registerButton.setTitle("我要报名[\(activity?.signnumber ?? "0")]", forState: .Normal)
                cell.registerButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
                cell.registerButton.addTarget(self, action: "register:", forControlEvents: .TouchUpInside)

            }
            if let s = activity?.likeFlag where s == true {
                cell.likeButton.setTitle("取消关注", forState: .Normal)
                cell.likeButton.backgroundColor = THEME_COLOR_BACK
                cell.likeButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
                cell.likeButton.addTarget(self, action: "unlike:", forControlEvents: .TouchUpInside)
            }
            else {
                cell.likeButton.backgroundColor = THEME_COLOR
                cell.likeButton.setTitle("关注一下", forState: .Normal)
                cell.likeButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
                cell.likeButton.addTarget(self, action: "like:", forControlEvents: .TouchUpInside)
            }
            cell.selectionStyle = .None
            cell.titleInfoLabel.text = sections[indexPath.section]
            if let a = activity {
                cell.titleInfoLabel.text = a.needsImage ? "\(sections[indexPath.section])(报名该活动需上传生活照)" : sections[indexPath.section]
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityInfoTableViewCell), forIndexPath: indexPath) as! ActivityInfoTableViewCell
            cell.textContentLabel.text = content[indexPath.section-1]
            cell.selectionStyle  = .None
            cell.titleInfoLabel.text = sections[indexPath.section]
            if indexPath.section == 1 {
                cell.detailButton.alpha = 1.0
            }
            else {
                cell.detailButton.alpha = 0
            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if let a = activity{
                let vc = InfoVC()
                vc.id = a.authorID
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if indexPath.section == 1 {
            if let ac = self.activity {
                let vc = ActivityCommentVC()
                vc.activity = ac
                self.navigationController?.pushViewController(vc, animated: true)
            }

        }
    }
    
    func action(sender:AnyObject) {
        
        sheet = IBActionSheet(title: nil, callback: { (sheet, index) -> Void in
            if index == 0 {
                if let ac = self.activity {
                    let vc = ActivityCommentVC()
                    vc.activity = ac
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            else if index == 1 {
                let vc = ActivityQRCodeVC()
                vc.info = self.activity
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if index == 2 {
         
                let vc = ActivityStatVC()
                vc.activityID = self.activityID
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else if index == 3 {
                let alertText = AlertTextView(title: "举报", placeHolder: "犀利的写下你的举报内容吧╮(╯▽╰)╭")
                alertText.showInView(self.navigationController!.view)

            }
            }, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitlesArray: ["活动评论","活动二维码","更多活动信息", "举报",])
        sheet?.setButtonTextColor(THEME_COLOR)
        sheet?.showInView(navigationController!.view)
        
    }
    
    
    
    
    func register(sender:AnyObject) {
        if let a = activity {
            if a.needsImage {
                let vc = UpLoadImageVC()
                vc.id = a.activityID
                navigationController?.pushViewController(vc, animated: true)
            }
            else {
                if let t = token {
                    request(.POST, SIGNUP_ACTIVITY_URL, parameters: ["token":t, "activity":activityID], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                        debugPrint(response)
                        if let d = response.result.value, S = self {
                            let json = JSON(d)
                            guard json != .null && json["state"].stringValue == "successful" else {
                                let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                                hud.labelText = "错误"
                                hud.detailsLabelText = "报名失败"
                                hud.hide(true, afterDelay: 1)
                                return
                            }
                            
                            S.fetchActivityInfo()
                            let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                            hud.labelText = "报名成功"
                            hud.mode = .CustomView
                            hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                            hud.hide(true, afterDelay: 1)
                            
                        }
                        })
                }
            }
        }


    }
    
    func like(sender:AnyObject) {
        if let t = token {
            request(.POST, LIKE_ACTIVITY_URL, parameters: ["token":t, "activityid":activityID], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" else {
                        let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                        hud.labelText = "错误"
                        hud.detailsLabelText = "添加关注失败"
                        hud.hide(true, afterDelay: 1)
                        return
                    }
                    S.fetchActivityInfo()
                    let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                    hud.labelText = "添加关注成功"
                    hud.mode = .CustomView
                    hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                    hud.hide(true, afterDelay: 1)

                }
            })
        }

    }
    
    func unregister(sender:AnyObject) {
        let alert = UIAlertController(title: "提示", message: "确定取消报名么？", preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (action) -> Void in
            if let t = token {
                request(.POST, CANCEL_REGISTER_ACTIVITY_URL, parameters: ["token":t, "activityid":self.activityID], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                    debugPrint(response)
                    if let d = response.result.value, S = self {
                        let json = JSON(d)
                        guard json != .null && json["state"].stringValue == "successful" else {
                            let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                            hud.labelText = "错误"
                            hud.detailsLabelText = "取消报名失败"
                            hud.hide(true, afterDelay: 1)
                            return
                        }
                        S.fetchActivityInfo()
                        let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                        hud.labelText = "取消报名成功"
                        hud.mode = .CustomView
                        hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                        hud.hide(true, afterDelay: 1)
                        
                    }
                    
                    })
            }

        }))
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) -> Void in
            
        }))
        alert.view.tintColor = THEME_COLOR
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func unlike(sender:AnyObject) {
        if let t = token {
            request(.POST, CANCEL_LIKE_ACTIVITY_URL, parameters: ["token":t, "activityid":activityID], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" else {
                        let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                        hud.labelText = "错误"
                        hud.detailsLabelText = "取消关注失败"
                        hud.hide(true, afterDelay: 1)
                        return
                    }
                    S.fetchActivityInfo()
                    let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                    hud.labelText = "取消关注成功"
                    hud.mode = .CustomView
                    hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                    hud.hide(true, afterDelay: 1)
                    
                }
                
                })
        }

    }
    
}

class ActivityInfoActionTableViewCell:UITableViewCell {
    
    private var registerButton:UIButton!
    private var likeButton:UIButton!
    private var titleInfoLabel:UILabel!
    private var backView:UIView!
    
    func initialize() {
        
        contentView.backgroundColor = BACK_COLOR
        
        backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = BACK_COLOR
        contentView.addSubview(backView)

        
        titleInfoLabel = UILabel()
        titleInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInfoLabel.backgroundColor = BACK_COLOR
        titleInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        titleInfoLabel.textColor = UIColor.lightGrayColor()
        contentView.addSubview(titleInfoLabel)
        
        backView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(titleInfoLabel.snp_bottom).offset(5)
            make.bottom.equalTo(contentView.snp_bottom)
            backView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            backView.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        }

        
        registerButton = UIButton()
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.backgroundColor = THEME_COLOR
        registerButton.layer.cornerRadius = 4.0
        registerButton.layer.masksToBounds = true
        registerButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        backView.addSubview(registerButton)
        
        likeButton = UIButton()
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.backgroundColor = THEME_COLOR
        likeButton.layer.cornerRadius = 4.0
        likeButton.layer.masksToBounds = true
        likeButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        backView.addSubview(likeButton)
        
        titleInfoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left).offset(5)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(contentView.snp_top).offset(5)
            titleInfoLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            titleInfoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        }
        
        registerButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(backView.snp_leftMargin)
            //make.top.equalTo(titleInfoLabel.snp_bottom)
            make.centerY.equalTo(backView.snp_centerY)
        }
        
        likeButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(registerButton.snp_right).offset(10)
            make.right.equalTo(backView.snp_rightMargin)
            make.centerY.equalTo(registerButton.snp_centerY)
            make.width.equalTo(registerButton.snp_width).multipliedBy(0.5)
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


class ActivityInfoAvatarTableViewCell:UITableViewCell {
    var titleInfoLabel:UILabel!
    var avatar:UIImageView!
    var nameLabel:UILabel!
    var infoLabel:UILabel!
    var backView:UIView!
    var detailButton:UIImageView!
    
    func initialize() {
        contentView.backgroundColor = BACK_COLOR
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
        }
        titleInfoLabel = UILabel()
        titleInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInfoLabel.backgroundColor = BACK_COLOR
        titleInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        titleInfoLabel.textColor = UIColor.lightGrayColor()
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
        
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 25
        avatar.layer.masksToBounds = true
        backView.addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        nameLabel.textColor = UIColor(red: 81/255.0, green: 87/255.0, blue: 113/255.0, alpha: 1.0)
        backView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        infoLabel.textColor = UIColor(red: 81/255.0, green: 87/255.0, blue: 113/255.0, alpha: 1.0)
        backView.addSubview(infoLabel)
        
        detailButton = UIImageView(image: UIImage(named: "forward")?.imageWithRenderingMode(.AlwaysTemplate))
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        detailButton.tintColor = THEME_COLOR_BACK
        backView.addSubview(detailButton)
        
        
        titleInfoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(backView.snp_left).offset(5)
            make.right.equalTo(backView.snp_right)
            make.top.equalTo(contentView.snp_top).offset(5)
            titleInfoLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            titleInfoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        }

        
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(backView.snp_leftMargin)
            make.centerY.equalTo(backView.snp_centerY)
            //make.top.equalTo(titleInfoLabel.snp_bottom)
            make.width.height.equalTo(50)
        }
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(10)
            make.right.equalTo(detailButton.snp_left)
            make.top.equalTo(avatar.snp_top).offset(5)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
            make.right.equalTo(detailButton.snp_left)
            make.bottom.equalTo(avatar.snp_bottom).offset(-5)
        }
        
        detailButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(backView.snp_rightMargin)
            make.centerY.equalTo(backView.snp_centerY)
            make.height.width.equalTo(16)
            
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

class ActivityInfoTableViewCell:UITableViewCell {
    var titleInfoLabel:UILabel!
    var textContentLabel:UILabel!
    var backView:UIView!
    var detailButton:UIImageView!
    
    func initialize() {
        
        
        contentView.backgroundColor = BACK_COLOR
        titleInfoLabel = UILabel()
        titleInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInfoLabel.backgroundColor = BACK_COLOR
        titleInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        titleInfoLabel.textColor = UIColor.lightGrayColor()
        contentView.addSubview(titleInfoLabel)
        
        backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = UIColor.whiteColor()
        contentView.addSubview(backView)
        
        detailButton = UIImageView(image: UIImage(named: "forward")?.imageWithRenderingMode(.AlwaysTemplate))
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        detailButton.tintColor = THEME_COLOR_BACK
        backView.addSubview(detailButton)
        
        
        backView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(titleInfoLabel.snp_bottom).offset(5)
            make.bottom.equalTo(contentView.snp_bottom)
            backView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            backView.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            
        }

        
        //contentView.backgroundColor = UIColor.whiteColor()
        textContentLabel = UILabel()
        textContentLabel.translatesAutoresizingMaskIntoConstraints = false
        textContentLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        textContentLabel.textColor = UIColor(red: 81/255.0, green: 87/255.0, blue: 113/255.0, alpha: 1.0)
        textContentLabel.backgroundColor = UIColor.whiteColor()
        textContentLabel.numberOfLines = 0
        textContentLabel.lineBreakMode = .ByWordWrapping
        backView.addSubview(textContentLabel)
        
        titleInfoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left).offset(5)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(contentView.snp_top).offset(5)
            titleInfoLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            titleInfoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        }
        
        detailButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(backView.snp_rightMargin)
            make.centerY.equalTo(backView.snp_centerY)
            make.height.width.equalTo(16)
            
        }

        textContentLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(detailButton.snp_left)
            make.top.equalTo(backView.snp_top)
            make.bottom.equalTo(contentView.snp_bottom)
            textContentLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            textContentLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
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
