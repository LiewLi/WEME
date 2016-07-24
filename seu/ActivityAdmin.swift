//
//  ActivityAdmin.swift
//  WE
//
//  Created by liewli on 1/4/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

class ActivityAdminVC:UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, QRCodeReaderViewControllerDelegate  {
    
    var activityID:String!
    private var tableView:UITableView!
    
    private let sections = ["管理报名用户", "活动详情", "人数", "时间", "地点", "备注"]
    
    private var content:[String] = [" ", " ", " ", " ", " "]
    
    private var poster:UIImageView!
    
    private var activity:ActivityModel?
    
    let sloganLabel = DLLabel()
    var visualView:UIVisualEffectView?
    
     var sheet:IBActionSheet?
    
    static let TOPIC_IMAGE_WIDTH = SCREEN_WIDTH
    static let TOPIC_IMAGE_HEIGHT = SCREEN_WIDTH * 1/2
    let imgBG = UIImageView(frame: CGRectMake(0, -ActivityInfoVC.TOPIC_IMAGE_HEIGHT, ActivityInfoVC.TOPIC_IMAGE_WIDTH, ActivityInfoVC.TOPIC_IMAGE_HEIGHT))
    
    lazy var reader: QRCodeReaderViewController = {
        let builder = QRCodeViewControllerBuilder { builder in
            builder.reader          = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
            builder.showTorchButton = true
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.whiteColor()
        tableView = UITableView(frame: view.frame)
        view.addSubview(tableView)
        tableView.backgroundColor = BACK_COLOR
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(ActivityInfoTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityInfoTableViewCell))
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
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
            content = [a.detail, a.capacity, a.time, a.location, a.remark]
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
            return 44
        }
        else {
            let data = content[indexPath.section-1]
            let rect = (data as NSString).boundingRectWithSize(CGSizeMake(tableView.frame.size.width-40, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)], context: nil)
            
            return rect.height+40
        }
    
        
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
            cell.accessoryType = .DisclosureIndicator
            cell.selectionStyle = .None
            cell.textLabel?.text = "管理报名用户[\(activity?.signnumber ?? "0")]"
            cell.textLabel?.textColor = UIColor(red: 81/255.0, green: 87/255.0, blue: 113/255.0, alpha: 1.0)
            cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityInfoTableViewCell), forIndexPath: indexPath) as! ActivityInfoTableViewCell
            cell.textContentLabel.text = content[indexPath.section-1]
            cell.selectionStyle  = .None
            cell.titleInfoLabel.text = sections[indexPath.section]
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if let a = activity{
                let vc = ActivityAdminUserVC()
                vc.activityID = a.activityID
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func action(sender:AnyObject) {
        sheet = IBActionSheet(title: nil, callback: { (sheet, index) -> Void in
            if index == 0 {
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
            }, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitlesArray: ["扫描二维码验证参与活动用户"])
        sheet?.setButtonTextColor(THEME_COLOR)
        sheet?.showInView(navigationController!.view)
        
    }
    
    func valid() {
        messageAlert("已获得活动邀请")
    }
    
    func invalid() {
        messageAlert("未获得活动邀请")
    }
    
    func validateUser(id:String){
        if let t = token {
            request(.POST, VALIDATE_ACTIVITY_USER_URL, parameters: ["token":t, "userid":id, "activityid":activityID], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" && json["result"].stringValue == "1" else {
                        S.invalid()
                        return
                    }
                    S.valid()
                }
            })
        }
    }
    
    func reader(reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        self.dismissViewControllerAnimated(true, completion: { [weak self] in
            if let url = NSURL(string: result.value) where url.scheme == "weme"{
                if let h = url.host where h == "user",
                    let com = url.pathComponents where com.count == 2 {
                    self?.validateUser(com[1])
                }
                else {
                    self?.messageAlert("无效WEME用户二维码")
                }
            }
            else {
                self?.messageAlert("无效WEME用户二维码")
            }
        })
        
    }
    
    func readerDidCancel(reader: QRCodeReaderViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
}

class ActivityAdminUserVC:UITableViewController {
    var activityID:String!
    
    var users = [PersonModel]()
    
    var currentPage = 1
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.alpha = 1.0
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "管理报名用户"
        view.backgroundColor = BACK_COLOR
        tableView.registerClass(ActivityAdminTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityAdminTableViewCell))
        tableView.registerClass(ActivityAdminImageTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityAdminImageTableViewCell))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .None
        fetchRegisteredUser()
        
    }
    
    func fetchRegisteredUser() {
        if let t = token {
            request(.POST, GET_REGISTERED_USER_URL, parameters: ["token":t, "activityid":activityID, "page":"\(currentPage)"], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null  && json["state"].stringValue == "successful" else {
                        return
                    }
                    
                    do {
                        let u = try MTLJSONAdapter.modelsOfClass(PersonModel.self, fromJSONArray: json["result"].arrayObject) as? [PersonModel]
                        if let uu = u where uu.count > 0 {
                            let indexSets = NSMutableIndexSet()
                            var k = S.users.count
                            for _ in uu {
                                indexSets.addIndex(k++)
                            }
                            S.users.appendContentsOf(uu)
                            S.currentPage++
                            S.tableView.beginUpdates()
                            S.tableView.insertSections(indexSets, withRowAnimation: .Right)
                            S.tableView.endUpdates()
                        }
                    }
                    catch {
                        print(error)
                    }
                }
            })
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     
        let u = users[indexPath.section]
        if u.activityImages.count  == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityAdminTableViewCell), forIndexPath: indexPath) as! ActivityAdminTableViewCell
            cell.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(u.ID), placeholderImage: UIImage(named: "avatar"))
            cell.nameLabel.text = u.name
            cell.infoLabel.text  = u.school
            if u.activityStatus {
                cell.actionButton.backgroundColor = THEME_COLOR_BACK
                cell.actionButton.setTitle(" 拒绝参加活动 ", forState: .Normal)
                cell.actionButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
                cell.actionButton.addTarget(self, action: "action:", forControlEvents: .TouchUpInside)
            }
            else {
                cell.actionButton.backgroundColor = THEME_COLOR
                cell.actionButton.setTitle(" 允许参加活动 ", forState: .Normal)
                cell.actionButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
                cell.actionButton.addTarget(self, action: "action:", forControlEvents: .TouchUpInside)
            }
            cell.actionButton.tag = indexPath.section
            cell.selectionStyle = .None
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityAdminImageTableViewCell), forIndexPath: indexPath) as! ActivityAdminImageTableViewCell
            if cell.imgController == nil {
                cell.imgController = ActivityImageController()
            }
            cell.imgController.imageURLs = u.activityImageThumbnails as! [NSURL]
            cell.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(u.ID), placeholderImage: UIImage(named: "avatar"))
            cell.nameLabel.text = u.name
            cell.infoLabel.text  = u.school
            if u.activityStatus {
                cell.actionButton.backgroundColor = THEME_COLOR_BACK
                cell.actionButton.setTitle(" 拒绝参加活动 ", forState: .Normal)
                cell.actionButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
                cell.actionButton.addTarget(self, action: "action:", forControlEvents: .TouchUpInside)
            }
            else {
                cell.actionButton.backgroundColor = THEME_COLOR
                cell.actionButton.setTitle(" 允许参加活动 ", forState: .Normal)
                cell.actionButton.removeTarget(nil, action: nil, forControlEvents: .TouchUpInside)
                cell.actionButton.addTarget(self, action: "action:", forControlEvents: .TouchUpInside)
            }
            cell.actionButton.tag = indexPath.section
            cell.selectionStyle = .None
            cell.delegate = self
            return cell
        }
    }
    
    func allow(uid:String, atIndex index:Int) {
        if let t = token {
            let userlist = [uid]
            request(.POST, ALLOW_USER_ACTIVITY_URL, parameters: ["token":t, "activityid":activityID, "userlist":userlist], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" else {
                        return
                    }
                    if index < S.users.count {
                        S.users[index].activityStatus = true
                        S.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: index)], withRowAnimation: .None)
                    }
                }
            })
        }
    }
    
    func deny(uid:String, atIndex index:Int) {
        if let t = token {
            let userlist = [uid]
            request(.POST, DENY_USER_ACTIVITY_URL, parameters: ["token":t, "activityid":activityID, "userlist":userlist], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                    if let d = response.result.value, S = self {
                        let json = JSON(d)
                        guard json != .null && json["state"].stringValue == "successful" else {
                            return
                        }
                        if index < S.users.count {
                            S.users[index].activityStatus = false
                            S.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: index)], withRowAnimation: .None)
                        }

                    }
                })
        }

    }
    
    func action(sender:UIButton) {
        if sender.tag < users.count {
            let u = users[sender.tag]
            if u.activityStatus {
                deny(u.ID, atIndex:sender.tag)
            }
            else {
                allow(u.ID, atIndex:sender.tag)
            }
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == users.count - 1 {
            fetchRegisteredUser()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let u = users[indexPath.section]
        let vc = InfoVC()
        vc.id = u.ID
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let u = users[indexPath.section]
        if u.activityImages.count  == 0 {
            return 60
        }
        else {
            return 60 + TopicImageCollectionViewCell.SIZE + 20
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 10))
        v.backgroundColor = BACK_COLOR
        return v
    }
    
}

extension ActivityAdminUserVC:ActivityImageCellDelegate {
    func didTapImageCollectionViewAtCell(cell: ActivityAdminImageTableViewCell, atIndexPath index: NSIndexPath) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let data = users[indexPath.section]
            let agrume = Agrume(imageURLs: data.activityImages as! [NSURL], startIndex: index.section)
            agrume.showFrom(self)
        }
    }
}

class ActivityAdminTableViewCell:UITableViewCell {
    
    var avatar:UIImageView!
    var nameLabel:UILabel!
    var infoLabel:UILabel!
    var actionButton:UIButton!
    
    func initialize() {
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 20
        avatar.layer.masksToBounds = true
        contentView.addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        nameLabel.textColor = TEXT_COLOR
        contentView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        infoLabel.textColor = TEXT_COLOR
        contentView.addSubview(infoLabel)
        
        actionButton = UIButton()
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.backgroundColor = THEME_COLOR
        actionButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        actionButton.layer.cornerRadius = 4.0
        actionButton.layer.masksToBounds = true
        contentView.addSubview(actionButton)
        
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            //make.top.equalTo(contentView.snp_topMargin)
            make.centerY.equalTo(contentView.snp_centerY)
            make.width.height.equalTo(40)
        }
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(5)
            make.top.equalTo(avatar.snp_top)
            make.right.equalTo(contentView.snp_rightMargin)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(5)
            make.bottom.equalTo(avatar.snp_bottom)
            make.right.equalTo(contentView.snp_rightMargin)
        }
        
        actionButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(contentView.snp_rightMargin)
            make.centerY.equalTo(contentView.snp_centerY)
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


class ActivityImageController:NSObject {
    private(set) var imageURLs = [NSURL]() {
        didSet {
            cell?.imageCollectionView.reloadData()
        }
    }
    
    private weak var cell:ActivityAdminImageTableViewCell?

}

extension ActivityImageController:UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(TopicImageCollectionViewCell), forIndexPath: indexPath) as! TopicImageCollectionViewCell
        cell.imgView.sd_setImageWithURL(imageURLs[indexPath.item])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: TopicImageCollectionViewCell.SIZE , height: TopicImageCollectionViewCell.SIZE)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        cell?.delegate?.didTapImageCollectionViewAtCell(cell!, atIndexPath: indexPath)
    }
    
}

protocol ActivityImageCellDelegate:class {
    func didTapImageCollectionViewAtCell(cell:ActivityAdminImageTableViewCell, atIndexPath:NSIndexPath)
}

class ActivityAdminImageTableViewCell:UITableViewCell {
    
    var avatar:UIImageView!
    var nameLabel:UILabel!
    var infoLabel:UILabel!
    var actionButton:UIButton!
    
    weak var delegate:ActivityImageCellDelegate?
    
    
    var imageCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(TopicImageCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TopicImageCollectionViewCell))
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
    }()
    
    var imgController:ActivityImageController! {
        didSet {
            imgController.cell = self
            imageCollectionView.dataSource = imgController
            imageCollectionView.delegate = imgController
        }
    }

    
    func initialze() {
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 20
        avatar.layer.masksToBounds = true
        contentView.addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        nameLabel.textColor = TEXT_COLOR
        contentView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        infoLabel.textColor = TEXT_COLOR
        contentView.addSubview(infoLabel)
        
        actionButton = UIButton()
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.backgroundColor = THEME_COLOR
        actionButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        actionButton.layer.cornerRadius = 4.0
        actionButton.layer.masksToBounds = true
        contentView.addSubview(actionButton)
        
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageCollectionView)
        
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.top.equalTo(contentView.snp_topMargin)
            //make.centerY.equalTo(contentView.snp_centerY)
            make.width.height.equalTo(40)
        }
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(5)
            make.top.equalTo(avatar.snp_top)
            make.right.equalTo(contentView.snp_rightMargin)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(5)
            make.bottom.equalTo(avatar.snp_bottom)
            make.right.equalTo(contentView.snp_rightMargin)
        }
        
        actionButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(contentView.snp_rightMargin)
            make.centerY.equalTo(avatar.snp_centerY)
        }
        
        imageCollectionView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(infoLabel.snp_bottom).offset(5)
            make.height.greaterThanOrEqualTo(TopicImageCollectionViewCell.SIZE+20)
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
        }


    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialze()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}