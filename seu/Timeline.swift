//
//  Timeline.swift
//  WEME
//
//  Created by liewli on 7/23/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit


class TimelineVC:UITableViewController, QZTabBarControllerChildControllerProtocol {
    var postIDSet = Set<String>()
    var timelineCurrentPage = 1
    var events = [TimelineModel]()
    var id:String!
    var sheet:IBActionSheet?

    override func viewDidLoad() {
         super.viewDidLoad()
         tableView.registerClass(TimelineTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TimelineTableViewCell))
         tableView.tableFooterView = UIView()
         tableView.separatorStyle = .None

        fetchEvents()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == events.count - 1{
            fetchEvents()
        }
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.events.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TimelineTableViewCell), forIndexPath: indexPath) as! TimelineTableViewCell
        let data = events[indexPath.section]
        let info = "\(data.time.hunmanReadableString())  发布帖子于\(data.topic)"
        let attributed = NSMutableAttributedString(string: info)
        attributed.addAttribute(NSForegroundColorAttributeName, value: THEME_COLOR, range:NSMakeRange(0, data.time.hunmanReadableString().characters.count))
        cell.infoLabel.attributedText = attributed
        cell.titleLabel.text = data.title
        cell.bodyLabel.text = data.body
        cell.thumbnail.sd_setImageWithURL(data.image, placeholderImage: UIImage(named: "avatar"))
        cell.selectionStyle = .None
        cell.delegate = self
        if let Id = myId where Id == id {
            cell.moreAction.hidden = false
        }
        else {
            cell.moreAction.hidden = true
        }
        return cell

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = events[indexPath.section]
        let vc = PostVC()
        vc.postID = data.postid
        navigationController?.pushViewController(vc, animated: true)

    }

    
    private lazy var postQueue:dispatch_queue_t = {
        let q = dispatch_queue_create("weme.info.post", DISPATCH_QUEUE_SERIAL)
        return q
    }()

    private func postPreProcess(c:[TimelineModel]) {
        dispatch_async(postQueue) { () -> Void in
            if c.count > 0 {
                var ts = [TimelineModel]()
                var k = self.events.count
                let indexSets = NSMutableIndexSet()
                for cc in c {
                    if self.postIDSet.contains(cc.postid) {
                        continue
                    }
                    else {
                        ts.append(cc)
                        self.postIDSet.insert(cc.postid)
                        indexSets.addIndex(k)
                        k += 1
                        
                    }
                }
                if ts.count  > 0 {
                    self.events.appendContentsOf(ts)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.timelineCurrentPage += 1
                            self.tableView.insertSections(indexSets, withRowAnimation: .Fade)

                    })
                    
                }
                
                
            }
        }
    }

    
    private func fetchEvents() {
        if let t = token{
            request(.POST, GET_USER_TIMELINE, parameters: ["token":t, "userid":id, "page":"\(timelineCurrentPage)"], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null  && json["state"].stringValue == "successful" else {
                        return
                    }
                    do {
                        let events = try MTLJSONAdapter.modelsOfClass(TimelineModel.self, fromJSONArray: json["result"].arrayObject) as! [TimelineModel]
                        if events.count > 0 {
                            S.postPreProcess(events)
                        }
                    }
                    catch let e as NSError {
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

extension TimelineVC:TimelineTableViewCellDelegate {
    func didTapMoreAtTimelineCell(cell: TimelineTableViewCell) {
        if let indexPath = self.tableView.indexPathForCell(cell) where indexPath.section < events.count{
            let event = self.events[indexPath.section]
            let postid = event.postid
            sheet = IBActionSheet(title: nil, callback: { (sheet, index) -> Void in
                if index == 0 {
                    if let t = token {
                        request(.POST, DELETE_POST_URL, parameters: ["token":t, "postid":"\(postid)"], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) in
                            if let d = response.result.value, S = self {
                                let json = JSON(d)
                                guard json["state"].stringValue == "successful" else {
                                    return
                                }

                                if let _ = S.tableView.cellForRowAtIndexPath(indexPath) as? TimelineTableViewCell {
                                    if S.events.count > indexPath.section && S.events[indexPath.section].postid == postid {
                                        S.events.removeAtIndex(indexPath.section)
                                        //                                            S.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
                                        S.tableView.reloadData()
                                    }
                                }
                                    

                            }
                            })
                    }
                    
                }
                
                }, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitlesArray: ["删除帖子"])
            sheet?.setButtonTextColor(THEME_COLOR)
            sheet?.showInView(navigationController!.view)
            
            
        }
    }
}

