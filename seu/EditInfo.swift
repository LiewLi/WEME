//
//  EditSchoolInfo.swift
//  WEME
//
//  Created by liewli on 1/6/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit
import RSKImageCropper

let EDIT_INFO_NOTIFICATION = "EDIT_INFO_NOTIFICATION"

class EditInfoVC:UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CityVCDelegate, UniversityVCDelegate {
    
    let sections = ["头像", "姓名", "性别(设定后不能修改)", "生日","手机号", "学校", "学历","专业","微信", "QQ", "家乡", ]
    let placeholder = ["必填...", "必填...", "必填...", "必填...", "必填(不公开)...","必填(公开)...", "必填(公开)...", "可选(公开)...","可选(公开)...", "可选(公开)...", "可选(公开)..."]
    
    var avatar:UIImage?
    
    var isRegistering = false
    
    var datePicker:UIDatePicker!
    var birthdayPickerToolbar:UIToolbar!
    var degreePicker:UIPickerView!
    var degreeToolbar:UIToolbar!
    
    let degreeData = ["本科", "硕士", "博士"]
    
    var personInfo:PersonModel?
    
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
        title = "个人信息"
        view.backgroundColor = BACK_COLOR
        tableView.separatorStyle = .None
        tableView.tableFooterView = UIView()
        tableView.registerClass(EditInfoTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(EditInfoTableViewCell))
        tableView.registerClass(EditInfoAvatarTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(EditInfoAvatarTableViewCell))
        tableView.registerClass(EditInfoGenderTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(EditInfoGenderTableViewCell))
        tableView.registerClass(EditInfoSelectionTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(EditInfoSelectionTableViewCell))
        let done = UIBarButtonItem(title: "完成", style: .Plain, target: self, action: "done:")
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        navigationItem.rightBarButtonItem = done
        setupUI()
        fetchProfileInfo()
    }
    
    func fetchProfileInfo() {
        if let t = token {
            request(.POST, GET_PROFILE_INFO_URL, parameters: ["token":t], encoding: .JSON).responseJSON{ [weak self](response) -> Void in
                if let d = response.result.value,S = self {
                    let json = JSON(d)
                    guard json["state"] == "successful" else{
                        return
                    }
                    do {
                        S.personInfo = try MTLJSONAdapter.modelOfClass(PersonModel.self, fromJSONDictionary: json.dictionaryObject) as? PersonModel
                        S.tableView.reloadData()
                    }
                    catch {
                        print(error)
                    }
                    
                }
                else if let S = self {
                    ProfileCache.sharedCache.loadProfileWithCompletionBlock({ [weak S](info) -> Void in
                        if let SS = S, p = info {
                            SS.personInfo = p
                            SS.tableView.reloadData()
                        }
                    })
                }
            }
            
        }

    }
    
    func done(sender:AnyObject) {
        guard personInfo?.name?.characters.count > 0 && personInfo?.gender?.characters.count > 0 && personInfo?.birthday?.characters.count > 0 && personInfo?.phone?.characters.count > 0 && personInfo?.school?.characters.count > 0 && personInfo?.degree?.characters.count > 0 else {
            messageAlert("必填信息不能为空")
            return
        }
        
        if let t = token, p = personInfo{
            do {
                var dict = try MTLJSONAdapter.JSONDictionaryFromModel(p, error: ()) as! [String:AnyObject]
                dict["token"] = t
                request(.POST, EDIT_PROFILE_INFO_URL, parameters: dict, encoding: .JSON).responseJSON(completionHandler: { [weak self] (response) -> Void in
                    if let d = response.result.value, S = self {
                        let json = JSON(d)
                        guard json["state"].stringValue == "successful" else {
                            S.messageAlert("提交信息失败")
                            return
                        }
                        let hud = MBProgressHUD.showHUDAddedTo(S.tableView, animated: true)
                        hud.labelText = "提交信息成功"
                        hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                        hud.mode = .CustomView
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
                        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
                            hud.hide(true)
                            if S.isRegistering {
                                S.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.window?.rootViewController = HomeVC()
                            }
                            else {
                                NSNotificationCenter.defaultCenter().postNotificationName(EDIT_INFO_NOTIFICATION, object: nil)
                                S.navigationController?.popViewControllerAnimated(true)
                            }
                        }
                        

                    }
                })
            }
            catch {
                print(error)
            }
        }
    }

    //MARK: birthday
    
    func birthPickerDone(sender:AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        personInfo?.birthday = dateFormatter.stringFromDate(datePicker.date)
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .None)
        tableView.endEditing(true)
    }
    
    func birthPickerCancel(sender:AnyObject) {
        tableView.endEditing(true)
    }
    
    
    //MARK: degree
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return degreeData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String {
        return degreeData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
          personInfo?.degree = degreeData[row]
    }
    
    func degreePickerDone(sender:AnyObject) {
          personInfo?.degree = degreeData[degreePicker.selectedRowInComponent(0)]
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 6, inSection: 0)], withRowAnimation: .None)
        tableView.endEditing(true)
    }
    
    func degreePickerCancel(sender:AnyObject) {
        tableView.endEditing(true)
    }

    //MARK: gender
    
    func genderChange(sender:UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
              personInfo?.gender = "男"
        }
        else {
              personInfo?.gender = "女"
        }
    }
    
    func setupUI() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.backgroundColor = BACK_COLOR
        let defaultDate = NSDateComponents()
        defaultDate.year = 1992
        defaultDate.month = 12
        defaultDate.day = 18
        datePicker.date = (NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian))!.dateFromComponents(defaultDate)!
        
        
        birthdayPickerToolbar = UIToolbar(frame: CGRectMake(0, 0, view.frame.size.width, 44))
        
        let doneButton1 = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action: "birthPickerDone:")
        let flexibleLeft1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: "")
        let birthPickerTitleLabel = UILabel(frame: CGRectMake(0, 0, 100, 44))
        birthPickerTitleLabel.text = "选择生日"
        birthPickerTitleLabel.textAlignment = NSTextAlignment.Center
        let titleButton1 = UIBarButtonItem(customView: birthPickerTitleLabel)
        let flexibleRight1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: "")
        let cancelButton1 = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "birthPickerCancel:")
        birthdayPickerToolbar.tintColor = THEME_COLOR
        birthdayPickerToolbar.setItems([cancelButton1, flexibleLeft1, titleButton1, flexibleRight1, doneButton1], animated: false)
        
        degreePicker = UIPickerView()
        degreePicker.delegate = self
        degreePicker.dataSource = self
        degreePicker.backgroundColor = BACK_COLOR
        
        degreeToolbar = UIToolbar(frame: CGRectMake(0, 0, view.frame.size.width, 44))
        
        let doneButton = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Plain, target: self, action: "degreePickerDone:")
        let flexibleLeft = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: "")
        let degreePickerTitleLabel = UILabel(frame: CGRectMake(0, 0, 100, 44))
        degreePickerTitleLabel.text = "选择学历"
        degreePickerTitleLabel.textAlignment = NSTextAlignment.Center
        let titleButton = UIBarButtonItem(customView: degreePickerTitleLabel)
        let flexibleRight = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: "")
        let cancelButton = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "degreePickerCancel:")
        degreeToolbar.tintColor = THEME_COLOR
        
        degreeToolbar.setItems([cancelButton, flexibleLeft, titleButton, flexibleRight, doneButton], animated: false)


    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let cropper = RSKImageCropViewController(image: image, cropMode:.Custom)
        cropper.delegate = self
        cropper.dataSource = self
        presentViewController(cropper, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let imagePicker = UIImagePickerController()
            imagePicker.navigationBar.barStyle = .Black
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            presentViewController(imagePicker, animated: true, completion: nil)

        }
        else if indexPath.row == 10 {
            let vc = CityVC()
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
        else if indexPath.row == 5 {
            let vc = UniversityVC()
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didSelectCity(city: String) {
        personInfo?.hometown = city
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 10, inSection: 0)], withRowAnimation: .None)
    }
    
    func didSelectUniversity(university: String) {
        personInfo?.school = university
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 5, inSection: 0)], withRowAnimation: .None)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(EditInfoAvatarTableViewCell), forIndexPath: indexPath) as! EditInfoAvatarTableViewCell
            cell.titleInfoLabel.text = sections[indexPath.row]
            if avatar == nil {
                cell.avatar.sd_setImageWithURL(thumbnailAvatarURL(), placeholderImage: UIImage(named: "avatar"))
            }
            else {
                cell.avatar.image = avatar
            }
            
            cell.selectionStyle = .None
            return cell
        }
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(EditInfoGenderTableViewCell), forIndexPath: indexPath) as! EditInfoGenderTableViewCell
            cell.titleInfoLabel.text = sections[indexPath.row]
            cell.selectionStyle = .None
            cell.segment.addTarget(self, action: "genderChange:", forControlEvents: .ValueChanged)
            if let g = personInfo?.gender {
                cell.segment.selectedSegmentIndex = (g == "男") ? 0 : 1
                personInfo?.gender = (g == "男") ? "男" : "女"

            }
            else {
                cell.segment.selectedSegmentIndex = 0
                personInfo?.gender = "男"
            }
            return cell
        }
            
        else if indexPath.row == 10 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(EditInfoSelectionTableViewCell), forIndexPath: indexPath) as! EditInfoSelectionTableViewCell
            cell.titleInfoLabel.text = sections[indexPath.row]
            if let h = personInfo?.hometown where h.characters.count > 0 {
                 cell.detailContentLabel.textColor = TEXT_COLOR
                 cell.detailContentLabel.text = h
            }
            else {
                cell.detailContentLabel.textColor = UIColor.colorFromRGB(0xC7C7CD)
                cell.detailContentLabel.text = placeholder[indexPath.row]
            }
            cell.selectionStyle = .None
            return cell
        }
        else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(EditInfoSelectionTableViewCell), forIndexPath: indexPath) as! EditInfoSelectionTableViewCell
            cell.titleInfoLabel.text = sections[indexPath.row]
            if let s = personInfo?.school where s.characters.count > 0 {
                cell.detailContentLabel.textColor = TEXT_COLOR
                cell.detailContentLabel.text = s
            }
            else {
                cell.detailContentLabel.textColor = UIColor.colorFromRGB(0xC7C7CD)
                cell.detailContentLabel.text = placeholder[indexPath.row]
            }
            cell.selectionStyle = .None
            return cell

        }
            
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(EditInfoTableViewCell), forIndexPath: indexPath) as! EditInfoTableViewCell
            cell.titleInfoLabel.text = sections[indexPath.row]
            cell.textContentField.placeholder = placeholder[indexPath.row]
            cell.textContentField.tag = indexPath.row
            cell.textContentField.addTarget(self, action: "textChange:", forControlEvents: .EditingChanged)
            cell.selectionStyle = .None
            if indexPath.row == 1 {
                cell.textContentField.text = personInfo?.name
            }
            else if indexPath.row == 3 {
                cell.textContentField.inputView = datePicker
                cell.textContentField.inputAccessoryView = birthdayPickerToolbar
                cell.textContentField.text = personInfo?.birthday
            }
                
            else if indexPath.row == 4 {
                cell.textContentField.keyboardType = UIKeyboardType.NumberPad
                cell.textContentField.text = personInfo?.phone
            }
            else if indexPath.row == 6 {
                cell.textContentField.inputView = degreePicker
                cell.textContentField.inputAccessoryView = degreeToolbar
                cell.textContentField.text = personInfo?.degree
            }
            else if indexPath.row == 7 {
                cell.textContentField.text = personInfo?.department
            }
            else if indexPath.row == 8 {
                cell.textContentField.text = personInfo?.wechat
            }
            else if indexPath.row == 9 {
                cell.textContentField.text = personInfo?.qq
            }
            return cell
        }
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        tableView.endEditing(true)
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        }
        else {
            return 60
        }
    }
    
    func textChange(sender:UITextField) {
        switch sender.tag {
        case 1:
            personInfo?.name = sender.text
            break
        case 2:
            personInfo?.gender = sender.text
        case 3:
            personInfo?.birthday = sender.text
        case 4:
            personInfo?.phone = sender.text
        case 6:
            personInfo?.degree = sender.text
        case 7:
            personInfo?.department = sender.text
        case 8:
            personInfo?.wechat = sender.text
        case 9:
            personInfo?.qq = sender.text
        default:
            break
        }
    }
    
}

extension EditInfoVC:RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource{
    func imageCropViewController(controller: RSKImageCropViewController!, didCropImage croppedImage: UIImage!, usingCropRect cropRect: CGRect) {
        dismissViewControllerAnimated(true, completion: nil)
        avatar = croppedImage
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
        if let t = token, img = avatar, id = myId{
            
            upload(.POST, UPLOAD_AVATAR_URL, multipartFormData: { multipartFormData in
                
                let dd = "{\"token\":\"\(t)\", \"type\":\"0\", \"number\":\"0\"}"
                let jsonData = dd.dataUsingEncoding(NSUTF8StringEncoding)
                let data = UIImageJPEGRepresentation(img, 0.5)
                multipartFormData.appendBodyPart(data:jsonData!, name:"json")
                multipartFormData.appendBodyPart(data:data!, name:"avatar", fileName:"avatar.jpg", mimeType:"image/jpeg")
                
                }, encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _ , _):
                        upload.responseJSON { response in
                            if let d = response.result.value {
                                let j = JSON(d)
                                if j["state"].stringValue  == "successful" {
                                    SDImageCache.sharedImageCache().storeImage(img, forKey:avatarURLForID(id).absoluteString, toDisk:true)
                                    SDImageCache.sharedImageCache().removeImageForKey(thumbnailAvatarURLForID(id).absoluteString, fromDisk:true)
                                }
                                else {
                                    self.messageAlert("上载头像失败")
                                }
                            }
                            else if let _ = response.result.error {
                                 self.messageAlert("上载头像失败")

                            }
                        }
                        
                    case .Failure:
                        break
                        
                    }
                }
                
            )
        }
    }
    
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageCropViewControllerCustomMaskRect(controller: RSKImageCropViewController!) -> CGRect {
        let w = min(SCREEN_HEIGHT, SCREEN_WIDTH)
        return CGRectMake(view.center.x - w/2, view.center.y - w/2, w, w)
    }
    
    func imageCropViewControllerCustomMaskPath(controller: RSKImageCropViewController!) -> UIBezierPath! {
        let w = min(SCREEN_HEIGHT, SCREEN_WIDTH)
        return UIBezierPath(rect: CGRectMake(view.center.x - w/2, view.center.y - w/2, w, w))
        
    }
}

protocol UniversityVCDelegate:class {
    func didSelectUniversity(university:String)
}

protocol UniversitySearchVCDelegate:class {
    func didScroll(vc:UniversitySearchVC)
    func didSelect(university:String, vc:UniversitySearchVC)
}

class UniversitySearchVC:UITableViewController {
    
    private var universities = [UniversityModel]()
    weak var delegate:UniversitySearchVCDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        self.edgesForExtendedLayout = .None
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return universities.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return universities[section].universities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
        cell.textLabel?.text = (universities[indexPath.section].universities[indexPath.row ] as! SchoolModel).name
        cell.textLabel?.textColor = TEXT_COLOR
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return universities[section].province
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.didScroll(self)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let uni = (universities[indexPath.section].universities[indexPath.row ] as! SchoolModel).name
        delegate?.didSelect(uni, vc: self)
    }
    
}

class UniversityVC:UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UniversitySearchVCDelegate {
    private var universities = [UniversityModel]()
    
    weak var delegate:UniversityVCDelegate?
    
    var searchController:UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "选择大学"
        view.backgroundColor = BACK_COLOR
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        
        let vc = UniversitySearchVC()
        vc.delegate = self
        searchController = UISearchController(searchResultsController: vc)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "搜索大学名称或所在省份"
        searchController.searchBar.barTintColor = BACK_COLOR
        searchController.searchBar.tintColor =  THEME_COLOR
        navigationController?.extendedLayoutIncludesOpaqueBars = true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let path = NSBundle.mainBundle().pathForResource("university", ofType: "json")!
            let data = NSData(contentsOfFile: path)!
            do {
                
                let arr = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                self.universities = try MTLJSONAdapter.modelsOfClass(UniversityModel.self, fromJSONArray: arr as! [AnyObject]) as! [UniversityModel]
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
            catch {
                print(error)
            }

        }
    }
    
    func didScroll(vc: UniversitySearchVC) {
        if let text = searchController?.searchBar.text where text.characters.count > 0,
            let s = searchController?.searchBar.isFirstResponder() where s == true{
                searchController?.searchBar.resignFirstResponder()
        }

    }
    
    func didSelect(university: String, vc: UniversitySearchVC) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        setNeedsStatusBarAppearanceUpdate()
        searchController.active = false
        navigationController?.popViewControllerAnimated(true)
        delegate?.didSelectUniversity(university)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return universities.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return universities[section].universities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
        cell.textLabel?.text = (universities[indexPath.section].universities[indexPath.row ] as! SchoolModel).name
        cell.textLabel?.textColor = TEXT_COLOR
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return universities[section].province
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let u = (universities[indexPath.section].universities[indexPath.row ] as! SchoolModel).name
        navigationController?.popViewControllerAnimated(true)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        setNeedsStatusBarAppearanceUpdate()
        delegate?.didSelectUniversity(u)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
       let vc =  searchController.searchResultsController as! UniversitySearchVC
        if let text = searchController.searchBar.text where text.characters.count > 0 {
            var uu = [UniversityModel]()
            let predict = NSPredicate(format: "name contains[c] %@", text)
            let provincePredict = NSPredicate(format: "SELF contains[c] %@", text)
            for u in universities {
                if provincePredict.evaluateWithObject(u.province) {
                    uu.append(u)
                    continue
                }
                let filtered_u = u.universities.filter{predict.evaluateWithObject($0)}
                if filtered_u.count > 0 {
                    let uni = UniversityModel()
                    uni.province = u.province
                    uni.universities = filtered_u
                    uu.append(uni)
                }
            }
            vc.universities = uu
            vc.tableView.reloadData()
        }
      
    }
    
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        setNeedsStatusBarAppearanceUpdate()
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        setNeedsStatusBarAppearanceUpdate()
    }
    


}

protocol CityVCDelegate:class {
    func didSelectCity(city:String)
}

protocol CitySearchVCDelegate:class {
    func didScroll(vc:CitySearchVC)
    func didSelect(city:String, vc:CitySearchVC)
}

class CitySearchVC:UITableViewController {
    private var cities = [CityModel]()
    weak var delegate:CitySearchVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        self.edgesForExtendedLayout = .None

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cities.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities[section].cities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
        cell.textLabel?.text = cities[indexPath.section].cities[indexPath.row] as! String
        cell.textLabel?.textColor = TEXT_COLOR
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cities[section].state
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.didScroll(self)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let city = cities[indexPath.section].cities[indexPath.row] as! String
        delegate?.didSelect(city, vc: self)
    }
    
    
}

class CityVC:UITableViewController, CitySearchVCDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    private var cities = [CityModel]()
    
    weak var delegate:CityVCDelegate?
    var searchController:UISearchController!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "选择城市"
        view.backgroundColor = BACK_COLOR
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        
        let vc = CitySearchVC()
        vc.delegate = self
        
        searchController = UISearchController(searchResultsController: vc)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "搜索城市或所在省份"
        searchController.searchBar.barTintColor = BACK_COLOR
        searchController.searchBar.tintColor =  THEME_COLOR
        navigationController?.extendedLayoutIncludesOpaqueBars = true
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let path = NSBundle.mainBundle().pathForResource("city", ofType: "plist")
            let arr = NSArray(contentsOfFile: path!)!
            do {
                self.cities = try MTLJSONAdapter.modelsOfClass(CityModel.self, fromJSONArray: arr as [AnyObject]) as! [CityModel]
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
            catch {
                print(error)
            }

        }

    }
    
    func didScroll(vc: CitySearchVC) {
        if let text = searchController?.searchBar.text where text.characters.count > 0,
            let s = searchController?.searchBar.isFirstResponder() where s == true{
                searchController?.searchBar.resignFirstResponder()
        }
    }
    
    func didSelect(city: String, vc: CitySearchVC) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        setNeedsStatusBarAppearanceUpdate()
        searchController.active = false
        navigationController?.popViewControllerAnimated(true)
        delegate?.didSelectCity(city)
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cities.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities[section].cities.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
        cell.textLabel?.text = cities[indexPath.section].cities[indexPath.row] as! String
        cell.textLabel?.textColor = TEXT_COLOR
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cities[section].state
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let city = cities[indexPath.section].cities[indexPath.row] as! String
        navigationController?.popViewControllerAnimated(true)
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        setNeedsStatusBarAppearanceUpdate()
        delegate?.didSelectCity(city)
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        setNeedsStatusBarAppearanceUpdate()
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        setNeedsStatusBarAppearanceUpdate()
    }
    

    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let vc =  searchController.searchResultsController as! CitySearchVC
        if let text = searchController.searchBar.text where text.characters.count > 0 {
            var cc = [CityModel]()
            let predict = NSPredicate(format: "SELF contains[c] %@", text)
            for c in cities {
                if predict.evaluateWithObject(c.state) {
                    cc.append(c)
                    continue
                }
                let filtered_c = c.cities.filter{predict.evaluateWithObject($0)}
                if filtered_c.count > 0 {
                    let city = CityModel()
                    city.state = c.state
                    city.cities = filtered_c
                    cc.append(city)
                }
            }
            vc.cities = cc
            vc.tableView.reloadData()
        }
        
    }
    

    
    
    
}

class EditInfoAvatarTableViewCell:UITableViewCell {
    var titleInfoLabel:UILabel!
    var avatar:UIImageView!
    var backView:UIView!
    var detailButton:UIImageView!
    
    func initialize() {
        
        
        contentView.backgroundColor = BACK_COLOR
        titleInfoLabel = UILabel()
        titleInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInfoLabel.backgroundColor = BACK_COLOR
        titleInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        titleInfoLabel.textColor = UIColor.lightGrayColor()
        contentView.addSubview(titleInfoLabel)
        
        backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = UIColor.whiteColor()
        contentView.addSubview(backView)
        
        backView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(titleInfoLabel.snp_bottom).offset(5)
            make.bottom.equalTo(contentView.snp_bottom)
            backView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            backView.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            
        }
        
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 25
        avatar.layer.masksToBounds = true
        backView.addSubview(avatar)
       
        detailButton = UIImageView(image: UIImage(named: "forward")?.imageWithRenderingMode(.AlwaysTemplate))
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        detailButton.tintColor = THEME_COLOR_BACK
        backView.addSubview(detailButton)
        
        titleInfoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left).offset(5)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(contentView.snp_top).offset(5)
            titleInfoLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            titleInfoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        }
        
        
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(backView.snp_leftMargin)
            make.centerY.equalTo(backView.snp_centerY)
            make.width.height.equalTo(50)
        }
        
        
        detailButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(backView.snp_rightMargin)
            make.centerY.equalTo(backView.snp_centerY)
            make.height.width.equalTo(16)
            
        }

    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

}



class EditInfoGenderTableViewCell:UITableViewCell {
    var titleInfoLabel:UILabel!
    var segment:UISegmentedControl!
    var backView:UIView!
    
    func initialize() {
        
        
        contentView.backgroundColor = BACK_COLOR
        titleInfoLabel = UILabel()
        titleInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInfoLabel.backgroundColor = BACK_COLOR
        titleInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        titleInfoLabel.textColor = UIColor.lightGrayColor()
        contentView.addSubview(titleInfoLabel)
        
        backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = UIColor.whiteColor()
        contentView.addSubview(backView)
        
        backView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(titleInfoLabel.snp_bottom).offset(5)
            make.bottom.equalTo(contentView.snp_bottom)
            backView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            backView.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            
        }
        
        segment = UISegmentedControl(items: ["男", "女"])
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.tintColor = THEME_COLOR
        backView.addSubview(segment)
     
        
        titleInfoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left).offset(5)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(contentView.snp_top).offset(5)
            titleInfoLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            titleInfoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        }
        
        segment.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.centerY.equalTo(backView.snp_centerY)
            segment.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            segment.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

}
class EditInfoTableViewCell:UITableViewCell {
    var titleInfoLabel:UILabel!
    var textContentField:UITextField!
    var backView:UIView!
    
    func initialize() {
        
        
        contentView.backgroundColor = BACK_COLOR
        titleInfoLabel = UILabel()
        titleInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInfoLabel.backgroundColor = BACK_COLOR
        titleInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        titleInfoLabel.textColor = UIColor.lightGrayColor()
        contentView.addSubview(titleInfoLabel)
        
        backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = UIColor.whiteColor()
        contentView.addSubview(backView)
        
        backView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(titleInfoLabel.snp_bottom).offset(5)
            make.bottom.equalTo(contentView.snp_bottom)
            backView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            backView.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            
        }
        
        
        //contentView.backgroundColor = UIColor.whiteColor()
        textContentField = UITextField()
        textContentField.translatesAutoresizingMaskIntoConstraints = false
        textContentField.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        textContentField.textColor = UIColor(red: 81/255.0, green: 87/255.0, blue: 113/255.0, alpha: 1.0)
        textContentField.backgroundColor = UIColor.whiteColor()
        textContentField.tintColor = THEME_COLOR
        backView.addSubview(textContentField)
        
        titleInfoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left).offset(5)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(contentView.snp_top).offset(5)
            titleInfoLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            titleInfoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        }
        
        textContentField.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(backView.snp_top)
            make.bottom.equalTo(contentView.snp_bottom)
            textContentField.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            textContentField.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
}

class EditInfoSelectionTableViewCell:UITableViewCell {
    var titleInfoLabel:UILabel!
    var detailContentLabel:UILabel!
    var backView:UIView!
    var detailButton:UIImageView!
    
    func initialize() {
        
        
        contentView.backgroundColor = BACK_COLOR
        titleInfoLabel = UILabel()
        titleInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        titleInfoLabel.backgroundColor = BACK_COLOR
        titleInfoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        titleInfoLabel.textColor = UIColor.lightGrayColor()
        contentView.addSubview(titleInfoLabel)
        
        backView = UIView()
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.backgroundColor = UIColor.whiteColor()
        contentView.addSubview(backView)
        
        backView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(titleInfoLabel.snp_bottom).offset(5)
            make.bottom.equalTo(contentView.snp_bottom)
            backView.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            backView.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            
        }
        
        
        
        detailContentLabel = UILabel()
        detailContentLabel?.translatesAutoresizingMaskIntoConstraints = false
        detailContentLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        detailContentLabel?.backgroundColor = UIColor.whiteColor()
        detailContentLabel?.tintColor = THEME_COLOR
        backView.addSubview(detailContentLabel)
        
        detailButton = UIImageView(image: UIImage(named: "forward")?.imageWithRenderingMode(.AlwaysTemplate))
        detailButton.translatesAutoresizingMaskIntoConstraints = false
        detailButton.tintColor = THEME_COLOR_BACK
        backView.addSubview(detailButton)
        

        
        titleInfoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_left).offset(5)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(contentView.snp_top).offset(5)
            titleInfoLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            titleInfoLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
        }
        
        detailContentLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(backView.snp_top)
            make.bottom.equalTo(contentView.snp_bottom)
            detailContentLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Vertical)
            detailContentLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        }
        
        
        detailButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(backView.snp_rightMargin)
            make.centerY.equalTo(backView.snp_centerY)
            make.height.width.equalTo(16)
            
        }

    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
}

