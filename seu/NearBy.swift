//
//  NearBy.swift
//  WEME
//
//  Created by liewli on 2016-01-13.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit
//
class PeopleLocationAnnotation:NSObject, MKAnnotation {
    let info:AMapNearbyUserInfo
    
    init(info:AMapNearbyUserInfo) {
        self.info = info
        super.init()
    }
    
    var id:String {
        return info.userID
    }
    
    var title:String? {
        return "距你\((Double(Int(info.distance)/10)/100)) km"
    }
    
    var distance:CGFloat {
        return info.distance
    }
    
    var coordinate:CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(info.location.latitude), longitude: Double(info.location.longitude))
    }
    
    var subtitle:String? {
        let localTimeZone = NSTimeZone.localTimeZone()
        let td = localTimeZone.secondsFromGMT
        let date = NSDate(timeIntervalSince1970: info.updatetime+Double(td))
        return date.hunmanReadableString()
    }
}

class NearByVC: UITableViewController,MKMapViewDelegate, AMapSearchDelegate,CLLocationManagerDelegate, AMapNearbySearchManagerDelegate {
    var mapView:MKMapView!
    var locationManager:CLLocationManager!
    var search:AMapSearchAPI!
    var nearbyManager:AMapNearbySearchManager!
    var currentCoordinate:CLLocationCoordinate2D?
    
    var nearbyPeople = [PeopleLocationAnnotation]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = THEME_COLOR
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.alpha = 1.0

    }
    
    deinit {
        if nearbyManager.isAutoUploading {
            nearbyManager.stopAutoUploadNearbyInfo()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "附近"
        automaticallyAdjustsScrollViewInsets = false
        tableView.tableFooterView = UIView()
        tableView.registerClass(NearByPeopleTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(NearByPeopleTableViewCell))
        mapView = MKMapView(frame: CGRectMake(0, 0, tableView.frame.width, min(tableView.frame.width,tableView.frame.height-120)))
        mapView.delegate = self
        nearbyManager = AMapNearbySearchManager.sharedInstance()
        nearbyManager.delegate = self
        tableView.tableHeaderView = mapView
        view.backgroundColor = UIColor.whiteColor()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        checkAuthorizationStatus()
        locationManager.distanceFilter = CLLocationDistance(1000)
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        search = AMapSearchAPI()
        search.delegate = self
        
   

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyPeople.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(NearByPeopleTableViewCell), forIndexPath: indexPath) as! NearByPeopleTableViewCell
        cell.distanceLabel.textColor = PLACEHOLDER_COLOR
        if cell.infoLoader == nil {
            cell.infoLoader = NearByInfoLoader()
        }
        let p = nearbyPeople[indexPath.row]
        cell.infoLoader.id = p.id
        cell.distanceLabel.text = "\((Double(Int(p.distance)/10)/100)) km"
        cell.selectionStyle = .None
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let p = nearbyPeople[indexPath.row]
        visitInfoForId(p.id)
    }
    
    func checkAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
            nearbyManager.startAutoUploadNearbyInfo()
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func nearbyInfoForUploading(manager: AMapNearbySearchManager!) -> AMapNearbyUploadInfo! {
        let info = AMapNearbyUploadInfo()
        if let id = myId, coord = currentCoordinate {
            info.userID = id
            info.coordinate = coord
        }
        
        return info
    }
    
    func searchNearBy() {
        if let coord = currentCoordinate {
            let request = AMapNearbySearchRequest()
            request.center = AMapGeoPoint.locationWithLatitude(CGFloat(coord.latitude), longitude: CGFloat(coord.longitude))
            request.radius = 10000
            request.timeRange = 10000
            request.searchType = AMapNearbySearchType.Driving
            search.AMapNearbySearch(request)
            
        }
        
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for (idx, aV) in views.enumerate() {
            if let _ = aV.annotation as? PeopleLocationAnnotation {
                let point = MKMapPointForCoordinate(aV.annotation!.coordinate)
                if !MKMapRectContainsPoint(mapView.visibleMapRect, point) {
                    continue
                }
                let endFrame = aV.frame;
                aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y-view.frame.size.height, aV.frame.width, aV.frame.height)
                
                UIView.animateWithDuration(0.5, delay: 0.04*Double(idx), options: .CurveLinear, animations: { () -> Void in
                    aV.frame = endFrame
                    }, completion: { (finished) -> Void in
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            aV.transform = CGAffineTransformMakeScale(1.0, 0.8)
                            
                            }, completion: { (finished) -> Void in
                                aV.transform = CGAffineTransformIdentity
                        })
                })
                
            }
        }
    }
    
    
    func visitInfoForId(id:String?) {
        if let ID = id {
            let vc = InfoVC()
            vc.id = ID
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let p = view.annotation as? PeopleLocationAnnotation
        visitInfoForId(p?.id)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? PeopleLocationAnnotation {
            let identifier = NSStringFromClass(MKPointAnnotation)
            var view:MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
                let avatar = UIButton(frame: CGRectMake(0, 0, 40, 40))
                avatar.sd_setImageWithURL(thumbnailAvatarURLForID(annotation.id), forState: .Normal, placeholderImage: UIImage(named: "avatar"))
                avatar.layer.cornerRadius = 20
                avatar.layer.masksToBounds = true
                view.rightCalloutAccessoryView = avatar
            }
            else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: NSStringFromClass(LocationAnnotation))
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                let avatar = UIButton(frame: CGRectMake(0, 0, 40, 40))
                avatar.sd_setImageWithURL(thumbnailAvatarURLForID(annotation.id), forState: .Normal, placeholderImage: UIImage(named: "avatar"))
                avatar.layer.cornerRadius = 20
                avatar.layer.masksToBounds = true
                view.rightCalloutAccessoryView = avatar
            }
            
            return view
        }
        
        return nil
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let p = nearbyPeople[indexPath.row]
        let follow = UITableViewRowAction(style: .Normal, title: "关注") { (action, indexPath) -> Void in
            if let token = token {
                request(.POST, FOLLOW_URL, parameters: ["token":token, "id":p.id], encoding: .JSON).responseJSON{ [weak self](response) -> Void in
                    if let d = response.result.value, S = self {
                        let json = JSON(d)
                        guard json["state"].stringValue == "successful" else {
                            S.messageAlert("关注失败 \(json["reason"].stringValue)")
                            return
                        }
                        
                       
                    }
                    
                }
                
            }
            
        }
        let message = UITableViewRowAction(style: .Normal, title: "私信") { (action, indexPath) -> Void in
            let p = self.nearbyPeople[indexPath.row]
            let vc = ComposeMessageVC()
            vc.recvID = p.id
            let nav = UINavigationController(rootViewController: vc)
            self.presentViewController(nav, animated: true, completion: { () -> Void in
                
            });
        }
        message.backgroundColor = FEMALE_COLOR
        follow.backgroundColor = MALE_COLOR
        
        return [follow, message]
    }

    
    func onNearbySearchDone(request: AMapNearbySearchRequest!, response: AMapNearbySearchResponse!) {
        if response.infos.count == 0 {
            return
        }
        mapView.removeAnnotations(mapView.annotations)
        var infos = [PeopleLocationAnnotation]()
        for info in response.infos as! [AMapNearbyUserInfo] {
            let annotation = PeopleLocationAnnotation(info: info)
            infos.append(annotation)
            mapView.addAnnotation(annotation)
        }
        nearbyPeople = infos
        tableView.reloadData()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count == 0 {
            return
        }
        let currentCoord = locations[0]
        currentCoordinate = currentCoord.coordinate
        let mapRegion = MKCoordinateRegion(center: currentCoord.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(mapRegion, animated: true)
        searchNearBy()

    }
}




class NearByInfoLoader: NSObject {
    weak var cell:NearByPeopleTableViewCell?
    var id:String = "" {
        didSet {
            cell?.avatar.sd_setImageWithURL(thumbnailAvatarURLForID(id), placeholderImage: UIImage(named: "avatar"))
            fetchInfoFor(id)
        }
    }
    
    func fetchInfoFor(id:String) {
        if let t = token {
            request(.POST, GET_FRIEND_PROFILE_URL, parameters: ["token": t, "id":id], encoding: .JSON).responseJSON(completionHandler: { [weak self](response) -> Void in
                debugPrint(response)
                if let d = response.result.value, S = self {
                    let json = JSON(d)
                    guard json != .null && json["state"].stringValue == "successful" && json.dictionaryObject != nil else {
                        return
                    }
                    
                    
                    do {
                        let p = try MTLJSONAdapter.modelOfClass(PersonModel.self, fromJSONDictionary: json.dictionaryObject!) as! PersonModel
                        if S.id == id {
                            S.cell?.nameLabel.text = p.name
                            S.cell?.infoLabel.text = p.school
                            if p.gender == "男" {
                                S.cell?.distanceLabel.textColor = MALE_COLOR
                            }
                            else if p.gender == "女" {
                                S.cell?.distanceLabel.textColor = FEMALE_COLOR
                            }
                        }
                    }
                    catch let error as NSError {
                        print(error.localizedDescription)
                    }
                }
                
                
                
          })
        }
        
    }
    
 }

class NearByPeopleTableViewCell:UITableViewCell {
    
    var avatar:UIImageView!
    var nameLabel:UILabel!
    var infoLabel:UILabel!
    var distanceLabel:UILabel!
    var gender:UIImageView!
    
    var infoLoader:NearByInfoLoader! {
        didSet {
            infoLoader.cell = self
        }
    }
    
    func initialize() {
        avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 20
        avatar.layer.masksToBounds = true
        contentView.addSubview(avatar)
        
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = TEXT_COLOR
        nameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        contentView.addSubview(nameLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = TEXT_COLOR
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        contentView.addSubview(infoLabel)
        
        distanceLabel = UILabel()
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        distanceLabel.textAlignment = .Right
        distanceLabel.textColor = PLACEHOLDER_COLOR
        contentView.addSubview(distanceLabel)
        
        
        avatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.centerY.equalTo(contentView.snp_centerY)
            make.width.height.equalTo(40)
        }
        
        nameLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(10)
            make.top.equalTo(avatar.snp_top)
            nameLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatar.snp_right).offset(10)
            make.bottom.equalTo(avatar.snp_bottom)
        }
        
        distanceLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLabel.snp_right)
            make.right.equalTo(contentView.snp_rightMargin)
            make.centerY.equalTo(nameLabel.snp_centerY)
            distanceLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
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
