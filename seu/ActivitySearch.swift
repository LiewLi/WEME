//
//  ActivitySearch.swift
//  WE
//
//  Created by liewli on 12/29/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit

protocol ActivitySearchVCDelegate :class {
    func didSearchText(text:String)
}

class ActivitySearchVC:UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate{
    
    private var tableView:UITableView!
    private var searchBar:UISearchBar!
    
    private var history = [String]()
    
    weak var delegate:ActivitySearchVCDelegate?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "搜索活动"
        view.backgroundColor = UIColor.whiteColor()
        setupUI()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.loadDataFromFile()
        })

    }
    
    func loadDataFromFile() {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        let dataFile = cacheDir.stringByAppendingString("sd")
        if NSFileManager.defaultManager().fileExistsAtPath(dataFile) {
            if let d = NSKeyedUnarchiver.unarchiveObjectWithFile(dataFile) as? [String] {
                history = d
                if history.count > 10 {
                    history.removeRange(10 ..< history.count)
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
                
            }
        }

    }
    
    func saveSearchTextToFile() {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0]
        let dataFile = cacheDir.stringByAppendingString("sd")
        NSKeyedArchiver.archiveRootObject(history, toFile: dataFile)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            
            }) { (finished) -> Void in
                self.searchBar.becomeFirstResponder()
        }
    }
    
    func setupUI() {
        searchBar = UISearchBar()
        navigationItem.hidesBackButton = true
        searchBar.tintColor = THEME_COLOR
        searchBar.placeholder = "搜索活动"
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        let right = UIBarButtonItem(title: "取消", style: .Plain, target: self, action: "cancel:")
        navigationItem.rightBarButtonItem = right
        tableView = UITableView(frame: view.frame, style:.Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = BACK_COLOR
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        view.addSubview(tableView)
    }
    
    
    func cancel(sender:AnyObject) {
        navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count == 0 ? 0 : history.count + 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return history.count == 0 ? "" :  "搜索历史"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != history.count {
            let text = history[indexPath.row]
            history.removeAtIndex(indexPath.row)
            history.insert(text, atIndex: 0)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.saveSearchTextToFile()
            })
            navigationController?.popViewControllerAnimated(false)
            delegate?.didSearchText(text)
        }
        else {
            history.removeAll()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                 self.saveSearchTextToFile()
            })
            tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
        if indexPath.row == history.count {
            cell.textLabel?.text = "清除清除历史"
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.textColor = UIColor.lightGrayColor()
        }
        else {
            cell.textLabel?.text = history[indexPath.row]
            cell.textLabel?.textColor = TEXT_COLOR
        }
        cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rect = ("历" as NSString).boundingRectWithSize(CGSizeMake(tableView.frame.size.width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName:UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)], context: nil)
        return rect.height + 16
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if searchBar.isFirstResponder() {
            searchBar.resignFirstResponder()
        }
    }
    

    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let text = searchBar.text where text.characters.count > 0 {
            history.insert(text, atIndex: 0)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                self.saveSearchTextToFile()
            })
            navigationController?.popViewControllerAnimated(false)
            delegate?.didSearchText(text)
        }
    }
 
}


class ActivitySearchResultVC:UITableViewController {
    private var activities = [ActivityModel]()
    var searchText:String!
    var isempty = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = true
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR//UIColor.colorFromRGB(0x104E8B)//UIColor.blackColor()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "活动搜索结果"
        view.backgroundColor = BACK_COLOR
        tableView.registerClass(ActivityCell.self, forCellReuseIdentifier: NSStringFromClass(ActivityCell))
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        //tableView.reloadData()
        fetchActivityInfo()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return activities.count > 0 ? activities.count : (isempty ? 1 : 0)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if activities.count > 0 {
            let cell  = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ActivityCell), forIndexPath: indexPath) as! ActivityCell
            let data = activities[indexPath.section]
            cell.titleLabel.text = data.title
            cell.timeLabel.text = data.time
            cell.locationLabel.text = data.location
            cell.infoLabel.text = " \(data.signnumber)/\(data.capacity) "
            
            cell.hostIcon.sd_setImageWithURL(thumbnailAvatarURLForID(data.authorID ?? ""), placeholderImage: UIImage(named: "avatar"))
            cell.selectionStyle = .None
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
            cell.textLabel?.text = "没有找到相关活动╮(╯▽╰)╭"
            cell.textLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            cell.textLabel?.textColor = UIColor.lightGrayColor()
            cell.textLabel?.textAlignment = .Center
            cell.selectionStyle = .None
            return cell
        }
    }
    
    func fetchActivityInfo() {
        if let t = token {
            request(.POST, SEARCH_ACTIVITY_URL, parameters: ["token":t, "text":searchText], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let S = self, d = response.result.value {
                    let json = JSON(d)
                    guard json != .null && json["state"] == "successful" && json["result"] != .null else {
                        return
                    }
                    
                    do {
                        let ac = try MTLJSONAdapter.modelsOfClass(ActivityModel.self, fromJSONArray: json["result"].arrayObject) as? [ActivityModel]
                        if let a = ac where a.count > 0 {
//                            var k = S.activities.count
//                            let indexSets = NSMutableIndexSet()
//                            for _ in a {
//                                indexSets.addIndex(k++)
//                            }
                            S.activities = a
                            
                           // S.tableView.insertSections(indexSets, withRowAnimation: .Fade)
                        }
                        else {
                            S.isempty = true
                        }
                        S.tableView.reloadData()
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                    
                    
                }
                })
        }
    }
    

    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 10 : 5
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 5))
        v.backgroundColor = BACK_COLOR
        return v
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: section == 0 ? 10 : 5))
        v.backgroundColor = BACK_COLOR
        return v
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section < activities.count {
            let data = activities[indexPath.section]
            let vc = ActivityInfoVC()
            vc.activityID = data.activityID
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return activities.count > 0 ? 100 : 50
    }
    
    
}
