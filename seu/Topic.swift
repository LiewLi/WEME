//
//  Topic.swift
//  牵手东大
//
//  Created by liewli on 11/22/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit


struct Post {
    let postid:String
    let userid:String
    let name:String
    let school:String
    let gender:String
    let timestamp:String
    let title:String
    let body:String
    let likenumber:String
    let commentnumber:String
    let imageurl:[String]
    let thumbnail:[String]
    let verified:Bool
}

class TopicVC:UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, FloatingActionViewDelegate,UINavigationControllerDelegate {
    static let TOPIC_IMAGE_WIDTH = SCREEN_WIDTH
    static let TOPIC_IMAGE_HEIGHT = SCREEN_WIDTH * 2/3
    let imgBG = UIImageView(frame: CGRectMake(0, -TopicVC.TOPIC_IMAGE_HEIGHT, TopicVC.TOPIC_IMAGE_WIDTH, TopicVC.TOPIC_IMAGE_HEIGHT))
    
    var initialTransform:CATransform3D!
    
    var visualView:UIVisualEffectView?
    
    var composeAction:FloatingActionView!
    
    var tableView:UITableView!
    
    var refreshControl:UIRefreshControl!
    
    var shownIndexPaths = Set<NSIndexPath>()
    
    let transition = BubbleTransition()
    
    var refreshImgs = [UIImage]()
    
    let sloganLabel = DLLabel()
    
    var currentIndex = 0
    var animateTimer:NSTimer!
    
    var currentPage = 1
    
    var isLoading = false
    
    let refreshCustomizeImageView = UIImageView()
    
    var interactionController:UIPercentDrivenInteractiveTransition?

    
    let topicID:String
    
    var posts = [Post]()
    
    init(topic:String) {
        topicID = topic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
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
        //visualView?.hidden = true
        print(tableView.contentOffset.y)
        if tableView.contentOffset.y <= -TopicVC.TOPIC_IMAGE_HEIGHT {
            hiddenVisualView()
        }
        else {
            showVisualView()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "publishPost:", name: ComposePostVC.DID_SEND_POST_NOTIFICATION, object: nil)
        
        MobClick.beginLogPageView("Topic-\(topicID)")

    }
    
    

    
    func publishPost(sender:AnyObject) {
        reload()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        visualView?.removeFromSuperview()
        MobClick.endLogPageView("Topic-\(topicID)")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let data = posts[indexPath.section]
        if data.imageurl.count > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TopicTableViewCell), forIndexPath: indexPath) as! TopicTableViewCell
            let url = thumbnailAvatarURLForID(data.userid)
            cell.avatar.sd_setImageWithURL(url, placeholderImage: UIImage(named: "avatar"))//UIImage(named: "dev_liuli")
            cell.nameLabel.text = data.name//"牵手东大官方帐号"
            cell.infoLabel.text = data.school//"东南大学・射手座"
            let dateFormat = NSDateFormatter(withUSLocaleAndFormat: "EE, d LLLL yyyy HH:mm:ss zzzz")
            if let date = dateFormat.dateFromString(data.timestamp) {
                cell.timeLabel.text = date.hunmanReadableString()
            }
            //cell.timeLabel.text = "1小时前"
            cell.titleLabel.text = data.title//"好奇心远比雄心走的更远"
            cell.bodyLabel.text = data.body//" <<丈量世界>>里的主人公--数学家高斯和博物学家洪堡，一个足不出户，一个步行天下，两人本不是一路人, 数学..."
            let attributedText = NSMutableAttributedString(string: "\(data.likenumber) 个点赞・\(data.commentnumber) 条评论")
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorFromRGB(0xFF69B4) , range: NSMakeRange(0, data.likenumber.characters.count))
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorFromRGB(0x32CD32), range: NSMakeRange(data.likenumber.characters.count+5, data.commentnumber.characters.count))
            cell.topicInfoLabel.attributedText = attributedText
            if cell.imgController == nil {
                cell.imgController = TopicImageCollectionViewController()
            }
            cell.imgController.imageURLs = data.thumbnail
            cell.delegate = self
            cell.selectionStyle = .None
            cell.verifiedIcon.hidden = !data.verified
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TopicTableViewPureTextCell), forIndexPath: indexPath) as! TopicTableViewPureTextCell
            let url = thumbnailAvatarURLForID(data.userid)
            cell.avatar.sd_setImageWithURL(url, placeholderImage: UIImage(named: "avatar"))
            cell.nameLabel.text = data.name
            cell.infoLabel.text = data.school
            let dateFormat = NSDateFormatter(withUSLocaleAndFormat: "EE, d LLLL yyyy HH:mm:ss zzzz")
            if let date = dateFormat.dateFromString(data.timestamp) {
                cell.timeLabel.text = date.hunmanReadableString()
            }
            cell.titleLabel.text = data.title
            cell.bodyLabel.text = data.body
            let attributedText = NSMutableAttributedString(string: "\(data.likenumber) 个点赞・\(data.commentnumber) 条评论")
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorFromRGB(0xFF69B4) , range: NSMakeRange(0, data.likenumber.characters.count))
            attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.colorFromRGB(0x32CD32), range: NSMakeRange(data.likenumber.characters.count+5, data.commentnumber.characters.count))
            cell.topicInfoLabel.attributedText = attributedText
            cell.selectionStyle = .None
            cell.verifiedIcon.hidden = !data.verified
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = PostVC()
        let data = posts[indexPath.section]
        vc.postID = data.postid
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //title = "话题"
        automaticallyAdjustsScrollViewInsets = false
        tableView = UITableView(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(tableView)
        tableView.tableFooterView = UIView()
        
        
        //navigationController?.navigationBar.tintColor = UIColor.clearColor()
        tableView.backgroundColor = BACK_COLOR
        tableView.contentInset = UIEdgeInsetsMake(TopicVC.TOPIC_IMAGE_HEIGHT, 0, 0, 0)
        //imgBG.image = UIImage(named: "test")
        tableView.addSubview(imgBG)
        
        tableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TopicTableViewCell))
        tableView.registerClass(TopicTableViewPureTextCell.self, forCellReuseIdentifier: NSStringFromClass(TopicTableViewPureTextCell))
        //tableView.rowHeight = UITableViewAutomaticDimension
       // tableView.estimatedRowHeight = 260
        
        
        sloganLabel.translatesAutoresizingMaskIntoConstraints = false
        sloganLabel.numberOfLines = 0
        sloganLabel.lineBreakMode = .ByWordWrapping
        sloganLabel.textColor = UIColor.whiteColor()
        sloganLabel.textAlignment = .Center
        sloganLabel.font = UIFont.systemFontOfSize(16)
        imgBG.addSubview(sloganLabel)
        //sloganLabel.text = "Stay hungry・Stay foolish・Stay cool\nAnoynomous"
        //sloganLabel.layer.appendShadow()
                                   //sloganLabel.glowAmount = 2
        sloganLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(imgBG.snp_left)
            make.right.equalTo(imgBG.snp_right)
            make.bottom.equalTo(imgBG.snp_bottom).offset(-20)
        }
        
        
        let rotationRadian = CGFloat((0)*(M_PI/180))
        let offset = CGPoint(x: -40, y: 140)
        initialTransform = CATransform3DIdentity
        initialTransform = CATransform3DConcat(initialTransform, CATransform3DMakeRotation(rotationRadian, 0, 0, 1))
        initialTransform = CATransform3DTranslate(initialTransform, offset.x, offset.y, 0)
        
        
        composeAction = FloatingActionView(center: CGPointMake(view.frame.size.width-40, view.frame.size.height-60), radius: 30, color: THEME_COLOR, icon: UIImage(named: "edit")!, scrollview:tableView)
        composeAction.hideWhileScrolling = true
        composeAction.delegate = self
        view.addSubview(composeAction)
        
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.clearColor()
        refreshControl.tintColor = UIColor.clearColor()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        loadRefreshContents()
        
        configUI()
        
//        let edge = UIScreenEdgePanGestureRecognizer(target: self, action: "handleSwipe:")
//        edge.edges = .Left
//        self.view.addGestureRecognizer(edge)

        
    }
    
  


    
    func handleSwipe(gesture:UIScreenEdgePanGestureRecognizer) {
        
        let translate = gesture.translationInView(gesture.view)
        let percent = translate.x / gesture.view!.bounds.size.width
        switch gesture.state {
        case .Began:
            let navDelegate = (self.navigationController?.delegate) as! SocialVC
         
            self.interactionController = UIPercentDrivenInteractiveTransition()
            navDelegate.interactionController = self.interactionController
            self.navigationController?.popViewControllerAnimated(true)
        case .Changed:
            print(percent)
            self.interactionController?.updateInteractiveTransition(percent)
        
        case .Ended, .Cancelled:
            let v = gesture.velocityInView(view)
            if percent > 0.5 && v.x > 0 {
                self.interactionController?.finishInteractiveTransition()
            }
            else {
                self.interactionController?.cancelInteractiveTransition()
            }
            
            self.interactionController = nil
        default:
            break
        }
        
    }
//
    
    func fetchTopicInfo() {
        if let t = token {
            request(.POST, GET_TOPIC_SLOGAN, parameters: ["token":t, "topicid":topicID], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let S = self, let d = response.result.value  {
                    let json = JSON(d)
                    if json["state"] == "successful" {
                        guard json != .null && json["result"] != .null && json["result"]["imageurl"] != .null  else {
                            return
                        }
                        S.imgBG.sd_setImageWithURL(NSURL(string:json["result"]["imageurl"].stringValue)!, placeholderImage: UIImage(named: "profile_background"))
                        S.sloganLabel.text = json["result"]["slogan"].stringValue
                    }
                }
                
            })
        }
    }
    
    func fetchTopicPostsAtPage(page:Int) {
        if let t = token {
            isLoading = true
            request(.POST, GET_POST_LIST, parameters: ["token":t, "page":"\(page)", "topicid":topicID], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let S = self, d = response.result.value {
                    let json = JSON(d)
                    if json["state"].stringValue == "successful" {
                        guard let arr = json["result"].array where arr.count > 0 else {
                            return
                        }
                        
                        var post_arr = [Post]()
                        var k = S.posts.count
                        //var indexPaths = [NSIndexPath]()
                        let indexSets = NSMutableIndexSet()
                        for a in arr  {
                            guard a["postid"] != .null && a["userid"] != .null else {
                                continue
                            }
                            
                            post_arr.append(Post(postid: a["postid"].stringValue, userid: a["userid"].stringValue, name: a["name"].stringValue, school: a["school"].stringValue, gender: a["gender"].stringValue, timestamp: a["timestamp"].stringValue, title: a["title"].stringValue, body: a["body"].stringValue, likenumber: a["likenumber"].stringValue, commentnumber: a["commentnumber"].stringValue, imageurl: (a["imageurl"].arrayObject as! [String]),thumbnail:(a["thumbnail"].arrayObject as! [String]), verified: a["certification"].boolValue))
                            //indexPaths.append(NSIndexPath(forRow: 0, inSection: k++))
                            indexSets.addIndex(k++)
                        }
                        
                        if post_arr.count > 0 && post_arr.count == indexSets.count{
                            print("load \(post_arr.count) rows")
                            S.currentPage++
                            S.posts.appendContentsOf(post_arr)
                            S.tableView.beginUpdates()
                            //let offset = S.tableView.contentOffset
                           // S.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
                            S.tableView.insertSections(indexSets, withRowAnimation: .Fade)
                            //S.tableView.contentOffset = offset
                            S.tableView.endUpdates()
                        }
                        
                    }
                    S.isLoading = false
                    //S.refreshControl.endRefreshing()
                }
                
            })
        }
    }
    
    func configUI() {
        fetchTopicInfo()
        fetchTopicPostsAtPage(currentPage)
    }
    
    func reload() {
        posts.removeAll()
        self.tableView.reloadData()
        self.currentPage = 1
        fetchTopicPostsAtPage(self.currentPage)
    }
    
    func refresh(sender:UIRefreshControl) {
       // print("called refresh")
        reload()
        for k in 1..<110 {
            //refreshImgs.append(UIImage(named: "RefreshContents.bundle/loadding_\(k)")!)
            //refreshImgs.append(UIImage(contentsOfFile: "RefreshContents.bundle/loadding_\(k)")!)
            let imagePath = NSBundle.mainBundle().pathForResource("RefreshContents.bundle/loadding_\(k)", ofType: "png")
            refreshImgs.append(UIImage(contentsOfFile:imagePath!)!)

        }
        animateTimer = NSTimer.scheduledTimerWithTimeInterval(0.015, target: self, selector: "tick:", userInfo: nil, repeats: true)
        //animateRefresh()
        let endTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
        dispatch_after(endTime, dispatch_get_main_queue()) { () -> Void in
            self.refreshControl.endRefreshing()
        }
    }
    
    func loadRefreshContents() {
        refreshCustomizeImageView.contentMode = .ScaleAspectFill
        let rect = CGRectMake(refreshControl.center.x-80/2, refreshControl.center.y-80/2-TopicVC.TOPIC_IMAGE_HEIGHT/2, 80, 80)
        refreshCustomizeImageView.frame = rect
        refreshControl.addSubview(refreshCustomizeImageView)
        
    }
    
    func tick(sender:AnyObject) {
       // print("called tick")
        self.refreshCustomizeImageView.image = self.refreshImgs[self.currentIndex]
        self.currentIndex++
        if self.refreshControl.refreshing {
            if self.currentIndex >= self.refreshImgs.count {
                self.currentIndex = 0
            }
        }
        else {
            resetAnimateRefresh()
        }
    }
    

    
    func resetAnimateRefresh() {
        self.currentIndex = 0
        refreshCustomizeImageView.image = nil
        animateTimer.invalidate()
        animateTimer = nil
        refreshImgs.removeAll()
    }
    
    func didTapFloatingAction(action: FloatingActionView) {
        let composeVC = ComposePostVC()
        composeVC.topicID = topicID
        let vc = UINavigationController(rootViewController: composeVC)
        vc.modalPresentationStyle = .Custom
        vc.transitioningDelegate = self
        presentViewController(vc, animated: true, completion: nil)
    }
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        composeAction.hideWhileScrolling  = false
        visualView?.removeFromSuperview()
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if !shownIndexPaths.contains(indexPath) {
            shownIndexPaths.insert(indexPath)
            
            cell.layer.transform = initialTransform
            
            //UIView.animateWithDuration(0.6, animations: { () -> Void in
               
            //})
            
            UIView.animateWithDuration(0.6, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                     cell.layer.transform = CATransform3DIdentity
                }, completion: nil)
            
        }
        
        if indexPath.section >= posts.count - 5 && !isLoading{
            fetchTopicPostsAtPage(currentPage)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let data = posts[indexPath.section]
        let titleHeight = (data.title as NSString).boundingRectWithSize(CGSizeMake(SCREEN_WIDTH-20, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)], context: nil).size.height
        let bodyHeight = ("历" as NSString).boundingRectWithSize(CGSizeMake(SCREEN_WIDTH-20, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)], context: nil).size.height
        let bodyRealHeight =  (data.body as NSString).boundingRectWithSize(CGSizeMake(SCREEN_WIDTH-20, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)], context: nil).size.height
        
        
        if data.imageurl.count == 0 {
            return titleHeight+bodyHeight + 78 + (data.body.characters.count == 0 ? 0:min(2*bodyHeight, bodyRealHeight)+10)
        }
        else {
            return TopicImageCollectionViewCell.SIZE +  titleHeight+bodyHeight + 93 + (data.body.characters.count == 0 ? 0:min(2*bodyHeight, bodyRealHeight)+10)

        }
    }
    
    
    func hiddenVisualView() {
        if let bounds = self.navigationController?.navigationBar.bounds {
            //UIView.animateWithDuration(0.5) { () -> Void in
            self.visualView?.frame = CGRectMake(0, (bounds.height - 64)-64, SCREEN_WIDTH, 64)
        }
        //}
        
    }
    
    func showVisualView() {
        if let bounds = self.navigationController?.navigationBar.bounds {
            //UIView.animateWithDuration(0.5) { () -> Void in
            self.visualView?.frame = CGRectMake(0, (bounds.height - 64), SCREEN_WIDTH, 64)
        }
        // }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        //if !self.showing && !self.hiding {
        //composeAction?.center = CGPointMake(tableView.frame.size.width-40, tableView.frame.size.height-60+yOffset)
        //}
        if yOffset <= -TopicVC.TOPIC_IMAGE_HEIGHT{
            //visualView?.hidden = true
            hiddenVisualView()
            let xOffset = (yOffset + TopicVC.TOPIC_IMAGE_HEIGHT)/2
            var rect = imgBG.frame
            rect.origin.y = yOffset
            rect.size.height = -yOffset
            rect.origin.x = xOffset
            rect.size.width = TopicVC.TOPIC_IMAGE_WIDTH + fabs(xOffset)*2
            imgBG.frame = rect
            let ratio = max(0, min((-yOffset-TopicVC.TOPIC_IMAGE_HEIGHT)/TopicVC.TOPIC_IMAGE_HEIGHT,1.0))
            //sloganLabel.font = UIFont.systemFontOfSize(16 + (24-16)*ratio)
            sloganLabel.transform = CGAffineTransformMakeScale( 1+ratio, 1+ratio)
            // composeAction?.center = CGPointMake(tableView.frame.size.width-40, tableView.frame.size.height-60+yOffset)
        }
            
        else if yOffset <= -64 {
            showVisualView()
            sloganLabel.transform = CGAffineTransformIdentity
            //visualView?.hidden = false
            imgBG.frame = CGRectMake(0, -TopicVC.TOPIC_IMAGE_HEIGHT, TopicVC.TOPIC_IMAGE_WIDTH, TopicVC.TOPIC_IMAGE_HEIGHT)
            // composeAction?.center = CGPointMake(tableView.frame.size.width-40, tableView.frame.size.height-60+yOffset)
            
            
        }
        else {
            showVisualView()
            sloganLabel.transform = CGAffineTransformIdentity
            imgBG.frame = CGRectMake(0, yOffset-(TopicVC.TOPIC_IMAGE_HEIGHT-64), TopicVC.TOPIC_IMAGE_WIDTH, TopicVC.TOPIC_IMAGE_HEIGHT)
            //visualView?.hidden = false
            
        }
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if yOffset <= -TopicVC.TOPIC_IMAGE_HEIGHT+10{
            //visualView?.hidden = true
            hiddenVisualView()
        }
        else {
            //visualView?.hidden = false
            showVisualView()
        }
        
        
    }
}

extension TopicVC: TopicTableViewCellDelegate {
    
    func didTapImageCollectionViewAtCell(cell: TopicTableViewCell, startIndex: Int) {
        if let indexPath = tableView.indexPathForCell(cell) where indexPath.section < posts.count  {
            let vc = PostVC()
            let data = posts[indexPath.section]
            vc.postID = data.postid
            navigationController?.pushViewController(vc, animated: true)
        }
//        if let indexpath = indexPath {
//            let urls = posts[(indexpath.item)].imageurl
//            var URLs = [NSURL]()
//            for s in urls {
//                URLs.append(NSURL(string:s)!)
//            }
//            let agrume = Agrume(imageURLs: URLs, startIndex: startIndex, backgroundBlurStyle: .Dark)
//            agrume.title = "查看照片"
//            agrume.showFrom(self)
//            
//        }
    }
    
    func didTapCollectionViewAtCell(cell: TopicTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) where indexPath.section < posts.count {
            let vc = PostVC()
            let data = posts[indexPath.section]
            vc.postID = data.postid
            navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    func didTapAvatarAtCell(cell: TopicTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) where indexPath.section < posts.count {
            //if let id = myId {
                let vc = InfoVC()
                let data = posts[indexPath.section]
                vc.id = data.userid
                //if id != vc.id {
                    navigationController?.pushViewController(vc, animated: true)
                //}
            //}
        }
    }
}

extension TopicVC:TopicTableViewPureTextCellDelegate {
    func didTapAvatarAtPureTextCell(cell: TopicTableViewPureTextCell) {
        if let indexPath = tableView.indexPathForCell(cell) where indexPath.section < posts.count {
            //if let id = myId {
                let vc = InfoVC()
                let data = posts[indexPath.section]
                vc.id = data.userid
              //  if id != vc.id {
                    navigationController?.pushViewController(vc, animated: true)
              //  }
            //}
        }
    }
}


extension TopicVC : UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //let bubbleTransition = BubbleTransition()
        transition.transitionMode = .Present
        transition.startingPoint = composeAction.center
        transition.bubbleColor = UIColor.clearColor()//composeAction.color
        return transition
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //let bubbleTransition = BubbleTransition()
        transition.transitionMode = .Dismiss
        transition.startingPoint = composeAction.center
        transition.bubbleColor = UIColor.clearColor()//composeAction.color
        return transition
        
    }
}

protocol TopicTableViewCellDelegate:class {
    func didTapImageCollectionViewAtCell(cell:TopicTableViewCell, startIndex:Int)
    func didTapCollectionViewAtCell(cell:TopicTableViewCell)
    func didTapAvatarAtCell(cell:TopicTableViewCell)
}

protocol TopicTableViewPureTextCellDelegate:class {
    func didTapAvatarAtPureTextCell(cell:TopicTableViewPureTextCell)
}

class TopicTableViewPureTextCell:UITableViewCell {
    var avatar:UIImageView!
    var nameLabel:UILabel!
    var infoLabel:UILabel!
    var timeLabel:UILabel!
    var seperator:UIView!
    var titleLabel:UILabel!
    var bodyLabel:UILabel!
    var verifiedIcon:UIImageView!
    
    var topicInfoLabel:UILabel!
    weak var delegate:TopicTableViewPureTextCellDelegate?
    
    func initialize() {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
        }
        
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 16
        avatar.layer.masksToBounds = true
        avatar.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapAvatar:")
        avatar.addGestureRecognizer(tapGesture)
        contentView.addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        //nameLabel.backgroundColor = SECONDAY_COLOR
        //nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        nameLabel.font = UIFont.boldSystemFontOfSize(13)
        nameLabel.textColor =  UIColor.darkGrayColor()
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = UIColor.lightGrayColor()
        contentView.addSubview(infoLabel)
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        //infoLabel.backgroundColor = UIColor.yellowColor()
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = UIColor.lightGrayColor()
        contentView.addSubview(timeLabel)
        timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        timeLabel.textAlignment = .Right
        //timeLabel.backgroundColor = SECONDAY_COLOR
        
        seperator = UIView()
        seperator.backgroundColor = BACK_COLOR
        seperator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(seperator)
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .ByWordWrapping
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bodyLabel = UILabel()
        bodyLabel.numberOfLines = 2
        bodyLabel.lineBreakMode = .ByWordWrapping
        contentView.addSubview(bodyLabel)
        bodyLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        bodyLabel.textColor = UIColor.darkGrayColor()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        topicInfoLabel = UILabel()
        topicInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        topicInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topicInfoLabel)
        
        verifiedIcon = UIImageView(image: UIImage(named: "verified0"))
        verifiedIcon.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(verifiedIcon)
        verifiedIcon.hidden = true
        
        avatar.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp_top).offset(10)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.width.height.equalTo(32)
        }
        
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(avatar.snp_top)
            make.left.equalTo(avatar.snp_right).offset(5)
            nameLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
        
        verifiedIcon.snp_makeConstraints { (make) in
            make.top.equalTo(avatar.snp_top)
            make.left.equalTo(nameLabel.snp_right)
            make.width.height.equalTo(14)
        }
        
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
            make.bottom.equalTo(avatar.snp_bottom)
            make.right.equalTo(timeLabel.snp_left)
            //infoLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: UILayoutConstraintAxis.Horizontal)
        }
        
        
        
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(contentView.snp_right).offset(-10)
            make.centerY.equalTo(infoLabel.snp_centerY)
            //timeLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: UILayoutConstraintAxis.Horizontal)
            
        }
        
        seperator.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(avatar.snp_bottom).offset(5)
            make.left.equalTo(snp_left).offset(10)
            make.right.equalTo(snp_right).offset(-10)
            make.height.equalTo(1)
        }
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(seperator.snp_bottom).offset(10)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.right.equalTo(contentView.snp_right).offset(-10)
        }
        
        bodyLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp_bottom).offset(10)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.right.equalTo(contentView.snp_right).offset(-10)
        }
        
  
        topicInfoLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(bodyLabel.snp_bottom).offset(10)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.right.equalTo(contentView.snp_right).offset(-10)
        }
        
        
        
        //contentView.backgroundColor = BACK_COLOR
        contentView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(topicInfoLabel.snp_bottom).offset(10)
        }
    }
    func tapAvatar(sender:AnyObject) {
        delegate?.didTapAvatarAtPureTextCell(self)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

class TopicTableViewCell:UITableViewCell {
    var avatar:UIImageView!
    var nameLabel:UILabel!
    var infoLabel:UILabel!
    var timeLabel:UILabel!
    var seperator:UIView!
    var titleLabel:UILabel!
    var bodyLabel:UILabel!
    var verifiedIcon:UIImageView!
    
    private var imgController:TopicImageCollectionViewController! {
        didSet {
            imgController.cell = self
            imageCollectionView.dataSource = imgController
            imageCollectionView.delegate = imgController
        }
    }
    
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
    var topicInfoLabel:UILabel!
    
    weak var delegate:TopicTableViewCellDelegate?
    
    
    func initialize() {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
        }
        
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 16
        avatar.layer.masksToBounds = true
        avatar.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapAvatar:")
        avatar.addGestureRecognizer(tapGesture)
        contentView.addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        //nameLabel.backgroundColor = SECONDAY_COLOR
        //nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        nameLabel.font = UIFont.boldSystemFontOfSize(13)
        nameLabel.textColor =  UIColor.darkGrayColor()
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = UIColor.lightGrayColor()
        contentView.addSubview(infoLabel)
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        //infoLabel.backgroundColor = UIColor.yellowColor()
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = UIColor.lightGrayColor()
        contentView.addSubview(timeLabel)
        timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        timeLabel.textAlignment = .Right
        //timeLabel.backgroundColor = SECONDAY_COLOR
        
        seperator = UIView()
        seperator.backgroundColor = BACK_COLOR
        seperator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(seperator)
        
        titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .ByWordWrapping
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bodyLabel = UILabel()
        bodyLabel.numberOfLines = 2
        bodyLabel.lineBreakMode = .ByWordWrapping
        contentView.addSubview(bodyLabel)
        bodyLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        bodyLabel.textColor = UIColor.darkGrayColor()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        let tapGest = UITapGestureRecognizer(target: self, action: "tap:")
        imageCollectionView.addGestureRecognizer(tapGest)
        contentView.addSubview(imageCollectionView)
        
        topicInfoLabel = UILabel()
        topicInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        topicInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(topicInfoLabel)
        
        verifiedIcon = UIImageView(image: UIImage(named: "verified0"))
        verifiedIcon.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(verifiedIcon)
        verifiedIcon.hidden = true
        
        
        avatar.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp_top).offset(10)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.width.height.equalTo(32)
        }
        
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(avatar.snp_top)
            make.left.equalTo(avatar.snp_right).offset(5)
            nameLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
        
        verifiedIcon.snp_makeConstraints { (make) in
            make.top.equalTo(avatar.snp_top)
            make.left.equalTo(nameLabel.snp_right)
            make.width.height.equalTo(14)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
            make.bottom.equalTo(avatar.snp_bottom)
            make.right.equalTo(timeLabel.snp_left)
            //infoLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: UILayoutConstraintAxis.Horizontal)
        }
        
        
        
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(contentView.snp_right).offset(-10)
            make.centerY.equalTo(infoLabel.snp_centerY)
            make.bottom.equalTo(avatar.snp_bottom)
            //timeLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: UILayoutConstraintAxis.Horizontal)
            
        }
        
        seperator.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(avatar.snp_bottom).offset(5)
            make.left.equalTo(snp_left).offset(10)
            make.right.equalTo(snp_right).offset(-10)
            make.height.equalTo(1)
        }
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(seperator.snp_bottom).offset(10)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.right.equalTo(contentView.snp_right).offset(-10)
        }
        
        bodyLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp_bottom).offset(10)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.right.equalTo(contentView.snp_right).offset(-10)
        }
        
        imageCollectionView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(bodyLabel.snp_bottom).offset(5)
            make.height.greaterThanOrEqualTo(TopicImageCollectionViewCell.SIZE)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.right.equalTo(contentView.snp_right).offset(-10)
        }
        
        topicInfoLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(imageCollectionView.snp_bottom).offset(10)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.right.equalTo(contentView.snp_right).offset(-10)
        }
        
        contentView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(topicInfoLabel.snp_bottom).offset(10)
        }
    }
    
    func tapAvatar(sender:AnyObject) {
        delegate?.didTapAvatarAtCell(self)
    }
    func tap(sender:AnyObject?) {
        delegate?.didTapCollectionViewAtCell(self)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

class TopicImageCollectionViewController:NSObject {
   // private var images = [UIImage(named: "dev_liuli")!, UIImage(named: "dev_lilei")!, UIImage(named: "dev_yeqingshi")!, UIImage(named: "dev_songjiaji")!, UIImage(named: "dev_mashenbin")!, UIImage(named: "dev_liuli")!]
    //[UIImage]()
    private(set) var imageURLs = [String]() {
        didSet {
            cell?.imageCollectionView.reloadData()
        }
    }
    
    
    private weak var cell:TopicTableViewCell?
    
    
}

extension TopicImageCollectionViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(TopicImageCollectionViewCell), forIndexPath: indexPath) as! TopicImageCollectionViewCell
        cell.imgView.sd_setImageWithURL(NSURL(string:imageURLs[indexPath.item]))
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: TopicImageCollectionViewCell.SIZE , height: TopicImageCollectionViewCell.SIZE)
    }
 
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        cell?.delegate?.didTapImageCollectionViewAtCell(cell!, startIndex: indexPath.item)
    }
    
}
typealias CommonImageCollectionViewCell = TopicImageCollectionViewCell
class TopicImageCollectionViewCell: UICollectionViewCell {
    static let SIZE = (SCREEN_WIDTH-20-15)/4
    
    let imgView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        //imageView.layer.cornerRadius = 4
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        contentView.addSubview(imgView)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.snp_makeConstraints { (make) -> Void in
            //make.top.equalTo(contentView.snp_top)
            make.left.equalTo(contentView.snp_left)
            make.top.equalTo(contentView.snp_top)
            //            make.width.equalTo(40)
            //            make.height.equalTo(40)
            make.right.equalTo(contentView.snp_right)
            make.bottom.equalTo(contentView.snp_bottom)
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
        }
        
    }
    
    
}