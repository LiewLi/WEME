//
//  Album.swift
//  WEME
//
//  Created by liewli on 7/23/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

class AlbumVC:UITableViewController, QZTabBarControllerChildControllerProtocol {
    
    private var personalImages = [PersonalImageModel]()
    private var imageCurrentPage = 1
    
    var imgIDSet = Set<String>()

    var id:String!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(ThreeImageTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ThreeImageTableViewCell))
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .None
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.uploadPersonalImageNotify(_:)), name: UploadPersonalImageVC.UPLOAD_PERSONAL_IMAGE_NOTIFICATION, object: nil)

        self.fetchPersonalImages()
    }
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (SCREEN_WIDTH-10) / 3 + 5
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (personalImages.count + 2) / 3
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == ((personalImages.count + 2)/3) - 1 {
            fetchPersonalImages()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ThreeImageTableViewCell), forIndexPath: indexPath) as! ThreeImageTableViewCell
        let startIdx = 3 * indexPath.row
        cell.leftImageView.sd_setImageWithURL(personalImages[startIdx].thumbnailURL)
        if startIdx + 1 < personalImages.count {
            cell.midImageView.sd_setImageWithURL(personalImages[startIdx + 1].thumbnailURL)
        }
        if startIdx + 2 < personalImages.count {
            cell.rightImageView.sd_setImageWithURL(personalImages[startIdx + 2].thumbnailURL)
        }
        cell.selectionStyle = .None
        cell.delegate = self
        return cell

    }

    
    
    private lazy var queue:dispatch_queue_t = {
        let q = dispatch_queue_create("weme.info.image", DISPATCH_QUEUE_SERIAL)
        return q
    }()

    
    private func preProcess(c:[PersonalImageModel]) {
        dispatch_async(queue) { () -> Void in
            if c.count > 0 {
                var imgs = [PersonalImageModel]()
                for cc in c {
                    if self.imgIDSet.contains(cc.imgID) {
                        continue
                    }
                    else {
                        imgs.append(cc)
                        self.imgIDSet.insert(cc.imgID)
                    }
                }
                if imgs.count  > 0 {
                    self.personalImages.appendContentsOf(imgs)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                    
                }
                
                
            }
        }
    }

    func uploadPersonalImageNotify(sender:NSNotification) {
        personalImages.removeAll()
        imgIDSet.removeAll()
        fetchPersonalImages()
    }

    
    private func fetchPersonalImages() {
        var img_id = "0"
        if personalImages.count > 0 {
            img_id = personalImages[personalImages.count - 1].imgID
        }
        if let t = token {
            request(.POST, GET_PERSONAL_IMAGES_URL, parameters: ["token":t, "userid":id,"previous_id":"\(img_id)"], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        return
                    }
                    
                    do {
                        if let imgs = try MTLJSONAdapter.modelsOfClass(PersonalImageModel.self, fromJSONArray: json["result"].arrayObject) as? [PersonalImageModel] where imgs.count > 0 {
                            S.preProcess(imgs)
                        }
                    }
                    catch let e as NSError{
                        print(e)
                    }
                    
                }
                })
        }
    }
    
    func targetScrollView() -> UIScrollView {
        return self.tableView
    }


}

extension AlbumVC:ThreeImageTableViewCellDelegate {
    func didTapImageAtThreeImageTableViewCell(cell: ThreeImageTableViewCell, atIndex idx: Int) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let browser = MWPhotoBrowser(delegate: self)
            browser.setCurrentPhotoIndex(UInt(indexPath.row * 3 + idx))
            browser.displayActionButton = true
            navigationController?.pushViewController(browser, animated: true)
            
        }

    }
}

extension AlbumVC:MWPhotoBrowserDelegate {
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(personalImages.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        let data = personalImages[Int(index)]
        let photo = MWPhoto(URL: data.imgURL)
        var time = ""
        let dateFormat = NSDateFormatter(withUSLocaleAndFormat: "EE, d LLLL yyyy HH:mm:ss zzzz")
        if let date = dateFormat.dateFromString(data.timestamp) {
            time = date.hunmanReadableString()
        }
        let caption = "\(data.username) 上传于\n\(time)"
        let attributedText = NSMutableAttributedString(string: caption)
        attributedText.addAttributes([NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1), NSForegroundColorAttributeName:UIColor.lightGrayColor()], range: NSMakeRange(0, data.username.characters.count + 4))
        attributedText.addAttributes([NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote), NSForegroundColorAttributeName:UIColor.whiteColor()], range: NSMakeRange(data.username.characters.count+5, time.characters.count))
        photo.caption = attributedText
        
        return photo
    }
    
}


