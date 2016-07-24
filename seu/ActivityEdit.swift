//
//  ActivityEdit.swift
//  WE
//
//  Created by liewli on 12/30/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit
import RSKImageCropper

class ActivityEditVC:UITableViewController, ActivityEditMainCellDelegate, UITextFieldDelegate, UITextViewDelegate{
    
    private let info = ["活动时间(必填)...", "活动地点(必填)...", "活动人数(必填)...", "活动备注(可选)..."]
    private let info_icon = ["time", "location", "hand", "remark"]
    
    private var posterImg:UIImage?
    private var needImage = false
    
    
    private var aTitle:String?
    private var aContent:String?
    private var aTime:String?
    private var aLocation:String?
    private var aPeople:String?
    private var aRemark:String?
    private var aSlogan:String?
    
    private var hudd:MBProgressHUD?
    
    func dismiss() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    var controller:ImagePickerSheetController {
        get {
            let presentImagePickerController: UIImagePickerControllerSourceType -> () = { [weak self] source in
                if source == .Camera {
                    let controller = UIImagePickerController()
                    controller.delegate = self
                    var sourceType = source
                    if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                        sourceType = .PhotoLibrary
                    }
                    controller.sourceType = sourceType
                    self?.presentViewController(controller, animated: true, completion: nil)
                    
                }
                else {
                    let controller = UIImagePickerController()
                    controller.delegate = self
                    controller.sourceType = .PhotoLibrary
                    self?.presentViewController(controller, animated: true, completion: nil)
                }
            }
            
            
            let controller = ImagePickerSheetController(mediaType: .Image)
            controller.view.tintColor = THEME_COLOR
            controller.addAction(ImagePickerAction(title: "拍摄", secondaryTitle: "拍摄", handler: { _ in
                presentImagePickerController(.Camera)
                }, secondaryHandler: { _, numberOfPhotos in
                    presentImagePickerController(.Camera)
            }))
            controller.addAction(ImagePickerAction(title: "从相册选择", secondaryTitle:{
                NSString(format: "确定选择这%lu张照片", $0) as String
                }, handler: { _ in
                    presentImagePickerController(.PhotoLibrary)
                }, secondaryHandler: {[weak self] _, numberOfPhotos in
                    if let StrongSelf = self {
                        let asset = controller.selectedImageAssets[0]
                        controller.imageManager.requestImageDataForAsset(asset, options: nil, resultHandler: { (imageData, dataUTI, orientation, info) -> Void in
                            let image = UIImage(data: imageData!)
                            let cropper = RSKImageCropViewController(image: image, cropMode:.Custom)
                            cropper.delegate = self
                            cropper.dataSource = self
                            StrongSelf.presentViewController(cropper, animated: true, completion: nil)
                        })
                        
                    }
                }))
            controller.addAction(ImagePickerAction(title:"取消", style: .Cancel, handler: { _ in
            }))
            
            controller.maximumSelection = 1
            
            return controller
            
        }}

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "发布活动"
        view.backgroundColor = BACK_COLOR
        tableView.tableFooterView = UIView()
        tableView.registerClass(ActivityEditMainTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityEditMainTableViewCell))
        tableView.registerClass(ActivityEditMoreTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityEditMoreTableViewCell))
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        let left = UIBarButtonItem(title: "取消", style: .Plain, target: self, action: "cancel:")
        navigationItem.leftBarButtonItem = left
        
        let right = UIBarButtonItem(title: "发布", style: .Plain, target: self, action: "publish:")
        navigationItem.rightBarButtonItem = right
    }
    
    func cancel(sender:AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func publish(sender:AnyObject) {
        guard aTitle?.characters.count > 0 && aContent?.characters.count > 0 && aTime?.characters.count > 0 && aLocation?.characters.count > 0 && aPeople?.characters.count > 0 else {
            messageAlert("活动信息字段不能为空╮(╯▽╰)╭")
            return
        }
                
        hudd = MBProgressHUD.showHUDAddedTo(tableView, animated: true)
        hudd?.mode = .Indeterminate
        hudd?.labelText = "发布活动..."
        if let t = token {
            let dict = ["token":t,
                        "title":aTitle ?? "",
                        "time":aTime ?? "",
                        "location":aLocation ?? "",
                        "number":aPeople ?? "",
                        "remark":aRemark ?? "",
                        "detail":aContent ?? "",
                        "whetherimage":(needImage ? "1" : "0"),
                        "advertise":(aSlogan ?? ""),
                        "label":""]
            request(.POST, PUBLISH_ACTIVITY_URL, parameters: dict, encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" else {
                        S.hudd?.hide(true)
                        let hud = MBProgressHUD.showHUDAddedTo(S.tableView, animated: true)
                        hud.labelText = "错误"
                        hud.detailsLabelText = "发布活动失败 \(json["reason"].stringValue)"
                        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
                        dispatch_after(delay, dispatch_get_main_queue(), { () -> Void in
                            hud.hide(true)
                           
                        })

                        return
                    }
                    
                    let id = json["id"].stringValue
                    
                    if let img = S.posterImg{
                            upload(.POST, UPLOAD_AVATAR_URL, multipartFormData: { multipartFormData in
                                let dd = "{\"token\":\"\(t)\", \"type\":\"-10\", \"activityid\":\"\(id)\",\"number\":\"0\"}"
                                let jsonData = dd.dataUsingEncoding(NSUTF8StringEncoding)
                                let data = UIImageJPEGRepresentation(img, 0.75)
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
                                                    S.hudd?.hide(true)
                                                    let hud = MBProgressHUD.showHUDAddedTo(S.tableView, animated: true)
                                                    hud.labelText = "发布活动成功"
                                                    hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                                                    hud.mode = .CustomView
                                                    
                                                    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
                                                    dispatch_after(delay, dispatch_get_main_queue(), { () -> Void in
                                                        hud.hide(true)
                                                        S.dismiss()
                                                    })

                                                }
                                                else {
                                                  S.hudd?.hide(true)
                                                    let alert = UIAlertController(title: "提示", message: j["reason"].stringValue, preferredStyle: .Alert)
                                                    alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                                                    S.presentViewController(alert, animated: true, completion: nil)
                                                    return
                                                    
                                                }
                                            }
                                            else if let error = response.result.error {
                                               S.hudd?.hide(true)
                                                let alert = UIAlertController(title: "提示", message: error.localizedFailureReason ?? error.localizedDescription, preferredStyle: .Alert)
                                                alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                                                S.presentViewController(alert, animated: true, completion: nil)
                                                return
                                                
                                            }
                                        }
                                        
                                    case .Failure:
                                        //print(encodingError)
                                       // S.hudd?.hide(true)
                                        let alert = UIAlertController(title: "提示", message: "上载活动图片失败" , preferredStyle: .Alert)
                                        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                                        S.presentViewController(alert, animated: true, completion: nil)
                                        return
                                        
                                    }
                                }
                                
                            )
                            
                            
                            
                    }
                    else {
                       S.hudd?.hide(true)
                        let hud = MBProgressHUD.showHUDAddedTo(S.tableView, animated: true)
                        hud.labelText = "发布活动成功"
                        hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                        hud.mode = .CustomView
                        
                        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64( NSEC_PER_SEC))
                        dispatch_after(delay, dispatch_get_main_queue(), { () -> Void in
                            hud.hide(true)
                            S.dismiss()
                        })

                    }
                    
                }
            })
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        tabBarController?.tabBar.hidden = true
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : ((section == 1) ? info.count : 1)
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRectZero)
        return v
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityEditMainTableViewCell), forIndexPath: indexPath) as! ActivityEditMainTableViewCell
            
            cell.titleTextView.placeholder = "活动标题(必填)"
            cell.sloganTextView.placeholder = "活动宣传语(可选)"
            cell.sloganTextView.tag = 0
            cell.titleTextView.tag = 1
            cell.sloganTextView.delegate = self
            cell.bodyTextView.delegate = self
            cell.titleTextView.delegate = self
            cell.coverImageView.image = posterImg ?? UIImage(named: "add_img")
            cell.titleTextView.becomeFirstResponder()
            cell.sloganTextView.addTarget(self, action: "textChange:", forControlEvents: .EditingChanged)
            cell.titleTextView.addTarget(self, action: "textChange:", forControlEvents: UIControlEvents.EditingChanged)
            cell.selectionStyle = .None
            cell.delegate = self
            return cell
        }
        else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityEditMoreTableViewCell), forIndexPath: indexPath) as! ActivityEditMoreTableViewCell
            cell.icon.image = UIImage(named: info_icon[indexPath.row])
            cell.textContentField.placeholder = info[indexPath.row]
            cell.selectionStyle = .None
            cell.textContentField.addTarget(self, action: "textChange:", forControlEvents: UIControlEvents.EditingChanged)
            cell.textContentField.delegate = self
            cell.textContentField.tag =  2 + indexPath.row
            if indexPath.row == 0 {
                cell.textContentField.text = aTime
            }
            else if indexPath.row == 1 {
                cell.textContentField.text = aLocation
            }
            else if indexPath.row == 2 {
                cell.textContentField.text = aPeople
                cell.textContentField.keyboardType = .NumberPad
            }
            else {
                cell.textContentField.text = aRemark
            }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
            cell.textLabel?.text  = "是否需要用户上传生活照"
            cell.textLabel?.textColor =  UIColor(red: 81/255.0, green: 87/255.0, blue: 113/255.0, alpha: 1.0)
            cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
            let toggle = UISwitch(frame: CGRectZero)
            toggle.onTintColor = THEME_COLOR
            cell.accessoryView = toggle
            toggle.setOn(false, animated: false)
            toggle.addTarget(self, action: "toggle:", forControlEvents: UIControlEvents.ValueChanged)
            cell.selectionStyle = .None
            return cell
        }
    }
    
 
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if let pointInTable = textField.superview?.convertPoint(textField.frame.origin, toView: tableView) {
            var contentOffset = tableView.contentOffset
            contentOffset.y = max(0, pointInTable.y - 100)
            tableView.setContentOffset(contentOffset, animated: true)
        }
        return true
    }
    
    func textChange(sender:UITextField) {
       switch sender.tag {
       case 0:
            aSlogan = sender.text
        case 1:
            aTitle = sender.text
        case 2:
            aTime = sender.text
        case 3:
            aLocation = sender.text
        case 4:
            aPeople = sender.text
        case 5:
            aRemark = sender.text
        default:
            break
        }

    }
    
    
    func toggle(sender:UISwitch) {
        needImage = sender.on
    }
    
    func didTapCoverAtCell(cell: ActivityEditMainTableViewCell) {
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        aContent = textView.text
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if let pointInTable = textView.superview?.convertPoint(textView.frame.origin, toView: tableView) {
            var contentOffset = tableView.contentOffset
            contentOffset.y = max(0, pointInTable.y - 100)
            tableView.setContentOffset(contentOffset, animated: true)

        }

        return true
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        tableView.endEditing(true)
    }
    
 
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text
        let updatedText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: text)
        if updatedText.isEmpty {
            textView.text = "活动详情(必填)..."
            textView.textColor = UIColor.colorFromRGB(0xC7C7CD)
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            return false
        }
            
        else if textView.textColor == UIColor.colorFromRGB(0xC7C7CD) && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor(red: 81/255.0, green: 87/255.0, blue: 113/255.0, alpha: 1.0)
        }
        return true
        
    }

    
    func textViewDidChangeSelection(textView: UITextView) {
        if textView.textColor == UIColor.colorFromRGB(0xC7C7CD) {
            textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
            
        }
    }
    
}

extension ActivityEditVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let cropper = RSKImageCropViewController(image: image, cropMode:.Custom)
        cropper.delegate = self
        cropper.dataSource = self
        presentViewController(cropper, animated: true, completion: nil)
        
    }
}

extension ActivityEditVC:RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource{
    func imageCropViewController(controller: RSKImageCropViewController!, didCropImage croppedImage: UIImage!, usingCropRect cropRect: CGRect) {
        dismissViewControllerAnimated(true, completion: nil)
         let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! ActivityEditMainTableViewCell
         cell.coverImageView.image = croppedImage
         self.posterImg = croppedImage
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageCropViewControllerCustomMaskRect(controller: RSKImageCropViewController!) -> CGRect {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! ActivityEditMainTableViewCell
        let cover = cell.coverImageView
        return CGRectMake(view.center.x - cover.bounds.size.width/2, view.center.y-cover.bounds.size.height/2, cover.bounds.size.width, cover.bounds.size.height)
    }
    
    func imageCropViewControllerCustomMaskPath(controller: RSKImageCropViewController!) -> UIBezierPath! {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! ActivityEditMainTableViewCell
        let cover = cell.coverImageView
        return UIBezierPath(rect: CGRectMake(view.center.x - cover.bounds.size.width/2, view.center.y-cover.bounds.size.height/2, cover.bounds.size.width, cover.bounds.size.height))
    }
}


class ActivityEditMoreTableViewCell:UITableViewCell {
    
    private var icon:UIImageView!
    private var textContentField:UITextField!
    
    func initialize() {
        icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(icon)
        
        textContentField = UITextField()
        textContentField.translatesAutoresizingMaskIntoConstraints = false
        textContentField.textColor = UIColor(red: 81/255.0, green: 87/255.0, blue: 113/255.0, alpha: 1.0)
        textContentField.tintColor = THEME_COLOR
        textContentField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        contentView.addSubview(textContentField)
        
        icon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.centerY.equalTo(contentView.snp_centerY)
            make.width.height.equalTo(26)
        }
        
        textContentField.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(icon.snp_right).offset(10)
            make.centerY.equalTo(icon.snp_centerY)
            make.right.equalTo(contentView.snp_rightMargin)
            make.bottom.equalTo(contentView.snp_bottom)
            make.height.equalTo(44)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

protocol ActivityEditMainCellDelegate:class {
    func didTapCoverAtCell(cell:ActivityEditMainTableViewCell)
}

class ActivityEditMainTableViewCell:UITableViewCell{
    
    private var titleTextView:UITextField!
    
    private var coverImageView:UIImageView!
    
    private var bodyTextView:UITextView!
    
    private var sloganTextView:UITextField!
    
    weak var delegate:ActivityEditMainCellDelegate?

    func initialize() {
        titleTextView = UITextField()
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextView.tintColor = THEME_COLOR
        titleTextView.textColor = UIColor(red: 81/255.0, green: 87/255.0, blue: 113/255.0, alpha: 1.0)
        titleTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        contentView.addSubview(titleTextView)
        
        coverImageView = UIImageView()
        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.userInteractionEnabled = true
        coverImageView.contentMode = .ScaleAspectFit
        let tap = UITapGestureRecognizer(target: self, action: "tapCover:")
        coverImageView.addGestureRecognizer(tap)
        contentView.addSubview(coverImageView)
        
        let seperator = UIView()
        seperator.backgroundColor = BACK_COLOR
        seperator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(seperator)
        
        bodyTextView = UITextView()
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bodyTextView)
        bodyTextView.text = "活动详情(必填)..."
        bodyTextView.textColor = UIColor.colorFromRGB(0xC7C7CD)
        bodyTextView.tintColor = THEME_COLOR
        bodyTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        bodyTextView.selectedTextRange = bodyTextView.textRangeFromPosition(bodyTextView.beginningOfDocument, toPosition: bodyTextView.beginningOfDocument)

        let seperator1 = UIView()
        seperator1.backgroundColor = BACK_COLOR
        seperator1.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(seperator1)
        
        sloganTextView = UITextField()
        sloganTextView.translatesAutoresizingMaskIntoConstraints = false
        sloganTextView.tintColor = THEME_COLOR
        sloganTextView.textColor = TEXT_COLOR
        sloganTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        contentView.addSubview(sloganTextView)
        
        
        coverImageView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(contentView.snp_top)
            make.height.equalTo(coverImageView.snp_width).multipliedBy(0.5)
            
        }
        
        titleTextView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(coverImageView.snp_bottom).offset(20)
        }
        
        seperator.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(titleTextView.snp_bottom).offset(5)
            make.height.equalTo(1)
        }
        
        sloganTextView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(seperator.snp_bottom).offset(10)
        }

        seperator1.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(sloganTextView.snp_bottom).offset(10)
            make.height.equalTo(1)
        }


        
        bodyTextView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(seperator1.snp_bottom).offset(5)
            make.height.equalTo(bodyTextView.snp_width).multipliedBy(0.2)
            make.bottom.equalTo(contentView.snp_bottom)
        }
        
    }
    
    
    func tapCover(sender:AnyObject) {
        delegate?.didTapCoverAtCell(self)
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

