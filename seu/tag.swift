//
//  tag.swift
//  WEME
//
//  Created by liewli on 4/5/16.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit

var TAG_BACK_COLORS = [UIColor.colorFromRGB(0xcac9e2), UIColor.colorFromRGB(0xcfead8), UIColor.colorFromRGB(0xd3dee3), UIColor.colorFromRGB(0xf7b0a4), UIColor.colorFromRGB(0xfeeebf), UIColor.colorFromRGB(0xb5b6b7), UIColor.colorFromRGB(0xb6c0de)]
var TAG_FRONT_COLORS = [UIColor.colorFromRGB(0x64638d), UIColor.colorFromRGB(0x13602d), UIColor.colorFromRGB(0x35769c),UIColor.colorFromRGB(0xc4503c), UIColor.colorFromRGB(0xc3a245), UIColor.colorFromRGB(0x5a6b80), UIColor.colorFromRGB(0x6478b8)]

class TagCollectionViewCell:UICollectionViewCell {
    
    var tagLabel:UILabel!
    
    func initialize() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp_makeConstraints { (make) in
            make.left.equalTo(snp_left)
            make.right.equalTo(snp_right)
            make.top.equalTo(snp_top)
            make.bottom.equalTo(snp_bottom)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        self.addGestureRecognizer(tap)
        tagLabel = UILabel()
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 4.0
        self.layer.masksToBounds = true
        let idx = Int(rand()) % TAG_BACK_COLORS.count
        self.backgroundColor = TAG_BACK_COLORS[idx]
        tagLabel.textColor = TAG_FRONT_COLORS[idx]
        tagLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        tagLabel.numberOfLines = 0
        tagLabel.lineBreakMode = .ByTruncatingTail
        tagLabel.textAlignment  = .Left
        tagLabel.preferredMaxLayoutWidth = SCREEN_WIDTH-30
        contentView.addSubview(tagLabel)
        
        tagLabel.snp_makeConstraints { (make) in
            make.left.equalTo(contentView.snp_left).offset(5)
            make.right.equalTo(contentView.snp_right).offset(-5)
            make.top.equalTo(contentView.snp_top).offset(5)
            make.bottom.equalTo(contentView.snp_bottom).offset(-5)
        }
    }
    
    func tap(tapGest:UITapGestureRecognizer) {
        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: {
                self.transform = CGAffineTransformMakeScale(1.05, 1.05)
            }) { (finished) in
                UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: {
                    self.transform = CGAffineTransformMakeScale(0.95, 0.95)
                    }, completion: { (finished) in
                        self.transform = CGAffineTransformIdentity
                })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError();
    }
}

class TagManager:NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var tags = [String]() {
        didSet {
            cell?.tagCollectionView.reloadData()
        }
    }
    weak var cell:TagTableViewCell?
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(TagCollectionViewCell.self), forIndexPath: indexPath) as! TagCollectionViewCell
        cell.tagLabel.text = tags[indexPath.item]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
}




class LeftAlignedColllectionViewFlowLayout:UICollectionViewFlowLayout {
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let att = super.layoutAttributesForItemAtIndexPath(indexPath)?.copy() as? UICollectionViewLayoutAttributes
        if indexPath.item == 0 {
            if let a = att {
                var f = a.frame
                f.origin.x = 10
                a.frame = f
                return a
 
            }
            
            return att
        }
        
        let prevIndexPath = NSIndexPath(forItem: indexPath.item-1, inSection: indexPath.section)
        
        if let fPrev = self.layoutAttributesForItemAtIndexPath(prevIndexPath)?.frame, a = att{
            let rightPrev = fPrev.origin.x + fPrev.size.width + 10
            if a.frame.origin.x < rightPrev {
                var f = a.frame
                f.origin.x = 10
                a.frame = f
                return a
            }
            else {
                var f = a.frame
                f.origin.x = rightPrev
                a.frame = f
                return a
            }
        }
        
        return nil
        
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let arr = super.layoutAttributesForElementsInRect(rect)
        if let atts = arr {
            var att_copy = [UICollectionViewLayoutAttributes]()
            for att in atts {
                let a = att.copy() as! UICollectionViewLayoutAttributes
                att_copy.append(a)
                if a.representedElementKind == nil {
                    let indexPath = a.indexPath
                    if let f = self.layoutAttributesForItemAtIndexPath(indexPath)?.frame {
                        a.frame = f
                    }
                }
            }
        }
        return arr;
    }
}

class TagTableViewCell:UITableViewCell {
    
    var tagCollectionView:UICollectionView = {
        let layout = LeftAlignedColllectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .Vertical
        layout.estimatedItemSize = CGSizeMake(40, 40)
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(TagCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TagCollectionViewCell))
        collectionView.scrollEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        //collectionView.backgroundColor = SECONDAY_COLOR
        return collectionView
    }()
    
    
    var tagManager:TagManager? {
        didSet {
            tagManager?.cell = self
            tagCollectionView.dataSource = tagManager
            tagCollectionView.delegate = tagManager
        }
    }
    
    var titleLabel:UILabel!
    
    func initialize() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        titleLabel.textColor = TEXT_COLOR
        addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(contentView.snp_top).offset(10)
        }
        
        tagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagCollectionView)
        tagCollectionView.snp_makeConstraints { (make) in
            make.left.equalTo(contentView.snp_left)
            make.right.equalTo(contentView.snp_right)
            make.top.equalTo(titleLabel.snp_bottom)
            make.bottom.equalTo(contentView.snp_bottom)
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

class EditTagViewController:UITableViewController, AddTagViewControllerDelegate {
    
    static let EDIT_TAG_NOTIFICATION = "EDIT_TAG_NOTIFICATION"
    
    var tags = [String]()
    var selectedIndex = Set<Int>()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.alpha = 1.0
        
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "编辑标签"
        view.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell))
        
        let cancel = UIBarButtonItem(title: "取消", style: .Plain, target: self, action: #selector(self.cancel(_:)))
        let done = UIBarButtonItem(title: "完成", style: .Plain, target: self, action: #selector(self.done(_:)))
        
        navigationItem.leftBarButtonItem = cancel
        navigationItem.rightBarButtonItem = done
        
        tableView.tableFooterView  = UIView()
        
        tableView.backgroundColor = BACK_COLOR
        
        fetchTags()
        
    }
    
    func cancel(sender:AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func done(sender:AnyObject) {
        var selectedTags = [String]()
        for idx in selectedIndex where idx < tags.count{
            selectedTags.append(tags[idx])
        }
        if let t = token {
            let dic = ["token":t, "tags": ["custom":selectedTags]]
            request(.POST, SET_TAGS_URL, parameters: dic as! [String : AnyObject], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" else {
                        S.messageAlert("设置标签失败")
                        return
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName(EditTagViewController.EDIT_TAG_NOTIFICATION, object: nil)
                    S.navigationController?.popViewControllerAnimated(true)
                }
                
            })
        }
    }
    
    func fetchTags() {
        if let t = token, id = myId{
            let dic = ["token":t, "userid":id]
            request(.POST, GET_TAGS_URL, parameters: dic, encoding: .JSON).responseJSON(completionHandler: { [weak self](response) in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json["state"].stringValue == "successful" && json["result"]["tags"]["custom"] != .null else {
                        return
                    }
                    
                    if let tt = json["result"]["tags"]["custom"].array {
                        var indexPaths = [NSIndexPath]()
                        var k = S.tags.count
                        for ta in tt {
                            S.tags.append(ta.stringValue)
                            indexPaths.append(NSIndexPath(forRow: k, inSection: 1))
                            S.selectedIndex.insert(k)
                            k += 1
                        }
                        S.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                    }
                }
                
            })
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return tags.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell), forIndexPath: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = "添加标签"
            cell.textLabel?.textColor = THEME_COLOR
            cell.accessoryType = .DisclosureIndicator
        }
        else {
            cell.textLabel?.text = tags[indexPath.row]
            cell.accessoryType = selectedIndex.contains(indexPath.row) ? .Checkmark : .None
        }
        
        cell.selectionStyle = .None
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let vc = AddTagViewController()
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            if selectedIndex.contains(indexPath.row) {
                selectedIndex.remove(indexPath.row)
                if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                    cell.accessoryType = .None
                }
            }
            else {
                selectedIndex.insert(indexPath.row)
                if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                    cell.accessoryType = .Checkmark
                }
            }
        }
    }
    
    func didAddTag(tag: String) {
        tags.insert(tag, atIndex: 0)
        var newIndex = [Int]()
        newIndex.append(0)
        for t in selectedIndex {
            newIndex.append(t+1)
        }
        selectedIndex.removeAll()
        for t in newIndex {
            selectedIndex.insert(t)
        }
        tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 1)], withRowAnimation: .Fade)
    }
}

protocol AddTagViewControllerDelegate:class {
    func didAddTag(tag:String)
}

class AddTagViewController:UIViewController {
    var bottomLine:UILabel!
    var textField:UITextField!
    var infoLabel:UILabel!
    
    weak var delegate:AddTagViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BACK_COLOR
        title = "添加标签"
        let cancel = UIBarButtonItem(title: "取消", style: .Plain, target: self, action: #selector(self.cancel(_:)))
        let done = UIBarButtonItem(title: "完成", style: .Plain, target: self, action: #selector(self.done(_:)))
        
        navigationItem.leftBarButtonItem = cancel
        navigationItem.rightBarButtonItem = done
        
        setupUI()
        
        textField.becomeFirstResponder()

    }
    
    func textChange(sender:UITextField) {
        if let text = textField.text {
            if text.characters.count > 40 {
                textField.text = text.substringWithRange(text.startIndex ..< text.startIndex.advancedBy(40))
            }
            else {
                infoLabel.text = "\(40-text.characters.count)"
            }
        }
    }
    
    func setupUI() {
        textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(self.textChange(_:)), forControlEvents: .EditingChanged)
        view.addSubview(textField)
        
        bottomLine = UILabel()
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = THEME_COLOR
        view.addSubview(bottomLine)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textAlignment = .Right
        infoLabel.text = "40"
        view.addSubview(infoLabel)
        
        
        textField.snp_makeConstraints { (make) in
            make.left.equalTo(view.snp_leftMargin)
            make.right.equalTo(view.snp_rightMargin)
            make.top.equalTo(snp_topLayoutGuideBottom).offset(20)
        }
        
        bottomLine.snp_makeConstraints { (make) in
            make.left.equalTo(view.snp_leftMargin)
            make.right.equalTo(view.snp_rightMargin)
            make.top.equalTo(textField.snp_bottom)
            make.height.equalTo(1)
        }
    
        infoLabel.snp_makeConstraints { (make) in
            make.left.equalTo(view.snp_leftMargin)
            make.right.equalTo(view.snp_rightMargin)
            make.top.equalTo(bottomLine.snp_bottom).offset(5)
        }
    }
    
    func cancel(sender:AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func done(sender:AnyObject) {
        if let text = textField.text where text.characters.count > 0 {
            delegate?.didAddTag(text)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

}
