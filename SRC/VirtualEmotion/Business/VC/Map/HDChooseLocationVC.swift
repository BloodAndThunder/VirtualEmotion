//
//  HDChooseLocationVC.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/8/29.
//  Copyright © 2019 Chiery. All rights reserved.
//

import UIKit
import MapKit

class HDChooseLocationVC: HDBaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.view.addSubview(mapView)
        self.view.addSubview(tableView)
        self.view.addSubview(searchBar)
    }
    
    var maptItems: [MKMapItem]?
    
    lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        return locationManager
    }()
    
    lazy var mapView: MKMapView = {
        let view = MKMapView.init(frame: CGRect.init(x: 0, y: 0, width: HDScreenWidth, height: HDScreenHeight / 2.0))
        view.showsUserLocation = true
        view.isZoomEnabled = true
        view.isScrollEnabled = true
        view.mapType = .standard
        view.showsScale = true
        view.showsPointsOfInterest = true
        
        // 默认天安门
        let span = MKCoordinateSpan.init(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion.init(center: CLLocationCoordinate2D.init(latitude: 39.908722, longitude: 116.397499), span: span)
        view.region = region
        
        return view
    }()
    
    lazy var searchBar: UISearchBar = {
       let view = UISearchBar.init(frame: CGRect.init(x: 20, y: HDStatusBarHeight, width: HDScreenWidth - 40, height: 44))
        view.placeholder = "搜地点"
        view.backgroundImage = UIImage()
        view.backgroundColor = .clear
        view.delegate = self
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView.init(frame: CGRect.init(x: 0, y: HDScreenHeight / 2.0, width: HDScreenWidth, height: HDScreenHeight / 2.0))
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    lazy var geocoder: CLGeocoder = {
        let geocoder: CLGeocoder = CLGeocoder()
        return geocoder
    }()

}
