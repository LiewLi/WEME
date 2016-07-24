//
//  MyQRCode.swift
//  WEME
//
//  Created by liewli on 2016-01-14.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit
import QRCode

class MyQRCodeVC:UIViewController {
    private var hostView:UIView!
    
    private var qrCardView:QRCardView!
    
    private var info:PersonModel?
    
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
        title = "我的二维码"
        view.backgroundColor = UIColor.whiteColor()
        setupUI()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        if let id = myId {
            qrCardView.qrImgView.image = {
                var qrCode = QRCode("weme://user/\(id)")!
                qrCode.size = self.qrCardView.bounds.size
                qrCode.errorCorrection = .High
                qrCode.color = CIColor(rgba: "3e5d9e")
                return qrCode.image
            }()
        }
        fetchInfo()
    }
    
    func configUI() {
        if let p  = info {
            qrCardView.avatar.sd_setImageWithURL(thumbnailAvatarURL(), placeholderImage: UIImage(named: "avatar"))
            qrCardView.nameLabel.text = p.name
            qrCardView.infoLabel.text = p.school
            qrCardView.gender.image = p.gender == "男" ? UIImage(named: "male") : (p.gender == "女" ? UIImage(named: "female") : nil)
        }
        
    }
    
    func fetchInfo() {
        if let t = token, id = myId {
            request(.POST, GET_FRIEND_PROFILE_URL, parameters: ["token": t, "id":id], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" && json.dictionaryObject != nil else {
                        return
                    }
                    
                    do {
                        if let p = try MTLJSONAdapter.modelOfClass(PersonModel.self, fromJSONDictionary: json.dictionaryObject!) as? PersonModel {
                            S.info = p
                            S.configUI()
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
                            SS.configUI()
                        }
                    })
                }
                
                
                
                })
        }
        
        
    }

    
    
    func setupUI() {
        hostView = UIView()
        hostView.backgroundColor = UIColor.blackColor().alpha(0.8)
        hostView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostView)

        
        qrCardView = QRCardView(frame: CGRectZero)
        qrCardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(qrCardView)
        
        hostView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(view.snp_top)
            make.bottom.equalTo(view.snp_bottom)
        }
        
        qrCardView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(view.snp_centerX)
            make.centerY.equalTo(view.snp_centerY)
            make.width.equalTo(view.snp_width).multipliedBy(0.9)
            make.height.equalTo(qrCardView.snp_width).offset(90)
        }
        
    }
    
    
}

class QRCardView:UIView {
    
    var avatar:UIImageView!
    var nameLabel:UILabel!
    var infoLabel:UILabel!
    var gender:UIImageView!
    
    var qrImgView:UIImageView!
    
    var containView:UIView!
    
    func initialize() {
        backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 4.0
        layer.masksToBounds = true
        
        
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 30
        avatar.layer.masksToBounds = true
        addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        nameLabel.textColor = UIColor.blackColor()
        addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = UIColor.lightGrayColor()
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        addSubview(infoLabel)
        
        gender = UIImageView()
        gender.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gender)
        
        containView = UIView()
        containView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containView)
        
        qrImgView = UIImageView()
        qrImgView.translatesAutoresizingMaskIntoConstraints = false
        containView.addSubview(qrImgView)
        
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_leftMargin)
            make.top.equalTo(snp_topMargin)
            make.width.height.equalTo(60)
        }
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(10)
            make.top.equalTo(avatar.snp_top).offset(5)
        }
        gender.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_right).offset(2)
            make.centerY.equalTo(nameLabel.snp_centerY)
            make.width.equalTo(16)
            make.height.equalTo(18)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
            make.bottom.equalTo(avatar.snp_bottom).offset(-5)
            make.right.equalTo(snp_rightMargin)
        }
        
        containView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_leftMargin)
            make.right.equalTo(snp_rightMargin)
            make.top.equalTo(avatar.snp_bottom)
            make.bottom.equalTo(snp_bottom)
        }
        
        qrImgView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(containView.snp_left)
            make.right.equalTo(containView.snp_right)
            make.height.equalTo(qrImgView.snp_width)
            make.centerY.equalTo(containView.snp_centerY)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
