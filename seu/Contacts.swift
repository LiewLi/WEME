//
//  Contacts.swift
//  牵手东大
//
//  Created by liewli on 10/22/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import Foundation
import UIKit


protocol ConversationTableCellDelegate {
    func didTapAvatarAtCell(cell:ConversationTableCell)
}

class ConversationTableCell:UITableViewCell {
    var avatar :UIImageView!
    var nameLabel:UILabel!
    var infoLabel:UILabel!
    var gender:UIImageView!
    var delegate:ConversationTableCellDelegate?
    
    func tap(sender:AnyObject?) {
        delegate?.didTapAvatarAtCell(self)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        avatar = UIImageView()
        //avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 25
        avatar.layer.masksToBounds = true
        avatar.userInteractionEnabled = true
        avatar.bounds.size = CGSizeMake(50, 50)
        let tap = UITapGestureRecognizer(target: self, action: "tap:")
        avatar.addGestureRecognizer(tap)
        addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        nameLabel.textColor = TEXT_COLOR
        addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        infoLabel.textColor = UIColor.lightGrayColor()
        addSubview(infoLabel)
        
        gender = UIImageView()
        gender.translatesAutoresizingMaskIntoConstraints = false
        addSubview(gender)
        
        
        let viewDict = ["avatar" : avatar, "nameLabel":nameLabel, "infoLabel":infoLabel, "gender":gender]
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[avatar(50)]", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: viewDict)
        var constraint = NSLayoutConstraint(item: avatar, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 50)
        
        addConstraints(constraints)
        addConstraint(constraint)
        constraint = NSLayoutConstraint(item: avatar, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
        
        addConstraint(constraint)
        
        
        
        constraint = NSLayoutConstraint(item: nameLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: avatar, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 2)
        addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: nameLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: avatar, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 5)
        addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: infoLabel, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: avatar, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -2)
        addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: infoLabel, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: nameLabel, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0)
        addConstraint(constraint)

        gender.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_right).offset(5)
            make.centerY.equalTo(nameLabel.snp_centerY)
            make.height.equalTo(18)
            make.width.equalTo(16)
        }
        
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[infoLabel]-5-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: viewDict)
        addConstraints(constraints)

        layoutMargins = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        infoLabel.text = ""
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

protocol SearchResultsVCDelegate:class {
    func didScroll()
    func didSelectUserID(id:String)
}

class SearchResultsVC:UITableViewController, ConversationTableCellDelegate {
    
    weak var delegate:SearchResultsVCDelegate?
    private var friendsData = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = .None
        tableView.backgroundColor = BACK_COLOR//backColor
        tableView.tableFooterView = UIView()
        
        tableView.registerClass(ConversationTableCell.self, forCellReuseIdentifier: "ConversationTableCell")
        
        UITableViewHeaderFooterView.appearance().tintColor = BACK_COLOR//backColor

    }
    
    
    

    func didTapAvatarAtCell(cell: ConversationTableCell) {
        let indexPath = tableView.indexPathForCell(cell)
        let id = self.friendsData[indexPath!.row]["id"].stringValue
        let url = avatarURLForID(id)
        let agrume = Agrume(imageURL:url)
        agrume.showFrom(self)
        
    }

//    override func scrollViewDidScroll(scrollView: UIScrollView) {
//        delegate?.didScroll()
//    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.didScroll()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 60
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = friendsData[indexPath.row]
        let id = data["id"].stringValue
        delegate?.didSelectUserID(id)
    }
    

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ConversationTableCell", forIndexPath: indexPath) as! ConversationTableCell
        let data = friendsData[indexPath.row]
        let id = data["id"].stringValue
        let url = thumbnailAvatarURLForID(id)
        cell.avatar.sd_setImageWithURL(url, placeholderImage: UIImage(named: "avatar"))
        cell.nameLabel.text = data["name"].string ?? " "
        cell.infoLabel.text = data["school"].string ?? " "
        
        if data["gender"].stringValue == "男" {
            cell.gender.image  = UIImage(named: "male")
        }
        else if data["gender"].stringValue == "女" {
            cell.gender.image = UIImage(named: "female")
        }
        cell.selectedBackgroundView = UIView()
        cell.delegate = self
        cell.selectionStyle = .None
        return cell

    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let follow = UITableViewRowAction(style: .Normal, title: "关注") { (action, indexPath) -> Void in
            //print("unfollow")
            if let t = token{
                request(.POST, FOLLOW_URL, parameters: ["token":t, "id":self.friendsData[indexPath.row]["id"].stringValue], encoding: .JSON).responseJSON{ [weak self](response) -> Void in
                    //debugprint(response)
                    if let d = response.result.value {
                        let json = JSON(d)
                        if json["state"] == "successful" || json["state"] == "sucessful" {
                            self?.friendsData.removeAtIndex(indexPath.row)
                            self?.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                            
                        }
                        else {
                            let alert = UIAlertController(title: "提示", message: json["reason"].stringValue, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                            self?.presentViewController(alert, animated: true, completion: nil)
                            return
                        }
                    }
                        
                    else if let error = response.result.error {
                        let alert = UIAlertController(title: "提示", message: error.localizedFailureReason ?? error.localizedDescription, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                        self?.presentViewController(alert, animated: true, completion: nil)
                        return
                        
                    }
                    
                }
                
            }
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        let data = friendsData[indexPath.row]
        follow.backgroundColor = data["gender"].stringValue == "男" ? MALE_COLOR : (data["gender"].stringValue == "女" ? FEMALE_COLOR : THEME_COLOR)
        
        let message = UITableViewRowAction(style: .Normal, title: "私信") { (action, indexPath) -> Void in
            let data = self.friendsData[indexPath.row]
            let id = data["id"].stringValue
            
            let vc = ComposeMessageVC()
            vc.recvID = id
            
            let nav = UINavigationController(rootViewController: vc)
            self.presentViewController(nav, animated: true, completion: { () -> Void in
                
            });
        }
        
        
        message.backgroundColor =  data["gender"].stringValue == "男" ? MALE_COLOR : (data["gender"].stringValue == "女" ? FEMALE_COLOR : THEME_COLOR)
        follow.backgroundColor = THEME_COLOR
        
        return [follow, message]
    }
    
}

class ContactsVC:UITableViewController, UINavigationControllerDelegate, UISearchBarDelegate, SearchResultsVCDelegate, ConversationTableCellDelegate {
    
    
    // private var searchVC :UISearchDisplayController!
    private var friendsData = [JSON]()
    
    private var searchController:UISearchController?
    
    var refreshCont:UIRefreshControl!
    
    private var page = 1
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR//UIColor.colorFromRGB(0x104E8B)//UIColor.blackColor()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.alpha = 1.0
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
    
    func didScroll() {
        //searchController?.searchBar.resignFirstResponder()
        if let text = searchController?.searchBar.text where text.characters.count > 0,
            let s = searchController?.searchBar.isFirstResponder() where s == true{
            searchController?.searchBar.resignFirstResponder()
        }
        
    }
    
    func didTapAvatarAtCell(cell: ConversationTableCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let vc = InfoVC()
            vc.id = friendsData[indexPath.row]["id"].stringValue
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didSelectUserID(id: String) {
        let vc = InfoVC()
        vc.id = id
        searchController?.active = false
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        setNeedsStatusBarAppearanceUpdate()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "好友"
        setNeedsStatusBarAppearanceUpdate()
        tableView.tableFooterView = UIView()
        
        //let backColor = BACK_COLOR//UIColor(red: 238/255.0, green: 233/255.0, blue: 233/255.0, alpha: 1.0)
        let vc = SearchResultsVC()
        vc.delegate = self
        searchController = UISearchController(searchResultsController: vc)
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.placeholder = "输入姓名快速查找"
        searchController?.searchBar.sizeToFit()
        searchController?.searchBar.tintColor = THEME_COLOR//UIColor.redColor()
        searchController?.searchBar.barTintColor = BACK_COLOR//backColor
        searchController?.searchBar.backgroundColor = BACK_COLOR//backColor
        searchController?.definesPresentationContext = true
        //searchController?.searchBar.scopeButtonTitles = []
       // searchController?.hidesNavigationBarDuringPresentation = false
       // definesPresentationContext = false
        //searchController?.searchBar.setValue("取消", forKey: "_cancelButtonText")
        searchController?.delegate = self
        searchController?.searchBar.delegate = self
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true

        
        tableView.tableHeaderView = searchController?.searchBar
        
        
        
        tableView.backgroundColor = BACK_COLOR//backColor
        //view.backgroundColor = backColor
        //searchBar.barTintColor = backColor
        
        tableView.registerClass(ConversationTableCell.self, forCellReuseIdentifier: "ConversationTableCell")
        
        UITableViewHeaderFooterView.appearance().tintColor = BACK_COLOR//backColor
        
        refreshCont = UIRefreshControl()
        refreshCont.backgroundColor = BACK_COLOR//backColor
        refreshCont.addTarget(self, action: "pullRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        view.addSubview(refreshCont)
        loadOnePage()
        
        if #available(iOS 9, *) {
            if self.traitCollection.forceTouchCapability == .Available {
                self.registerForPreviewingWithDelegate(self, sourceView: tableView)
            }
        }
    }
    
    func recommendFriendsExit(sender: AnyObject?) {
        pullRefresh(self.refreshCont)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.hidden = true
    }
    
    
    
    func pullRefresh(sender:AnyObject) {
        friendsData = [JSON]()
        tableView.reloadData()
        page = 1
        loadOnePage()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2*Int64(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.refreshCont.endRefreshing()
        }
    }

    
    func loadOnePage() {
            if let token = NSUserDefaults.standardUserDefaults().stringForKey("TOKEN") {
                request(.POST, GET_FOLLOWERS_URL, parameters: ["token":token, "page":"\(page)", "direction":"followeds"], encoding: .JSON, headers: nil).responseJSON(completionHandler: { (response) -> Void in
                    //debugprint(response)
                    if let d = response.result.value {
                        
                        let json = JSON(d)
                        if json["state"] == "successful" || json["state"] == "sucessful" {
                         
                            if let arr = json["result"].array {
                                let cnt = self.friendsData.count
                                
                                
                                self.friendsData.appendContentsOf(arr)
                                
                                var indexArr = [NSIndexPath]()
                                for k in 0..<arr.count {
                                    let indexPath = NSIndexPath(forRow: cnt+k, inSection: 1)
                                    indexArr.append(indexPath)
                                }
                                
                                if (arr.count > 0) {
                                    self.page++
                                    self.tableView.insertRowsAtIndexPaths(indexArr, withRowAnimation: UITableViewRowAnimation.Fade)
                                    
                                    
                                }

                            }
                        }
                    }
                    
                    self.refreshCont.endRefreshing()

                })
            }
        
        
    }
    
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return indexPath.section == 1
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let unfollow = UITableViewRowAction(style: .Normal, title: "取消关注") { (action, indexPath) -> Void in
           // print("unfollow")
                if let token = NSUserDefaults.standardUserDefaults().stringForKey("TOKEN") {
                    request(.POST, UNFOLLOW_URL, parameters: ["token":token, "id":self.friendsData[indexPath.row]["id"].stringValue], encoding: .JSON).responseJSON{ [weak self](response) -> Void in
                        //debugprint(response)
                        if let d = response.result.value {
                            let json = JSON(d)
                            if json["state"].stringValue == "successful"{
                                self?.friendsData.removeAtIndex(indexPath.row)
                                self?.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                
                            }
                            else {
                                let alert = UIAlertController(title: "提示", message: json["reason"].stringValue, preferredStyle: .Alert)
                                alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                                self?.presentViewController(alert, animated: true, completion: nil)
                                return
                            }
                        }
                        
                        else if let error = response.result.error {
                            let alert = UIAlertController(title: "提示", message: error.localizedFailureReason ?? error.localizedDescription, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                            self?.presentViewController(alert, animated: true, completion: nil)
                            return

                        }
                        
                    }
                
            }
            

            
            
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        let message = UITableViewRowAction(style: .Normal, title: "私信") { (action, indexPath) -> Void in
            let data = self.friendsData[indexPath.row]
            let id = data["id"].stringValue

            let vc = ComposeMessageVC()
            vc.recvID = id
            
            let nav = UINavigationController(rootViewController: vc)
            self.presentViewController(nav, animated: true, completion: { () -> Void in
                
            });
        }
        let data = friendsData[indexPath.row]
        
        message.backgroundColor =  data["gender"].stringValue == "男" ? MALE_COLOR : (data["gender"].stringValue == "女" ? FEMALE_COLOR : THEME_COLOR)
        unfollow.backgroundColor = UIColor.redColor()
        
        return indexPath.section == 1 ? [unfollow, message] : nil
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.friendsData.count - 1 {
            loadOnePage()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "关注我的人"//indexPath.row == 0 ? "好友推荐":"关注我的人"
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = .None
            cell.textLabel?.textColor = TEXT_COLOR
            return cell
            
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ConversationTableCell", forIndexPath: indexPath) as! ConversationTableCell
                let data = friendsData[indexPath.row]
                let id = data["id"].stringValue
                let url = thumbnailAvatarURLForID(id)
                cell.avatar.sd_setImageWithURL(url, placeholderImage: UIImage(named: "avatar"))
                cell.nameLabel.text = data["name"].string ?? " "
                cell.infoLabel.text = data["school"].string ?? " "
            
            if data["gender"].stringValue == "男" {
                cell.gender.image  = UIImage(named: "male")
            }
            else if data["gender"].stringValue == "女" {
                cell.gender.image = UIImage(named: "female")
            }
            cell.selectionStyle = .None
            cell.delegate = self
            return cell
        }
        
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section <= 0 {
            return 1
        }
        else {
            return friendsData.count
        }
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRectZero)
        return v
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 20
        }
        return 0
    }
  
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section <= 0 {
            return 44
        }
        else {
            return 60
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                //navigationController?.pushViewController(CardPeopleVC(), animated: true)
                let VC = MyFolloweeVC()
                VC.title = "关注我的人"
                navigationController?.pushViewController(VC, animated: true)
            }
//            else {
//                let VC = MyFolloweeVC()
//                VC.title = "关注我的人"
//                navigationController?.pushViewController(VC, animated: true)
//            }
        }
        else {
            let vc = InfoVC()
            vc.id = friendsData[indexPath.row]["id"].stringValue
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    
    
}

@available(iOS 9.0, *)
extension ContactsVC:UIViewControllerPreviewingDelegate {
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }
    
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRowAtPoint(location) {
            previewingContext.sourceRect = tableView.rectForRowAtIndexPath(indexPath)
            let data = friendsData[indexPath.row]
            let vc = InfoVC()
            vc.id = data["id"].stringValue
            vc.infoVCDelegate = self
            return vc
        }
        
        return nil
    }
    
}

extension ContactsVC:InfoVCPreviewDelegate {
    func didTapMessage(id: String) {
        let vc = ComposeMessageVC()
        vc.recvID = id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapUnfollow(id: String) {
        if let token = token {
            request(.POST, UNFOLLOW_URL, parameters: ["token":token, "id":id], encoding: .JSON).responseJSON{ [weak self](response) -> Void in
                //debugprint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    if json["state"].stringValue == "successful"{
                        for (idx, f) in S.friendsData.enumerate() {
                            if f["id"].stringValue == id {
                               let indexPath = NSIndexPath(forRow: idx, inSection: 1)
                                S.friendsData.removeAtIndex(indexPath.row)
                                S.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                                break
                            }
                        }
                       
                        
                    }
                    else {
                        S.messageAlert("取消关注失败")
                        return
                    }
                }
            }
        }
    }
}

extension ContactsVC: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            let searchVC = searchController.searchResultsController as! SearchResultsVC
            if text.characters.count > 0 {
                if let token = NSUserDefaults.standardUserDefaults().stringForKey("TOKEN") {
                request(.POST, SEARCH_USER_URL, parameters: ["token":token, "text":text], encoding: .JSON).responseJSON{ [weak searchVC](response) -> Void in
                    //debugprint(response)
                    if let d = response.result.value {
                        let json = JSON(d)
                        if json["state"] == "successful" || json["state"] == "sucessful" {
                            let data = json["result"].array!
                            searchVC?.friendsData = data
                            searchVC?.tableView.reloadData()
                        }
                        else {
//                            let alert = UIAlertController(title: "提示", message: json["reason"].stringValue, preferredStyle: .Alert)
//                            alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
//                            self?.presentViewController(alert, animated: true, completion: nil)
//                            return
                        }
                    }
                        
                   // else if let error = response.result.error {
//                        let alert = UIAlertController(title: "提示", message: error.localizedFailureReason ?? error.localizedDescription, preferredStyle: .Alert)
//                        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
//                        self?.presentViewController(alert, animated: true, completion: nil)
//                        return
                        
                   // }
                    
                }
                
            }
            }
            
        }
    }
}

extension ContactsVC: UISearchControllerDelegate {
    func didDismissSearchController(searchController: UISearchController) {
        pullRefresh(self.refreshCont)
    }
}

class MyFolloweeVC:UIViewController, UITableViewDataSource, UITableViewDelegate, ConversationTableCellDelegate  {
    private var tableView:UITableView!
    private var friendsData = [JSON]()
    private var page = 1
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR//UIColor.colorFromRGB(0x104E8B)//UIColor.blackColor()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.alpha = 1.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = THEME_COLOR_BACK
        tableView = UITableView(frame: view.frame)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
        tableView.registerClass(ConversationTableCell.self, forCellReuseIdentifier: NSStringFromClass(ConversationTableCell))
        view.addSubview(tableView)
        tableView.tableFooterView = UIView()
        loadOnePage()
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let follow = UITableViewRowAction(style: .Normal, title: "关注") { (action, indexPath) -> Void in
            //print("unfollow")
            if let t = token{
                request(.POST, FOLLOW_URL, parameters: ["token":t, "id":self.friendsData[indexPath.row]["id"].stringValue], encoding: .JSON).responseJSON{ [weak self](response) -> Void in
                    //debugprint(response)
                    if let d = response.result.value {
                        let json = JSON(d)
                        if json["state"] == "successful" || json["state"] == "sucessful" {
                            self?.friendsData.removeAtIndex(indexPath.row)
                            self?.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                            
                        }
                        else {
                            let alert = UIAlertController(title: "提示", message: json["reason"].stringValue, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                            self?.presentViewController(alert, animated: true, completion: nil)
                            return
                        }
                    }
                        
                    else if let error = response.result.error {
                        let alert = UIAlertController(title: "提示", message: error.localizedFailureReason ?? error.localizedDescription, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
                        self?.presentViewController(alert, animated: true, completion: nil)
                        return
                        
                    }
                    
                }
                
            }
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        let data = friendsData[indexPath.row]
        follow.backgroundColor = data["gender"].stringValue == "男" ? MALE_COLOR : (data["gender"].stringValue == "女" ? FEMALE_COLOR : THEME_COLOR)
        
        let message = UITableViewRowAction(style: .Normal, title: "私信") { (action, indexPath) -> Void in
            let data = self.friendsData[indexPath.row]
            let id = data["id"].stringValue
            
            let vc = ComposeMessageVC()
            vc.recvID = id
            
            let nav = UINavigationController(rootViewController: vc)
            self.presentViewController(nav, animated: true, completion: { () -> Void in
                
            });
        }
        
        
        message.backgroundColor =  data["gender"].stringValue == "男" ? MALE_COLOR : (data["gender"].stringValue == "女" ? FEMALE_COLOR : THEME_COLOR)
        follow.backgroundColor = THEME_COLOR
        
        return [follow, message]
    }
    

    
    func loadOnePage() {
        if let t = token {
            request(.POST, GET_FOLLOWERS_URL, parameters: ["token":t, "page":"\(page)", "direction":"followers"], encoding: .JSON, headers: nil).responseJSON(completionHandler: { (response) -> Void in
                debugPrint(response)
                if let d = response.result.value {
                    
                    let json = JSON(d)
                    if json["state"].stringValue == "successful"{
                        
                        if let arr = json["result"].array {
                            let cnt = self.friendsData.count
                            
                            
                            self.friendsData.appendContentsOf(arr)
                            
                            var indexArr = [NSIndexPath]()
                            for k in 0..<arr.count {
                                let indexPath = NSIndexPath(forRow: cnt+k, inSection: 0)
                                indexArr.append(indexPath)
                            }
                            
                            if (arr.count > 0) {
                                self.page++
                                self.tableView.insertRowsAtIndexPaths(indexArr, withRowAnimation: UITableViewRowAnimation.Fade)
                                
                            }
                            
                        }
                    }
                }
                
            })
        }
        
        
    }
  
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ConversationTableCell), forIndexPath: indexPath) as! ConversationTableCell
        let data = friendsData[indexPath.row]
        let id = data["id"].stringValue
        let url = thumbnailAvatarURLForID(id)
        cell.avatar.sd_setImageWithURL(url, placeholderImage: UIImage(named: "avatar"))
        cell.nameLabel.text = data["name"].string ?? " "
        cell.infoLabel.text = data["school"].string ?? " "
        
        if data["gender"].stringValue == "男" {
            cell.gender.image  = UIImage(named: "male")
        }
        else if data["gender"].stringValue == "女" {
            cell.gender.image = UIImage(named: "female")
        }
        cell.selectionStyle = .None
        cell.delegate = self

        return cell
    }
    
    func didTapAvatarAtCell(cell: ConversationTableCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            let vc = InfoVC()
            vc.id = friendsData[indexPath.row]["id"].stringValue
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
     
        let vc = InfoVC()
        vc.id = friendsData[indexPath.row]["id"].stringValue
        navigationController?.pushViewController(vc, animated: true)

    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.friendsData.count - 1 {
            loadOnePage()
        }
    }
    
}



