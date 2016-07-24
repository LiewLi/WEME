//
//  Profile.swift
//  WEME
//
//  Created by liewli on 7/23/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit
import RSKImageCropper
import LiquidFloatingActionButton

class ProfileHeaderView:QZStretchableHeaderView {
    
    override static func instantiate() -> ProfileHeaderView {
        let headerView = ProfileHeaderView(frame:CGRectZero)
        return headerView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView = UIImageView()
        self.contentView.contentMode = .ScaleAspectFill
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol ProfileOverlayViewDelegate:class {
    func didTapAvatar()
    func didTapCover()
}
class  ProfileOverlayView:QZStretchableOverlayView {
    var avatar:UIImageView!
    var infoLabel:DLLabel!
    var moreInfoLabel:DLLabel!
    var gender:UIImageView!
    var likeInfoLabel:DLLabel!
    
    var verifiedIcon:UIImageView!
    
    weak var delegate: ProfileOverlayViewDelegate?
    
    override static func instantiate() -> ProfileOverlayView {
        return ProfileOverlayView(frame:CGRectZero)
    }
    
    func initialize() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCover(_:)))
//        addGestureRecognizer(tap)
        backgroundColor = UIColor.clearColor()
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.userInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapAvatar(_:)))
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
    
//    func tapCover(sender:AnyObject) {
//        delegate?.didTapCover()
//    }
//    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    static func preferredHeight() -> CGFloat {
        return SCREEN_WIDTH*2/3
    }
    
    override func interactiveSubviews() -> [UIView]! {
        return [self.avatar]
    }
    

}

class InfoVC:QZStretchableTabBarController, EZAudioPlayerDelegate{
    
    var id:String!
    var info:PersonModel?
    var sheet:IBActionSheet?
    weak var infoVCDelegate:InfoVCPreviewDelegate?
    
    enum AudioState {
        case Play
        case Stop
    }
    var currentAudioState:AudioState = .Stop

    var audioAction:FloatingActionView!
    var player:EZAudioPlayer!
    
    var floatingCells = [LiquidFloatingCell]()
    
    @available(iOS 9, *)
    override func previewActionItems() -> [UIPreviewActionItem] {
        let message = UIPreviewAction(title: "私信", style: .Default) { (action, viewController) -> Void in
            self.infoVCDelegate?.didTapMessage(self.id)
        }
        
        let unfollow = UIPreviewAction(title: "取消关注", style: .Destructive) { (action, vc) -> Void in
            self.infoVCDelegate?.didTapUnfollow(self.id)
        }
        
        
        return [message, unfollow]
    }
    
    func visit() {
        if let t = token, id = id {
            request(.POST, VISIT_URL, parameters: ["token":t, "userid":id], encoding: .JSON).responseJSON(completionHandler: { (response) -> Void in
                
            })
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



    override class func headerViewClass() -> AnyClass! {
        return ProfileHeaderView.self
    }
    
    override class func infoViewClass() -> AnyClass! {
        return ProfileOverlayView.self
    }
    
    override func initialization() {
        super.initialization()
        self.infoViewFrame = self.calcInfoViewFrame()
        self.titleLabelFrame = self.calcTitleFrame()
        self.titleLabelPinFrame = self.calcTilePinFrame()
        self.needRealTimeBlur = true
        
        self.qzTabBar.barBottomSplitLineColor = UIColor.colorFromRGB(0xf5f5f5)
        self.qzTabBar.underlineH = DP(2)
        self.qzTabBar.underlineW = DP(70)
        self.qzTabBar.underlineColor = UIColor.colorFromRGB(0xa198d1)
        self.qzTabBar.selectedColor = UIColor.colorFromRGB(0xa198d1)
        self.qzTabBar.normalColor = TEXT_COLOR
        self.qzTabBar.showTitleGradient = true
        self.qzTabBar.titleGradientStyle = .Fade
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupControllers()
        self.automaticallyAdjustsScrollViewInsets = false
        self.headerView.maskColor = UIColor.colorFromRGB(0x000000).alpha(0.3)
        self.titleLabel.text = ""

        
        let action = UIBarButtonItem(image: UIImage(named: "more")?.imageWithRenderingMode(.AlwaysTemplate), style: .Plain, target: self, action: #selector(action(_:)))
        action.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = action
        
        let headerView = self.headerView as! ProfileHeaderView
        (headerView.contentView as! UIImageView).sd_setImageWithURL(profileBackgroundURLForID(id), placeholderImage: UIImage(named: "info_default")) { (image, error, cacheType, url) in
            headerView.contentDidUpdated()
        }
        
        let infoView = self.infoView as! ProfileOverlayView
        infoView.delegate  = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(editInfo(_:)), name: EDIT_INFO_NOTIFICATION, object: nil)
        
        self.fetchInfo()
        (self.infoView as! ProfileOverlayView).avatar.sd_setImageWithURL(thumbnailAvatarURLForID(id), placeholderImage: UIImage(named: "avatar"))

        
        if let Id = myId where Id == self.id{
            self.fetchLikeInfo()
            setupActionMenu()
        } else {
            self.visit()
        }
        self.fetchVisitInfo()

    }
    
    func editInfo(sender:NSNotification) {
        if let ID = myId where ID == id {
            let headerView = self.infoView as! ProfileOverlayView
            headerView.avatar.sd_setImageWithURL(thumbnailAvatarURL(), placeholderImage: UIImage(named: "avatar"))
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
        
    }
    
    private func fetchVisitInfo() {
        if let t = token, id = id {
            request(.POST, GET_VISIT_INFO_URL, parameters: ["token": t, "userid":id], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" && json["result"] != .null && json["result"]["today"] != .null else {
                        return
                    }
                    let headerView = S.infoView as! ProfileOverlayView
                    headerView.infoLabel.text = "今日访问 \((json["result"]["today"]).stringValue)  总访问 \(json["result"]["total"].stringValue)"
                    
                }
                
                
                
                })
        }
        
    }

    
    private func fetchLikeInfo() {
        if let t = token {
            request(.POST, GET_LIKED_NUMBER_URL, parameters: ["token":t], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                if let S = self, d = response.result.value {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        return
                    }
                    let headerView = S.infoView as! ProfileOverlayView
                    headerView.likeInfoLabel.hidden = false
                    let number = json["likenumber"].stringValue
                    let attText = NSMutableAttributedString(string: "已被 \(number) 人喜欢")
                    attText.addAttributes([NSForegroundColorAttributeName:UIColor.colorFromRGB(0xD0104C), NSFontAttributeName: UIFont.italicSystemFontOfSize(18)], range: NSMakeRange(3, number.characters.count))
                    headerView.likeInfoLabel.attributedText = attText
                }
                })
        }
    }
    

    
    private func fetchInfo() {
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
                        let headerView = S.infoView as! ProfileOverlayView
                        headerView.moreInfoLabel.text = p.constellation
                        headerView.gender.image = p.gender == "男" ? UIImage(named: "male") : (p.gender == "女" ? UIImage(named: "female") : nil)
                        headerView.verifiedIcon.hidden = !p.verified
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
                else if let S = self {
                    ProfileCache.sharedCache.loadProfileWithCompletionBlock({ [weak S](info) -> Void in
                        if let p = info, SS = S {
                            SS.info = p
                        }
                        })
                }
                
                })
        }
        
        
    }

    
    private func setupControllers() {
        let infoVC = InfomationVC()
        infoVC.id = self.id
        
        let timelineVC = TimelineVC()
        timelineVC.id = self.id
        
        let albumVC = AlbumVC()
        albumVC.id = self.id
        self.setViewControllers([infoVC, timelineVC, albumVC], titles: ["资料", "时间轴", "相册"])
    }

    private func calcInfoViewFrame() -> CGRect {
        let infoTop = self.headerHeight - ProfileOverlayView.preferredHeight()
        return CGRectMake(0, infoTop, CGRectGetWidth(self.view.bounds), ProfileOverlayView.preferredHeight())
    }
    
    private func calcTitleFrame() -> CGRect {
        //let infoFrame = self.infoViewFrame
        //return CGRectMake(0, CGRectGetMinY(infoFrame)-DP(38), CGRectGetWidth(self.view.bounds), DP(34))
        return CGRectZero
    }
    
    private func calcTilePinFrame() -> CGRect {
       // return CGRectMake(0, DP(11), CGRectGetWidth(self.view.bounds), DP(22))
        return CGRectZero
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
        let headerView = self.headerView as! ProfileHeaderView
        let coverImageView = (headerView.contentView as! UIImageView)
        coverImageView.image = croppedImage
        headerView.contentDidUpdated()
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
        let headerView = self.headerView as! ProfileHeaderView
        let coverImageView = (headerView.contentView as! UIImageView)

        return CGRectMake(view.center.x - coverImageView.bounds.size.width/2, view.center.y-coverImageView.bounds.size.width/2, coverImageView.bounds.size.width, coverImageView.bounds.size.width)
    }
    
    func imageCropViewControllerCustomMaskPath(controller: RSKImageCropViewController!) -> UIBezierPath! {
        let headerView = self.headerView as! ProfileHeaderView
        let coverImageView = (headerView.contentView as! UIImageView)

        return UIBezierPath(rect: CGRectMake(view.center.x - coverImageView.bounds.size.width/2, view.center.y-coverImageView.bounds.size.width/2, coverImageView.bounds.size.width, coverImageView.bounds.size.width))
    }
}


extension InfoVC:ProfileOverlayViewDelegate {
    func didTapAvatar() {
        let showImg = Agrume(imageURL: avatarURLForID(id))
        showImg.showFrom(self)
    }
    
    func didTapCover() {
        self.tapCover(self.headerView)
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

}

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





