//
//  About.swift
//  WE
//
//  Created by liewli on 12/23/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit

class AboutUSView:UIView {
    var imgView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    func initialize() {
        backgroundColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1.0)
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        
        imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.userInteractionEnabled = true
//        let tap = UITapGestureRecognizer(target: self, action: "tapAvatar:")
//        imgView.addGestureRecognizer(tap)
        addSubview(imgView)
        
        imgView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(snp_top)
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.bottom.equalTo(snp_bottom)
        }
        
        
    }
    
//    func tapAvatar(sender:AnyObject) {
//        
//    }
//    

}

class AboutVC:UIViewController, UIScrollViewDelegate {
    private let name_arr = ["李磊", "叶庆仕", "刘历", "宋嘉冀", "刘继龙", "叶枝", "卢硕","王阳","马申斌","董嘉"]
    private let info_arr = ["产品经理", "后端开发工程师", "iOS开发工程师","Android开发工程师","Android开发工程师","UI设计师", "交互设计师","Web前端工程师","产品推广经理","产品运营经理"]
    private let img_arr = ["ll", "yqs", "liewli", "sjj", "ljl", "yz", "ls", "wy", "msb", "dj"]
    
    private let id_arr = ["140", "72", "37", "49", "877", "887", "889", "958", "156", "914"]
    
    var actionLeft:UIButton!
    var titleLabel:UILabel!
    var actionRight:UIButton!
    
    var sheet:IBActionSheet?
    
    private var cardView:UIScrollView!
    
    private var backView:UIImageView!
    
    
    private var visualView:UIVisualEffectView!
    
    private var hostView:UIView!
    
    private var pageControl:UIPageControl!
    
    private var nameLabel:UILabel!
    private var infoLabel:UILabel!
    
    var timer:NSTimer?
    
    private var currentCard:CardContentView? {
        didSet {
          
        }
    }
    
    var scrolling = false
    
    func moveToNext(sender:AnyObject?) {
        if !scrolling  && pageControl.numberOfPages > 0{
            if pageControl.currentPage == pageControl.numberOfPages - 1 {
                pageControl.currentPage = 0
                let offset_x = CGFloat(pageControl.numberOfPages+1) * cardView.frame.size.width
                cardView.scrollRectToVisible(CGRectMake(offset_x, 0, cardView.frame.size.width, cardView.frame.size.height), animated: true)
                pageControl.currentPage = 0
            }
            else {
                pageControl.currentPage = (pageControl.currentPage + 1) % pageControl.numberOfPages
                let offset_x = CGFloat(pageControl.currentPage+1) * cardView.frame.size.width
                cardView.setContentOffset(CGPointMake(offset_x, 0), animated: true)
            }
            refreshBackground(UIImage(named: img_arr[pageControl.currentPage])!)
            refreshInfoAtIndex(pageControl.currentPage)
        }
        
        
        
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "moveToNext:", userInfo: nil, repeats: true)
            
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        configUI()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden =  true
        navigationController?.navigationBar.hidden = true
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        navigationController?.navigationBar.hidden = false
        sheet?.removeFromView()
    }
    
    func setupUI() {
        backView = UIImageView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backView)
        backView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(view.snp_top)
            make.bottom.equalTo(view.snp_bottom)
        }
        
        let blurEffect = UIBlurEffect(style: .Light)
        visualView = UIVisualEffectView(effect: blurEffect)
        visualView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualView)
        visualView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(view.snp_top)
            make.bottom.equalTo(view.snp_bottom)
        }
        
        hostView = UIView()
        hostView.translatesAutoresizingMaskIntoConstraints = false
        hostView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        visualView.contentView.addSubview(hostView)
        hostView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(visualView.contentView.snp_left)
            make.right.equalTo(visualView.contentView.snp_right)
            make.top.equalTo(visualView.contentView.snp_top)
            make.bottom.equalTo(visualView.contentView.snp_bottom)
        }
    
        
        actionLeft = UIButton(type: .System)
        actionLeft.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(actionLeft)
        actionLeft.setImage(UIImage(named: "card_back")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        actionLeft.addTarget(self, action: "tapLeft:", forControlEvents: .TouchUpInside)
        actionLeft.tintColor = UIColor.whiteColor()
        actionLeft.snp_makeConstraints { (make) -> Void in
           make.top.equalTo(hostView.snp_topMargin).offset(10)
            make.centerX.equalTo(hostView.snp_centerX).multipliedBy(0.2)
            make.height.width.equalTo(24)
        }
        
        
        actionRight = UIButton(type: .System)
        actionRight.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(actionRight)
        actionRight.setImage(UIImage(named: "card_more")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        actionRight.addTarget(self, action: "tapRight:", forControlEvents: .TouchUpInside)
        actionRight.tintColor = UIColor.whiteColor()
        actionRight.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(actionLeft.snp_centerY)
            make.centerX.equalTo(hostView.snp_centerX).multipliedBy(1.8)
            make.height.width.equalTo(24)
        }
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .Center
        titleLabel.text = "\(APP)"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        hostView.addSubview(titleLabel)
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(actionLeft.snp_right)
            make.right.equalTo(actionRight.snp_left)
            make.centerY.equalTo(actionLeft.snp_centerY)
        }
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textAlignment = .Center
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont.boldSystemFontOfSize(21)
        hostView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textAlignment = .Center
        infoLabel.textColor = UIColor.whiteColor()
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        hostView.addSubview(infoLabel)
        

        
       
        
        cardView = UIScrollView()
        cardView.delegate = self
        cardView.pagingEnabled = true
        cardView.bounces = false
        cardView.showsHorizontalScrollIndicator = false
        cardView.showsVerticalScrollIndicator = false
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = UIColor.clearColor()
        let tap = UITapGestureRecognizer(target: self, action: "tapCard:")
        cardView.addGestureRecognizer(tap)
        hostView.addSubview(cardView)
         cardView.layer.cornerRadius = 5.0
         cardView.layer.masksToBounds = true
        cardView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(hostView.snp_centerX)
            make.centerY.equalTo(hostView.snp_centerY)
            make.width.equalTo(hostView.snp_width).multipliedBy(0.9)
            make.height.equalTo(cardView.snp_width).multipliedBy(1)
        }
        
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(hostView.snp_left)
            make.right.equalTo(hostView.snp_right)
            make.bottom.equalTo(cardView.snp_top).offset(-20)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(hostView.snp_left)
            make.right.equalTo(hostView.snp_right)
            make.top.equalTo(cardView.snp_bottom).offset(20)
        }

        
        
        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(pageControl)
        pageControl.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(cardView.snp_width)
            make.height.equalTo(20)
            make.bottom.equalTo(cardView.snp_bottom)
            make.centerX.equalTo(cardView.snp_centerX)
        }
        

        
    }
    
    func tapCard(sender:AnyObject) {
        print("called")
        let index  = pageControl.currentPage
        if index >= 0  && index < name_arr.count {
           let vc = InfoVC()
            vc.id = id_arr[index]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func refreshInfoAtIndex(index:Int) {
        
        if index >= 0  && index < name_arr.count {
            nameLabel.text = name_arr[index]
            infoLabel.text = info_arr[index]
            if index == 2 {
            self.nameLabel.transform = CGAffineTransformMakeScale(0, 0)
            self.infoLabel.transform =  CGAffineTransformMakeScale(0, 0)
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                 self.nameLabel.transform = CGAffineTransformMakeScale(2.0, 2.0)
                 self.infoLabel.transform = CGAffineTransformMakeScale(2.0, 2.0)
                }, completion: { (finished) -> Void in
                 UIView.animateWithDuration(1.0, animations: { () -> Void in
                    self.nameLabel.transform = CGAffineTransformIdentity
                    self.infoLabel.transform = CGAffineTransformIdentity
                    }, completion: { (finished) -> Void in
                        //self.nameLabel.transform = CGAffineTransformIdentity
                        //self.infoLabel.transform =  CGAffineTransformIdentity
                 })
                 
            })
            }
            else {
                self.nameLabel.transform = CGAffineTransformIdentity
                self.infoLabel.transform = CGAffineTransformIdentity
            }
            
        }
       
    }
    
    func tapLeft(sender:AnyObject) {
      
        navigationController?.popViewControllerAnimated(true)
    }
    
    func shareToWeChat(scene: UInt32) {
        var image:UIImage?
        image = Utility.imageWithImage(UIImage(named: "app"), scaledToSize: CGSizeMake(100, 100))
        
        let title = "\(APP)唯觅"
        let body = "高校轻社交平台, 让沟通更真实"
        WXApiRequestHandler.sendLinkURL("http://www.weme.space", tagName: "WEME唯觅", title: title, description: body, thumbImage: image, inScene: WXScene.init(rawValue:scene))
    }

    
    
    func tapRight(sender:AnyObject) {
        if WXApi.isWXAppInstalled() {
            sheet = IBActionSheet(title: nil, callback: { [weak self](sheet, index) -> Void in
                if let S = self {
                    if index == 0 {
                        S.shareToWeChat(0)
                    }
                    else if index == 1 {
                         S.shareToWeChat(1)
                    }
                    else if index == 2 {
                        let vc = ComposeMessageVC()
                        vc.recvID = "2"
                        let nav = UINavigationController(rootViewController: vc)
                        S.presentViewController(nav, animated: true, completion: nil)

                    }
                }
                }, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitlesArray: ["分享WEME到微信会话", "分享WEME到微信朋友圈", "联系我们"])
            sheet?.setButtonTextColor(THEME_COLOR)
            sheet?.showInView(self.navigationController!.view)
        }
        else {
            let sheet = IBActionSheet(title: nil, callback: { [weak self](sheet, index) -> Void in
                if let S = self {
                    if index == 0 {
                        let vc = ComposeMessageVC()
                        vc.recvID = "2"
                        let nav = UINavigationController(rootViewController: vc)
                       S.presentViewController(nav, animated: true, completion: nil)
                    }
                }
                }, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitlesArray: ["联系我们"])
            sheet?.setButtonTextColor(THEME_COLOR)
            sheet?.showInView(self.navigationController!.view)

        }
        

    }

    func refreshBackground(image:UIImage) {
        let backImg = Utility.imageWithImage(image, scaledToSize: backView.bounds.size)
        backView.image = backImg
    }
    
    func configUI() {
      
        refreshBackground(UIImage(named:img_arr[0])!)
        refreshInfoAtIndex(0)
        cardView.contentSize = CGSizeMake(cardView.bounds.width * CGFloat(name_arr.count + 2), cardView.bounds.height)
        
        let first = AboutUSView(frame: CGRectMake(0 , 0, cardView.bounds.size.width, cardView.bounds.size.height))
        first.imgView.image = UIImage(named: img_arr[img_arr.count-1])
        cardView.addSubview(first)
        
        for (index, _) in name_arr.enumerate() {
            let about = AboutUSView(frame: CGRectMake(cardView.bounds.width * CGFloat(index + 1), 0, cardView.bounds.size.width, cardView.bounds.size.height))

            about.imgView.image = UIImage(named: img_arr[index])
            cardView.addSubview(about)
        }
        
        let last = AboutUSView(frame: CGRectMake(cardView.bounds.width * CGFloat(name_arr.count + 1) , 0, cardView.bounds.size.width, cardView.bounds.size.height))
        last.imgView.image = UIImage(named: img_arr[0])
        
        cardView.addSubview(last)
        
        cardView.setContentOffset(CGPointMake(cardView.frame.size.width, 0), animated: false)
        pageControl.numberOfPages = name_arr.count
        pageControl.currentPage = 0

    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
         let page = lroundf(Float(scrollView.contentOffset.x / (scrollView.frame.size.width)))
        
        if page == 0 {
            cardView.scrollRectToVisible(CGRectMake(cardView.frame.size.width * CGFloat(pageControl.numberOfPages), 0, cardView.frame.size.width, cardView.frame.size.height), animated: false)
            pageControl.currentPage = pageControl.numberOfPages-1
        }
        else if page == pageControl.numberOfPages + 1 {
            cardView.scrollRectToVisible(CGRectMake(cardView.frame.size.width , 0, cardView.frame.size.width, cardView.frame.size.height), animated: false)
            pageControl.currentPage = 0
        }
        else {
            cardView.scrollRectToVisible(CGRectMake(cardView.frame.size.width*CGFloat(page) , 0, cardView.frame.size.width, cardView.frame.size.height), animated: true)
            pageControl.currentPage = page - 1
        }
        
        refreshBackground(UIImage(named: img_arr[pageControl.currentPage])!)
        refreshInfoAtIndex(pageControl.currentPage)
        
        scrolling = false
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "moveToNext:", userInfo: nil, repeats: true)
        }

    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        scrolling = true
        timer?.invalidate()
        timer = nil
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        if scrollView.contentOffset.x == scrollView.frame.width * CGFloat(pageControl.numberOfPages+1) {
            scrollView.scrollRectToVisible(CGRectMake(cardView.frame.size.width , 0, cardView.frame.size.width, cardView.frame.size.height), animated: false)
        }
    }
    

}

class AboutUSVC:UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var tableView:UITableView!
    private let name_arr = ["李磊", "叶庆仕", "刘历", "宋嘉冀", "刘继龙", "叶枝", "卢硕","王阳","马申斌","董嘉"]
    private let info_arr = ["产品经理", "后端开发工程师", "iOS开发工程师","Android开发工程师","Android开发工程师","UI设计师", "交互设计师","Web前端工程师","产品推广经理","产品运营经理"]
    private let img_arr = ["ll", "yqs", "liewli", "sjj", "ljl", "yz", "ls", "wy", "msb", "dj"]
    
    private let id_arr = ["140", "72", "37", "49", "877", "887", "889", "958", "156", "914"]
    
    private var initialTransform:CGAffineTransform!
    
    private var shownIndexPaths = Set<NSIndexPath>()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  title = "关于\(APP)"
        automaticallyAdjustsScrollViewInsets = false
        let backView = UIImageView(image: UIImage(named: "splash"))
        backView.frame = view.frame
        view.addSubview(backView)
        
//        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongVerticalAxis)
//        verticalMotionEffect.minimumRelativeValue = -50
//        verticalMotionEffect.maximumRelativeValue = 50
//        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongHorizontalAxis)
//        horizontalMotionEffect.minimumRelativeValue = -50
//        horizontalMotionEffect.maximumRelativeValue = 50
//        
//        let group = UIMotionEffectGroup()
//        group.motionEffects = [verticalMotionEffect, horizontalMotionEffect]
//        
//        backView.addMotionEffect(group)
        
        let blurEffect = UIBlurEffect(style: .Light)
        let visualView = UIVisualEffectView(effect: blurEffect)
        visualView.frame = view.frame
        view.addSubview(visualView)
        view.backgroundColor = UIColor.whiteColor()
        tableView = UITableView(frame: view.frame)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.contentInset = UIEdgeInsetsMake(40, 0, 0, 0)
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        
        tableView.registerClass(AboutUSTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(AboutUSTableViewCell))
        initialTransform = CGAffineTransformMakeScale(0, 0)
        
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset < 40 {
            navigationItem.hidesBackButton = false
            //navigationItem.titleView?.hidden = false
        }
        else {
            navigationItem.hidesBackButton = true
           // navigationItem.titleView?.hidden = true
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return name_arr.count
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(AboutUSTableViewCell), forIndexPath: indexPath) as! AboutUSTableViewCell
        cell.avatar.image = UIImage(named: img_arr[indexPath.row])
        cell.nameLabel.text = name_arr[indexPath.row]
        cell.infoLabel.text = info_arr[indexPath.row]
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        //cell.backView.image = UIImage(named: "dev_liuli")?.crop(cell.bounds)
        cell.selectionStyle = .None
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SCREEN_HEIGHT / 5
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return true
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let messageAction = UITableViewRowAction(style:.Default, title: "私信") { (action, indexPath) -> Void in
            let id = self.id_arr[indexPath.row]
            let vc = ComposeMessageVC()
            vc.recvID = id
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        let infoAction = UITableViewRowAction(style: .Default, title: "了解更多") { (action, indexPath) -> Void in
            let id = self.id_arr[indexPath.row]
            let vc = InfoVC()
            vc.id = id
            self.navigationController?.pushViewController(vc, animated: true)
        }
        messageAction.backgroundColor = UIColor.clearColor()
        infoAction.backgroundColor = UIColor.clearColor()
        return [messageAction, infoAction]
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if !shownIndexPaths.contains(indexPath) {
            shownIndexPaths.insert(indexPath)
            if let c = cell as? AboutUSTableViewCell {
                c.avatar.transform = initialTransform
                c.nameLabel.transform = initialTransform
                c.infoLabel.transform = initialTransform
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    c.avatar.transform = CGAffineTransformIdentity
                    c.nameLabel.transform = CGAffineTransformIdentity
                    c.infoLabel.transform = CGAffineTransformIdentity
                })
            }
        }
      
    }

}

extension AboutUSVC:AboutUSTableViewCellDelegate {
    func didTapAvatarAt(cell: AboutUSTableViewCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let avatar = img_arr[indexPath.row]
            let agrume = Agrume(image: UIImage(named: avatar)!)
            agrume.showFrom(self)
        }
    }
}


protocol AboutUSTableViewCellDelegate:class {
    func didTapAvatarAt(cell:AboutUSTableViewCell)
}

class AboutUSTableViewCell : UITableViewCell {
    
    private var avatar:UIImageView!
    private var nameLabel:UILabel!
    private var infoLabel:UILabel!
    weak var delegate:AboutUSTableViewCellDelegate?
    func initialize() {
        backgroundColor = UIColor.clearColor()

    
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = SCREEN_HEIGHT/12
        avatar.layer.masksToBounds = true
        avatar.layer.borderColor = UIColor.whiteColor().CGColor
        avatar.layer.borderWidth = 2
        avatar.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        avatar.addGestureRecognizer(tap)
        contentView.addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        nameLabel.textAlignment = .Center
        contentView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = UIColor.whiteColor()
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        infoLabel.textAlignment = .Center
        contentView.addSubview(infoLabel)
        
        
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.centerY.equalTo(contentView.snp_centerY)
            make.width.height.equalTo(SCREEN_HEIGHT/6)
        }
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(10)
            make.top.equalTo(avatar.snp_top).offset(15)
            make.right.equalTo(contentView.snp_rightMargin)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(10)
            make.bottom.equalTo(avatar.snp_bottom).offset(-15)
            make.right.equalTo(contentView.snp_rightMargin)
        }
        
    }
    
    func tap(sender:AnyObject) {
        delegate?.didTapAvatarAt(self)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
}
