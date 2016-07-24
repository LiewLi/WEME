//
//  PostLike.swift
//  牵手东大
//
//  Created by liewli on 11/26/15.
//  Copyright © 2015 li liew. All rights reserved.
//

import UIKit

struct LikeUser {
    let id:String
    let name:String
    let gender:String
    let school:String
}

class PostLikeVC:UITableViewController {
    
    var users = [LikeUser]()
    var currentPage = 1
    var isLoading = false
    var postID:String?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.translucent = false
        //navigationController?.navigationBar.backgroundColor = UIColor.blackColor()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.barStyle = .Black

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "赞过的童鞋"
        tableView.tableFooterView = UIView()
        tableView.registerClass(PostLikeTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(PostLikeTableViewCell))
        fetchLikeUser()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(PostLikeTableViewCell), forIndexPath: indexPath) as! PostLikeTableViewCell
        let data = users[indexPath.row]
        cell.nameLabel.text = data.name
        cell.infoLabel.text = data.school
        cell.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(data.id), placeholderImage: UIImage(named: "avatar"))
        if data.gender == "男" {
             cell.gender.image = UIImage(named: "male")
        }
        else if data.gender == "女" {
            cell.gender.image = UIImage(named: "female")
        }
        cell.selectionStyle = .None
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = InfoVC()
        vc.id = users[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row >= users.count - 5 && !isLoading {
            fetchLikeUser()
        }
    }
    
    func fetchLikeUser() {
        if let t = token, id = postID {
            isLoading = true
            request(.POST, GET_POST_LIKE_USERS, parameters: ["token":t, "postid":id, "page":"\(currentPage)"], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let S = self, d = response.result.value {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" && json["result"] != .null && json["result"].array != nil else {
                        return
                    }
                    
                    var likeUsers = [LikeUser]()
                    var k = S.users.count
                    var indexPaths = [NSIndexPath]()
                    for a in json["result"].array! {
                        guard a["id"] != .null else {
                            continue
                        }
                        let u = LikeUser(id: a["id"].stringValue, name: a["name"].stringValue, gender: a["gender"].stringValue, school: a["school"].stringValue)
                        likeUsers.append(u)
                        indexPaths.append(NSIndexPath(forItem: k++, inSection: 0))
                    }
                    
                    if likeUsers.count > 0  && likeUsers.count == indexPaths.count{
                        S.currentPage++
                        S.users.appendContentsOf(likeUsers)
                        S.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                    }
                    
                    S.isLoading = false
                }
                
            })
        }
    }
}

class PostLikeTableViewCell:UITableViewCell {
    var avatar:UIImageView!
    var nameLabel:UILabel!
    var gender:UIImageView!
    var infoLabel:UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initialize() {
        accessoryType = .DisclosureIndicator
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
        }
        
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 40/2
        avatar.layer.masksToBounds = true
        contentView.addSubview(avatar)
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.centerY.equalTo(contentView.snp_centerY)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        nameLabel.font = UIFont.boldSystemFontOfSize(14)
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(avatar.snp_top)
            make.left.equalTo(avatar.snp_right).offset(5)
            //make.right.equalTo(contentView.snp_rightMargin)
        }
        
        gender = UIImageView()
        gender.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gender)
        gender.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_right).offset(5)
            make.centerY.equalTo(nameLabel.snp_centerY)
            make.height.equalTo(16)
            make.width.equalTo(14)
        }
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(infoLabel)
        infoLabel.textColor = UIColor.lightGrayColor()
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_left)
            make.top.equalTo(nameLabel.snp_bottom).offset(5)
            make.right.equalTo(contentView.snp_rightMargin)
        }
    }

}
