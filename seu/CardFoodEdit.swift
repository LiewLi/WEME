//
//  CardFoodEdit.swift
//  WEME
//
//  Created by liewli on 2016-01-12.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit
import MapKit
import RSKImageCropper
import GMImagePicker

class CardFoodEditVC:UITableViewController,UITextViewDelegate, CardFoodEditTableViewCellDelegate, LocationVCDelegate,CardFoodPriceRangeVCDelegate {
    private var fTitle:String?
    private var fComment:String?
    private var fLocationName:String?
    private var fLocation:CLLocationCoordinate2D?
    private var fPrice:String?
    private var fCoverImg:UIImage?
    
    private var moreInfo = ["美食地点", "人均消费"]
    private var moreImg = ["location", "rmb"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "编辑美食卡片"
        tableView.backgroundColor = BACK_COLOR
        tableView.registerClass(CardFoodEditTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(CardFoodEditTableViewCell))
        tableView.registerClass(CardFoodMoreTebleViewCell.self, forCellReuseIdentifier: NSStringFromClass(CardFoodMoreTebleViewCell))
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        let left = UIBarButtonItem(title: "取消", style: .Plain, target: self, action: "cancel:")
        navigationItem.leftBarButtonItem = left
        
        let right = UIBarButtonItem(title: "完成", style: .Plain, target: self, action: "publish:")
        navigationItem.rightBarButtonItem = right
    }
    
    func cancel(sender:AnyObject) {
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

    
    func publish(sender:AnyObject) {
        guard fTitle?.characters.count > 0 && fLocationName?.characters.count > 0 && fPrice?.characters.count > 0 && fLocation != nil else {
            messageAlert("必填信息不能遗漏哦")
            return
        }
        guard fComment?.characters.count < 100 else {
            messageAlert("评论信息不要超过100字")
            return
        }
        guard fCoverImg != nil else {
            messageAlert("美食照片不能为空哦")
            return
        }
        if let t = token {
            let dict = ["token":t,
                        "title":fTitle ?? "",
                        "location":fLocationName ?? "",
                        "longitude":"\(fLocation!.longitude)",
                        "latitude":"\(fLocation!.latitude)",
                        "price":fPrice ?? "",
                        "comment":fComment ?? ""]
            request(.POST, PUBLISH_FOOD_CARD_URL, parameters: dict, encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        S.messageAlert("提交卡片失败")
                        return
                    }
                    
                    let id = json["id"].stringValue
                    let img = S.fCoverImg!
                    upload(.POST, UPLOAD_AVATAR_URL, multipartFormData: { multipartFormData in
                        let dd = "{\"token\":\"\(t)\", \"type\":\"-11\", \"foodcardid\":\"\(id)\"}"
                        print(dd)
                        let jsonData = dd.dataUsingEncoding(NSUTF8StringEncoding)
                        let data = UIImageJPEGRepresentation(img, 0.75)
                        multipartFormData.appendBodyPart(data:jsonData!, name:"json")
                        multipartFormData.appendBodyPart(data:data!, name:"avatar", fileName:"avatar.jpg", mimeType:"image/jpeg")
                        
                        }, encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .Success(let upload, _ , _):
                                upload.responseJSON { response in
                                    debugPrint(response)
                                    if let d = response.result.value {
                                        let j = JSON(d)
                                        if j != .null && j["state"].stringValue  == "successful" {
                        
                                            let hud = MBProgressHUD.showHUDAddedTo(S.view, animated: true)
                                            hud.mode = .CustomView
                                            hud.customView = UIImageView(image: UIImage(named:"checkmark"))
                                            hud.labelText = "提交成功，等待审核"
                                            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
                                            dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
                                                S.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                                            }

                                        }
                                        else {
                                            print(j["reason"].stringValue)
                                            S.messageAlert("上载活动图片失败")
                                            return
                                            
                                        }
                                    }
                                    else if let _ = response.result.error {
                                        S.messageAlert("上载活动图片失败")
                                        return
                                        
                                    }
                                }
                                
                            case .Failure:
                                S.messageAlert("上载活动图片失败")
                                return
                                
                            }
                        }
                        
                    )

                    

                }
            })
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return moreInfo.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(CardFoodEditTableViewCell), forIndexPath: indexPath) as! CardFoodEditTableViewCell
            cell.titleTextView.placeholder = "美食名称(必填)"
            cell.coverImageView.image = fCoverImg ?? UIImage(named: "add_img")
            cell.titleTextView.addTarget(self, action: "textChange:", forControlEvents: .EditingChanged)
            cell.bodyTextView.delegate = self
            cell.selectionStyle = .None
            cell.delegate = self
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(CardFoodMoreTebleViewCell), forIndexPath: indexPath) as! CardFoodMoreTebleViewCell
            cell.selectionStyle = .None
            cell.icon.image = UIImage(named: moreImg[indexPath.row])?.imageWithRenderingMode(.AlwaysTemplate)
            if indexPath.row == 0 {
                if let loc = fLocationName {
                    print(loc)
                    cell.infoLabel.textColor = TEXT_COLOR
                    cell.infoLabel.text = loc
                }
                else {
                    cell.infoLabel.textColor = PLACEHOLDER_COLOR
                    cell.infoLabel.text = moreInfo[indexPath.row]
                }
            }
            else if indexPath.row == 1  {
                if let price = fPrice {
                    cell.infoLabel.textColor = TEXT_COLOR
                    cell.infoLabel.text = price
                }
                else {
                    cell.infoLabel.textColor = PLACEHOLDER_COLOR
                    cell.infoLabel.text = moreInfo[indexPath.row]
                }
            }
            cell.accessoryType = .DisclosureIndicator
            return cell
        }
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let vc = LocationVC()
                vc.delegate = self
                navigationController?.pushViewController(vc, animated: true)
            }
            else if indexPath.row == 1 {
                let vc = CardFoodPriceRangeVC()
                vc.delegate = self
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        fComment = textView.text
    }
    
    func didSelectLocation(location: LocationAnnotation) {
        fLocationName = location.locationName
        fLocation = location.coordinate
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .None)
    }
    
    func textChange(sender:UITextField) {
        fTitle = sender.text
    }
    
    func didSelectPrice(price: String) {
        fPrice = price
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: .None)
    }
    
    
    func didTapCoverAtCell(cell: CardFoodEditTableViewCell) {
        self.presentViewController(controller, animated: true, completion: nil)
        
    }

    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text
        let updatedText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: text)
        if updatedText.isEmpty {
            textView.text = "美食评论(可选，100字以内)..."
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
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRectZero)
        return v
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        tableView.endEditing(true)
    }


    
  
}


extension CardFoodEditVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let cropper = RSKImageCropViewController(image: image, cropMode:.Custom)
        cropper.delegate = self
        cropper.dataSource = self
        presentViewController(cropper, animated: true, completion: nil)
        
    }
}

extension CardFoodEditVC:RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource{
    func imageCropViewController(controller: RSKImageCropViewController!, didCropImage croppedImage: UIImage!, usingCropRect cropRect: CGRect) {
        dismissViewControllerAnimated(true, completion: nil)
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! CardFoodEditTableViewCell
        cell.coverImageView.image = croppedImage
        self.fCoverImg = croppedImage
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageCropViewControllerCustomMaskRect(controller: RSKImageCropViewController!) -> CGRect {
        
        return CGRectMake(view.center.x - view.bounds.size.width/2, view.center.y-view.bounds.size.width/2, view.bounds.size.width, view.bounds.size.width)
    }
    
    func imageCropViewControllerCustomMaskPath(controller: RSKImageCropViewController!) -> UIBezierPath! {

        return UIBezierPath(rect: CGRectMake(view.center.x - view.bounds.size.width/2, view.center.y-view.bounds.size.width/2, view.bounds.size.width, view.bounds.size.width))
    }
}

protocol CardFoodPriceRangeVCDelegate:class {
    func didSelectPrice(price:String)
}

class CardFoodPriceRangeVC:UITableViewController {
    private let prices = ["免费", "1-10", "10-50", "50-100", "100-200", "200-500", "500-1000", "1000+"]
    weak var delegate:CardFoodPriceRangeVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "价格范围"
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        tableView.tableFooterView = UIView()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prices.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
        cell.textLabel?.text = prices[indexPath.row]
        cell.textLabel?.textColor = TEXT_COLOR
        cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        navigationController?.popViewControllerAnimated(true)
        delegate?.didSelectPrice(prices[indexPath.row])
    }
}



class CardFoodMoreTebleViewCell:UITableViewCell {
    private var icon:UIImageView!
    private var infoLabel:UILabel!

    
    func initialize() {
        icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = THEME_COLOR_BACK
        contentView.addSubview(icon)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        contentView.addSubview(infoLabel)

        
        icon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.centerY.equalTo(contentView.snp_centerY)
            make.height.width.equalTo(20)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(icon.snp_right).offset(10)
            make.centerY.equalTo(contentView.snp_centerY)
            make.right.equalTo(contentView.snp_rightMargin)
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

protocol CardFoodEditTableViewCellDelegate:class {
    func didTapCoverAtCell(cell:CardFoodEditTableViewCell)
}
class CardFoodEditTableViewCell:UITableViewCell {
    private var titleTextView:UITextField!
    
    private var coverImageView:UIImageView!
    
    private var bodyTextView:UITextView!
    
    weak var delegate:CardFoodEditTableViewCellDelegate?
    
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
        bodyTextView.text = "美食评论(可选，100字以内)..."
        bodyTextView.textColor = UIColor.colorFromRGB(0xC7C7CD)
        bodyTextView.tintColor = THEME_COLOR
        bodyTextView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        bodyTextView.selectedTextRange = bodyTextView.textRangeFromPosition(bodyTextView.beginningOfDocument, toPosition: bodyTextView.beginningOfDocument)
     
      
        
        coverImageView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(contentView.snp_centerX)
            make.top.equalTo(contentView.snp_top)
            make.width.equalTo(coverImageView.snp_height)
            make.height.equalTo(contentView.snp_width).multipliedBy(0.5)
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
        
        
        
        bodyTextView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(seperator.snp_bottom).offset(5)
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
