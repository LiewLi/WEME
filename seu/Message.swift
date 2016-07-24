//
//  Message.swift
//  牵手东大
//
//  Created by liewli on 11/5/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit
import Photos
import GMImagePicker



import WebImage


//MARK: - ComposeMessage
let COMPOSE_MESSAGE_IMAGE_SIZE:CGFloat  = 80
let COMPOSE_MESSAGE_IMAGE_SPACE:CGFloat = 10

class ComposeMessageVC:UIViewController {
    
    static let DID_SEND_MESSAGE_NOTIFICATION = "DID_SEND_MESSAGE_NOTIFICATION "
    
    private var _view :UIScrollView!
    private var contentView :UIView!
    
    var recvID:String?
    
    var textView:UITextView!
    
    
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
    
    
    var controller:ImagePickerSheetController {
        get {
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
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.alpha = 1
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "编辑私信"
        view.backgroundColor = BACK_COLOR
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "cancel:")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: UIBarButtonItemStyle.Plain, target: self, action: "send:")
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.whiteColor()], forState: UIControlState.Normal)
        
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
        
        
        textView = UITextView()
        back.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints  = false
        textView.delegate = self
        textView.text = "说点什么吧..."
        textView.textColor = UIColor.lightGrayColor()
        textView.tintColor = THEME_COLOR
        textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textView.becomeFirstResponder()
        textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[textView]-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: ["textView":textView])
        view.addConstraints(constraints)
        constraint = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: back, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
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
        guard images.count > 0 || (textView.textColor != UIColor.lightGrayColor() &&  textView.text.characters.count > 0) else {
            messageAlert("消息不能为空")
            return
        }
        guard self.images.count <= 9 else {
            messageAlert("请最多选择9张照片")
            return
        }
        if let token = NSUserDefaults.standardUserDefaults().stringForKey(TOKEN),
           let recvid = recvID{
            let text = textView.textColor == UIColor.lightGrayColor() ? "" : textView.text
            request(.POST, SEND_MESSAGE, parameters: ["token":token, "text":text, "RecId":recvid], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                if let StrongSelf = self {
                    if let d = response.result.value {
                        let json = JSON(d)
                        if json["state"].stringValue == "successful" {
                            let id = json["id"].stringValue
                            if (StrongSelf.images.count > 0) {
                                for k in 1...StrongSelf.images.count {
                                    upload(.POST, UPLOAD_AVATAR_URL, multipartFormData: { multipartFormData in
                                        let dd = "{\"token\":\"\(token)\", \"type\":\"\(-2)\", \"messageid\":\"\(id)\", \"number\":\"\(k)\"}"
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
                                                            //print(j["reason"].stringValue)
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
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(ComposeMessageVC.DID_SEND_MESSAGE_NOTIFICATION, object: nil)

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

extension ComposeMessageVC:UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if textView.isFirstResponder() {
            textView.resignFirstResponder()
        }
    }
}

extension ComposeMessageVC:UITextViewDelegate {
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

extension ComposeMessageVC:UICollectionViewDataSource {
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

extension ComposeMessageVC:UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.item == self.images.count{
            presentViewController(controller, animated: true, completion: nil)
        }
        
        
    }
    
}

extension ComposeMessageVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.images.append(image)
        //resizeImageColletionView()
        self.imageCollectionView.insertItemsAtIndexPaths([NSIndexPath(forItem: self.images.count-1, inSection: 0)])
        self.view.setNeedsLayout()
        
    }
    
}
extension ComposeMessageVC:GMImagePickerControllerDelegate {
    
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



extension ComposeMessageVC:UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: COMPOSE_MESSAGE_IMAGE_SIZE, height: COMPOSE_MESSAGE_IMAGE_SIZE)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(COMPOSE_MESSAGE_IMAGE_SPACE, COMPOSE_MESSAGE_IMAGE_SPACE,COMPOSE_MESSAGE_IMAGE_SPACE,COMPOSE_MESSAGE_IMAGE_SPACE)
    }
}


extension ComposeMessageVC:ImageCollectionViewCellDelegate {
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


//MARK: - Message

protocol MessagePureTextCellDelegate :class {
    func didTapReplyAtPureTextCell(cell:MessagePureTextCell)
    func didTapAvatarAtPureTextCell(cell:MessagePureTextCell)
}



class MessagePureTextCell:UITableViewCell {
    private var avatar:UIImageView!
    private var nameLabel:UILabel!
    private var infoLabel:UILabel!
    
    private var bodyLabel:UILabel!
    
    private var timeLabel:UILabel!
    
    private var reply:UIImageView!
    
    private weak var delegate : MessagePureTextCellDelegate?
    
    func tap(sender:AnyObject?) {
        delegate?.didTapReplyAtPureTextCell(self)
    }
    
    func tapAvatar(sender:AnyObject) {
        delegate?.didTapAvatarAtPureTextCell(self)
    }

    
    func initialize() {
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = MessageSingleImageCell.AVATAR_SIZE/2
        avatar.layer.masksToBounds = true
        avatar.frame = CGRectMake(0, 0, MessageSingleImageCell.AVATAR_SIZE, MessageSingleImageCell.AVATAR_SIZE)
        contentView.addSubview(avatar)
        avatar.userInteractionEnabled = true
        let tapAvatar = UITapGestureRecognizer(target: self, action: "tapAvatar:")
        avatar.addGestureRecognizer(tapAvatar)
        //contentView.backgroundColor = SECONDAY_COLOR
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFontOfSize(15)
        //nameLabel.backgroundColor = SECONDAY_COLOR
        nameLabel.textColor = THEME_COLOR//UIColor.colorFromRGB(0x6A5ACD)
        contentView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        infoLabel.textColor = UIColor.lightGrayColor()
        infoLabel.textAlignment = .Right
        contentView.addSubview(infoLabel)
        
        bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .ByWordWrapping
        bodyLabel.textColor = TEXT_COLOR
        //bodyLabel.backgroundColor = UIColor.yellowColor()
        bodyLabel.font = UIFont.systemFontOfSize(15)
        contentView.addSubview(bodyLabel)
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        timeLabel.textColor = UIColor.lightGrayColor()
        //timeLabel.backgroundColor = UIColor.blueColor()//SECONDAY_COLOR
        contentView.addSubview(timeLabel)
        
        
        reply = UIImageView(image: UIImage(named: "reply"))
        reply.userInteractionEnabled = true
        reply.translatesAutoresizingMaskIntoConstraints = false
        reply.tintColor = THEME_COLOR
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        reply.addGestureRecognizer(tap)
        contentView.addSubview(reply)
        //contentView.translatesAutoresizingMaskIntoConstraints = false
        avatar.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp_top).offset(10)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.width.height.equalTo(MessageSingleImageCell.AVATAR_SIZE)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(contentView.snp_right).offset(-10)
            make.centerY.equalTo(nameLabel.snp_centerY)
            make.left.equalTo(nameLabel.snp_right)
            infoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
        let rect = ("历" as NSString).boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:nameLabel.font], context: nil)
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(avatar.snp_top).offset(0)
            make.left.equalTo(avatar.snp_right).offset(10)
            make.height.equalTo(rect.height)
            nameLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        }
        
        bodyLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
            make.top.equalTo(nameLabel.snp_bottom).priorityHigh()
            make.right.equalTo(contentView.snp_rightMargin)
            make.height.equalTo(100).priorityMedium()
            bodyLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            //make.bottom.equalTo(snp_bottom).offset(-10)
        }
        //
        //imgView.contentMode = UIViewContentMode.ScaleAspectFill
        let rec = ("历" as NSString).boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:timeLabel.font], context: nil)
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
            make.top.equalTo(bodyLabel.snp_bottom).offset(5)
            make.width.equalTo(100)
            make.height.equalTo(rec.height)
            make.bottom.equalTo(contentView.snp_bottom).offset(-10)
            
        }
        
        reply.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(infoLabel.snp_right)
            make.width.height.equalTo(20)
            make.centerY.equalTo(timeLabel.snp_centerY)
            //make.bottom.equalTo(snp_bottom).offset(-10)
            
        }
        
        
    }

    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        contentView.invalidateIntrinsicContentSize()
//        contentView.setNeedsLayout()
//    }
//    override func updateConstraints() {
//        print("called")
//        bodyLabel.resizeMessageBodyLabelHeightWithSnapKit()
//        super.updateConstraints()
//        
//    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}
protocol MessageSingleImageCellDelegate:class {
    func didTapReplyAtSingleImageCell(cell:MessageSingleImageCell)
    func didTapImgAtSingleImageCell(cell:MessageSingleImageCell)
    func didTapAvatarAtSingleImageCell(cell:MessageSingleImageCell)
}


class MessageSingleImageCell:UITableViewCell {
    
    func imageSizeFor(image:UIImage?) ->CGSize {
        
        let newHeight = MessageSingleImageCell.IMAGE_SIZE
        if let img = image {
            let newWidth = min(img.size.width * newHeight / img.size.height,SCREEN_WIDTH - 100)
            return CGSizeMake(newWidth, newHeight)
        }
        else {
            return CGSizeMake(0, newHeight)
        }

    }
    
    static let AVATAR_SIZE:CGFloat = 48
    
    static let IMAGE_SIZE:CGFloat = 180
    
    private var avatar:UIImageView!
    private var nameLabel:UILabel!
    private var infoLabel:UILabel!
    
    private var bodyLabel:UILabel!
    
    private var timeLabel:UILabel!
    
    private var imgView:UIImageView!
    
    private var reply:UIImageView!

    private weak var delegate:MessageSingleImageCellDelegate?
    
    func tap(sender:AnyObject?) {
        delegate?.didTapReplyAtSingleImageCell(self)
    }
    
    func tapImg(sender:AnyObject?) {
        delegate?.didTapImgAtSingleImageCell(self)
    }
    
    func tapAvatar(sender:AnyObject) {
        delegate?.didTapAvatarAtSingleImageCell(self)
    }
    
    func initialize() {
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = MessageSingleImageCell.AVATAR_SIZE/2
        avatar.layer.masksToBounds = true
        avatar.frame = CGRectMake(0, 0, MessageSingleImageCell.AVATAR_SIZE, MessageSingleImageCell.AVATAR_SIZE)
        contentView.addSubview(avatar)
        avatar.userInteractionEnabled = true
        let tapAvatar = UITapGestureRecognizer(target: self, action: "tapAvatar:")
        avatar.addGestureRecognizer(tapAvatar)

        //contentView.backgroundColor = SECONDAY_COLOR
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFontOfSize(15)
        //nameLabel.backgroundColor = SECONDAY_COLOR
        nameLabel.textColor = THEME_COLOR//UIColor.colorFromRGB(0x6A5ACD)
        contentView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        infoLabel.textColor = UIColor.lightGrayColor()
        infoLabel.textAlignment = .Right
        contentView.addSubview(infoLabel)
        
        bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .ByWordWrapping
        bodyLabel.textColor = TEXT_COLOR
       // bodyLabel.backgroundColor = UIColor.yellowColor()
        bodyLabel.font = UIFont.systemFontOfSize(15)
        contentView.addSubview(bodyLabel)
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        timeLabel.textColor = UIColor.lightGrayColor()
        //timeLabel.backgroundColor = UIColor.blueColor()//SECONDAY_COLOR
        contentView.addSubview(timeLabel)
        
        imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        //imgView.frame = CGRectMake(0, 0, MessageSingleImageCell.AVATAR_SIZE, MessageSingleImageCell.AVATAR_SIZE)
        //imgView.backgroundColor = SECONDAY_COLOR
        let tapImg = UITapGestureRecognizer(target: self, action: "tapImg:")
        imgView.userInteractionEnabled = true
        imgView.addGestureRecognizer(tapImg)
        contentView.addSubview(imgView)
        
        
        reply = UIImageView(image: UIImage(named: "reply"))
        reply.userInteractionEnabled = true
        reply.translatesAutoresizingMaskIntoConstraints = false
        reply.tintColor = THEME_COLOR
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        reply.addGestureRecognizer(tap)
        contentView.addSubview(reply)
        //contentView.translatesAutoresizingMaskIntoConstraints = false
        avatar.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp_top).offset(10)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.width.height.equalTo(MessageSingleImageCell.AVATAR_SIZE)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(contentView.snp_right).offset(-10)
            make.centerY.equalTo(nameLabel.snp_centerY)
            make.left.equalTo(nameLabel.snp_right)
            infoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)

        }
        let rect = ("历" as NSString).boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:nameLabel.font], context: nil)
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(avatar.snp_top).offset(0)
            make.left.equalTo(avatar.snp_right).offset(10)
            make.height.equalTo(rect.height)
            nameLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        }
        
        bodyLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
            make.top.equalTo(nameLabel.snp_bottom).offset(0)
            make.right.equalTo(contentView.snp_rightMargin)
           // make.height.equalTo(100).priorityMedium()
            bodyLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            //make.bottom.equalTo(snp_bottom).offset(-10)
        }
        //
        //imgView.contentMode = UIViewContentMode.ScaleAspectFill
        imgView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
            make.top.equalTo(bodyLabel.snp_bottom)
            //make.width.equalTo(180)//.priorityLow()
            make.height.equalTo(180)//.priorityLow()
            
        }
        let rec = ("历" as NSString).boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:timeLabel.font], context: nil)
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
            make.top.equalTo(imgView.snp_bottom).offset(5)
            make.width.equalTo(100)
            make.height.equalTo(rec.height)
            make.bottom.equalTo(contentView.snp_bottom).offset(-10)

        }
        
        reply.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(infoLabel.snp_right)
            make.width.height.equalTo(20)
            make.centerY.equalTo(timeLabel.snp_centerY)
            //make.bottom.equalTo(snp_bottom).offset(-10)
            
        }
        

    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    
    override func prepareForReuse() {
         super.prepareForReuse()
        imgView.image = nil
    }
//    override func updateConstraints() {
//        print("called")
//        bodyLabel.resizeMessageBodyLabelHeightWithSnapKit()
//        imgView.resizeMessageImageViewSizeWithSnapKit()
//        super.updateConstraints()
//
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


class MessageMultiImageController:NSObject {
    private var images = [UIImage]()
    
    private(set) var imageURLs = [String]() {
        didSet {
            cell?.resizeImageCollectionView()
            cell?.imageCollectionView.reloadData()
        }
    }
    
    private weak var cell:MessageMultiImageCell?
    
    
}

extension MessageMultiImageController:UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(MessageMultiImageCollectionViewCell), forIndexPath: indexPath) as! MessageMultiImageCollectionViewCell
        cell.imageView.sd_setImageWithURL(NSURL(string:imageURLs[indexPath.item]), placeholderImage: nil)
        return cell
        
    }
}

extension MessageMultiImageController:UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        cell?.delegate?.didTapImageCollectionView(imageURLs, startIndex: indexPath.item)
    }
}


extension MessageMultiImageController:UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: MessageMultiImageCell.IMAGE_SIZE , height: MessageMultiImageCell.IMAGE_SIZE)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(MessageMultiImageCell.IMAGE_SPACE, MessageMultiImageCell.IMAGE_SPACE, MessageMultiImageCell.IMAGE_SPACE, MessageMultiImageCell.IMAGE_SPACE)
    }

}

class MessageMultiImageCollectionViewCell:UICollectionViewCell {
    lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.bounds.size = CGSizeMake(MessageMultiImageCell.IMAGE_SIZE, MessageMultiImageCell.IMAGE_SIZE)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initialize() {
        addSubview(imageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        
    }

}


protocol MessageMultiImageCellDelegate: class{
    func didTapReplyAtMultiImageCell(cell:MessageMultiImageCell)
    func didTapImageCollectionView(urls:[String], startIndex:Int)
    func didTapAvatarAtMultiImageCell(cell:MessageMultiImageCell)
}

class MessageMultiImageCell:UITableViewCell {
    private var msgController:MessageMultiImageController! {
        didSet {
            msgController.cell = self
            imageCollectionView.dataSource = msgController
            imageCollectionView.delegate  = msgController
            //resizeImageCollectionView()
        }
    }
    
    static let AVATAR_SIZE:CGFloat = 48
    
    static let IMAGE_SPACE:CGFloat = 10
    static let IMAGE_SIZE:CGFloat = (SCREEN_WIDTH-120)/3
    
    private weak var delegate:MessageMultiImageCellDelegate?
    private var avatar:UIImageView!
    private var nameLabel:UILabel!
    private var infoLabel:UILabel!
    
    private var bodyLabel:UILabel!
    
    private var timeLabel:UILabel!
    
    private(set) lazy var imageCollectionView:UICollectionView = {
        let imageCollectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
      
        imageCollectionView.registerClass(MessageMultiImageCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(MessageMultiImageCollectionViewCell))
        //let backColor = UIColor(red: 238/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1.0)
        imageCollectionView.backgroundColor = UIColor.whiteColor()
        return imageCollectionView
    }()
    
    private var reply:UIImageView!
    
    func tap(sender:AnyObject?) {
        delegate?.didTapReplyAtMultiImageCell(self)
    }
    
    func tapAvatar(sender:AnyObject) {
        delegate?.didTapAvatarAtMultiImageCell(self)
    }
    
    func initialize() {
        avatar.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(contentView.snp_top).offset(10)
            make.left.equalTo(contentView.snp_left).offset(10)
            make.width.height.equalTo(MessageSingleImageCell.AVATAR_SIZE)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(contentView.snp_right).offset(-10)
            make.centerY.equalTo(nameLabel.snp_centerY)
            make.left.equalTo(nameLabel.snp_right)
            infoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)

        }
        let rect = ("历" as NSString).boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:nameLabel.font], context: nil)
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(avatar.snp_top).offset(0)
            make.left.equalTo(avatar.snp_right).offset(10)
            make.height.equalTo(rect.height)
            nameLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)

        }
        
        bodyLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
            make.top.equalTo(nameLabel.snp_bottom).offset(0)
            make.right.equalTo(contentView.snp_rightMargin)
            //make.height.equalTo(100).priorityHigh()
            bodyLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        }
            //make.bottom.equalTo(snp
        imageCollectionView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left).offset(-MessageMultiImageCell.IMAGE_SPACE)
            make.top.equalTo(bodyLabel.snp_bottom)
            //make.width.equalTo(0)
            //make.height.equalTo(80 * (msgController.imageURLs.count + 2/3))
            //resizeImageCollectionView()
        }
        
        let rec = ("历" as NSString).boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:timeLabel.font], context: nil)
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
            make.top.equalTo(imageCollectionView.snp_bottom).offset(5)
            make.width.equalTo(100)
            make.height.equalTo(rec.height)
            make.bottom.equalTo(contentView.snp_bottom).offset(-10)
        }
        
        reply.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(infoLabel.snp_right)
            make.width.height.equalTo(20)
            make.centerY.equalTo(timeLabel.snp_centerY)
            
            
        }
        

    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       // contentView.translatesAutoresizingMaskIntoConstraints = false
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = MessageSingleImageCell.AVATAR_SIZE/2
        avatar.layer.masksToBounds = true
        avatar.frame = CGRectMake(0, 0, MessageSingleImageCell.IMAGE_SIZE, MessageSingleImageCell.IMAGE_SIZE)
        contentView.addSubview(avatar)
        
        avatar.userInteractionEnabled = true
        let tapAvatar = UITapGestureRecognizer(target: self, action: "tapAvatar:")
        avatar.addGestureRecognizer(tapAvatar)

        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.boldSystemFontOfSize(15)
        //nameLabel.backgroundColor = SECONDAY_COLOR
        nameLabel.textColor = THEME_COLOR//UIColor.colorFromRGB(0x6A5ACD)
        contentView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        infoLabel.textColor = UIColor.lightGrayColor()
        infoLabel.textAlignment = .Right
        contentView.addSubview(infoLabel)
        
        bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .ByWordWrapping
        bodyLabel.textColor = TEXT_COLOR
        //bodyLabel.backgroundColor = UIColor.yellowColor()
        bodyLabel.font = UIFont.systemFontOfSize(15)
        contentView.addSubview(bodyLabel)
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        timeLabel.textColor = UIColor.lightGrayColor()
        
        contentView.addSubview(timeLabel)
        
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        imageCollectionView.scrollEnabled = false
        contentView.addSubview(imageCollectionView)

        
        
        reply = UIImageView(image: UIImage(named: "reply"))
        reply.translatesAutoresizingMaskIntoConstraints = false
        reply.userInteractionEnabled = true
        reply.tintColor = THEME_COLOR
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        reply.addGestureRecognizer(tap)

        contentView.addSubview(reply)
        
        initialize()
        
    }
    
    func resizeImageCollectionView() {
        let rows = (msgController.imageURLs.count + 2) / 3
        let h = CGFloat(rows) * MessageMultiImageCell.IMAGE_SIZE + CGFloat(rows + 1) * MessageMultiImageCell.IMAGE_SPACE
        let cols = min(msgController.imageURLs.count, 3)
        let w = CGFloat(cols) * MessageMultiImageCell.IMAGE_SIZE + CGFloat(cols + 1) * MessageMultiImageCell.IMAGE_SPACE
        
        imageCollectionView.snp_updateConstraints { (make) -> Void in
            make.height.equalTo(h).priorityHigh()
            make.width.equalTo(w)
        }
        
    }
    

 
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    
}

class MessageVC :UITableViewController {

    var sendID:String?
    
    private var page = 1

    
    private var messages = [JSON]()
    
    var refreshCont:UIRefreshControl!


    
    func loadOnePage() {
        if let token = NSUserDefaults.standardUserDefaults().stringForKey("TOKEN"),
            let id = sendID {
            request(.POST, GET_MESSAGE_DETAIL_LIST, parameters: ["token":token, "page":"\(page)", "SendId":id], encoding: .JSON, headers: nil).responseJSON(completionHandler: { [weak self](response) -> Void in
                //debugPrint(response)
                if let _self = self {
                    if let d = response.result.value {
                    
                    let json = JSON(d)
                    if json["state"] == "successful" {
                        
                        if let arr = json["result"].array {
                            let cnt = _self.messages.count
                            _self.messages.appendContentsOf(arr)
                            
                            var indexArr = [NSIndexPath]()
                            for k in 0..<arr.count {
                                let indexPath = NSIndexPath(forRow: cnt+k, inSection: 0)
                                indexArr.append(indexPath)
                            }
                            
                            if (arr.count > 0) {
                                _self.page++
                                _self.tableView.insertRowsAtIndexPaths(indexArr, withRowAnimation: UITableViewRowAnimation.Fade)
                            }
                            
                        }
                    }
                }
                }
                
            })
        }
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
        title = "私信"
        automaticallyAdjustsScrollViewInsets = false
        tableView.backgroundColor = BACK_COLOR
        tableView.tableFooterView = UIView()
        tableView.registerClass(MessagePureTextCell.self, forCellReuseIdentifier: (NSStringFromClass(MessagePureTextCell.self) as String))
        tableView.registerClass(MessageSingleImageCell.self, forCellReuseIdentifier: (NSStringFromClass(MessageSingleImageCell.self) as String))
        tableView.registerClass(MessageMultiImageCell.self, forCellReuseIdentifier: NSStringFromClass(MessageMultiImageCell))
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 180
        tableView.allowsSelection = false
        
        
        refreshCont = UIRefreshControl()
        refreshCont.backgroundColor = BACK_COLOR
        refreshCont.addTarget(self, action: "pullRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        view.addSubview(refreshCont)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didSendMessage:", name: ComposeMessageVC.DID_SEND_MESSAGE_NOTIFICATION, object: nil)
        
        loadOnePage()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func didSendMessage(sender:AnyObject) {
        pullRefresh(nil)
    }
    
    

    func pullRefresh(sender:AnyObject?) {
        messages = [JSON]()
        tableView.reloadData()
        page = 1
        loadOnePage()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1*Int64(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.refreshCont.endRefreshing()
        }
    }

    func back(sender:AnyObject?) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.messages.count - 1 {
            loadOnePage()
        }

    }
    
    func readMessageForID(id:String) {
        if let token = NSUserDefaults.standardUserDefaults().stringForKey(TOKEN) {
            request(.POST, READ_MESSAGE, parameters: ["token":token, "id":id], encoding: .JSON).responseJSON(completionHandler: { (response) -> Void in
                
            })
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let data = self.messages[indexPath.row]
        let text = data["text"].string ?? " "
        let rect = (text as NSString).boundingRectWithSize(CGSizeMake(tableView.frame.size.width-80, CGFloat.max), options: .UsesLineFragmentOrigin, attributes:[NSFontAttributeName:UIFont.systemFontOfSize(15)], context: nil)

        
        if data["image"].array?.count == 1 {
            return rect.height + MessageSingleImageCell.IMAGE_SIZE + 80
        }
        else if data["image"].array?.count > 1 {
            let c = data["image"].array!.count
            let rows = (c + 2) / 3
            let h = CGFloat(rows) * MessageMultiImageCell.IMAGE_SIZE + CGFloat(rows + 1) * MessageMultiImageCell.IMAGE_SPACE
            return rect.height + h + 80
        }
        else {
            return rect.height + 80
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let data = self.messages[indexPath.row]
        if data["readstate"].stringValue == "1" {
            readMessageForID(data["messageid"].stringValue)
        }
        
       
        if data["image"].array?.count == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MessageSingleImageCell), forIndexPath: indexPath) as! MessageSingleImageCell
            cell.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(data["SendId"].stringValue), placeholderImage: UIImage(named: "avatar"))


            cell.infoLabel.text = data["school"].string ?? " "
            cell.timeLabel.text = " "
            cell.bodyLabel.text = data["text"].string ?? " "
           // cell.bodyLabel.resizeMessageBodyLabelHeightWithSnapKit()
            let url = NSURL(string:data["image"][0].stringValue)!
            cell.imgView?.sd_setImageWithURL(url, completed: { (image, error, cacheType, url) -> Void in
                let img = image?.scaleImage(cell.imageSizeFor(image))
                cell.imgView?.image = img
            })
            

            cell.nameLabel.text = data["name"].string ?? " "
            let time = data["time"].stringValue
            let dateFormat = NSDateFormatter(withUSLocaleAndFormat: "EE, d LLLL yyyy HH:mm:ss zzzz")
            if let date = dateFormat.dateFromString(time) {
                cell.timeLabel.text = date.hunmanReadableString()
            }
            cell.reply.hidden = (data["SendId"].stringValue != (sendID!))
            cell.delegate = self
            return cell
        }
        else if data["image"].array?.count > 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MessageMultiImageCell), forIndexPath: indexPath) as! MessageMultiImageCell
            if cell.msgController == nil {
                cell.msgController = MessageMultiImageController()
            }
     
            cell.msgController.imageURLs = data["image"].arrayObject as! [String]
           
   
            cell.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(data["SendId"].stringValue), placeholderImage: UIImage(named: "avatar"))
        
            cell.infoLabel.text = data["school"].string ?? " "
            cell.timeLabel.text = " "
            cell.bodyLabel.text = data["text"].string ?? " "
           // cell.bodyLabel.resizeMessageBodyLabelHeightWithSnapKit()
            cell.nameLabel.text = data["name"].string ?? " "
            let time = data["time"].stringValue
            let dateFormat = NSDateFormatter(withUSLocaleAndFormat: "EE, d LLLL yyyy HH:mm:ss zzzz")
            if let date = dateFormat.dateFromString(time) {
                cell.timeLabel.text = date.hunmanReadableString()
            }
            cell.reply.hidden = (data["SendId"].stringValue != (sendID!))
            cell.delegate = self
            return cell

        }
        
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MessagePureTextCell)) as! MessagePureTextCell
            cell.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(data["SendId"].stringValue), placeholderImage: UIImage(named: "avatar"))

            cell.nameLabel.text = data["name"].string ?? " "
            cell.infoLabel.text = data["school"].string ?? " "
            cell.timeLabel.text = " "
            cell.bodyLabel.text = data["text"].string ?? " "
            //cell.bodyLabel.resizeMessageBodyLabelHeightWithSnapKit()
            let time = data["time"].stringValue
            let dateFormat = NSDateFormatter(withUSLocaleAndFormat: "EE, d LLLL yyyy HH:mm:ss zzzz")
            if let date = dateFormat.dateFromString(time) {
                cell.timeLabel.text = date.hunmanReadableString()
            }
            cell.reply.hidden = (data["SendId"].stringValue != (sendID!))
            cell.delegate = self

            return cell
        }

    }
    

}

extension MessageVC:MessageSingleImageCellDelegate, MessageMultiImageCellDelegate, MessagePureTextCellDelegate{
    func compose(cell:UITableViewCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        let vc = ComposeMessageVC()
        vc.recvID = messages[indexPath.row]["SendId"].stringValue
        navigationController?.pushViewController(vc, animated: true)

    }
    
    func visitInfo(cell:UITableViewCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        let vc = InfoVC()
        let id = messages[indexPath.row]["SendId"].stringValue
        vc.id = id
        navigationController?.pushViewController(vc, animated: true)

    }
    
    func didTapAvatarAtMultiImageCell(cell: MessageMultiImageCell) {
        visitInfo(cell)
    }
    
    func didTapAvatarAtPureTextCell(cell: MessagePureTextCell) {
        visitInfo(cell)
    }
    
    func didTapAvatarAtSingleImageCell(cell: MessageSingleImageCell) {
        visitInfo(cell)
    }
    
    func didTapReplyAtSingleImageCell(cell: MessageSingleImageCell) {
        compose(cell)
    }
    func didTapImgAtSingleImageCell(cell: MessageSingleImageCell) {
        let indexPath = tableView.indexPathForCell(cell)!
        let url = messages[indexPath.row]["image"][0].stringValue
        let agrume = Agrume(imageURL: NSURL(string: url)!)
        agrume.title = "查看照片"
        agrume.showFrom(self)
    }
    
    func didTapImageCollectionView(urls: [String], startIndex: Int) {
        var URLs = [NSURL]()
        for s in urls {
            URLs.append(NSURL(string:s)!)
        }
        let agrume = Agrume(imageURLs: URLs, startIndex: startIndex, backgroundBlurStyle: .Dark)
        agrume.title = "查看照片"
        agrume.showFrom(self)
    }
    
    func didTapReplyAtMultiImageCell(cell: MessageMultiImageCell) {
        compose(cell)
    }
    
    func didTapReplyAtPureTextCell(cell: MessagePureTextCell) {
        compose(cell)
    }
}


protocol MessageConversationCellDelegate:class {
    func didTapAvatarAtCell(cell:MessageConversationCell)
}

class MessageConversationCell : UITableViewCell {
    var avatar :UIImageView!
    var nameLabel:UILabel!
    var infoLabel:UILabel!
    var timeLabel:UILabel!
    var schoolLabel:UILabel!
    var gender:UIImageView!
    var alertInfoView:UIView!
    var messageIcon:UIImageView!
    var verifiedIcon:UIImageView!
    weak var delegate:MessageConversationCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.whiteColor()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left).offset(10)
            make.right.equalTo(snp_right).offset(-10)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
            contentView.layer.cornerRadius = 4.0
            contentView.layer.masksToBounds = true
        }
        
        avatar = UIImageView()
        //avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 30
        avatar.layer.masksToBounds = true
        //avatar.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "tapAvatar:")
        avatar.userInteractionEnabled = true
        avatar.addGestureRecognizer(tap)
        avatar.bounds.size = CGSizeMake(60, 60)
        contentView.addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        nameLabel.textColor = THEME_COLOR//UIColor.colorFromRGB(0x6A5ACD)
        //nameLabel.backgroundColor = SECONDAY_COLOR
        contentView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        infoLabel.textColor = UIColor.lightGrayColor()
        //infoLabel.textAlignment = .Center
        contentView.addSubview(infoLabel)
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        timeLabel.textColor = THEME_COLOR_BACK
        timeLabel.textAlignment = .Right
        contentView.addSubview(timeLabel)
        
        gender = UIImageView()
        gender.translatesAutoresizingMaskIntoConstraints  = false
        contentView.addSubview(gender)
        
        schoolLabel = UILabel()
        schoolLabel.translatesAutoresizingMaskIntoConstraints = false
        schoolLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        //schoolLabel.backgroundColor = THEME_COLOR
        schoolLabel.textColor = THEME_COLOR_BACK
        contentView.addSubview(schoolLabel)
        
        alertInfoView = UIView()
        alertInfoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(alertInfoView)
        
        messageIcon = UIImageView(image: UIImage(named: "message")?.imageWithRenderingMode(.AlwaysTemplate))
        messageIcon.tintColor = THEME_COLOR_BACK
        messageIcon.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageIcon)
        
        verifiedIcon = UIImageView(image: UIImage(named: "verified"))
        verifiedIcon.translatesAutoresizingMaskIntoConstraints = false
        addSubview(verifiedIcon)
        verifiedIcon.hidden = true

        
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_leftMargin)
            //make.top.equalTo(snp_topMargin)
            make.centerY.equalTo(snp_centerY)
            make.width.height.equalTo(60)
        }
        
        verifiedIcon.snp_makeConstraints { (make) in
            make.height.width.equalTo(16)
            make.centerX.equalTo(avatar.snp_centerX).offset(20)
            make.centerY.equalTo(avatar.snp_centerY).offset(20)
        }
        
        let rect = ("历" as NSString).boundingRectWithSize(CGSize(width: CGFloat.max, height: CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:nameLabel.font!], context: nil)
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(5)
            make.centerY.equalTo(timeLabel.snp_centerY)
            make.top.equalTo(avatar.snp_top)
            make.height.equalTo(rect.height)
            nameLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
        
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_right)
            make.right.equalTo(snp_rightMargin)
        }
        
        
        let rec = ("历" as NSString).boundingRectWithSize(CGSize(width: CGFloat.max, height: CGFloat.max), options:NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:schoolLabel.font!], context: nil)
        
        schoolLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
           // make.centerY.equalTo(gender.snp_centerY)
            make.top.equalTo(nameLabel.snp_bottom).offset(5)
            make.height.equalTo(rec.height)
           // make.bottom.equalTo(avatar.snp_bottomMargin)
        }
        
        gender.snp_makeConstraints { (make) -> Void in
            //make.right.equalTo(timeLabel.snp_left)
            make.centerY.equalTo(nameLabel.snp_centerY)
            make.height.equalTo(18)
            make.width.equalTo(16)
            make.left.equalTo(nameLabel.snp_right).offset(2)
        }
        
        messageIcon.snp_makeConstraints { (make) -> Void in
            make.width.height.equalTo(15)
            make.left.equalTo(nameLabel.snp_left)
            make.top.equalTo(schoolLabel.snp_bottom).offset(5)
            make.centerY.equalTo(infoLabel.snp_centerY)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(messageIcon.snp_right).offset(10)
            //make.top.equalTo(schoolLabel.snp_bottom).offset(5)
            //make.right.equalTo(snp_rightMargin)
            //make.bottom.equalTo(snp_bottomMargin)
            make.centerY.equalTo(alertInfoView.snp_centerY)
        }
        
        alertInfoView.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(snp_rightMargin)
            make.left.equalTo(infoLabel.snp_right)
            make.width.height.equalTo(20)
        }
        
        
        
        
    }
    
    func tapAvatar(sender:AnyObject?) {
        delegate?.didTapAvatarAtCell(self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //avatar.image = nil
        nameLabel.text = ""
        infoLabel.text = ""
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MessageConversationVC:UITableViewController {

    private var conversations = [JSON]()
    var refreshCont:UIRefreshControl!

    override func viewDidLoad() {
        title = "私信"
        automaticallyAdjustsScrollViewInsets = false
        tableView.backgroundColor = BACK_COLOR
        tableView.tableFooterView = UIView()
        tableView.registerClass(MessageConversationCell.self, forCellReuseIdentifier: NSStringFromClass(MessageConversationCell))
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 100
        refreshCont = UIRefreshControl()
        refreshCont.backgroundColor = BACK_COLOR
        refreshCont.addTarget(self, action: "pullRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshCont)
        loadConversation()
        if #available(iOS 9, *) {
            if traitCollection.forceTouchCapability == .Available {
                self.registerForPreviewingWithDelegate(self, sourceView: tableView)
            }
        }

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
    
    func pullRefresh(sender:AnyObject) {
        //conversations = [JSON]()
        //tableView.reloadData()
        loadConversation()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1*Int64(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.refreshCont.endRefreshing()
        }
    }

    
    func loadConversation() {
        if let token = NSUserDefaults.standardUserDefaults().stringForKey(TOKEN) {
            request(.POST, GET_MESSGE_USER_LIST, parameters: ["token":token], encoding: .JSON).responseJSON(completionHandler: { (response) -> Void in
               debugPrint(response)
                if let d = response.result.value {
                    let json = JSON(d)
                    if json["state"] == "successful" {
                        let con = json["result"].array!
                        self.conversations = con
                        self.tableView.reloadData()
                    }
                }
                else {}
            })
        }

    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return conversations.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(MessageConversationCell), forIndexPath: indexPath) as! MessageConversationCell
        let data = conversations[indexPath.section]
        let id = data["SendId"].stringValue
        let url = thumbnailAvatarURLForID(id)
        cell.avatar.sd_setImageWithURL(url, placeholderImage: UIImage(named: "avatar"))
        cell.nameLabel.text = data["name"].string ?? " "
        cell.infoLabel.text = data["text"].string ?? " "
        if data["gender"].stringValue == "男" {
            cell.gender.image  = UIImage(named: "male")
        }
        else if data["gender"].stringValue == "女" {
            cell.gender.image = UIImage(named: "female")
        }
        cell.schoolLabel.text = data["school"].string ?? " "
        
        if  data["unreadnum"].stringValue != "0" && data["unreadnum"].stringValue != "" {
            let badge = CustomBadge(string: data["unreadnum"].stringValue)
            cell.alertInfoView.addSubview(badge)
        }
        else if cell.alertInfoView.subviews.count > 0 &&  cell.alertInfoView.subviews[0] is CustomBadge{
            cell.alertInfoView.subviews[0].removeFromSuperview()
        }
        
        
        let lasttime = data["lasttime"].stringValue
        let dateFormat = NSDateFormatter(withUSLocaleAndFormat: "EE, d LLLL yyyy HH:mm:ss zzzz")
        if let date = dateFormat.dateFromString(lasttime) {
            cell.timeLabel.text = date.hunmanReadableString()
        }
        
        cell.delegate = self

        cell.selectionStyle = .None
        cell.backgroundColor = tableView.backgroundColor
        cell.verifiedIcon.hidden = !data["certification"].boolValue
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == conversations.count - 1 ? 10 : 5
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 10 : 5
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRectZero)
        return v
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = conversations[indexPath.section]
        let id = data["SendId"].stringValue
        let msgVC = MessageVC()
        let nav = UINavigationController(rootViewController: msgVC)
        nav.navigationBar.barStyle = .Black
        msgVC.sendID = id
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MessageConversationCell
        if cell.alertInfoView.subviews.count > 0 &&  cell.alertInfoView.subviews[0] is CustomBadge {
            cell.alertInfoView.subviews[0].removeFromSuperview()
        }

        navigationController?.pushViewController(msgVC, animated: true)
    }
    
    
}

@available(iOS 9.0, *)
extension MessageConversationVC:UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
    
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRowAtPoint(location) {
            previewingContext.sourceRect = tableView.rectForRowAtIndexPath(indexPath)
            let data = conversations[indexPath.section]
            let vc = MessageVC()
            vc.sendID = data["SendId"].stringValue
            return vc
        }
        
        return nil
    }
    
}

extension MessageConversationVC:MessageConversationCellDelegate {
    func didTapAvatarAtCell(cell: MessageConversationCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let data = conversations[indexPath.section]
            let id = data["SendId"].stringValue
            let vc = InfoVC()
            vc.id = id
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

