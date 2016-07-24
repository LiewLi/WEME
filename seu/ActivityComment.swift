//
//  ActivityComment.swift
//  WEME
//
//  Created by liewli on 2/2/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

class ActivityCommentVC:UITableViewController {
    var activity:ActivityModel!
    
    var comments = [CommentModel]()
    
    var commentIDSet = Set<Int>()
    var shownIDSet = Set<Int>()
    var refresh:UIRefreshControl!
    var initialTransform:CATransform3D!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.alpha = 1.0

    }
    
    lazy var queue:dispatch_queue_t = {
        let q = dispatch_queue_create("weme.activity.comment", DISPATCH_QUEUE_SERIAL)
        return q
    }()
    
    func preProcess(c:[CommentModel]) {
        dispatch_async(queue) { () -> Void in
            if c.count > 0 {
                if let id = Int(c[0].commentID) {
                    guard !self.commentIDSet.contains(id) else {
                        return
                    }
                    
                    var k = self.comments.count + 1
                    let indexSets = NSMutableIndexSet()
                    for cc in c {
                        indexSets.addIndex(k++)
                        if let id = Int(cc.commentID) {
                            self.commentIDSet.insert(id)
                        }
                    }
                    self.comments.appendContentsOf(c)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                         self.tableView.insertSections(indexSets, withRowAnimation: .Fade)
                         self.refresh.endRefreshing()
                    })
                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        view.backgroundColor = BACK_COLOR
        title = "活动评论"
        tableView.registerClass(ActivityHeaderTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityHeaderTableViewCell))
        tableView.registerClass(ActivityCommentTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityCommentTableViewCell))
        tableView.registerClass(ActivityCommentImageTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityCommentImageTableViewCell))

        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .None
        let edit = UIBarButtonItem(image: UIImage(named: "activity_comment"), style: .Plain, target: self, action: "comment:")
        navigationItem.rightBarButtonItem = edit
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "composeNotify:", name: ActivityCommentComposeVC.COMMENT_ACTIVITY_NOTIFICATION, object: nil)
        automaticallyAdjustsScrollViewInsets = false
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: "refreshFetch:", forControlEvents: .ValueChanged)
        tableView.addSubview(refresh)
        
        let rotationRadian = CGFloat((0)*(M_PI/180))
        let offset = CGPoint(x: -40, y: 140)
        initialTransform = CATransform3DIdentity
        initialTransform = CATransform3DConcat(initialTransform, CATransform3DMakeRotation(rotationRadian, 0, 0, 1))
        initialTransform = CATransform3DTranslate(initialTransform, offset.x, offset.y, 0)
        
        fetchComment()
    }
    func refreshFetch(sender:AnyObject) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, 2*Int64(NSEC_PER_SEC))
        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
            self.refresh.endRefreshing()
        }
        reload()

    }
    
    func reload() {
        dispatch_async(queue) { () -> Void in
            self.comments.removeAll()
            self.commentIDSet.removeAll()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
                self.fetchComment()
            })
        }

    }
    func composeNotify(notification:NSNotification) {
        reload()
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func comment(sender:AnyObject) {
        let vc = ActivityCommentComposeVC()
        vc.activityID = activity.activityID
        let nav = UINavigationController(rootViewController: vc)
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1 + comments.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityHeaderTableViewCell), forIndexPath: indexPath) as! ActivityHeaderTableViewCell
            cell.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(activity.authorID), placeholderImage: UIImage(named: "avatar"))
            cell.nameLabel.text = activity.author
            cell.infoLabel.text = activity.school
            cell.acTitleLabel.text = activity.title
            cell.acContentLabel.text = activity.detail
            let signText = "已报名・\(activity.signnumber)/\(activity.capacity)"
            let attributedText = NSMutableAttributedString(string: signText)
            attributedText.addAttribute(NSForegroundColorAttributeName, value: THEME_COLOR, range: NSMakeRange(4, signText.characters.count-4))
            cell.moreLabel.attributedText = attributedText
            cell.selectionStyle = .None
            cell.delegate = self
            return cell
        }
        else {
            let c = comments[indexPath.section-1]
            if c.images.count > 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityCommentImageTableViewCell), forIndexPath: indexPath) as! ActivityCommentImageTableViewCell
                if cell.imgController == nil {
                    cell.imgController = ActivityCommentImageManager()
                }
                cell.imgController?.imageURLs = c.thumbnailImages as! [NSURL]
                cell.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(c.authorID), placeholderImage: UIImage(named: "avatar"))
                cell.nameLabel.text = c.authorName
                cell.infoLabel.text = c.school
                let dateFormat = NSDateFormatter(withUSLocaleAndFormat: "EE, d LLLL yyyy HH:mm:ss zzzz")
                if let date = dateFormat.dateFromString(c.timestamp) {
                    cell.timeLabel.text = date.hunmanReadableString()
                }
                cell.moreInfoLabel.text = c.constelleation
                cell.gender.image = c.gender == "男" ? UIImage(named: "male") : (c.gender == "女" ? UIImage(named:"female") : nil)
                cell.commentContentLabel.text = c.body
                cell.likeLabel.text = c.likeNumber
                if c.likeFlag {
                   cell.likeButton.setBackgroundImage(UIImage(named: "liked")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                }
                else {
                   cell.likeButton.setBackgroundImage(UIImage(named: "like")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                }
                cell.likeButton.tag = indexPath.section
                cell.selectionStyle = .None
                cell.delegate = self
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityCommentTableViewCell), forIndexPath: indexPath) as! ActivityCommentTableViewCell
                
                cell.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(c.authorID), placeholderImage: UIImage(named: "avatar"))
                cell.nameLabel.text = c.authorName
                cell.infoLabel.text = c.school
                let dateFormat = NSDateFormatter(withUSLocaleAndFormat: "EE, d LLLL yyyy HH:mm:ss zzzz")
                if let date = dateFormat.dateFromString(c.timestamp) {
                    cell.timeLabel.text = date.hunmanReadableString()
                }
                cell.moreInfoLabel.text = c.constelleation
                cell.gender.image = c.gender == "男" ? UIImage(named: "male") : (c.gender == "女" ? UIImage(named:"female") : nil)
                cell.commentContentLabel.text = c.body
                cell.likeLabel.text = c.likeNumber
                if c.likeFlag {
                    cell.likeButton.setBackgroundImage(UIImage(named: "liked")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                }
                else {
                    cell.likeButton.setBackgroundImage(UIImage(named: "like")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                }
                cell.likeButton.tag = indexPath.section
                cell.selectionStyle = .None
                cell.delegate = self
                return cell
            }
      
        }
    }
    
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == comments.count {
            fetchComment()
        }
        if indexPath.section > 0 {
            if let id = Int(comments[indexPath.section-1].commentID) {
                if !shownIDSet.contains(id) {
                    shownIDSet.insert(id)
                    cell.layer.transform = initialTransform
                    UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                        cell.layer.transform = CATransform3DIdentity
                        }, completion: nil)
                }
            }
            
        }
      

    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let rect = (activity.detail as NSString).boundingRectWithSize(CGSize(width: CGRectGetWidth(tableView.bounds), height: CGRectGetHeight(tableView.bounds)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)], context: nil)
            
            return rect.height + 120
        }
        else {
            let c = comments[indexPath.section-1]
            let rect = (c.body as NSString).boundingRectWithSize(CGSize(width: CGRectGetWidth(tableView.bounds), height: CGRectGetHeight(tableView.bounds)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)], context: nil)

            if c.images.count == 0 {
                return rect.height + 90
            }
            else {
                return rect.height + ActivityCommentImageManager.SIZE + 95
            }
        }
    }
    
    override  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }
    
    func fetchComment() {
        var endid = "0"
        if comments.count > 0 {
            endid = comments[comments.count - 1].commentID
        }
        if let token = token {
            request(.POST, GET_ACTIVITY_COMMENT_URL, parameters: ["token":token, "activityid":activity.activityID, "endid":endid], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let S = self, d = response.result.value {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        return
                    }
                    do {
                        if let c = try MTLJSONAdapter.modelsOfClass(CommentModel.self, fromJSONArray: json["result"].arrayObject) as? [CommentModel] where c.count > 0 {
                            S.preProcess(c)
                        }
                    }
                    catch {
                        print(error)
                    }
                    
                    
                }
            })
        }
    }
    
}

extension ActivityCommentVC:ActivityCommentTableViewCellDelegate {
    func likeActivityComment(c:CommentModel) {
        let id = c.commentID
        if let t = token {
            request(.POST, LIKE_ACTIVITY_COMMENT_URL, parameters: ["token":t, "commentid":id], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let S = self, d = response.result.value {
                   let json = JSON(d)
                    if json["state"].stringValue == "successful" {
                        for (idx, cc) in S.comments.enumerate() {
                            if cc.commentID == id {
                                cc.likeFlag = true
                                if let n = Int(cc.likeNumber) {
                                    cc.likeNumber = "\(n+1)"
                                }
                                S.tableView.reloadSections(NSIndexSet(index: idx+1), withRowAnimation: .None)
                            }
                        }
                    }
                }
            })
        }
    }
    func didTapLikeButton(likeButton: UIButton) {
        let section = likeButton.tag
        if section <= comments.count {
            let c = comments[section-1]
            likeActivityComment(c)
        }
    }
    
    
    func didTapAvatarAtCell(cell: UITableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            if indexPath.section == 0 {
                let vc = InfoVC()
                vc.id = activity.activityID
                navigationController?.pushViewController(vc, animated: true)
            }
            else {
                if indexPath.section <= comments.count {
                    let vc = InfoVC()
                    vc.id = comments[indexPath.section-1].authorID
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func didTapImageCollectionViewAtCell(cell: ActivityCommentImageTableViewCell, indexPath imgIndexPath: NSIndexPath) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let c = comments[indexPath.section-1]
            let agrume = Agrume(imageURLs: c.images as! [NSURL], startIndex: imgIndexPath.item)
            agrume.showFrom(self)
        }
    }
}

class ActivityCommentImageManager:NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    static let SIZE = (SCREEN_WIDTH-20-40)/3
    weak var cell:ActivityCommentImageTableViewCell?
    private(set) var imageURLs = [NSURL]() {
        didSet {
            cell?.imageCollectionView.reloadData()
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(CommonImageCollectionViewCell), forIndexPath: indexPath) as! CommonImageCollectionViewCell
        cell.imgView.sd_setImageWithURL(imageURLs[indexPath.item])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: ActivityCommentImageManager.SIZE , height: ActivityCommentImageManager.SIZE)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let c = cell {
             c.delegate?.didTapImageCollectionViewAtCell?(c, indexPath: indexPath)
        }
       
    }


}

@objc protocol ActivityCommentTableViewCellDelegate:class {
    func didTapLikeButton(likeButton:UIButton)
    func didTapAvatarAtCell(cell:UITableViewCell)
    optional
    func didTapImageCollectionViewAtCell(cell:ActivityCommentImageTableViewCell, indexPath:NSIndexPath)
}

class ActivityCommentImageTableViewCell:UITableViewCell {
    var avatar:UIImageView!
    var nameLabel:UILabel!
    var infoLabel:UILabel!
    var timeLabel:UILabel!
    var moreInfoLabel:UILabel!
    var gender:UIImageView!
    var commentContentLabel:UILabel!
    var likeButton:UIButton!
    var likeLabel:UILabel!
    
    weak var delegate: ActivityCommentTableViewCellDelegate?
    
    var imgController:ActivityCommentImageManager? {
        didSet {
            imgController?.cell = self
            imageCollectionView.dataSource = imgController
            imageCollectionView.delegate = imgController
        }
    }
    
    var imageCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(CommonImageCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(CommonImageCollectionViewCell ))
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    
    func initialize() {
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.whiteColor()
        let tapFool = UITapGestureRecognizer(target: self, action: "tapFool:")
        contentView.addGestureRecognizer(tapFool)
        contentView.layer.cornerRadius = 6.0
        contentView.layer.masksToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left).offset(5)
            make.right.equalTo(snp_right).offset(-5)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
        }
        
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 20
        avatar.layer.masksToBounds = true
        avatar.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        avatar.addGestureRecognizer(tap)
        contentView.addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        nameLabel.textColor = TEXT_COLOR
        contentView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = UIColor.lightGrayColor()
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        contentView.addSubview(infoLabel)
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = UIColor.lightGrayColor()
        timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        contentView.addSubview(timeLabel)
        
        moreInfoLabel = UILabel()
        moreInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        moreInfoLabel.textColor = TEXT_COLOR
        moreInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        contentView.addSubview(moreInfoLabel)
        
        gender = UIImageView()
        gender.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gender)
        
        commentContentLabel = UILabel()
        commentContentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentContentLabel.numberOfLines = 0
        commentContentLabel.lineBreakMode = .ByWordWrapping
        commentContentLabel.textColor = TEXT_COLOR
        commentContentLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        contentView.addSubview(commentContentLabel)
        
        likeLabel = UILabel()
        likeLabel.translatesAutoresizingMaskIntoConstraints = false
        likeLabel.textColor = UIColor.lightGrayColor()
        likeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        contentView.addSubview(likeLabel)
        
        likeButton = UIButton()
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(likeButton)
        likeButton.setBackgroundImage(UIImage(named: "like")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        likeButton.tintColor = FEMALE_COLOR
        likeButton.addTarget(self, action: "like:", forControlEvents: .TouchUpInside)
        
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageCollectionView)
        
        
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.top.equalTo(contentView.snp_topMargin)
            make.width.height.equalTo(40)
        }
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(5)
            make.top.equalTo(avatar.snp_top)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(5)
            make.bottom.equalTo(avatar.snp_bottom)
        }
        
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_right)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(avatar.snp_top)
            timeLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
        
        moreInfoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(infoLabel.snp_right)
            make.bottom.equalTo(avatar.snp_bottom)
            moreInfoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
        gender.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(avatar.snp_bottom)
            make.width.equalTo(16)
            make.height.equalTo(18)
            make.left.equalTo(moreInfoLabel.snp_right).offset(5)
            make.right.equalTo(contentView.snp_rightMargin)
        }
        commentContentLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(avatar.snp_bottom).offset(5)
        }
        
        imageCollectionView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(commentContentLabel.snp_bottom).offset(5)
            make.height.equalTo(ActivityCommentImageManager.SIZE)
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
        }
        
        likeLabel.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(likeButton.snp_centerY)
            make.left.equalTo(contentView.snp_rightMargin)
            likeLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
        
        likeButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(likeLabel.snp_left).offset(-5)
            make.width.height.equalTo(16)
            make.top.equalTo(imageCollectionView.snp_bottom).offset(5)
        }
        
        
    }
    
    func tapFool(tapGest:UITapGestureRecognizer) {
        let loc = tapGest.locationInView(contentView)
        let c = likeButton.center
        if max(abs(loc.x-c.x), abs(loc.y-c.y)) < 40 {
            delegate?.didTapLikeButton(likeButton)
        }
        else {
            let p = tapGest.locationInView(imageCollectionView)
            if let indexPath = imageCollectionView.indexPathForItemAtPoint(p) {
                delegate?.didTapImageCollectionViewAtCell?(self, indexPath: indexPath)
            }
        }
    }

    
    func tap(sender:AnyObject) {
        delegate?.didTapAvatarAtCell(self)
    }
    func like(sender:UIButton) {
        delegate?.didTapLikeButton(sender)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class ActivityCommentTableViewCell:UITableViewCell {
    var avatar:UIImageView!
    var nameLabel:UILabel!
    var infoLabel:UILabel!
    var timeLabel:UILabel!
    var moreInfoLabel:UILabel!
    var gender:UIImageView!
    var commentContentLabel:UILabel!
    var likeButton:UIButton!
    var likeLabel:UILabel!
    weak var delegate: ActivityCommentTableViewCellDelegate?
    func initialize() {
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.whiteColor()
        let tapFool = UITapGestureRecognizer(target: self, action: "tapFool:")
        contentView.addGestureRecognizer(tapFool)
        contentView.layer.cornerRadius = 6.0
        contentView.layer.masksToBounds = true
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left).offset(5)
            make.right.equalTo(snp_right).offset(-5)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
        }

        
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 20
        avatar.layer.masksToBounds = true
        avatar.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        avatar.addGestureRecognizer(tap)
        contentView.addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        nameLabel.textColor = TEXT_COLOR
        contentView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = UIColor.lightGrayColor()
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        contentView.addSubview(infoLabel)
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = UIColor.lightGrayColor()
        timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        contentView.addSubview(timeLabel)
        
        moreInfoLabel = UILabel()
        moreInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        moreInfoLabel.textColor = TEXT_COLOR
        moreInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        contentView.addSubview(moreInfoLabel)
        
        gender = UIImageView()
        gender.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gender)
        
        commentContentLabel = UILabel()
        commentContentLabel.translatesAutoresizingMaskIntoConstraints = false
        commentContentLabel.numberOfLines = 0
        commentContentLabel.lineBreakMode = .ByWordWrapping
        commentContentLabel.textColor = TEXT_COLOR
        commentContentLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        contentView.addSubview(commentContentLabel)
        
        likeLabel = UILabel()
        likeLabel.translatesAutoresizingMaskIntoConstraints = false
        likeLabel.textColor = UIColor.lightGrayColor()
        likeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        contentView.addSubview(likeLabel)
        
        likeButton = UIButton()
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(likeButton)
        likeButton.setBackgroundImage(UIImage(named: "like")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        likeButton.tintColor = FEMALE_COLOR
        likeButton.addTarget(self, action: "like:", forControlEvents: .TouchUpInside)

        
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.top.equalTo(contentView.snp_topMargin)
            make.width.height.equalTo(40)
        }
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(5)
            make.top.equalTo(avatar.snp_top)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(5)
            make.bottom.equalTo(avatar.snp_bottom)
        }
        
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_right)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(avatar.snp_top)
            timeLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
        
        moreInfoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(infoLabel.snp_right)
            make.bottom.equalTo(avatar.snp_bottom)
            moreInfoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
        gender.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(avatar.snp_bottom)
            make.width.equalTo(16)
            make.height.equalTo(18)
            make.left.equalTo(moreInfoLabel.snp_right).offset(5)
            make.right.equalTo(contentView.snp_rightMargin)
        }
        commentContentLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(avatar.snp_bottom).offset(5)
        }
        
        likeLabel.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(likeButton.snp_centerY)
            make.left.equalTo(contentView.snp_rightMargin)
            likeLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
        
        likeButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(likeLabel.snp_left).offset(-5)
            make.width.height.equalTo(16)
            make.top.equalTo(commentContentLabel.snp_bottom).offset(5)
        }


    }
    
    func tapFool(tapGest:UITapGestureRecognizer) {
        let loc = tapGest.locationInView(contentView)
        let c = likeButton.center
        if max(abs(loc.x-c.x), abs(loc.y-c.y)) < 40 {
            delegate?.didTapLikeButton(likeButton)
        }
    }
    func like(sender:UIButton) {
        delegate?.didTapLikeButton(sender)
    }
    func tap(sender:AnyObject) {
        delegate?.didTapAvatarAtCell(self)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

class ActivityHeaderTableViewCell:UITableViewCell {
    
    var avatar:UIImageView!
    var nameLabel:UILabel!
    var infoLabel:UILabel!
    var acTitleLabel:UILabel!
    var acContentLabel:UILabel!
    var moreLabel:UILabel!
    weak var delegate: ActivityCommentTableViewCellDelegate?
    func initialize() {
        layer.cornerRadius = 6.0
        layer.masksToBounds = true
        
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 20
        avatar.layer.masksToBounds = true
        avatar.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        avatar.addGestureRecognizer(tap)
        contentView.addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        nameLabel.textColor = TEXT_COLOR
        contentView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = UIColor.lightGrayColor()
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        contentView.addSubview(infoLabel)
        
        acTitleLabel = UILabel()
        acTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        acTitleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        contentView.addSubview(acTitleLabel)
        
        acContentLabel = UILabel()
        acContentLabel.translatesAutoresizingMaskIntoConstraints = false
        acContentLabel.numberOfLines = 0
        acContentLabel.lineBreakMode = .ByWordWrapping
        acContentLabel.textColor = TEXT_COLOR
        acContentLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        contentView.addSubview(acContentLabel)
        
        moreLabel = UILabel()
        moreLabel.translatesAutoresizingMaskIntoConstraints = false
        moreLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        moreLabel.textColor = UIColor.lightGrayColor()
        moreLabel.textAlignment = .Right
        contentView.addSubview(moreLabel)
        
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.top.equalTo(contentView.snp_topMargin)
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
        
        acTitleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(avatar.snp_bottom).offset(10)
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
        }
        
        acContentLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(acTitleLabel.snp_bottom).offset(5)
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
        }
        
        moreLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(acContentLabel.snp_bottom).offset(5)
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    func tap(sender:AnyObject) {
        delegate?.didTapAvatarAtCell(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
