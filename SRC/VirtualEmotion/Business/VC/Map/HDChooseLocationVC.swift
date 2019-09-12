//
//  HDChooseLocationVC.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/8/29.
//  Copyright © 2019 Chiery. All rights reserved.
//

import UIKit
import MapKit

typealias HDChooseLocationVCCallBack = (MKMapItem)->()

class HDChooseLocationVC: HDBaseVC {
    
    var locationSelectedCallback: HDChooseLocationVCCallBack?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.view.addSubview(mapView)
        self.mapView.addSubview(locationButton)
        self.view.addSubview(tableView)
        self.view.addSubview(searchBar)
        self.view.addSubview(button)
        
        layoutStaticSubviews()
    }
    
    func layoutStaticSubviews() {
        self.button.snp_makeConstraints { (make) in
            make.centerY.equalTo(self.searchBar)
            make.width.equalTo(60)
            make.left.equalTo(self.searchBar.snp_right).offset(10)
            make.height.equalTo(35)
        }
        
        self.locationButton.snp_makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.bottom.right.equalTo(-20)
        }
    }
    
    @objc func sureButtonClick() {
        if let selectedLocationItem = self.selectedLocationItem {
            locationSelectedCallback?(selectedLocationItem)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func startUploadLocation() {
        self.locationManager.startUpdatingLocation()
    }
    
    var maptItems: [MKMapItem]?
    
    var selectedLocationItem: MKMapItem?
    
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
        view.delegate = self
        
        // 默认天安门
        let span = MKCoordinateSpan.init(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion.init(center: CLLocationCoordinate2D.init(latitude: 39.908722, longitude: 116.397499), span: span)
        view.region = region
        
        return view
    }()
    
    lazy var searchBar: UISearchBar = {
       let view = UISearchBar.init(frame: CGRect.init(x: 20, y: HDStatusBarHeight, width: HDScreenWidth - 110, height: 44))
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

    lazy var button: UIButton = {
        let button = UIButton.init()
        button.backgroundColor = UIColor.init(hex: "#00AE66")
        button.layer.cornerRadius = 4
        button.setTitle("确定", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(sureButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy var locationButton: UIButton = {
        let button = UIButton.init()
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.setImage(#imageLiteral(resourceName: "Location"), for: .normal)
        button.addTarget(self, action: #selector(startUploadLocation), for: .touchUpInside)
        return button
    }()
}
