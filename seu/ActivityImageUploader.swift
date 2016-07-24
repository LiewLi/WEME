//
//  ActivityImageUploader.swift
//  WE
//
//  Created by liewli on 1/4/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

import Photos

import GMImagePicker


class UpLoadImageVC:UIViewController {
    
    var id:String!
    private var _view :UIScrollView!
    private var contentView :UIView!
    var confirmButton:UIButton!
    var infoLabel:UILabel!
    var titleLabel:UILabel!
    
    private var imageCollectionViewHeightConstraint:NSLayoutConstraint!
    
    private(set) lazy var imageCollectionView:UICollectionView = {
        let imageCollectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
        imageCollectionView.dataSource = self
        imageCollectionView.delegate  = self
        imageCollectionView.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ImageCollectionViewCell))
        //let backColor = UIColor(red: 238/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1.0)
        imageCollectionView.backgroundColor = UIColor.whiteColor()
        return imageCollectionView
    }()
    
    
    var controller:ImagePickerSheetController {get {
        let presentImagePickerController: UIImagePickerControllerSourceType -> () = { [weak self] source in
            
            if source == .Camera {
                let controller = UIImagePickerController()
                controller.delegate = self
                var sourceType = source
                if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                    sourceType = .PhotoLibrary
                    //print("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
                }
                controller.sourceType = sourceType
                self?.presentViewController(controller, animated: true, completion: nil)
                
            }
            else {
                let controller = GMImagePickerController()
                controller.delegate = self
                controller.mediaTypes = [PHAssetMediaType.Image.rawValue]
                
                self?.presentViewController(controller, animated: true, completion: nil)
            }
            
        }
        
        
        let controller = ImagePickerSheetController(mediaType: .Image)
        controller.view.tintColor = THEME_COLOR//UIColor.redColor()
        controller.addAction(ImagePickerAction(title: "拍摄", secondaryTitle: "拍摄", handler: { _ in
            presentImagePickerController(.Camera)
            }, secondaryHandler: {[weak self]_, numberOfPhotos in
                presentImagePickerController(.Camera)
            }))
        controller.addAction(ImagePickerAction(title: "从相册选择", secondaryTitle:{
            NSString(format: "确定选择这%lu张照片", $0) as String
            }, handler: { _ in
                presentImagePickerController(.PhotoLibrary)
            }, secondaryHandler: {[weak self] _, numberOfPhotos in
                if let StrongSelf = self {
                    var indexPaths = [NSIndexPath]()
                    for asset in controller.selectedImageAssets{
                        StrongSelf.images.append(asset)
                        let k = StrongSelf.images.count-1
                        indexPaths.append(NSIndexPath(forItem: k, inSection: 0))
                    }
                    //StrongSelf.resizeImageColletionView()
                    //self?.imageCollectionView.reloadData()
                    StrongSelf.imageCollectionView.insertItemsAtIndexPaths(indexPaths)
                    StrongSelf.view.setNeedsLayout()
                }
            }))
        controller.addAction(ImagePickerAction(title:"取消", style: .Cancel, handler: { _ in
            //print("Cancelled")
        }))
        
        return controller
        
        }}
    
    private(set) var images = [AnyObject]()
    
    func resizeImageColletionView() {
        let newHeight = CGFloat((images.count+4)/4) * 80 + CGFloat((images.count+4)/4 + 1) * 10
        //let oldHeight = imageCollectionView.bounds.size.height
        imageCollectionViewHeightConstraint.constant = newHeight
        //bottomConstraint.constant = min(bottomConstraint.constant + newHeight-oldHeight,0)
        view.layoutIfNeeded()
    }
    
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
        automaticallyAdjustsScrollViewInsets = false
        
        _view = UIScrollView()
        //_view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        _view.backgroundColor = BACK_COLOR
        view.addSubview(_view)
        // _view.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        _view.translatesAutoresizingMaskIntoConstraints = false
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[_view]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["_view":_view])
        view.addConstraints(constraints)
        var constraint = NSLayoutConstraint(item: _view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: _view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal , toItem:view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        contentView = UIView()
        contentView.backgroundColor = BACK_COLOR
        _view.addSubview(contentView)
        // contentView.backgroundColor = UIColor.yellowColor()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[contentView]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["contentView":contentView])
        _view.addConstraints(constraints)
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[contentView]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["contentView":contentView])
        _view.addConstraints(constraints)
        
        constraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        
        title = "报名活动"
        view.backgroundColor = BACK_COLOR
    
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = BACK_COLOR//backColor
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        titleLabel.text = "上传生活照(最多9张)"
        titleLabel.textAlignment = .Center
        contentView.addSubview(titleLabel)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[titleLabel]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["titleLabel":titleLabel])
        view.addConstraints(constraints)
        constraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 40)
        view.addConstraint(constraint)
        
        
        
        contentView.addSubview(imageCollectionView)
        
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageCollectionView]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["imageCollectionView":imageCollectionView])
        view.addConstraints(constraints)
        
        constraint = NSLayoutConstraint(item: imageCollectionView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: titleLabel, attribute:NSLayoutAttribute.Bottom , multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        
        imageCollectionViewHeightConstraint = NSLayoutConstraint(item: imageCollectionView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 200)
        view.addConstraint(imageCollectionViewHeightConstraint)
        
        
        let seperator = UILabel()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        seperator.backgroundColor = THEME_COLOR_BACK//UIColor.blackColor()
        view.addSubview(seperator)
        constraint = NSLayoutConstraint(item: seperator, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 2)
        view.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: seperator, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: imageCollectionView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[seperator]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["seperator":seperator])
        view.addConstraints(constraints)
        
        
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        infoLabel.text = "  请保证个人资料中的信息真实有效，否则将取消参加资格，我们将根据报名情况进行筛选，并告知您是否入选参加活动。"
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .ByWordWrapping
        contentView.addSubview(infoLabel)
        let rect = (infoLabel.text! as NSString).boundingRectWithSize(CGSizeMake(view.frame.size.width-20, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:infoLabel.font], context: nil)
        //print(rect)
        constraint = NSLayoutConstraint(item: infoLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: rect.size.height+10)
        view.addConstraint(constraint)
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[infoLabel]-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["infoLabel":infoLabel])
        view.addConstraints(constraints)
        constraint = NSLayoutConstraint(item: infoLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: seperator, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 5)
        view.addConstraint(constraint)
        
        
        
        confirmButton = UIButton()
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.setTitle("确认报名", forState: UIControlState.Normal)
        confirmButton.backgroundColor = THEME_COLOR
        confirmButton.addTarget(self, action: "confirm:", forControlEvents: UIControlEvents.TouchUpInside)
        confirmButton.layer.cornerRadius = 5
        confirmButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        contentView.addSubview(confirmButton)
        
        let constraint_button = NSLayoutConstraint(item: confirmButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: infoLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 20)
        view.addConstraint(constraint_button)
        
        let constraint_button_center = NSLayoutConstraint(item: confirmButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint_button_center)
        
        confirmButton.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(view.snp_width).multipliedBy(4/5.0)
        }
        
        contentView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(confirmButton.snp_bottom).priorityLow()
        }
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if _view.contentSize.height < view.frame.height {
            contentView.snp_makeConstraints(closure: { (make) -> Void in
                make.height.greaterThanOrEqualTo(view.snp_height).offset(5).priorityHigh()
            })
        }
        
        if (imageCollectionViewHeightConstraint.constant < imageCollectionView.collectionViewLayout.collectionViewContentSize().height) || (imageCollectionViewHeightConstraint.constant > imageCollectionView.collectionViewLayout.collectionViewContentSize().height + 10) {
            imageCollectionViewHeightConstraint.constant = imageCollectionView.collectionViewLayout.collectionViewContentSize().height + 10
        }
        
    }
    
    func confirm(sender:AnyObject!) {
        guard images.count > 0 && images.count < 10 else {
            let alert = UIAlertController(title: "提示", message: "请选择不超过9张图片", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = .Determinate
        hud.labelText = "上传图片..."
        
        if let token = NSUserDefaults.standardUserDefaults().stringForKey("TOKEN"),
            activityId = id {
                let total = images.count
                var uploadedImages = 0
                for k in 1...total {
                    upload(.POST, UPLOAD_AVATAR_URL, multipartFormData: { multipartFormData in
                        let dd = "{\"token\":\"\(token)\", \"type\":\"\(-9)\", \"activityid\":\"\(activityId)\", \"number\":\"\(k)\"}"
                        let jsonData = dd.dataUsingEncoding(NSUTF8StringEncoding)
                        let data = UIImageJPEGRepresentation((self.imageCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: k-1, inSection: 0)) as! ImageCollectionViewCell).imageView.image!, 0.5)
                        multipartFormData.appendBodyPart(data:jsonData!, name:"json")
                        multipartFormData.appendBodyPart(data:data!, name:"avatar", fileName:"avatar.jpg", mimeType:"image/jpeg")
                        }, encodingCompletion:{ encodingResult in
                            switch encodingResult {
                            case .Success(let upload, _ , _):
                                upload.responseJSON { response in
                                    if let d = response.result.value {
                                        let j = JSON(d)
                                        if j["state"].stringValue  == "successful" {
                                            uploadedImages++
                                            hud.progress = Float(uploadedImages)/Float(total)
                                            if uploadedImages == total {
                                                request(.POST, SIGNUP_ACTIVITY_URL, parameters: ["token":token,"activity":activityId], encoding: .JSON).responseJSON(completionHandler: { (response) -> Void in
                                                    if let d = response.result.value {
                                                        let json = JSON(d)
                                                        
                                                        if json["state"].stringValue == "successful" || json["state"].stringValue == "sucessful" {
                                                            hud.hide(true)
                                                            let hudd = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                                            hudd.mode = .CustomView
                                                            hudd.labelText = "报名成功"
                                                            hudd.customView = UIImageView(image: UIImage(named: "checkmark"))
                                                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
                                                            dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
                                                                self.navigationController?.popToRootViewControllerAnimated(true)
                                                            }
                                                        }
                                                        else {
                                                            hud.hide(true)
                                                            let hudd = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                                            hudd.labelText = "错误"
                                                            hudd.detailsLabelText = "报名失败"
                                                            hudd.hide(true, afterDelay: 1.0)
                                                            return
                                                        }
                                                    }
                                                        
                                                    else if let _ = response.result.error {
                                                        hud.hide(true)
                                                        let hudd = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                                        hudd.labelText = "错误"
                                                        hudd.detailsLabelText = "报名失败"
                                                        hudd.hide(true, afterDelay: 1.0)
                                                        return
                                                    }
                                                    
                                                    
                                                })
                                            }
                                            
                                            
                                        }
                                        else {
                                            
                                        }
                                    }
                                    else if let _ = response.result.error {
                                     
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

extension UpLoadImageVC:UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ImageCollectionViewCell), forIndexPath: indexPath) as! ImageCollectionViewCell
        if indexPath.item == self.images.count {
            cell.imageView.image = UIImage(named: "add_img")
        }
        else {
            if let asset = self.images[indexPath.item] as? PHAsset {
                controller.imageManager.requestImageDataForAsset(asset, options: nil, resultHandler: { (imageData, dataUTI, orientation, info) -> Void in
                    cell.imageView.image = UIImage(data: imageData!)
                    //collectionView.reloadItemsAtIndexPaths([indexPath])
                })
            }
                
            else {
                cell.imageView.image = self.images[indexPath.item] as! UIImage
            }
            
            cell.overlay.image = UIImage(named: "delete_img")
            cell.overlay.userInteractionEnabled = true
        }
        
        cell.delegate = self
        
        return cell
    }
}

extension UpLoadImageVC:UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.item == self.images.count{
            presentViewController(controller, animated: true, completion: nil)
        }
        
        
    }
    
}

extension UpLoadImageVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //self.images.insert(image, atIndex: 0)
        self.images.append(image)
        //self.resizeImageColletionView()
        self.imageCollectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.images.count-1, inSection: 0)])
        self.view.setNeedsLayout()
        
    }
    
}

extension UpLoadImageVC:GMImagePickerControllerDelegate {
    
    
    func assetsPickerController(picker: GMImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        picker.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        var indexPaths = [NSIndexPath]()
        for asset in assets{
            self.images.append(asset)
            let k = self.images.count-1
            indexPaths.append(NSIndexPath(forItem: k, inSection: 0))
        }
        //self.resizeImageColletionView()
        //self?.imageCollectionView.reloadData()
        self.imageCollectionView.insertItemsAtIndexPaths(indexPaths)
        self.view.setNeedsLayout()
    }
    
}


extension UpLoadImageVC:UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
}

extension UpLoadImageVC:ImageCollectionViewCellDelegate {
    func didTapDelete(cell : ImageCollectionViewCell) {
        //print("tap delete")
        if let indexPath = self.imageCollectionView.indexPathForCell(cell) {
            if indexPath.item < self.images.count {
                self.images.removeAtIndex(indexPath.item)
                self.imageCollectionView.deleteItemsAtIndexPaths([indexPath])
                self.view.setNeedsLayout()
            }
        }
    }
}

