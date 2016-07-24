//
//  Social.swift
//  牵手东大
//
//  Created by liewli on 11/16/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit
import WebImage



class SocialVC:UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate{
    static let BOARD_SCROLLVIEW_HEIGHT:CGFloat = SCREEN_WIDTH*1/2
    
    var timer:NSTimer?
    
    var scrolling = false
    
    var refreshImgs = [UIImage]()
    var refreshControl:UIRefreshControl!
    var currentIndex = 0
    var animateTimer:NSTimer?
    
    let refreshCustomizeImageView = UIImageView()

    weak var interactionController:UIPercentDrivenInteractiveTransition?

    
    var topics = [TopicModel]()
    
    
    //var barBG:UIImage?
    
   // var restartTimer:NSTimer?
    
    func moveToNext(sender:AnyObject?) {
        if !scrolling  && pageControl.numberOfPages > 0{
           if pageControl.currentPage == pageControl.numberOfPages - 1 {
                pageControl.currentPage = 0
                let offset_x = CGFloat(pageControl.numberOfPages+1) * boardScrollView.frame.size.width
                self.boardScrollView.scrollRectToVisible(CGRectMake(offset_x, 0, boardScrollView.frame.size.width, boardScrollView.frame.size.height), animated: true)
                pageControl.currentPage = 0
            
                //self.boardScrollView.scrollRectToVisible(CGRectMake(boardScrollView.frame.size.width, 0, boardScrollView.frame.size.width, boardScrollView.frame.size.height), animated: true)
           }
           else {
                pageControl.currentPage = (pageControl.currentPage + 1) % pageControl.numberOfPages
               let offset_x = CGFloat(pageControl.currentPage+1) * boardScrollView.frame.size.width
               boardScrollView.setContentOffset(CGPointMake(offset_x, 0), animated: true)
            }
        }
        
        
        
    }

    var boardViewModel:BoardViewModel? {
        didSet {
            boardViewModel?.boards.observe {
                [weak self] (board_arr) in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if board_arr.count > 0 {
                        self?.view.layoutIfNeeded()
                        self?.boardScrollView.contentSize = CGSizeMake((self?.view.frame.width)! * CGFloat(board_arr.count+2), SocialVC.BOARD_SCROLLVIEW_HEIGHT)
                  
                        var imgView = UIImageView()//UIImageView(image: imgs[board_arr.count-1])
                        imgView.sd_setImageWithURL(board_arr[board_arr.count-1].imageURL, placeholderImage: UIImage(named: "profile_background"))
                        //imgView.contentMode = UIViewContentMode.ScaleAspectFill
                        imgView.frame = CGRectMake(0, 0, (self?.boardScrollView.frame.width)!, SocialVC.BOARD_SCROLLVIEW_HEIGHT)
                        self?.boardScrollView.addSubview(imgView)
//                        

                        for (index, board) in board_arr.enumerate() {
                            let imgView = UIImageView()
                            //imgView.contentMode = UIViewContentMode.ScaleAspectFill
                            imgView.sd_setImageWithURL(board.imageURL, placeholderImage: UIImage(named: "profile_background"))
                            imgView.frame = CGRectMake((self?.boardScrollView.frame.width)! * CGFloat(index+1), 0, (self?.boardScrollView.frame.width)!, SocialVC.BOARD_SCROLLVIEW_HEIGHT)
                            self?.boardScrollView.addSubview(imgView)
                        }
//
                        imgView = UIImageView()
                        imgView.sd_setImageWithURL(board_arr[0].imageURL, placeholderImage: UIImage(named: "profile_background"))
                        //imgView.contentMode = UIViewContentMode.ScaleAspectFill
                        imgView.frame = CGRectMake((self?.boardScrollView.frame.width)! * CGFloat(board_arr.count+1), 0, (self?.boardScrollView.frame.width)!, SocialVC.BOARD_SCROLLVIEW_HEIGHT)
                        self?.boardScrollView.addSubview(imgView)

                        
                        self?.boardScrollView.setContentOffset(CGPointMake((self?.boardScrollView.frame.size.width)!, 0), animated: false)
                        self?.pageControl.numberOfPages = board_arr.count
                        self?.pageControl.currentPage = 0
                    }

                })
                
            }
        }
    }
    
    let boardScrollView = UIScrollView()
    let pageControl = UIPageControl()
    
    let topicCollectionView:UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(TopicCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TopicCollectionViewCell))
        collectionView.registerClass(CollectionSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(CollectionSectionHeaderView))
        return collectionView
    }()
    
    private var _view :UIScrollView!
    private var contentView :UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        title = "社区"
        navigationController?.navigationBar.barStyle = .Black
       // barBG = navigationController?.navigationBar.backgroundImageForBarMetrics(.Default)
        setUI()
        boardViewModel = BoardViewModel()
        refreshControl = UIRefreshControl()
        //refreshControl.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200)
       // refreshControl.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin]
        refreshControl.backgroundColor =  THEME_COLOR//UIColor.blackColor()//UIColor.colorFromRGB(0x104E8B)//UIColor.blackColor()//SECONDAY_COLOR//UIColor.clearColor()
        refreshControl.tintColor = UIColor.clearColor()
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        _view.addSubview(refreshControl)
       // _view.backgroundColor = SECONDAY_COLOR
        contentView.backgroundColor = UIColor.whiteColor()
        loadRefreshContents()
        //navigationController?.navigationBar.shadowImage = UIImage()
        removeNavBorderLine()
        configUI()
        
        if #available(iOS 9, *) {
            if self.traitCollection.forceTouchCapability == .Available {
                self.registerForPreviewingWithDelegate(self, sourceView: topicCollectionView)
            }
        }
        
      // self.n-avigationController?.delegate = self
    }
    
//    
//    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return interactionController
//    }
//    
//    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        if case .Push = operation {
//            return NavigationPushAnimator()
//        }
//        else if case .Pop = operation {
//            return NavigationPopAnimator()
//        }
//        
//        return nil
//    }
    
    
    
    
    
    func removeNavBorderLine() {
        if let nav = navigationController {
            var flag = false
            for v in nav.navigationBar.subviews {
                if !flag {
                    for vv in v.subviews {
                        if vv is UIImageView && vv.frame.size.height < 2 {
                            vv.removeFromSuperview()
                            flag = true
                            break
                        }
                    }
                }
            }
        }
    }
    
    func refresh(sender:UIRefreshControl) {
        // print("called refresh")
        for k in 1..<110 {
            //refreshImgs.append(UIImage(named: "RefreshContents.bundle/loadding_\(k)")!)
            let imagePath = NSBundle.mainBundle().pathForResource("RefreshContents.bundle/loadding_\(k)", ofType: "png")
            refreshImgs.append(UIImage(contentsOfFile:imagePath!)!)
            
        }
        animateTimer = NSTimer.scheduledTimerWithTimeInterval(0.015, target: self, selector: "tick:", userInfo: nil, repeats: true)
        //animateRefresh()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
            self.configUI()
        }

        let endTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * NSEC_PER_SEC))
        dispatch_after(endTime, dispatch_get_main_queue()) { () -> Void in
            self.refreshControl.endRefreshing()
        }
    }
    
    func loadRefreshContents() {
        
        refreshCustomizeImageView.contentMode = .ScaleAspectFill
        let rect = CGRectMake(view.center.x-40, 0, 80, 80)
        
        refreshCustomizeImageView.frame = rect
        refreshCustomizeImageView.backgroundColor = UIColor.clearColor()
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
        animateTimer?.invalidate()
        animateTimer = nil
        refreshImgs.removeAll()
        //print(refreshImgs.count)
        //_view.backgroundColor = UIColor.whiteColor()
    }

    
    
    func configUI() {
        boardViewModel?.fetchBoardInfo()
        fetchTopic()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = false
       // navigationController?.navigationBar.setBackgroundImage(barBG, forBarMetrics: .Default)
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR//UIColor.colorFromRGB(0x104E8B)//UIColor.blackColor()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
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
    
    func setupScrollView() {
        //view.backgroundColor =UIColor.colorFromRGB(0x1874CD)//UIColor.blackColor()
        _view = UIScrollView()
        _view.backgroundColor = UIColor.whiteColor()
        view.addSubview(_view)
        _view.translatesAutoresizingMaskIntoConstraints = false
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[_view]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["_view":_view])
        view.addConstraints(constraints)
        var constraint = NSLayoutConstraint(item: _view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: _view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal , toItem:view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        contentView = UIView()
        _view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[contentView]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["contentView":contentView])
        _view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[contentView]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["contentView":contentView])
        _view.addConstraints(constraints)
        
        constraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //print(contentView.frame.size.height)
        // print(_view.contentSize.height)
 
        
        //print(topicCollectionView.collectionViewLayout.collectionViewContentSize().height, topicCollectionView.frame.height)
        if topicCollectionView.collectionViewLayout.collectionViewContentSize().height > topicCollectionView.frame.height {
            topicCollectionView.snp_updateConstraints(closure: { (make) -> Void in
                make.height.equalTo(topicCollectionView.collectionViewLayout.collectionViewContentSize().height)
                
            })
        }
        
        
        if _view.contentSize.height < view.frame.height {
            contentView.snp_makeConstraints { (make) -> Void in
                make.height.greaterThanOrEqualTo(view.snp_height).offset(5).priorityHigh()
                
            }
            
        }
        
        _view.layoutIfNeeded()
        
    }
    
    func tapBoard(sender:AnyObject) {
        guard pageControl.currentPage < boardViewModel?.boards.value.count else {
            return
        }
        if let postID = boardViewModel?.boards.value[pageControl.currentPage].postID{
            let vc = PostVC()
            vc.postID = postID
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    func setUI() {
        
        setupScrollView()
        let TapGesture = UITapGestureRecognizer(target: self, action: "tapBoard:")
        boardScrollView.addGestureRecognizer(TapGesture)
        boardScrollView.pagingEnabled = true
        boardScrollView.translatesAutoresizingMaskIntoConstraints = false
        boardScrollView.bounces = false
        boardScrollView.showsHorizontalScrollIndicator = false
        boardScrollView.showsVerticalScrollIndicator = false
        boardScrollView.backgroundColor = BACK_COLOR
        contentView.addSubview(boardScrollView)
        boardScrollView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.width.equalTo(view.snp_width)
            make.top.equalTo(contentView.snp_top)
            make.height.equalTo(SocialVC.BOARD_SCROLLVIEW_HEIGHT)
        }
        boardScrollView.delegate = self
       // boardScrollView.setContentOffset(CGPointMake(0, 0), animated: false)
        contentView.addSubview(pageControl)
        pageControl.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(view.snp_width)
            make.height.equalTo(20)
            make.bottom.equalTo(boardScrollView.snp_bottom)
            make.centerX.equalTo(view.snp_centerX)
        }
        
        //pageControl.addTarget(self, action: "changePage:", forControlEvents: .ValueChanged)
        topicCollectionView.dataSource = self
        topicCollectionView.delegate = self
        
        topicCollectionView.translatesAutoresizingMaskIntoConstraints = false
        topicCollectionView.contentInset = UIEdgeInsetsMake(0, TOPIC_CELL_SPACE, 0, TOPIC_CELL_SPACE)
        topicCollectionView.scrollEnabled = false
        contentView.addSubview(topicCollectionView)
        topicCollectionView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(boardScrollView.snp_bottom).offset(10)
            //make.height.equalTo(200)
        }
        contentView.snp_makeConstraints { (make) -> Void in
            let h = tabBarController?.tabBar.frame.size.height ?? 5
            make.bottom.greaterThanOrEqualTo(topicCollectionView.snp_bottom).offset(h).priorityLow()
        }
        
    }
    
    func changePage(sender:AnyObject?) {
        let offset_x = CGFloat(pageControl.currentPage+1) * boardScrollView.frame.size.width
        boardScrollView.setContentOffset(CGPointMake(offset_x, 0), animated: true)
    }
    
    
    //MARK: FETCH TOPIC
    
    func fetchTopic() {
        if let t = token {
             request(.POST, GET_TOPIC_LIST, parameters: ["token":t], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let S = self {
                    if let d = response.result.value {
                        let json = JSON(d)
                        if json["state"] == "successful" {
                            guard let arr = json["result"].array where arr.count > 0 else {
                                return
                            }
                            do {
                                let topics = try MTLJSONAdapter.modelsOfClass(TopicModel.self, fromJSONArray: json["result"].arrayObject) as? [TopicModel]
                                if let t = topics where t.count > 0 {
                                    S.topics = t
                                    TopicCache.sharedCache.saveTopics(t)
                                    S.topicCollectionView.invalidateIntrinsicContentSize()
                                    S.topicCollectionView.reloadData()
                                }
                            }
                            catch {
                                print(error)
                            }
                            
                        }
                    }
                    
                    else {
                        TopicCache.sharedCache.loadTopicsWithCompletionBlock({ [weak S](topic) -> Void in
                            if let t = topic , SS = S where t.count > 0 {
                                SS.topics = t
                                SS.topicCollectionView.invalidateIntrinsicContentSize()
                                SS.topicCollectionView.reloadData()

                            }
                        })
                    }
                    S.refreshControl.endRefreshing()
                }
             })
        }
       
    }
    
}

@available(iOS 9.0, *)
extension SocialVC:UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        let nav = viewControllerToCommit as! UINavigationController
        showViewController(nav.viewControllers[0], sender: self)
    }
    
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = self.topicCollectionView.indexPathForItemAtPoint(location){
            previewingContext.sourceRect = topicCollectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath)!.frame
            let vc = TopicVC(topic: topics[indexPath.item].topicID)
            let nav = UINavigationController(rootViewController: vc)
            return nav
        }
        
        return nil
    }
    
}

extension SocialVC:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(TopicCollectionViewCell), forIndexPath: indexPath) as! TopicCollectionViewCell
        
            let data = topics[indexPath.item]
            cell.imgView.sd_setImageWithURL(data.imageURL)
            cell.titleLabel.text = data.theme
            cell.infoLabel.text = data.footNote
            let num = Int(data.hotIndex)
            cell.badge.badgeText = num > 999 ? "999+" : data.hotIndex
            cell.badge.setNeedsDisplay()
            return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count//section == 0 ? topics.count : topics.count
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(TOPIC_CELL_WIDTH, TOPIC_CELL_HEIGHT+40)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return TOPIC_CELL_SPACE
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(SCREEN_WIDTH, 20)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let data = topics[indexPath.item]
            let vc = TopicVC(topic: data.topicID)
            vc.title = data.theme
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension SocialVC:UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = lroundf(Float(boardScrollView.contentOffset.x / (boardScrollView.frame.size.width)))
        
        if page == 0 {
            self.boardScrollView.scrollRectToVisible(CGRectMake(boardScrollView.frame.size.width * CGFloat(pageControl.numberOfPages), 0, boardScrollView.frame.size.width, boardScrollView.frame.size.height), animated: false)
            pageControl.currentPage = pageControl.numberOfPages-1
        }
        else if page == pageControl.numberOfPages + 1 {
            self.boardScrollView.scrollRectToVisible(CGRectMake(boardScrollView.frame.size.width , 0, boardScrollView.frame.size.width, boardScrollView.frame.size.height), animated: false)
            pageControl.currentPage = 0
        }
        else {
            self.boardScrollView.scrollRectToVisible(CGRectMake(boardScrollView.frame.size.width*CGFloat(page) , 0, boardScrollView.frame.size.width, boardScrollView.frame.size.height), animated: true)
            pageControl.currentPage = page - 1
        }
       
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
        if boardScrollView.contentOffset.x == boardScrollView.frame.width * CGFloat(pageControl.numberOfPages+1) {
            self.boardScrollView.scrollRectToVisible(CGRectMake(boardScrollView.frame.size.width , 0, boardScrollView.frame.size.width, boardScrollView.frame.size.height), animated: false)
        }
    }
    
    
    
}



class BoardViewModel {
 
    private var boards:Observable<[TopicBoardModel]> = Observable([])
    
    func fetchBoardInfo() {
        if let t = token {
            request(.POST, TOP_BOARD_URL, parameters: ["token":t], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let S = self {
                    if let d = response.result.value {
                        let json = JSON(d)
                        if json["state"].stringValue == "successful" {
                            guard let arr = json["result"].array where
                                arr.count > 0 else {
                                return
                            }
                            
                            do {
                                if let topics = try MTLJSONAdapter.modelsOfClass(TopicBoardModel.self, fromJSONArray: json["result"].arrayObject) as? [TopicBoardModel] where topics.count > 0 {
                                    S.boards.value = topics
                                    TopicBoardCache.sharedCache.saveTopics(topics)
                                }
                                
                            }
                            catch {
                                print(error)
                            }
                        }
                        
                    }
                    else {
                        TopicBoardCache.sharedCache.loadTopicsWithCompletionBlock({ [weak S](topics) -> Void in
                            if let SS = S, t = topics where t.count > 0{
                                SS.boards.value = t
                            }
                        })
                    }
                }
            })
        }
        
    }
    
    
}

//MARK: - TopicCollectionView

let TOPIC_CELL_WIDTH:CGFloat = (SCREEN_WIDTH-4*TOPIC_CELL_SPACE-20) / 3
let TOPIC_CELL_HEIGHT:CGFloat = TOPIC_CELL_WIDTH * 3/5
let TOPIC_CELL_SPACE:CGFloat = 10



class TopicCollectionViewCell:UICollectionViewCell {
    let imgView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        return imageView
    }()
    
    let titleLabel = UILabel()
    let infoLabel = UILabel()
    static let badgeStyle = BadgeStyle.freeStyleWithTextColor(UIColor.redColor(), withInsetColor: UIColor.whiteColor(), withFrameColor: UIColor.whiteColor(), withFrame: false, withShadow: false, withShining: false, withFontType: BadgeStyleFontTypeHelveticaNeueLight)
    
    let badge = CustomBadge(string: "1", withScale: 0.6, withStyle: TopicCollectionViewCell.badgeStyle)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
   
    
    func initialize() {
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        infoLabel.textColor = UIColor.lightGrayColor()
        infoLabel.textAlignment = .Center
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        contentView.addSubview(imgView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(badge)
        
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.width.equalTo(TOPIC_CELL_WIDTH)
            make.height.equalTo(TOPIC_CELL_HEIGHT)
            
        }
        
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(imgView.snp_top).offset(2)
            make.right.equalTo(imgView.snp_right).offset(-2)
            make.height.equalTo(16)
            make.width.equalTo(26)
        }
        
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(imgView.snp_bottom).offset(5)
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
        }
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp_bottom)
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.bottom.equalTo(contentView.snp_bottom).priorityLow()
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
        }
        
//        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
    }
    
 
}

class CollectionSectionHeaderView:UICollectionReusableView {
    
    let titleLabel = UILabel()
    let seperator = UIView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    convenience init() {
        self.init(frame:CGRectZero)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func initialize() {
        addSubview(titleLabel)
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        titleLabel.textColor = UIColor.lightGrayColor()
        addSubview(seperator)
        seperator.backgroundColor = BACK_COLOR
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        seperator.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.top.equalTo(snp_top)
        }
        
        seperator.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(titleLabel.snp_bottom).offset(2)
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.height.equalTo(2)
            make.bottom.equalTo(snp_bottom).offset(-5)
        }
    }
}



