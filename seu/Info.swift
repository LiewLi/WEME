//
//  Info.swift
//  WEME
//
//  Created by liewli on 2016-01-18.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit
import RSKImageCropper
import LiquidFloatingActionButton

enum MenuBarState {
    case dock(CGFloat, CGFloat, CGFloat)
    case float(CGFloat)
}

protocol InfoVCPreviewDelegate:class {
    func didTapMessage(id:String)
    func didTapUnfollow(id:String)
}

/*
class InfoVC:UIViewController, UITableViewDataSource, UITableViewDelegate, FloatingActionViewDelegate, EZAudioPlayerDelegate{
    enum AudioState {
        case Play
        case Stop
    }
    var currentAudioState:AudioState = .Stop

    var coverImageView:UIImageView!
    var tableView:UITableView!
    
    private var statusBarView:UIView?
    
    var id:String!
    
    var headerView:PersonalHeaderView!
    
    var menuBar:MenuBarView!
    
    let menu = ["资料", "时间轴", "图集"]
    
    var audioAction:FloatingActionView!
    var player:EZAudioPlayer!

    
    var currentIndex = 0
    
    var info:PersonModel?
    
    var events = [TimelineModel]()
    
    var timelineCurrentPage = 1
    
    weak var delegate:InfoVCPreviewDelegate?
    
    var sheet:IBActionSheet?
    
    var floatingCells = [LiquidFloatingCell]()
    
    var imgIDSet = Set<String>()
    var postIDSet = Set<String>()
    
    private let infos = ["姓名", "年龄", "学校", "学历", "专业", "家乡", "QQ", "微信", "标签"]
    private let sectionRows = [2, 3, 1, 2, 1]
    
    
    var tags = [String]()//["生活不止眼前的苟且", "技术宅", "果粉", "全栈工程师", "生活不止眼前的苟且，还有诗和远方的田野, 我赤手空拳来到人世间，我看那片海不顾一切", "bigbang", "Geek", "音乐发烧友"]
    
    //private var images = [UserImageModel]()
    
    private var personalImages = [PersonalImageModel]()
    private var imageCurrentPage = 1
    
    var currentMenuBarState:MenuBarState = .float(0)
    
    @available(iOS 9, *)
    override func previewActionItems() -> [UIPreviewActionItem] {
        let message = UIPreviewAction(title: "私信", style: .Default) { (action, viewController) -> Void in
            self.delegate?.didTapMessage(self.id)
        }
        
        let unfollow = UIPreviewAction(title: "取消关注", style: .Destructive) { (action, vc) -> Void in
            self.delegate?.didTapUnfollow(self.id)
        }
    
        
        return [message, unfollow]
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let action = UIBarButtonItem(image: UIImage(named: "more")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: "action:")
        action.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = action
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "editInfo:", name: EDIT_INFO_NOTIFICATION, object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.editTags(_:)), name: EditTagViewController.EDIT_TAG_NOTIFICATION, object: nil)
        setupUI()
        visit()
        configUI()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.uploadPersonalImageNotify(_:)), name: UploadPersonalImageVC.UPLOAD_PERSONAL_IMAGE_NOTIFICATION, object: nil)
    }
    
    
    func editTags(sender:NSNotification) {
        fetchTags()
    }
    
    func uploadPersonalImageNotify(sender:NSNotification) {
        personalImages.removeAll()
        imgIDSet.removeAll()
        if (self.currentIndex == 2) {
            fetchPersonalImages()
        }
        
    }
    
    
    func visit() {
        if let t = token, id = id {
            request(.POST, VISIT_URL, parameters: ["token":t, "userid":id], encoding: .JSON).responseJSON(completionHandler: { (response) -> Void in
                
            })
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if statusBarView != nil {
            statusBarView?.removeFromSuperview()
        }
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
        //statusBarView?.alpha = 0
        navigationController?.navigationBar.alpha = 1.0
        statusBarView?.backgroundColor = UIColor.clearColor()
        sheet?.removeFromView()
        if player != nil {
            player.pause()
        }
    }
    
    func editInfo(sender:NSNotification) {
        if let ID = myId where ID == id {
            headerView.avatar.sd_setImageWithURL(thumbnailAvatarURL(), placeholderImage: UIImage(named: "avatar"))
            fetchInfo()
        }
    }
    
    func tapCover(sender:AnyObject) {
        if let id = myId, pid = info?.ID where id == pid {
            sheet = IBActionSheet(title: nil, callback: { (sheet, index) -> Void in
                if index == 0 {
                    let imagePicker = UIImagePickerController()
                    imagePicker.navigationBar.barStyle = .Black
                    imagePicker.sourceType = .PhotoLibrary
                    imagePicker.delegate = self
                    self.presentViewController(imagePicker, animated: true, completion: nil)
                }
          
                }, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitlesArray: ["改变背景照"])
            sheet?.setButtonTextColor(THEME_COLOR)
            sheet?.showInView(navigationController!.view)
        }

    }
    
    func action(sender:AnyObject) {
        if let ID = myId where ID != id {
            sheet = IBActionSheet(title: nil, callback: { (sheet, index) -> Void in
                if index == 0 {
                    let alertText = AlertTextView(title: "举报", placeHolder: "犀利的写下你的举报内容吧╮(╯▽╰)╭")
                    alertText.delegate = self
                    alertText.showInView(self.navigationController!.view)
                }
                else if index == 1 {
                    let vc = ComposeMessageVC()
                    vc.recvID = self.id
                    let nav = UINavigationController(rootViewController: vc)
                    self.presentViewController(nav, animated: true, completion: nil)
                }
                }, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitlesArray: ["举报", "私信"])
            sheet?.setButtonTextColor(THEME_COLOR)
            sheet?.showInView(navigationController!.view)
        }
        else {
            sheet = IBActionSheet(title: nil, callback: { (sheet, index) -> Void in
                if index == 0 {
                    self.navigationController?.pushViewController(MyQRCodeVC(), animated: true)
                }
                else if index == 1 {
                    self.navigationController?.pushViewController(EditInfoVC(), animated: true)
                }
                else if index == 2 {
                    let imagePicker = UIImagePickerController()
                    imagePicker.navigationBar.barStyle = .Black
                    imagePicker.sourceType = .PhotoLibrary
                    imagePicker.delegate = self
                    self.presentViewController(imagePicker, animated: true, completion: nil)
                }
                }, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitlesArray: ["我的二维码","修改个人信息", "改变背景照"])
            sheet?.setButtonTextColor(THEME_COLOR)
            sheet?.showInView(navigationController!.view)
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
        
        if statusBarView != nil {
            statusBarView?.removeFromSuperview()
            statusBarView = nil
        }
        statusBarView = UIView(frame: CGRectMake(0, -20, SCREEN_WIDTH, 20))
        statusBarView?.backgroundColor = UIColor.clearColor()
        navigationController?.navigationBar.addSubview(statusBarView!)
        
        scrollViewDidScroll(tableView)
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
    
        if yOffset >= -SCREEN_WIDTH + SCREEN_WIDTH * 2 / 3 && yOffset <= 0  {
            let r = yOffset / (-SCREEN_WIDTH + SCREEN_WIDTH * 2 / 3)
            let yy = (-SCREEN_WIDTH + SCREEN_WIDTH * 2 / 3) * (2*r - r*r)
            coverImageView.frame = CGRectMake(0,  -SCREEN_WIDTH + SCREEN_WIDTH * 2 / 3 - yy, SCREEN_WIDTH, SCREEN_WIDTH )
        }
        else {
            coverImageView.frame = CGRectMake(0,  -SCREEN_WIDTH + SCREEN_WIDTH * 2 / 3 - yOffset, SCREEN_WIDTH, SCREEN_WIDTH )
        }
     
        
        if yOffset <= SCREEN_WIDTH*2/3 - 60 {
            title = ""
            menuBar.frame = CGRectMake(0, SCREEN_WIDTH * 2 / 3  - yOffset, SCREEN_WIDTH, 40)
            currentMenuBarState = .float(yOffset)
        }
        else {
            title = info?.name ?? ""
            menuBar.frame = CGRectMake(0, 60, SCREEN_WIDTH, 40)
            if case .float(_) = currentMenuBarState {
                currentMenuBarState = .dock(yOffset, yOffset, yOffset)
            }
            else if case let .dock(left, mid, right) = currentMenuBarState {
                if currentIndex == 0 {
                    currentMenuBarState = .dock(yOffset, mid, right)
                }
                else if currentIndex == 1 {
                    currentMenuBarState = .dock(left, yOffset, right)
                }
                else if currentIndex == 2 {
                    currentMenuBarState = .dock(left, mid, yOffset)
                }
            }

        }
        
       
        
        if yOffset <= 10 {
            navigationController?.navigationBar.translucent = true
            navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
            navigationController?.navigationBar.alpha = 1.0
            statusBarView?.backgroundColor = UIColor.clearColor()
        }
        else if yOffset <= SCREEN_WIDTH*2/3 - 60{
            navigationController?.navigationBar.backgroundColor = THEME_COLOR
            statusBarView?.backgroundColor = THEME_COLOR
            navigationController?.navigationBar.alpha = (yOffset-10)/((SCREEN_WIDTH*2/3 - 70.0))
        }
        else {
            navigationController?.navigationBar.backgroundColor = THEME_COLOR
            statusBarView?.backgroundColor = THEME_COLOR
            navigationController?.navigationBar.alpha = 1
        }
        
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, reachedEndOfAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue(), { [weak self]() -> Void in
            if let S = self {
                S.player.pause()
                S.toggleState()
            }
            })
        
    }
    
    

    
    func toggleState() {
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.toValue = -2*M_PI
        rotate.duration = 0.6
        rotate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        CATransaction.setCompletionBlock { [weak self]() -> Void in
            if let S = self{
                if case .Play = S.currentAudioState {
                    S.audioAction.imageView.tintColor = MenuBarView.HIGHLIGHTED_COLOR
                }
                else {
                    S.audioAction.imageView.tintColor = UIColor.whiteColor()
                }
                
            }
            
        }
        audioAction.layer.addAnimation(rotate, forKey: "rotation")
        CATransaction.commit()
        audioAction.transform = CGAffineTransformIdentity
        switch currentAudioState {
        case .Play:
            player.pause()

            currentAudioState = .Stop
        case .Stop:
            player.pause()
            currentAudioState = .Play
        }
        
    }

    
    func didTapFloatingAction(action: FloatingActionView) {
        toggleState()
        if case .Play = currentAudioState {
            if let p = info where p.voiceURL != nil {
                download(.GET, p.voiceURL.absoluteString, destination: { (url, response) -> NSURL in
                    debugPrint(response)
                    let directory = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
                    return directory.URLByAppendingPathComponent("voice_\(p.ID)")
                }).response(completionHandler: { [weak self](_, _, data, error) -> Void in
                    if let S = self where error == nil {
                        let directory = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
                        let fileurl = directory.URLByAppendingPathComponent("voice_\(p.ID)")
                        let file = EZAudioFile(URL: fileurl)
                        if file != nil {
                            S.player.playAudioFile(file)

                        }
                        
                    }
                    else {
                        print(error)
                    }
                    })
            }
        }

    }
    
    func setupAudio() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        }
        catch {
            print(error)
        }
        if player == nil {
            player = EZAudioPlayer(delegate: self)
        }
    }
    
    func setupUI() {

        
        view.backgroundColor = BACK_COLOR
        coverImageView = UIImageView(frame:CGRectMake(0, -SCREEN_WIDTH + SCREEN_WIDTH * 2 / 3, SCREEN_WIDTH, SCREEN_WIDTH ))
        view.addSubview(coverImageView)
      
        
        tableView = UITableView(frame: view.frame)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        tableView.registerClass(InfoTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(InfoTableViewCell))
        tableView.registerClass(ThreeImageTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ThreeImageTableViewCell))
        tableView.registerClass(TimelineTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TimelineTableViewCell))
        
        tableView.registerClass(TagTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TagTableViewCell))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clearColor()
        view.addSubview(tableView)
        headerView = PersonalHeaderView(frame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 2 / 3))
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0)
        
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 100
        
        menuBar = MenuBarView(frame: CGRectMake(0, SCREEN_WIDTH * 2 / 3, SCREEN_WIDTH, 40))
        menuBar.delegate = self
        view.addSubview(menuBar)
        
        //MARK: -setup action menu
        if let Id = myId where Id != self.id {
            audioAction = FloatingActionView(center: CGPointMake(view.frame.size.width/2, view.frame.size.height-60), radius: 30, color: ICON_THEME_COLOR, icon: UIImage(named: "voice")!, scrollview:tableView)
            audioAction.hideWhileScrolling = true
            audioAction.delegate = self
            audioAction.hidden = true
            view.addSubview(audioAction)

        }
        
        else {
           setupActionMenu()
        }
    }
    
    func setupActionMenu() {
        let createButton: (CGRect, LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton = { (frame, style) in
            let floatingActionButton = LiquidFloatingActionButton(frame: frame)
            floatingActionButton.animateStyle = style
            floatingActionButton.dataSource = self
            floatingActionButton.delegate = self
            floatingActionButton.color = ICON_THEME_COLOR
            return floatingActionButton
        }
        
        let cellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            return LiquidFloatingCell(icon: UIImage(named: iconName)!)
        }
        
        floatingCells.append(cellFactory("voice"))
        floatingCells.append(cellFactory("photo_album"))
        floatingCells.append(cellFactory("tag"))

        let floatingFrame = CGRect(x: self.view.frame.width/2 - 60/2, y: self.view.frame.height - 60 - 16, width: 60, height: 60)
        let bottomRightButton = createButton(floatingFrame, .Up)
        
        self.view.addSubview(bottomRightButton)
    }
    
    
      
    func fetchVisitInfo() {
        if let t = token, id = id {
            request(.POST, GET_VISIT_INFO_URL, parameters: ["token": t, "userid":id], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" && json["result"] != .null && json["result"]["today"] != .null else {
                        return
                    }
                    
                    S.headerView.infoLabel.text = "今日访问 \((json["result"]["today"]).stringValue)  总访问 \(json["result"]["total"].stringValue)"
                    
                }
                
                
                
                })
        }
        
    }
    
    func fetchLikeInfo() {
        if let t = token {
            request(.POST, GET_LIKED_NUMBER_URL, parameters: ["token":t], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                if let S = self, d = response.result.value {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        return
                    }
                    S.headerView.likeInfoLabel.hidden = false
                    let number = json["likenumber"].stringValue
                    let attText = NSMutableAttributedString(string: "已被 \(number) 人喜欢")
                    attText.addAttributes([NSForegroundColorAttributeName:UIColor.colorFromRGB(0xD0104C), NSFontAttributeName: UIFont.italicSystemFontOfSize(18)], range: NSMakeRange(3, number.characters.count))
                    S.headerView.likeInfoLabel.attributedText = attText
                }
            })
        }
    }
    
    func fetchTags() {
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
                        
                        if S.currentIndex == 0 {
                            S.tableView.reloadData()
                        }

                    }
                }
                })
        }
    }

    
    func fetchInfo() {
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
                        S.headerView.moreInfoLabel.text = p.constellation
                        S.headerView.gender.image = p.gender == "男" ? UIImage(named: "male") : (p.gender == "女" ? UIImage(named: "female") : nil)
                        S.headerView.verifiedIcon.hidden = !p.verified
                        if p.voiceURL != nil && S.audioAction != nil {
                            S.audioAction.hidden = false
                            S.setupAudio()
                        }
                        if S.currentIndex == 0 {
                            S.tableView.reloadData()
                        }
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
                else if let S = self {
                    ProfileCache.sharedCache.loadProfileWithCompletionBlock({ [weak S](info) -> Void in
                        if let p = info, SS = S {
                            SS.info = p
                            if SS.currentIndex == 0 {
                                SS.tableView.reloadData()
                            }
                        }
                    })
                }
                
                
                
            })
        }
        
        
    }
    
    func fetchEvents() {
        if let t = token{
            request(.POST, GET_USER_TIMELINE, parameters: ["token":t, "userid":id, "page":"\(timelineCurrentPage)"], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null  && json["state"].stringValue == "successful" else {
                        return
                    }
                    do {
                        let events = try MTLJSONAdapter.modelsOfClass(TimelineModel.self, fromJSONArray: json["result"].arrayObject) as! [TimelineModel]
                        if events.count > 0 {
                            S.postPreProcess(events)
                        }
                    }
                    catch let e as NSError {
                        print(e)
                    }
                }
                })
        }
    }
    
//    func fetchImages() {
//        if let t = token {
//            request(.POST, GET_USER_TIMELINE_IMAGES, parameters: ["token":t, "userid":id, "page":"\(imageCurrentPage)"], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
//                debugPrint(response)
//                if let d = response.result.value, S = self {
//                    let json = JSON(d)
//                    guard json != .null && json["state"].stringValue == "successful" else {
//                        return
//                    }
//                    
//                    do {
//                        let imgs = try MTLJSONAdapter.modelsOfClass(UserImageModel.self, fromJSONArray: json["result"].arrayObject) as! [UserImageModel]
//                        if imgs.count > 0 {
//                            S.imageCurrentPage++
//                            S.images.appendContentsOf(imgs)
//                            if (S.currentIndex == 2) {
//                                S.tableView.reloadData()
//                            }
//                            
//                        }
//                    }
//                    catch let e as NSError {
//                        print(e)
//                    }
//                }
//                })
//        }
//    }
    
    lazy var queue:dispatch_queue_t = {
        let q = dispatch_queue_create("weme.info.image", DISPATCH_QUEUE_SERIAL)
        return q
    }()
    
    
    func preProcess(c:[PersonalImageModel]) {
        dispatch_async(queue) { () -> Void in
            if c.count > 0 {
                var imgs = [PersonalImageModel]()
                for cc in c {
                    if self.imgIDSet.contains(cc.imgID) {
                        continue
                    }
                    else {
                        imgs.append(cc)
                        self.imgIDSet.insert(cc.imgID)
                    }
                }
                if imgs.count  > 0 {
                    self.personalImages.appendContentsOf(imgs)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if self.currentIndex == 2 {
                            self.tableView.reloadData()
                        }
                    })

                }
                
                
            }
        }
    }
    
    lazy var postQueue:dispatch_queue_t = {
        let q = dispatch_queue_create("weme.info.post", DISPATCH_QUEUE_SERIAL)
        return q
    }()
    
    
    func postPreProcess(c:[TimelineModel]) {
        dispatch_async(postQueue) { () -> Void in
            if c.count > 0 {
                var ts = [TimelineModel]()
                var k = self.events.count
                let indexSets = NSMutableIndexSet()
                for cc in c {
                    if self.postIDSet.contains(cc.postid) {
                        continue
                    }
                    else {
                        ts.append(cc)
                        self.postIDSet.insert(cc.postid)
                        indexSets.addIndex(k)
                        k += 1
                        
                    }
                }
                if ts.count  > 0 {
                    self.events.appendContentsOf(ts)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if self.currentIndex == 1 {
                            self.timelineCurrentPage += 1
                            if self.currentIndex == 1 {
                                self.tableView.insertSections(indexSets, withRowAnimation: .Fade)
                                
                            }

                        }
                    })
                    
                }
                
                
            }
        }
    }


    
    func fetchPersonalImages() {
        var img_id = "0"
        if personalImages.count > 0 {
            img_id = personalImages[personalImages.count - 1].imgID
        }
        if let t = token {
            request(.POST, GET_PERSONAL_IMAGES_URL, parameters: ["token":t, "userid":id,"previous_id":"\(img_id)"], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        return
                    }
                    
                    do {
                        if let imgs = try MTLJSONAdapter.modelsOfClass(PersonalImageModel.self, fromJSONArray: json["result"].arrayObject) as? [PersonalImageModel] where imgs.count > 0 {
                            S.preProcess(imgs)
                        }
                    }
                    catch let e as NSError{
                        print(e)
                    }
                    
                }
            })
        }
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
                    if S.currentIndex == 0 {
                        S.fetchInfo()
                    }
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
                            
                            if S.currentIndex == 0 {
                                S.fetchInfo()
                            }
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


    
    func configUI() {
        fetchVisitInfo()
        fetchInfo()
        fetchTags()
        if let Id = myId where Id == self.id{
            fetchLikeInfo() 
        }
        //fetchEvents()
        coverImageView.sd_setImageWithURL(profileBackgroundURLForID(id), placeholderImage: UIImage(named: "info_default"))
        headerView.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(id), placeholderImage: UIImage(named: "avatar"))
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if currentIndex == 0 {
             return section == 0 ? 40 : 20
        }
        else if currentIndex == 1 {
            return section == 0 ? 40 : 10
        }
        else {
            return section == 0 ? 40 : 20
        }
       
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRectZero)
        return v
    }
    
    
    func cellHeight(tags:[String], inBoundingSize S:CGSize)->CGFloat {
        var hx:CGFloat = 0
        var hy:CGFloat = 0
        var tmp:CGFloat = 0
      // print("S width:\(S.width)")
      // print("tags count\(tags.count)")
      //var r = 0
        for t in tags {
            let b = (t as NSString).boundingRectWithSize(CGSizeMake(S.width-30, S.height), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)], context: nil)
              // print("\(t):rect:\(b.size.width)")
            if hx + b.size.width + 10   > (S.width-20) {
                hx = b.size.width + 10 + 10
               // hy += b.size.height + 10 + 10
                hy += tmp == 0 ? 0 : tmp + 10 + 10
              //  print("row add at \(t)")
               // r += 1
            }
            else {
                hx += b.size.width + 10 + 10
            }
            tmp = b.size.height
          //  print("\(t):\(hx):\(hy)")
        }
      // r += 1
      //print("row count\(r)")
       //print("total height \(hy + tmp + 10 + 20)")
        return hy + tmp + 10 + 20
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if currentIndex == 0 {
            if indexPath.section == 0 && indexPath.item == infos.count-1 {
                let b = ("历" as NSString).boundingRectWithSize(CGSizeMake(self.tableView.frame.size.width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)], context: nil)
                return b.height + cellHeight(self.tags, inBoundingSize:CGSizeMake(self.tableView.frame.size.width, CGFloat.max)) + 10
            }
            else {
                let rect = ("历" as NSString).boundingRectWithSize(CGSizeMake(tableView.frame.width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)], context: nil)
                return ( indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 5 || indexPath.row == 6) ? rect.height + 40 : 40

            }
        }
        else if currentIndex == 1 {
            return 120
        }
        else {
            return (SCREEN_WIDTH-10) / 3 + 5
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if currentIndex == 1 {
            if indexPath.section == events.count - 1{
                fetchEvents()
            }
        }
        else if currentIndex == 2 {
            if indexPath.row == ((personalImages.count + 2)/3) - 1 {
                //fetchImages()
                fetchPersonalImages()
            }
        }
    }
    

   
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if currentIndex == 0 || currentIndex == 2 {
            return 1
        }
        else {
            return events.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentIndex == 0 {
            if let ID = myId where ID != id {
                return infos.count + 1
            }
            else {
                return infos.count
            }
        }
        else if currentIndex == 1 {
            return 1
        }
        else {
            return (personalImages.count + 2) / 3
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if currentIndex == 0 {
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
                messageButton.addTarget(self, action: "message:", forControlEvents: .TouchUpInside)
                
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
                    addFriendButton.addTarget(self, action: "unfollow:", forControlEvents: UIControlEvents.TouchUpInside)
                    addFriendButton.setTitle("已关注\(gg), 取消关注", forState: .Normal)
                }
                else if let p = info?.followFlag where p == "2" {
                    addFriendButton.setTitle("\(gg)已关注你, 去关注\(gg)吧", forState: .Normal)
                    addFriendButton.addTarget(self, action: "addFriend:", forControlEvents: UIControlEvents.TouchUpInside)
                }
                else if let p = info?.followFlag where p == "3" {
                    addFriendButton.addTarget(self, action: "unfollow:", forControlEvents: UIControlEvents.TouchUpInside)
                    addFriendButton.setTitle("已互相关注, 取消关注", forState: .Normal)
                }
                else {
                    addFriendButton.addTarget(self, action: "addFriend:", forControlEvents: UIControlEvents.TouchUpInside)
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
        else if currentIndex == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TimelineTableViewCell), forIndexPath: indexPath) as! TimelineTableViewCell
            let data = events[indexPath.section]
            let info = "\(data.time.hunmanReadableString())  发布帖子于\(data.topic)"
            let attributed = NSMutableAttributedString(string: info)
            attributed.addAttribute(NSForegroundColorAttributeName, value: THEME_COLOR, range:NSMakeRange(0, data.time.hunmanReadableString().characters.count))
            cell.infoLabel.attributedText = attributed
            cell.titleLabel.text = data.title
            cell.bodyLabel.text = data.body
            cell.thumbnail.sd_setImageWithURL(data.image, placeholderImage: UIImage(named: "avatar"))
            cell.selectionStyle = .None
            cell.delegate = self
            if let Id = myId where Id == id {
                cell.moreAction.hidden = false
            }
            else {
                cell.moreAction.hidden = true
            }
            return cell

        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ThreeImageTableViewCell), forIndexPath: indexPath) as! ThreeImageTableViewCell
            let startIdx = 3 * indexPath.row
            cell.leftImageView.sd_setImageWithURL(personalImages[startIdx].thumbnailURL)
            if startIdx + 1 < personalImages.count {
                cell.midImageView.sd_setImageWithURL(personalImages[startIdx + 1].thumbnailURL)
            }
            if startIdx + 2 < personalImages.count {
                cell.rightImageView.sd_setImageWithURL(personalImages[startIdx + 2].thumbnailURL)
            }
            cell.selectionStyle = .None
            cell.delegate = self
            return cell
        }
    }
    
    func message(sender:AnyObject) {
        let vc = ComposeMessageVC()
        vc.recvID = self.id
        let nav = UINavigationController(rootViewController: vc)
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if currentIndex == 1 {
            let data = events[indexPath.section]
            let vc = PostVC()
            vc.postID = data.postid
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension InfoVC:TimelineTableViewCellDelegate {
    func didTapMoreAtTimelineCell(cell: TimelineTableViewCell) {
        if let indexPath = self.tableView.indexPathForCell(cell) where indexPath.section < events.count{
            let event = self.events[indexPath.section]
            let postid = event.postid
            sheet = IBActionSheet(title: nil, callback: { (sheet, index) -> Void in
                if index == 0 {
                    if let t = token {
                       request(.POST, DELETE_POST_URL, parameters: ["token":t, "postid":"\(postid)"], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) in
                            if let d = response.result.value, S = self {
                                let json = JSON(d)
                                guard json["state"].stringValue == "successful" else {
                                    return
                                }
                                if S.currentIndex == 1 {
                                    if let _ = S.tableView.cellForRowAtIndexPath(indexPath) as? TimelineTableViewCell {
                                        if S.events.count > indexPath.section && S.events[indexPath.section].postid == postid {
                                            S.events.removeAtIndex(indexPath.section)
//                                            S.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
                                            S.tableView.reloadData()
                                        }
                                    }

                                }
                            }
                       })
                    }

                }
                
                }, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitlesArray: ["删除帖子"])
            sheet?.setButtonTextColor(THEME_COLOR)
            sheet?.showInView(navigationController!.view)

            
        }
    }
}

extension InfoVC:AlertTextViewDelegate {
    func alertTextView(alertView: AlertTextView, doneWithText text: String?) {
        if let t = token, s = text where s.characters.count > 0 {
            request(.POST, REPORT_URL, parameters: ["token":t, "body": s , "type":"user", "typeid": id], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        return
                    }
                    let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                    hud.mode = .CustomView
                    hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                    hud.labelText = "举报成功"
                    hud.hide(true, afterDelay: 1.0)
                }
                })

        }
    }
}

extension InfoVC:ThreeImageTableViewCellDelegate {
    func didTapImageAtThreeImageTableViewCell(cell: ThreeImageTableViewCell, atIndex idx: Int) {
        if currentIndex == 2 {
            if let indexPath = tableView.indexPathForCell(cell) {
                let browser = MWPhotoBrowser(delegate: self)
                browser.setCurrentPhotoIndex(UInt(indexPath.row * 3 + idx))
                browser.displayActionButton = true
                navigationController?.pushViewController(browser, animated: true)

            }
        }
    }
}

extension InfoVC:MenuBarViewDelegate {
    func didSelectButtonAtIndex(index: Int) {
        if index == 0 {
            currentIndex = 0
            
            if case let .float(yOffset) = currentMenuBarState {
                tableView.setContentOffset(CGPointMake(0, yOffset), animated: false)
            }
            else if case let .dock(left, _, _) = currentMenuBarState {
                tableView.setContentOffset(CGPointMake(0, left), animated: false)
            }
            tableView.reloadData()

            fetchInfo()
        }
        else if index == 1 {
            currentIndex = 1
            
            if case let .float(yOffset) = currentMenuBarState {
                tableView.setContentOffset(CGPointMake(0, yOffset), animated: false)
            }
            else if case let .dock(_, mid, _) = currentMenuBarState {
                tableView.setContentOffset(CGPointMake(0, mid), animated: false)
            }
            tableView.reloadData()
            if events.count == 0 {
                fetchEvents()
            }
        }
        else if index == 2 {
            currentIndex = 2
            
            
            if case let .float(yOffset) = currentMenuBarState {
                tableView.setContentOffset(CGPointMake(0, yOffset), animated: false)
            }
            else if case let .dock(_, _,right) = currentMenuBarState {
                tableView.setContentOffset(CGPointMake(0, right), animated: false)
            }
            tableView.reloadData()
            if personalImages.count == 0 {
                //fetchImages()
                fetchPersonalImages()
            }
        }
    }
}

extension InfoVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let cropper = RSKImageCropViewController(image: image, cropMode:.Custom)
        cropper.delegate = self
        cropper.dataSource = self
        presentViewController(cropper, animated: true, completion: nil)
        
    }
}

extension InfoVC:RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource{
    func imageCropViewController(controller: RSKImageCropViewController!, didCropImage croppedImage: UIImage!, usingCropRect cropRect: CGRect) {
        dismissViewControllerAnimated(true, completion: nil)
        self.coverImageView.image = croppedImage
        if let t = token,
            let id =  myId{
                upload(.POST, UPLOAD_AVATAR_URL, multipartFormData: { multipartFormData in
                    let dd = "{\"token\":\"\(t)\", \"type\":\"-1\", \"number\":\"1\"}"
                    let jsonData = dd.dataUsingEncoding(NSUTF8StringEncoding)
                    let data = UIImageJPEGRepresentation(croppedImage, 0.75)
                    multipartFormData.appendBodyPart(data:jsonData!, name:"json")
                    multipartFormData.appendBodyPart(data:data!, name:"avatar", fileName:"avatar.jpg", mimeType:"image/jpeg")
                    
                    }, encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _ , _):
                            upload.responseJSON { response in
                                //debugPrint(response)
                                if let d = response.result.value {
                                    let j = JSON(d)
                                    if j != .null && j["state"].stringValue  == "successful" {
                                        SDImageCache.sharedImageCache().storeImage(croppedImage, forKey:profileBackgroundURLForID(id).absoluteString)
                                    }
                                    else {
                                        let alert = UIAlertController(title: "提示", message: j["reason"].stringValue, preferredStyle: .Alert)
                                        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                                        self.presentViewController(alert, animated: true, completion: nil)
                                        return
                                        
                                        //self.navigationController?.popViewControllerAnimated(true)
                                        
                                    }
                                }
                                else if let error = response.result.error {
                                    let alert = UIAlertController(title: "提示", message: error.localizedFailureReason ?? error.localizedDescription, preferredStyle: .Alert)
                                    alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                    return
                                    //self.navigationController?.popViewControllerAnimated(true)
                                    
                                    
                                }
                            }
                            
                        case .Failure:
                            //print(encodingError)
                            let alert = UIAlertController(title: "提示", message: "上载图片失败" , preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                            return
                            //self.navigationController?.popViewControllerAnimated(true)
                            
                            
                        }
                    }
                    
                )
                
                
                
        }
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageCropViewControllerCustomMaskRect(controller: RSKImageCropViewController!) -> CGRect {
        return CGRectMake(view.center.x - coverImageView.bounds.size.width/2, view.center.y-coverImageView.bounds.size.height/2, coverImageView.bounds.size.width, coverImageView.bounds.size.height)
    }
    
    func imageCropViewControllerCustomMaskPath(controller: RSKImageCropViewController!) -> UIBezierPath! {
        return UIBezierPath(rect: CGRectMake(view.center.x - coverImageView.bounds.size.width/2, view.center.y-coverImageView.bounds.size.height/2, coverImageView.bounds.size.width, coverImageView.bounds.size.height))
    }
}

extension InfoVC:MWPhotoBrowserDelegate {
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(personalImages.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        let data = personalImages[Int(index)]
        let photo = MWPhoto(URL: data.imgURL)
        var time = ""
        let dateFormat = NSDateFormatter(withUSLocaleAndFormat: "EE, d LLLL yyyy HH:mm:ss zzzz")
        if let date = dateFormat.dateFromString(data.timestamp) {
            time = date.hunmanReadableString()
        }
        let caption = "\(data.username) 上传于\n\(time)"
        let attributedText = NSMutableAttributedString(string: caption)
        attributedText.addAttributes([NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName:UIColor.lightGrayColor()], range: NSMakeRange(0, data.username.characters.count + 4))
        attributedText.addAttributes([NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), NSForegroundColorAttributeName:UIColor.whiteColor()], range: NSMakeRange(data.username.characters.count+5, time.characters.count))
        photo.caption = attributedText
        
        return photo
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, didTapCaptionViewAtIndex index: UInt) {
//        let data = personalImages[Int(index)]
//        let vc = PostVC()
//        vc.postID = data.postid
//        navigationController?.pushViewController(vc, animated: true)
    }
    
}
//MARK: -LiquidFloatingActionButton
extension InfoVC:LiquidFloatingActionButtonDelegate, LiquidFloatingActionButtonDataSource {
    func numberOfCells(liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return floatingCells.count
    }
    
    func cellForIndex(index: Int) -> LiquidFloatingCell {
        return floatingCells[index]
    }
    
    func liquidFloatingActionButton(liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        liquidFloatingActionButton.close()
        if index == 0 {
            let vc = AudioRecordVC()
            self.presentViewController(vc, animated: true, completion: nil)
        }
        else if index == 1 {
            let vc = UploadPersonalImageVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if index == 2 {
           let vc = EditTagViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
*/
class UploadPersonalImageVC:UpLoadImageVC {
    static let UPLOAD_PERSONAL_IMAGE_NOTIFICATION = "UPLOAD_PERSONAL_IMAGE_NOTIFICATION"
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "一次最多9张"
        title = "上传个人照片到图集"
        infoLabel.textAlignment = .Center
        infoLabel.text = "上传的照片将公开, 你可以稍后在图集中查看"

        confirmButton.setTitle("上传照片", forState: .Normal)
    }
    
    override func confirm(sender:AnyObject!) {
        guard images.count > 0 && images.count < 10 else {
            self.messageAlert("请选择不超过9张图片")
            return
        }
        
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = .Determinate
        hud.labelText = "上传图片..."
        
        if let t = token{
            let total = images.count
            var uploadedImages = 0
            for k in 1...total {
                upload(.POST, UPLOAD_AVATAR_URL, multipartFormData: { multipartFormData in
                    let dd = "{\"token\":\"\(t)\", \"type\":\"\(-16)\"}"
                    let jsonData = dd.dataUsingEncoding(NSUTF8StringEncoding)
                    let data = UIImageJPEGRepresentation((self.imageCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: k-1, inSection: 0)) as! ImageCollectionViewCell).imageView.image!, 0.5)
                    multipartFormData.appendBodyPart(data:jsonData!, name:"json")
                    multipartFormData.appendBodyPart(data:data!, name:"avatar", fileName:"avatar.jpg", mimeType:"image/jpeg")
                    }, encodingCompletion:{ encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _ , _):
                            upload.responseJSON { response in
                                debugPrint(response)
                                if let d = response.result.value {
                                    let j = JSON(d)
                                    if j["state"].stringValue  == "successful" {
                                        uploadedImages += 1
                                        hud.progress = Float(uploadedImages)/Float(total)
                                        if uploadedImages == total {

                                            hud.hide(true)
                                            let hudd = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                            hudd.mode = .CustomView
                                            hudd.labelText = "上传照片成功"
                                            hudd.customView = UIImageView(image: UIImage(named: "checkmark"))
                                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
                                            dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
                                                self.navigationController?.popViewControllerAnimated(true)
                                                NSNotificationCenter.defaultCenter().postNotificationName(UploadPersonalImageVC.UPLOAD_PERSONAL_IMAGE_NOTIFICATION, object: self)
                                            }
                                        }
                                    }
                                    else {
                                        hud.hide(true)
                                        let hudd = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                        hudd.mode = .Text
                                        hudd.labelText = "错误"
                                        hudd.detailsLabelText = j["reason"].stringValue//"上传照片失败"
                                        hudd.hide(true, afterDelay: 1.0)
                                        return
                                        
                                    }

                                }
                                    
                                else if let _ = response.result.error {
                                    hud.hide(true)
                                    let hudd = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                    hudd.mode = .Text
                                    hudd.labelText = "错误"
                                    hudd.detailsLabelText = "上传照片失败"
                                    hudd.hide(true, afterDelay: 1.0)
                                    return
                                }
                                
                                
                            }
                            
                        case .Failure:
                            break
                        }
                        
                        
                        
                })
            }
            
        }
        
        
    }
}

//extension InfoVC:PersonalHeaderViewDelegate {
//    func didTapAvatar() {
//        let showImg = Agrume(imageURL: avatarURLForID(id))
//        showImg.showFrom(self)
//    }
//    
//    func didTapCover() {
//        self.tapCover(self.headerView)
//    }
//}

protocol PersonalHeaderViewDelegate:class {
    func didTapAvatar()
    func didTapCover()
}
class PersonalHeaderView:UIView {
    
    var avatar:UIImageView!
    var infoLabel:DLLabel!
    var moreInfoLabel:DLLabel!
    var gender:UIImageView!
   // var like:UIImageView!
    var likeInfoLabel:DLLabel!
    
    var verifiedIcon:UIImageView!
    
    weak var delegate:PersonalHeaderViewDelegate?
    func initialize() {
        let tap = UITapGestureRecognizer(target: self, action: "tapCover:")
        addGestureRecognizer(tap)
        
        backgroundColor = UIColor.clearColor()
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.userInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: "tapAvatar:")
        avatar.addGestureRecognizer(tap1)
        addSubview(avatar)
        
        infoLabel = DLLabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(infoLabel)
        infoLabel.textColor = UIColor.whiteColor()
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        infoLabel.textAlignment = .Center
        
        moreInfoLabel = DLLabel()
        moreInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(moreInfoLabel)
        moreInfoLabel.textColor = UIColor.whiteColor()
        moreInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        moreInfoLabel.textAlignment = .Right
        
        gender = UIImageView()
        gender.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gender)
        likeInfoLabel = DLLabel()
        likeInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(likeInfoLabel)
        likeInfoLabel.textColor = UIColor.whiteColor()
        likeInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        likeInfoLabel.textAlignment = .Center
        likeInfoLabel.hidden = true
        
        verifiedIcon = UIImageView(image: UIImage(named: "verified"))
        verifiedIcon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(verifiedIcon)
        verifiedIcon.hidden = true

        
        avatar.snp_makeConstraints { (make) -> Void in
            make.width.height.equalTo(84)
            make.centerY.equalTo(snp_centerY)
            make.centerX.equalTo(snp_centerX)
            avatar.layer.cornerRadius = 42
            avatar.layer.masksToBounds = true
            avatar.layer.borderWidth = 2.0
            avatar.layer.borderColor = UIColor.whiteColor().CGColor
        }
        
        verifiedIcon.snp_makeConstraints { (make) in
            make.height.width.equalTo(20)
            make.centerX.equalTo(avatar.snp_centerX).offset(30)
            make.centerY.equalTo(avatar.snp_centerY).offset(30)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.top.equalTo(avatar.snp_bottom).offset(5)
        }
        
        moreInfoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.centerY.equalTo(gender.snp_centerY)
            make.width.equalTo(snp_width).multipliedBy(0.5)
        }
        
        gender.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(moreInfoLabel.snp_right).offset(10)
            make.width.equalTo(16)
            make.height.equalTo(18)
            make.top.equalTo(infoLabel.snp_bottom).offset(5)
            
        }
        
        
        likeInfoLabel.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(snp_right)
            make.left.equalTo(snp_left)
            make.top.equalTo(gender.snp_bottom)
        }
        
    }
    
    func tapAvatar(sender:AnyObject?) {
        delegate?.didTapAvatar()
    }
    
    func tapCover(sender:AnyObject) {
        delegate?.didTapCover()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
protocol MenuBarViewDelegate:class {
    func didSelectButtonAtIndex(index:Int)
}
class MenuBarView:UIView {
    var leftButton:UIButton!
    var midButton:UIButton!
    var rightButton:UIButton!
    var leftLine:UILabel!
    var midLine:UILabel!
    var rightLine:UILabel!
    //var bottomline:UIView!
    //var hairline:UIView!
    weak var delegate:MenuBarViewDelegate?
    
    static let HIGHLIGHTED_COLOR = UIColor.colorFromRGB(0xa198d1)
    
    func initialize() {
        backgroundColor = UIColor.whiteColor()
        leftButton = UIButton()
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftButton)
        leftButton.backgroundColor = UIColor.whiteColor()
        leftButton.setTitle("个人资料", forState: .Normal)
        leftButton.setTitleColor(THEME_COLOR, forState: .Normal)
        leftButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        leftButton.addTarget(self, action: #selector(self.tapButton(_:)), forControlEvents: .TouchUpInside)
        leftButton.tag = 0
        
        midButton = UIButton()
        midButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(midButton)
        midButton.backgroundColor = UIColor.whiteColor()
        midButton.setTitle("时间轴", forState: .Normal)
        midButton.setTitleColor(TEXT_COLOR, forState: .Normal)
        midButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        midButton.addTarget(self, action:  #selector(self.tapButton(_:)), forControlEvents: .TouchUpInside)
        midButton.tag = 1
        
        rightButton = UIButton()
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightButton)
        rightButton.backgroundColor = UIColor.whiteColor()
        rightButton.setTitle("图集", forState: .Normal)
        rightButton.setTitleColor(TEXT_COLOR, forState: .Normal)
        rightButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        rightButton.addTarget(self, action:  #selector(self.tapButton(_:)), forControlEvents: .TouchUpInside)
        rightButton.tag = 2
        
        leftLine = UILabel()
        leftLine.translatesAutoresizingMaskIntoConstraints  = false
        leftLine.backgroundColor = MenuBarView.HIGHLIGHTED_COLOR
        addSubview(leftLine)
        
        midLine = UILabel()
        midLine.translatesAutoresizingMaskIntoConstraints  = false
        addSubview(midLine)
        
        rightLine = UILabel()
        rightLine.translatesAutoresizingMaskIntoConstraints  = false
        addSubview(rightLine)


        
        leftButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.centerY.equalTo(snp_centerY)
        }
        
        midButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(leftButton.snp_right)
            make.centerY.equalTo(leftButton.snp_centerY)
            make.width.equalTo(leftButton.snp_width)
        }
        
        rightButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(midButton.snp_right)
            make.right.equalTo(snp_right)
            make.centerY.equalTo(midButton.snp_centerY)
            make.width.equalTo(midButton.snp_width)
            
        }
        
        leftLine.snp_makeConstraints { (make) in
            make.top.equalTo(leftButton.snp_bottom)
            make.height.equalTo(4)
            make.left.equalTo(leftButton.snp_leftMargin)
            make.right.equalTo(leftButton.snp_rightMargin)
        }
        
        midLine.snp_makeConstraints { (make) in
            make.top.equalTo(midButton.snp_bottom)
            make.height.equalTo(4)
            make.left.equalTo(midButton.snp_leftMargin)
            make.right.equalTo(midButton.snp_rightMargin)
        }
        
        rightLine.snp_makeConstraints { (make) in
            make.top.equalTo(rightButton.snp_bottom)
            make.height.equalTo(4)
            make.left.equalTo(rightButton.snp_leftMargin)
            make.right.equalTo(rightButton.snp_rightMargin)
        }
        
        
    }
    
    func tapButton(sender:UIButton) {
 
        leftButton.setTitleColor(TEXT_COLOR, forState: .Normal)
        midButton.setTitleColor(TEXT_COLOR, forState: .Normal)
        rightButton.setTitleColor(TEXT_COLOR, forState: .Normal)
        
        sender.setTitleColor(THEME_COLOR, forState: .Normal)
        
        leftLine.backgroundColor = UIColor.whiteColor()
        midLine.backgroundColor = UIColor.whiteColor()
        rightLine.backgroundColor = UIColor.whiteColor()
        
        
        
        if sender.tag == 0 {
            leftLine.backgroundColor = MenuBarView.HIGHLIGHTED_COLOR
        }
        else if sender.tag == 1 {
            midLine.backgroundColor = MenuBarView.HIGHLIGHTED_COLOR
        }
        else if sender.tag == 2 {
            rightLine.backgroundColor = MenuBarView.HIGHLIGHTED_COLOR
        }
        delegate?.didSelectButtonAtIndex(sender.tag)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}


protocol ThreeImageTableViewCellDelegate:class {
    func didTapImageAtThreeImageTableViewCell(cell:ThreeImageTableViewCell, atIndex:Int)
}
class ThreeImageTableViewCell:UITableViewCell {
    var leftImageView:UIImageView!
    var midImageView:UIImageView!
    var rightImageView:UIImageView!
    weak var delegate:ThreeImageTableViewCellDelegate?
    
    func initialize() {
        leftImageView = UIImageView()
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.userInteractionEnabled = true
        leftImageView.tag = 0
        let tap = UITapGestureRecognizer(target: self, action: "tapImg:")
        leftImageView.addGestureRecognizer(tap)
        contentView.addSubview(leftImageView)
        
        midImageView = UIImageView()
        midImageView.translatesAutoresizingMaskIntoConstraints = false
        midImageView.tag = 1
        midImageView.userInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: "tapImg:")
        midImageView.addGestureRecognizer(tap1)
        contentView.addSubview(midImageView)
        
        rightImageView = UIImageView()
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        rightImageView.tag = 2
        rightImageView.userInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: "tapImg:")
        rightImageView.addGestureRecognizer(tap2)
        contentView.addSubview(rightImageView)
        
        leftImageView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.centerY.equalTo(contentView.snp_centerY)
            make.height.equalTo(leftImageView.snp_width)
            //make.bottom.equalTo(contentView.snp_bottom).offset(-2.5)
        }
        
        midImageView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(leftImageView.snp_right).offset(5)
            make.centerY.equalTo(contentView.snp_centerY)
            make.height.equalTo(midImageView.snp_width)
            make.width.equalTo(leftImageView.snp_width)
        }
        
        rightImageView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(midImageView.snp_right).offset(5)
            make.centerY.equalTo(contentView.snp_centerY)
            make.right.equalTo(contentView.snp_right)
            make.height.equalTo(rightImageView.snp_width)
            make.width.equalTo(midImageView.snp_width)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func tapImg(tap:UITapGestureRecognizer) {
        if let v = tap.view as? UIImageView{
            if v.image != nil {
                delegate?.didTapImageAtThreeImageTableViewCell(self, atIndex: v.tag)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftImageView.image = nil
        midImageView.image = nil
        rightImageView.image = nil
    }
}

class InfoTableViewCell:UITableViewCell {
    var titleLabel:UILabel!
    var infoLabel:UILabel!
    var detailLabel:UILabel!
    var bottomLine:UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    func initialize() {
        selectionStyle = .None
      
        let containerView = UIView()
        containerView.backgroundColor = UIColor.whiteColor()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        titleLabel.backgroundColor = BACK_COLOR
        titleLabel.textColor = TEXT_COLOR
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        infoLabel.textColor = UIColor.lightGrayColor()
        containerView.addSubview(infoLabel)
        detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.textAlignment = .Right
        detailLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        detailLabel.textColor = TEXT_COLOR
        containerView.addSubview(detailLabel)
        
        
        bottomLine = UILabel()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bottomLine)
        bottomLine.backgroundColor = UIColor.colorFromRGB(0xf0eff5)
        
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp_top)
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            
        }
        
        containerView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(titleLabel.snp_bottom)
            make.bottom.equalTo(contentView.snp_bottom)
            containerView.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            make.height.greaterThanOrEqualTo(40).priorityLow()
        }
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(containerView.snp_centerY)
            make.left.equalTo(containerView.snp_leftMargin)
            infoLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis:.Horizontal)
        }
        
        detailLabel.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(containerView.snp_rightMargin)
            make.centerY.equalTo(infoLabel.snp_centerY)
            make.left.equalTo(infoLabel.snp_right)
            detailLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
        
        bottomLine.snp_makeConstraints { (make) in
            make.left.equalTo(containerView.snp_leftMargin)
            make.right.equalTo(containerView.snp_rightMargin)
            make.bottom.equalTo(containerView.snp_bottom)
            make.height.equalTo(1)
            
        }
    }
    
}

protocol TimelineTableViewCellDelegate:class {
    func didTapMoreAtTimelineCell(cell:TimelineTableViewCell)
}

class TimelineTableViewCell:UITableViewCell {
    var infoLabel:UILabel!
    var moreAction:UIImageView!
    var thumbnail:UIImageView!
    var titleLabel:UILabel!
    var bodyLabel:UILabel!
    
    weak var delegate:TimelineTableViewCellDelegate?
    
    func initialize() {
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        contentView.addSubview(infoLabel)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.more(_:)))
        moreAction = UIImageView(image: UIImage(named: "more"))
        moreAction.translatesAutoresizingMaskIntoConstraints = false
        moreAction.userInteractionEnabled = true
        moreAction.addGestureRecognizer(tap)
        moreAction.hidden = true
        contentView.addSubview(moreAction)
        
        thumbnail = UIImageView()
        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(thumbnail)
        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        contentView.addSubview(titleLabel)
        
        bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        bodyLabel.textColor = UIColor.lightGrayColor()
        bodyLabel.numberOfLines = 2
        bodyLabel.lineBreakMode = .ByWordWrapping
        contentView.addSubview(bodyLabel)
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.top.equalTo(contentView.snp_topMargin)
        }
        
        moreAction.snp_makeConstraints { (make) -> Void in
            make.width.height.equalTo(24)
            make.right.equalTo(contentView.snp_rightMargin)
            make.left.equalTo(infoLabel.snp_right)
            make.centerY.equalTo(infoLabel.snp_centerY)
        }
        
        thumbnail.snp_makeConstraints { (make) -> Void in
            make.width.height.equalTo(60)
            make.left.equalTo(contentView.snp_leftMargin)
            make.top.equalTo(infoLabel.snp_bottom).offset(10)
            make.bottom.equalTo(contentView.snp_bottom).offset(-10)
        }
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(thumbnail.snp_top)
            make.left.equalTo(thumbnail.snp_right).offset(5)
            make.right.equalTo(contentView.snp_rightMargin)
        }
        
        bodyLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(titleLabel.snp_left)
            make.right.equalTo(contentView.snp_rightMargin)
            make.bottom.equalTo(thumbnail.snp_bottom)
            make.top.equalTo(titleLabel.snp_bottom)
        }
        
    }
    
    func more(sender:AnyObject) {
        delegate?.didTapMoreAtTimelineCell(self)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
}
