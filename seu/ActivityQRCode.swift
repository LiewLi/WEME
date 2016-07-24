//
//  ActivityQRCode.swift
//  WEME
//
//  Created by liewli on 2016-01-15.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

//
//  MyQRCode.swift
//  WEME
//
//  Created by liewli on 2016-01-14.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit
import QRCode

class ActivityQRCodeVC:UIViewController {
    private var hostView:UIView!
    
    private var qrCardView:QRCardView!
    
    var info:ActivityModel?
    
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
        title = "活动二维码"
        view.backgroundColor = UIColor.whiteColor()
        setupUI()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        if let a = info {
            qrCardView.qrImgView.image = {
                var qrCode = QRCode("weme://activity/\(a.activityID)")!
                qrCode.size = self.qrCardView.bounds.size
                qrCode.errorCorrection = .High
                qrCode.color = CIColor(rgba: "3e5d9e")
                return qrCode.image
                }()
        }
    
        configUI()
    }
    
    func configUI() {
        if let a  = info {
            qrCardView.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(a.authorID), placeholderImage: UIImage(named: "avatar"))
            qrCardView.nameLabel.text = a.title
            qrCardView.infoLabel.text = a.author
//            qrCardView.gender.image = p.gender == "男" ? UIImage(named: "male") : (p.gender == "女" ? UIImage(named: "female") : nil)
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



