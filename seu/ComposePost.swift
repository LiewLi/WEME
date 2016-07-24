//
//  ComposePost.swift
//  牵手东大
//
//  Created by liewli on 11/24/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit

import Photos
import GMImagePicker

let COMPOSE_POST_IMAGE_SIZE:CGFloat  = 80
let COMPOSE_POST_IMAGE_SPACE:CGFloat = 10

protocol ImageCollectionViewCellDelegate:class {
    func didTapDelete(cell:ImageCollectionViewCell)
}

class ImageCollectionViewCell:UICollectionViewCell {
    
    lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    weak var  delegate:ImageCollectionViewCellDelegate?
    
    lazy var overlay:UIImageView = {
        let overlay = UIImageView()
        overlay.contentMode = .ScaleAspectFill
        overlay.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "tap:" )
        overlay.addGestureRecognizer(tapGesture)
        return overlay
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func tap(tapGesture:UITapGestureRecognizer) {
        let p = tapGesture.locationInView(self)
        if p.x >= bounds.size.width/2 && p.y <= bounds.size.height/2 {
            delegate?.didTapDelete(self)
        }
    }
    
    func initialize() {
        addSubview(imageView)
        addSubview(overlay)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        overlay.image = nil
        overlay.userInteractionEnabled = false
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        overlay.frame = bounds
    }
    
    
}


class ComposePostVC:UIViewController {
    
    static let DID_SEND_POST_NOTIFICATION = "DID_SEND_POST_NOTIFICATION "
    
    private var _view :UIScrollView!
    private var contentView :UIView!
    private var titleTextField:UITextField!
    
    var topicID:String?
    
    private var textView:UITextView!
    
    
    private var imageCollectionViewHeightConstraint:NSLayoutConstraint!
    //private var bottomConstraint:NSLayoutConstraint!
    
    
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
    
    
    
    //    func resizeImageColletionView() {
    //        let newHeight = CGFloat((images.count+4)/4) * COMPOSE_MESSAGE_IMAGE_SIZE + CGFloat((images.count+4)/4 + 1) * COMPOSE_MESSAGE_IMAGE_SPACE
    //        //let oldHeight = imageCollectionView.bounds.size.height
    //        imageCollectionViewHeightConstraint.constant = newHeight
    //        //bottomConstraint.constant = min(bottomConstraint.constant + newHeight-oldHeight,0)
    //        view.layoutIfNeeded()
    //    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BACK_COLOR
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel:")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: UIBarButtonItemStyle.Plain, target: self, action: "send:")
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor()], forState: UIControlState.Normal)
        title = "发帖"
        loadUI()
    }
    
    
    func loadUI() {
        _view = UIScrollView()
        _view.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        _view.backgroundColor = BACK_COLOR
        view.addSubview(_view)
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
        
        
        let back = UIView()
        back.backgroundColor = UIColor.whiteColor()
        back.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(back)
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[back]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["back":back])
        view.addConstraints(constraints)
        
        constraint = NSLayoutConstraint(item: back, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        
        
        titleTextField = UITextField()
        back.addSubview(titleTextField)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.placeholder = "标题"
        titleTextField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        titleTextField.becomeFirstResponder()
        titleTextField.tintColor = THEME_COLOR
        
        titleTextField.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(back.snp_leftMargin).offset(5)
            make.right.equalTo(back.snp_rightMargin)
            make.top.equalTo(back.snp_top)
            make.height.equalTo(40)
        }
        
        let seperator = UIView()
        seperator.translatesAutoresizingMaskIntoConstraints = false
        back.addSubview(seperator)
        seperator.backgroundColor = BACK_COLOR
        back.addSubview(seperator)
        
        seperator.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(back.snp_leftMargin)
            make.right.equalTo(back.snp_rightMargin)
            make.height.equalTo(1)
            make.top.equalTo(titleTextField.snp_bottom)
        }
        
        textView = UITextView()
        back.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints  = false
        textView.delegate = self
        textView.text = "说点什么吧..."
        textView.textColor = UIColor.lightGrayColor()
        textView.tintColor = THEME_COLOR
        textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        //textView.becomeFirstResponder()
        textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
//        
//        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[textView]-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["textView":textView])
//        view.addConstraints(constraints)
        textView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(back.snp_leftMargin)
            make.right.equalTo(back.snp_rightMargin)
        }
        constraint = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: seperator, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        constraint = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 100)
        view.addConstraint(constraint)
        
        
        
        back.addSubview(imageCollectionView)
        //imageCollectionView.backgroundColor = UIColor.yellowColor()
        //imageCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        constraint = NSLayoutConstraint(item: imageCollectionView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: textView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageCollectionView]-0-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["imageCollectionView":imageCollectionView])
        view.addConstraints(constraints)
        imageCollectionViewHeightConstraint = NSLayoutConstraint(item: imageCollectionView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 100)
        view.addConstraint(imageCollectionViewHeightConstraint)
        
        
        
        
        
        constraint = NSLayoutConstraint(item: imageCollectionView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: back, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(constraint)
        
        //        bottomConstraint = NSLayoutConstraint(item: back, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -SCREEN_HEIGHT+240)
        //        view.addConstraint(bottomConstraint)
        contentView.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(back.snp_bottom).priorityLow()
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
    
    
    func cancel(sender:AnyObject?) {
        if let nav = navigationController {
            if nav.viewControllers.count > 1{
                nav.popViewControllerAnimated(true)
            }
            else {
                presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        else {
            presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func send(sender:AnyObject?) {
        guard textView.textColor != UIColor.lightGrayColor() && textView.text.characters.count > 0 && titleTextField.text?.characters.count > 0 else {
            messageAlert("消息不能为空")
            return
        }
   
        guard self.images.count <= 9 else {
            messageAlert("请最多选择9张照片")
            return
        }
        if let t = token, tid = topicID {
                request(.POST, SEND_POST, parameters: ["token":t, "title":titleTextField.text!, "body":textView.text, "topicid":tid], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                    debugPrint(response)
                    if let StrongSelf = self {
                        if let d = response.result.value {
                            let json = JSON(d)
                            if json["state"] == "successful" {
                                let postid = json["id"]
                                if (StrongSelf.images.count > 0 && postid != .null) {
                                    for k in 1...StrongSelf.images.count {
                                        upload(.POST, UPLOAD_AVATAR_URL, multipartFormData: { multipartFormData in
                                            let dd = "{\"token\":\"\(t)\", \"type\":\"\(-4)\", \"postid\":\"\(postid.stringValue)\", \"number\":\"\(k)\"}"
                                            print(dd)
                                            let jsonData = dd.dataUsingEncoding(NSUTF8StringEncoding)
                                            let data = UIImageJPEGRepresentation((self?.imageCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: k-1, inSection: 0)) as! ImageCollectionViewCell).imageView.image!, 0.5)
                                            multipartFormData.appendBodyPart(data:jsonData!, name:"json")
                                            multipartFormData.appendBodyPart(data:data!, name:"avatar", fileName:"avatar.jpg", mimeType:"image/jpeg")
                                            }, encodingCompletion:{
                                                encodingResult in
                                                switch encodingResult {
                                                case .Success(let upload, _ , _):
                                                    upload.responseJSON { response in
                                                        //debugPrint(response)
                                                        if let d = response.result.value {
                                                            let j = JSON(d)
                                                            if j["state"].stringValue  == "successful" {
                                                                
                                                            }
                                                            else {
                                                                print(j["reason"].stringValue)
                                                            }
                                                        }
                                                        else if let error = response.result.error {
                                                            
                                                        }
                                                    }
                                                    
                                                case .Failure:
                                                    break
                                                    
                                                }
                                                
                                                
                                                
                                        })
                                    }
                                }
                                if let nav = self?.navigationController {
                                    if nav.viewControllers.count > 1{
                                        nav.popViewControllerAnimated(true)
                                    }
                                    else {
                                        self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                                    }
                                }
                                else {
                                    self?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                                }
                                
                                NSNotificationCenter.defaultCenter().postNotificationName(ComposePostVC.DID_SEND_POST_NOTIFICATION, object: nil)
                                
                            }
                            else {
                                self?.messageAlert(json["reason"].stringValue)
                            }
                        }
                        else if let error = response.result.error {
                            self?.messageAlert(error.localizedFailureReason ?? "错误: 无法完成操作")
                        }
                    }
                    })
        }
    }
}

extension ComposePostVC:UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if textView.isFirstResponder() {
            textView.resignFirstResponder()
        }
    }
}

extension ComposePostVC:UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text
        let updatedText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: text)
        if updatedText.isEmpty {
            textView.text = "说点什么吧..."
            textView.textColor = UIColor.lightGrayColor()
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            return false
        }
            
        else if textView.textColor == UIColor.lightGrayColor() && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
        
        return true
        
    }
}

extension ComposePostVC:UICollectionViewDataSource {
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

extension ComposePostVC:UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.item == self.images.count{
            presentViewController(controller, animated: true, completion: nil)
        }
        
        
    }
    
}

extension ComposePostVC:UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: COMPOSE_POST_IMAGE_SIZE, height: COMPOSE_POST_IMAGE_SIZE)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(COMPOSE_POST_IMAGE_SPACE, COMPOSE_POST_IMAGE_SPACE,COMPOSE_POST_IMAGE_SPACE,COMPOSE_POST_IMAGE_SPACE)
    }
}

extension ComposePostVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.images.append(image)
        //resizeImageColletionView()
        self.imageCollectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.images.count-1, inSection: 0)])
        self.view.setNeedsLayout()
        
    }
    
}
extension ComposePostVC:GMImagePickerControllerDelegate {
    
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
        
        //resizeImageColletionView()
        //imageCollectionView.reloadData()
    }
    
}

extension ComposePostVC:ImageCollectionViewCellDelegate {
    func didTapDelete(cell : ImageCollectionViewCell) {
        //print("tap delete")
        if let indexPath = self.imageCollectionView.indexPathForCell(cell) {
            if indexPath.item < self.images.count {
                self.images.removeAtIndex(indexPath.item)
                self.imageCollectionView.deleteItemsAtIndexPaths([indexPath])
                //resizeImageColletionView()
                self.view.setNeedsLayout()
                
            }
        }
    }
}