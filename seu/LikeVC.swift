//
//  LikeVC.swift
//  WEME
//
//  Created by liewli on 3/7/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

@objc protocol LikeViewDelegate:class {
    func didTapAction(v:LikeView)
    func didTapDismiss(v:LikeView)
}

class LikeView:UIView{
    
    var rightPerson:PersonModel?
    
    weak var delegate: LikeViewDelegate?
    
    var titleLabel:UILabel!
    var leftImg:UIImageView!
    var rightImg:UIImageView!
    var infoLabel:UILabel!
    
    var action:UIView!
    var dismiss:UIView!
    var actionIcon:UIImageView!
    var actionLabel:UILabel!
    var dismissIcon:UIImageView!
    var dismissLabel:UILabel!
    
    var visualView:UIVisualEffectView!
    
    func showInView(v:UIView) {
        configUI()
        v.addSubview(self)
        self.alpha = 0
        self.transform = CGAffineTransformMakeScale(0, 0)

        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1.0, options: .CurveLinear, animations: { () -> Void in
                self.alpha = 1.0
                self.transform = CGAffineTransformIdentity

            }) { (finished) -> Void in
                
        }

    }
    

    func removeFromView() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.alpha = 0.0
            self.transform = CGAffineTransformMakeScale(0.2, 0.2)
            

            }) { (finished) -> Void in
            self.removeFromSuperview()
   
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configUI() {
        titleLabel.text = "Congratulations!"
        if let id = myId {
            leftImg.sd_setImageWithURL(thumbnailAvatarURLForID(id), placeholderImage: UIImage(named: "avatar"))
 
        }
        if let p = rightPerson {
            rightImg.sd_setImageWithURL(thumbnailAvatarURLForID(p.ID), placeholderImage: UIImage(named: "avatar"))
            infoLabel.text = "你和\(p.name)互相喜欢对方"
        }
    }
    
    func setupUI() {
        userInteractionEnabled = true
        
        let blurEffect = UIBlurEffect(style: .Dark)
        visualView = UIVisualEffectView(effect: blurEffect)
        visualView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(visualView)
        visualView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
        }
        

        
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabel.textAlignment = .Center
        //titleLabel.font = UIFont.systemFontOfSize(20)
        titleLabel.font = UIFont.init(name: "ScriptinaPro", size: 40)
        
        titleLabel.textColor = UIColor.whiteColor()
        
        titleLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(snp_top).offset(10)
            make.left.equalTo(snp_leftMargin)
            make.right.equalTo(snp_rightMargin)
        }
        
        leftImg = UIImageView()
        addSubview(leftImg)
        leftImg.translatesAutoresizingMaskIntoConstraints = false
        leftImg.layer.cornerRadius = SCREEN_WIDTH*5/24
        leftImg.layer.masksToBounds = true
        leftImg.layer.borderColor = UIColor.whiteColor().CGColor
        leftImg.layer.borderWidth = 2
        
        rightImg = UIImageView()
        addSubview(rightImg)
        rightImg.translatesAutoresizingMaskIntoConstraints = false
        rightImg.layer.cornerRadius = SCREEN_WIDTH*5/24
        rightImg.layer.masksToBounds = true
        rightImg.layer.borderColor = UIColor.whiteColor().CGColor
        rightImg.layer.borderWidth = 2

        leftImg.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(snp_centerX).offset(-SCREEN_WIDTH/6)
            make.width.height.equalTo(SCREEN_WIDTH*5/12)
            make.top.equalTo(titleLabel.snp_bottom).offset(30)
        }
        
        rightImg.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(snp_centerX).offset(SCREEN_WIDTH/6)
            make.width.height.equalTo(SCREEN_WIDTH*5/12)
            make.centerY.equalTo(leftImg.snp_centerY)
        }
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(infoLabel)
        
        infoLabel.textColor = UIColor.whiteColor()
        infoLabel.textAlignment = .Center
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .ByWordWrapping
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_leftMargin)
            make.right.equalTo(snp_rightMargin)
            make.top.equalTo(leftImg.snp_bottom).offset(20)
        }
        
        dismiss = UIView()
        dismiss.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dismiss)
        dismiss.layer.cornerRadius = 4
        dismiss.layer.masksToBounds = true
        dismiss.layer.borderColor = UIColor.whiteColor().CGColor
        dismiss.layer.borderWidth = 1
        
        let tapDismiss = UITapGestureRecognizer(target: self, action: "dismissTapped:")
        dismiss.addGestureRecognizer(tapDismiss)
        
        dismiss.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(leftImg.snp_left)
            make.right.equalTo(rightImg.snp_right)
            make.height.equalTo(40)
            make.bottom.equalTo(snp_bottom).offset(-30)
        }
        
        dismissIcon = UIImageView()
        dismissIcon.tintColor = UIColor.whiteColor()
        dismissIcon.image = UIImage(named: "discovery")?.imageWithRenderingMode(.AlwaysTemplate)
        dismissIcon.translatesAutoresizingMaskIntoConstraints = false
        dismiss.addSubview(dismissIcon)
        dismissIcon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(dismiss.snp_leftMargin).offset(10)
            make.centerY.equalTo(dismiss.snp_centerY)
            make.width.height.equalTo(20)
        }
        
        dismissLabel = UILabel()
        dismissLabel.translatesAutoresizingMaskIntoConstraints = false
        dismiss.addSubview(dismissLabel)
        dismissLabel.textColor = UIColor.whiteColor()
        dismissLabel.textAlignment = .Center
        dismissLabel.text = "继续寻觅"
        dismissLabel.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(dismiss.snp_centerY)
            make.left.equalTo(dismissIcon.snp_right)
            make.right.equalTo(dismiss.snp_rightMargin)
        }

        
        
        action = UIView()
        action.translatesAutoresizingMaskIntoConstraints = false
        action.backgroundColor = UIColor.colorFromRGB(0x5278c3)
        addSubview(action)
        action.layer.cornerRadius = 4
        action.layer.masksToBounds = true
        
        let tapAction = UITapGestureRecognizer(target: self, action: "actionTapped:")
        action.addGestureRecognizer(tapAction)

        
        
        action.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(leftImg.snp_left)
            make.right.equalTo(rightImg.snp_right)
            make.height.equalTo(40)
            make.bottom.equalTo(dismiss.snp_top).offset(-20)
        }
        
        actionIcon = UIImageView()
        actionIcon.tintColor = UIColor.whiteColor()
        actionIcon.image = UIImage(named: "comment")?.imageWithRenderingMode(.AlwaysTemplate)
        actionIcon.translatesAutoresizingMaskIntoConstraints = false
        action.addSubview(actionIcon)
        actionIcon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(action.snp_leftMargin).offset(10)
            make.centerY.equalTo(action.snp_centerY)
            make.width.height.equalTo(20)
        }
        
        actionLabel = UILabel()
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        action.addSubview(actionLabel)
        actionLabel.textColor = UIColor.whiteColor()
        actionLabel.textAlignment = .Center
        actionLabel.text = "发送消息"
        actionLabel.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(action.snp_centerY)
            make.left.equalTo(actionIcon.snp_right)
            make.right.equalTo(action.snp_rightMargin)
        }
        
        
    }
    
    func actionTapped(sender:AnyObject) {
        removeFromSuperview()
        delegate?.didTapAction(self)
    }

    
    func dismissTapped(sender:AnyObject) {
        removeFromView()
        delegate?.didTapDismiss (self)
    }
}
