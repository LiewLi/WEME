//
//  LocationVC.swift
//  WEME
//
//  Created by liewli on 2016-01-11.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation:NSObject, MKAnnotation {
    let title:String?
    let locationName:String?
    let coordinate:CLLocationCoordinate2D
    
    init(title:String, locationName:String, coordinate:CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        super.init()
    }
    
    
    convenience init(title:String, locationName:String, geoPoint:AMapGeoPoint) {
        let coord = CLLocationCoordinate2D(latitude: CLLocationDegrees(geoPoint.latitude), longitude: CLLocationDegrees(geoPoint.longitude))
        self.init(title:title, locationName:locationName, coordinate:coord)
    }
    
    var subtitle:String? {
        return locationName
    }
}

protocol LocationVCDelegate:class {
    func didSelectLocation(location:LocationAnnotation)
}

class LocationVC:UIViewController, MKMapViewDelegate, AMapSearchDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate,  LocationSearchResultVCDelegate{
    var mapView:MKMapView!
    var locationManager:CLLocationManager!
    var search:AMapSearchAPI!
    var searchController:UISearchController!
    var topView:UIView!
    var tableView:UITableView!
    var places = [AMapPOI]()
    var city = "南京"
    
    weak var delegate:LocationVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "地点"
        view.backgroundColor = UIColor.whiteColor()
        mapView = MKMapView()
        mapView.delegate = self
        tableView = UITableView()
        tableView.registerClass(LocationTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(LocationTableViewCell))
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        checkAuthorizationStatus()
        locationManager.distanceFilter = CLLocationDistance(1000)
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        search = AMapSearchAPI()
        search.delegate = self
        
        let vc = LocationSearchResultVC()
        vc.delegate = self
        searchController = UISearchController(searchResultsController: vc)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "搜索附近地点"
       // searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = THEME_COLOR
        searchController.searchBar.barTintColor = BACK_COLOR
        searchController.searchBar.backgroundColor = BACK_COLOR
        searchController.definesPresentationContext = true
        searchController?.delegate = self
        searchController?.searchBar.delegate = self
        self.navigationController?.extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.definesPresentationContext = true
        
        setupUI()
        
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

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(LocationTableViewCell), forIndexPath: indexPath) as! LocationTableViewCell
        cell.locationLabel.text = places[indexPath.row].name
        cell.infoLabel.text = places[indexPath.row].address
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let p = places[indexPath.row]
        let location = LocationAnnotation(title: p.name, locationName: p.address, geoPoint: p.location)
        navigationController?.popViewControllerAnimated(true)
        print(location.coordinate)
        delegate?.didSelectLocation(location)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count == 0 {
            return
        }
        let currentCoord = locations[0]
        let mapRegion = MKCoordinateRegion(center: currentCoord.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(mapRegion, animated: true)
        let request = AMapPOIAroundSearchRequest()
        request.location = AMapGeoPoint.locationWithLatitude(CGFloat(currentCoord.coordinate.latitude), longitude: CGFloat(currentCoord.coordinate.longitude))
        request.keywords = "美食"
        request.types = "餐饮服务|生活服务"
        request.sortrule = 0
        request.requireExtension = true
        search.AMapPOIAroundSearch(request)
        
        let cityRequest = AMapReGeocodeSearchRequest()
        cityRequest.location =  AMapGeoPoint.locationWithLatitude(CGFloat(currentCoord.coordinate.latitude), longitude: CGFloat(currentCoord.coordinate.longitude))
        search.AMapReGoecodeSearch(cityRequest)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
    }
    
    func checkAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.showsUserLocation = true
            locationManager.startUpdatingLocation()
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    func setupUI() {
        topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)
        topView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(snp_topLayoutGuideBottom)
            make.height.equalTo(44)
        }
        topView.addSubview(searchController.searchBar)
        searchController.searchBar.sizeToFit()
        searchController.searchBar.frame.size.width = view.frame.size.width
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        mapView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(topView.snp_bottom)
            make.height.equalTo(mapView.snp_width).multipliedBy(0.5)
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(mapView.snp_bottom).offset(5)
            make.bottom.equalTo(view.snp_bottom)
        }
        
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let text = searchController.searchBar.text where text.characters.count > 0 {
            let tips = AMapInputTipsSearchRequest()
            tips.keywords = text
            
            tips.city = city
            search.AMapInputTipsSearch(tips)
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? LocationAnnotation {
            let identifier = NSStringFromClass(LocationAnnotation)
            var view:MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            }
            else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: NSStringFromClass(LocationAnnotation))
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                let button = UIButton(type: .System)
                button.setImage(UIImage(named: "location_select"), forState: .Normal)
                button.tintColor = THEME_COLOR
                button.frame = CGRectMake(0, 0, 30, 30)
                view.rightCalloutAccessoryView = button
            }
            
            return view
        }
        
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        didSelect(view.annotation as? LocationAnnotation)
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for (idx, aV) in views.enumerate() {
            if let _ = aV.annotation as? LocationAnnotation {
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
    
    func didSelect(location:LocationAnnotation?) {
        if let loc = location {
            navigationController?.popViewControllerAnimated(true)
            delegate?.didSelectLocation(loc)
        }
    }
    
    
    
    func onInputTipsSearchDone(request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        if response.tips.count <= 0 {
            return
        }
     
        let vc = searchController.searchResultsController as! LocationSearchResultVC
        vc.tips = response.tips as! [AMapTip]//Array((response.tips as! [AMapTip])[1..<response.tips.count])
        vc.tableView.reloadData()
    }
    
    
    func onPOISearchDone(request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        if response.pois.count == 0 {
            return
        }
       // if request.isKindOfClass(AMapPOIAroundSearchRequest) {
            places = response.pois as! [AMapPOI]
            tableView.reloadData()
            mapView.removeAnnotations(mapView.annotations)
            for p in places {
                let annotation = LocationAnnotation(title: p.name, locationName: p.address, geoPoint: p.location)
                mapView.addAnnotation(annotation)
            }

        //}
       // else if request.isKindOfClass(AMapPOIIDSearchRequest){
            
       // }
    }
    
    func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        if let info = response.regeocode {
            city = info.addressComponent.city
        }
    }
    
    
    func didScroll() {
        if let text = searchController?.searchBar.text where text.characters.count > 0,
            let s = searchController?.searchBar.isFirstResponder() where s == true{
                searchController?.searchBar.resignFirstResponder()
        }

    }
    
    func didSelectTip(tip: AMapTip) {
        searchController?.active = false
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        setNeedsStatusBarAppearanceUpdate()
        if let uid = tip.uid where uid.characters.count > 0 {
            let request = AMapPOIIDSearchRequest()
            request.uid = uid
            search.AMapPOIIDSearch(request)
        }
        else {
            let request = AMapPOIKeywordsSearchRequest()
            request.keywords = tip.name
            request.city = city
            request.cityLimit = true
            search.AMapPOIKeywordsSearch(request)
        }
        
    }
    
}

class LocationTableViewCell:UITableViewCell {
    
    var locationLabel:UILabel!
    var infoLabel:UILabel!
    
    func initialize() {
        locationLabel = UILabel()
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.textColor = UIColor.darkGrayColor()
        locationLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        contentView.addSubview(locationLabel)
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textColor = TEXT_COLOR
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        contentView.addSubview(infoLabel)
        
        
        locationLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentView.snp_leftMargin)
            make.right.equalTo(contentView.snp_rightMargin)
            make.top.equalTo(contentView.snp_top)
        }
        
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(locationLabel.snp_bottom).offset(5)
            make.left.equalTo(contentView.snp_leftMargin)
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


protocol LocationSearchResultVCDelegate:class {
    func didScroll();
    func didSelectTip(tip:AMapTip);
}

class LocationSearchResultVC:UITableViewController {
    weak var delegate:LocationSearchResultVCDelegate?
    var tips = [AMapTip]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        edgesForExtendedLayout = .None
        tableView.registerClass(LocationTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(LocationTableViewCell))
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tips.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(LocationTableViewCell), forIndexPath: indexPath) as! LocationTableViewCell
        let tip = tips[indexPath.row]
        cell.locationLabel.text = tip.name
        cell.infoLabel.text = tip.district
        return cell
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.didScroll()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tip = tips[indexPath.row]
        delegate?.didSelectTip(tip)
    }
    
}
