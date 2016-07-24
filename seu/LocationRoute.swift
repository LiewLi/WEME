//
//  LocationRouteVC.swift
//  WEME
//
//  Created by liewli on 2016-01-15.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit
import MapKit

class LocationRouteVC:UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {
    var mapView:MKMapView!
    var locationManager:CLLocationManager!
    var food:FoodModel!
    
    
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
        view.backgroundColor = UIColor.whiteColor()
        title = "美食地点"
        mapView = MKMapView()
        view.addSubview(mapView)
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        checkAuthorizationStatus()
        locationManager.distanceFilter = CLLocationDistance(1000)
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        setupUI()
        configUI()
    }
    
    func configUI() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: food.latitude, longitude: food.longitude)
        annotation.title = food.title
        annotation.subtitle = food.location
        mapView.addAnnotation(annotation)
        let c = CLLocationCoordinate2D(latitude: food.latitude, longitude: food.longitude)
        let mapRegion = MKCoordinateRegion(center:c, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(mapRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for (idx, aV) in views.enumerate() {
            if let _ = aV.annotation as? MKPointAnnotation {
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
            }
            
            return view
        }
        
        return nil
    }
    

    
    func setupUI() {
        mapView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(view.snp_top)
            make.bottom.equalTo(view.snp_bottom)
        }
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


}
