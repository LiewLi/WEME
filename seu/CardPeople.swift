//
//  CardPeople.swift
//  WEME
//
//  Created by liewli on 2016-01-08.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

class CardPeopleVC:CardVC, CardPeopleContentViewDelegate, EZAudioPlayerDelegate, LikeViewDelegate{
    enum AudioState {
        case Play
        case Stop
    }
    var recommendPeople = [PersonModel]()
    var currentIndex = 0
    var audioPlot:EZAudioPlotGL!
    var player:EZAudioPlayer!
    var sheet:IBActionSheet?
    var infoLabel:UILabel!
    var currentAudioState:AudioState = .Play
    
    var currentPeople:PersonModel? {
        didSet {
            if currentPeople == nil {
                actionRight.enabled = false
            }
            else {
                actionRight.enabled = true
            }
        }
    }
    var currentCard:CardPeopleContentView?
    
    weak var likeView:LikeView?
    
    override func viewDidLoad() {
        cardText = "点击此处 抽取名片"
        super.viewDidLoad()
        currentPeople = nil
        fetchRecommendPeople()
        setupAudio()
    }
    
    func setupAudio() {
        
        audioPlot = EZAudioPlotGL(frame: CGRectZero)
        audioPlot.backgroundColor = UIColor.clearColor()
        audioPlot.plotType = EZPlotType.Buffer
        audioPlot.shouldFill = true
        audioPlot.shouldMirror = true
        
        audioPlot.translatesAutoresizingMaskIntoConstraints = false
        topView.addSubview(audioPlot)
        audioPlot.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(topView.snp_leftMargin)
            make.right.equalTo(topView.snp_rightMargin)
            make.top.equalTo(topView.snp_top)
            make.bottom.equalTo(topView.snp_bottom)
        }
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = UIColor.whiteColor()
        infoLabel.textAlignment = .Center
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        midView.addSubview(infoLabel)
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(midView.snp_left)
            make.right.equalTo(midView.snp_right)
            make.top.equalTo(midView.snp_top)
            make.bottom.equalTo(midView.snp_bottom)
        }
        player = EZAudioPlayer(delegate: self)
    }
    
    func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        }
        catch {
            print(error)
        }

    }
    
    override func tapDeck(sender: AnyObject) {
        super.tapDeck(sender)
        infoLabel.text = ""
        player.pause()
        audioPlot.clear()
        currentAudioState = .Play
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.audioPlot.clear()
        }
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue()) { [weak self]() -> Void in
            if let S = self {
                S.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
            }
        }
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue()) { [weak self]() -> Void in
            if let S = self {
                S.infoLabel.text = "\(audioPlayer.formattedCurrentTime)/\(audioPlayer.formattedDuration)"
            }
        }
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, reachedEndOfAudioFile audioFile: EZAudioFile!) {
            dispatch_async(dispatch_get_main_queue(), { [weak self]() -> Void in
                if let S = self {
                    S.audioPlot.clear()
                    S.player.pause()
                    S.infoLabel.text = ""
                    if let card = S.currentCard {
                        S.toggleState(card)
                    }
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        S.audioPlot.clear()
                        S.infoLabel.text = ""
                    })
                    
                }
            })
        
    }
    


    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        sheet?.removeFromView()
    }
    
    func fetchRecommendPeople() {
        if let t = token {
            request(.POST, GET_RECOMMENDED_FRIENDS_URL, parameters: ["token":t], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        return
                    }
                    
                    do {
                        let people = try MTLJSONAdapter.modelsOfClass(PersonModel.self, fromJSONArray: json["result"].arrayObject) as? [PersonModel]
                        if let t = people where t.count > 0 {
                            S.recommendPeople = t
                            S.currentIndex = 0
                        }
                    }
                    catch {
                        print(error)
                    }
                }
            })
        }
    }
    
    override func nextCard() -> CardContentView {
        if recommendPeople.count > 0 {
            let card = CardPeopleContentView()
            let p = recommendPeople[currentIndex % recommendPeople.count]
            print(p)
            if player != nil {
                player.pause()
            }
            if p.voiceURL != nil {
                setupAudioSession()
            }
            currentIndex = (++currentIndex) % recommendPeople.count
            if currentIndex == 0 {
                fetchRecommendPeople()
            }
            currentPeople = p
            card.imgView.sd_setImageWithURL(p.avatarURL, placeholderImage: UIImage(named: "avatar"), completed: { [weak self](image, error, cacheType, url) -> Void in
                if image != nil && error == nil {
                    if let S = self {
                        S.refreshBackground(image)
                    }
                    
                }
                else {
                    if let S = self {
                        S.refreshBackground(UIImage(named: "avatar")!)
                    }
                }
            })
            
            card.nameLabel.text = p.name
//            if p.gender == "男" {
//                card.gender.image = UIImage(named: "male")
//            }
//            else if p.gender == "女" {
//                card.gender.image = UIImage(named: "female")
//            }
//            card.birthdayLabel.text = p.birthday
            card.schoolLabel.text = p.school
//            card.degreeLabel.text = p.degree
//            card.locationLabel.text = p.hometown
            card.voiceButton.alpha = p.voiceURL == nil ? 0 : 1.0
           // card.likeLabel.text = "0"
            card.cardLikeButton.addTarget(self, action: #selector(self.like(_:)), forControlEvents: .TouchUpInside)
            
            card.cardNextButton.addTarget(self, action: #selector(self.nextCard(_:)), forControlEvents: .TouchUpInside)
            
            let placeholder = [ "学校(未知)"]
            let arr = [card.schoolLabel]
            for (index, label) in arr.enumerate() {
                if let text = label.text{
                    let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
                    if text.stringByTrimmingCharactersInSet(whitespaceSet) == "" {
                        label.text = placeholder[index]
                    }
                }
                else if label.text == nil {
                    label.text = placeholder[index]
                }

            }
            
            card.peopleCardDelegate = self
            currentCard = card
            return card
        }
        else {
            let card = CardDefaultView()
            card.imgView.image = UIImage(named: "avatar")
            fetchRecommendPeople()
            return card
        }
        
    }
    
    func nextCard(nextButton:UIButton) {
        self.tapDeck(nextButton)
    }
    
    func like(likeButton:UIButton) {
        let rect = likeButton.convertRect(likeButton.bounds, toView: view)
        let likeLabel = UILabel(frame: CGRectMake(CGRectGetMidX(rect)-40, CGRectGetMidY(rect)-20, 80, 40))
        likeLabel.textColor = UIColor.colorFromRGB(0xD0104C)
        likeLabel.text = "喜欢+1"
        likeLabel.textAlignment = .Center
        self.view.addSubview(likeLabel)
        let randomAngle = CGFloat((rand()%1000))*CGFloat(M_PI_2)/1000.0
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            likeLabel.transform = CGAffineTransformMakeTranslation(0, 60)
            likeLabel.transform = CGAffineTransformScale(likeLabel.transform, 0.5, 0.5)
            likeLabel.transform = CGAffineTransformRotate(likeLabel.transform, randomAngle)
            likeLabel.alpha = 0
            }) { (finished) -> Void in
            likeLabel.removeFromSuperview()
        }
        
        if let p = currentPeople, t = token {
            let ID = p.ID
            request(.POST,  LIKE_USER_URL, parameters: ["token":t, "userid":"\(ID)"], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let S = self, d = response.result.value {
                    let json = JSON(d)
                    if json["flag"].stringValue == "1" {
                        if let pp = S.currentPeople where pp.ID == ID {
                            if S.likeView != nil {
                                S.likeView?.removeFromSuperview()
                            }
                            let v = LikeView(frame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT))
                            v.rightPerson = S.currentPeople
                            S.likeView = v
                            v.delegate = S
                            v.showInView(S.navigationController!.view)
                            S.navigationController?.interactivePopGestureRecognizer?.enabled = false
                        }

                    }
                }
            })
        }
    }
    
    //MARK: LikeViewDelegate
    
    func didTapAction(v: LikeView) {
        if let p = currentPeople {
            let vc = ComposeMessageVC()
            vc.recvID = p.ID
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didTapDismiss(v: LikeView) {
        navigationController?.interactivePopGestureRecognizer?.enabled = true

    }
    
    override func detailViewForCurrentCard() -> CardDetailView? {
        return nil
    }
    
    func didTapAvatarAtCard(card: CardPeopleContentView) {
        if let p = currentPeople {
            let vc = InfoVC()
            vc.id = p.ID
            navigationController?.pushViewController(vc, animated: true)
        }
      
    }
    
    func toggleState(card:CardPeopleContentView) {
        let rotate = CAKeyframeAnimation(keyPath: "transform.rotation.y")
        rotate.values = [0.0, -M_PI / 2.0, -M_PI]
        rotate.duration = 0.6
        rotate.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)]
        CATransaction.setCompletionBlock { [weak self]() -> Void in
            if let S = self, card = self?.currentCard{
                if case .Play = S.currentAudioState {
                    card.voiceButton.tintColor = TEXT_COLOR
                }
                else {
                    card.voiceButton.tintColor = UIColor.redColor()
                }
                
            }

        }
        card.voiceButton.layer.addAnimation(rotate, forKey: "rotation")
        CATransaction.commit()
        card.voiceButton.transform = CGAffineTransformIdentity
        switch currentAudioState {
        case .Play:
            //card.voiceButton.tintColor = UIColor.redColor()
            currentAudioState = .Stop
        case .Stop:
            player.pause()
            audioPlot.clear()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.audioPlot.clear()
            })
            infoLabel.text = ""
            //card.voiceButton.tintColor = TEXT_COLOR
            currentAudioState = .Play
        }
      
    }
    
    func didTapVoiceAtCard(card: CardPeopleContentView) {
        toggleState(card)
        if case .Stop = currentAudioState {
            infoLabel.text = "加载中..."
        }
        if let p = currentPeople where p.voiceURL != nil {
            download(.GET, p.voiceURL.absoluteString, destination: { (url, response) -> NSURL in
                debugPrint(response)
                let directory = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
                return directory.URLByAppendingPathComponent("voice_\(p.ID)")
            }).response(completionHandler: { [weak self](_, _, data, error) -> Void in
                if let S = self {
                   S.infoLabel.text = ""
                }
                if let S = self where error == nil {
                    if let pp = S.currentPeople where pp.ID == p.ID {
                        let directory = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
                        let fileurl = directory.URLByAppendingPathComponent("voice_\(p.ID)")
                        if case .Stop = S.currentAudioState {
                            let file = EZAudioFile(URL: fileurl)
                            if file != nil {
                                S.player.playAudioFile(file)
                                
                            }
                        }
                    }
                }
                else {
                    print(error)
                }
            })
        }
    }
    
    func followUser(id:String) {
        if let t = token{
            request(.POST, FOLLOW_URL, parameters: ["token":t, "id":id], encoding: .JSON).responseJSON{ [weak self](response) -> Void in
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        S.messageAlert("关注失败")
                        return
                    }
                    
                    let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                    hud.mode = .CustomView
                    hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                    hud.labelText = "关注成功"
                    hud.hide(true, afterDelay: 1.0)
                }
                    
                else if let _ = response.result.error, S = self {
                    S.messageAlert("关注失败")
                }
                
            }
            
        }
    }
    
    override func tapRight(sender: AnyObject) {
        sheet = IBActionSheet(title: nil, callback: { (sheet, index) -> Void in
            if index == 0 {
                if let p = self.currentPeople {
                    self.followUser(p.ID)
                }
            }
            else if index == 1 {
                if let p = self.currentPeople {
                    let vc = ComposeMessageVC()
                    vc.recvID = p.ID
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            }, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitlesArray: ["关注", "私信"])
        sheet?.setButtonTextColor(THEME_COLOR)
        sheet?.showInView(navigationController!.view)
    }
}

protocol CardPeopleContentViewDelegate:class {
    func didTapAvatarAtCard(card:CardPeopleContentView)
    func didTapVoiceAtCard(card:CardPeopleContentView)
}

class CardPeopleContentView:CardContentView {
    
    var nameLabel:UILabel!
    var schoolLabel:UILabel!
    var gradientLayer:CAGradientLayer!
    var voiceButton:UIButton!
    
    var cardLikeButton:UIButton!
    var cardNextButton:UIButton!
    
    weak var peopleCardDelegate:CardPeopleContentViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    func tapAvatar(sender:AnyObject) {
        peopleCardDelegate?.didTapAvatarAtCard(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.bounds = imgView.bounds
        gradientLayer.position = CGPointMake(CGRectGetMidX(imgView.bounds), CGRectGetMidY(imgView.bounds))
        
    }

    
    func initialize() {
        backgroundColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1.0)
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        
        
        imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "tapAvatar:")
        imgView.addGestureRecognizer(tap)
        addSubview(imgView)
        
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRectMake(0, 0, 100, 100)
        gradientLayer.colors = [UIColor.blackColor().alpha(0.6).CGColor, UIColor.clearColor().CGColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x:0.5, y:0.8)
        layer.addSublayer(gradientLayer)
        
//
//        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = TEXT_COLOR
        nameLabel.textAlignment = .Center
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        addSubview(nameLabel)
        
        schoolLabel = UILabel()
        schoolLabel.translatesAutoresizingMaskIntoConstraints = false
        schoolLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        schoolLabel.textColor = TEXT_COLOR
        schoolLabel.textAlignment = .Center
        addSubview(schoolLabel)

        
        cardNextButton = UIButton()
        cardNextButton.translatesAutoresizingMaskIntoConstraints = false
        cardNextButton.setBackgroundImage(UIImage(named: "card_next"), forState: .Normal)
        addSubview(cardNextButton)
        
        cardLikeButton = UIButton()
        cardLikeButton.translatesAutoresizingMaskIntoConstraints = false
        cardLikeButton.setBackgroundImage(UIImage(named: "card_like"), forState: .Normal)
        addSubview(cardLikeButton)
        
        
        cardLikeButton.snp_makeConstraints { (make) in
            make.top.equalTo(schoolLabel.snp_bottom).offset(10)
            make.height.width.equalTo(60)
            make.left.equalTo(snp_leftMargin)
        }
        
        cardNextButton.snp_makeConstraints { (make) in
            make.top.equalTo(schoolLabel.snp_bottom).offset(10)
            make.height.width.equalTo(60)
            make.right.equalTo(snp_rightMargin)
        }


        voiceButton = UIButton()
        voiceButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(voiceButton)
        voiceButton.setBackgroundImage(UIImage(named: "voice")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        voiceButton.tintColor = TEXT_COLOR
        voiceButton.addTarget(self, action: "voiceTap:", forControlEvents: UIControlEvents.TouchUpInside)
        
        voiceButton.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(snp_centerX)
            make.bottom.equalTo(snp_bottom).offset(-20)
            make.width.height.equalTo(30)
        }
        
        imgView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(snp_top)
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.height.equalTo(imgView.snp_width)
        }
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(imgView.snp_bottom).offset(5)
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
        }
//
        schoolLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_leftMargin)
            make.right.equalTo(snp_rightMargin)
            make.top.equalTo(nameLabel.snp_bottom)
        }
        
    }
    
    func voiceTap(sender:AnyObject) {
        peopleCardDelegate?.didTapVoiceAtCard(self)
    }

}



