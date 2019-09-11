//
//  HDChooseLocationVC+Mapview.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/8/30.
//  Copyright © 2019 Chiery. All rights reserved.
//

import UIKit
import MapKit

extension HDChooseLocationVC: CLLocationManagerDelegate {
    
    func reverseGeocoder(location: CLLocation) {
        
        // 首先使用反地理解码 解析出地址信息
        self.geocoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            if let error = error {
                print("解析出错了", error)
            }
            
            if let mark = placeMarks?.first, mark.name?.count ?? 0 > 0 {
                let request = MKLocalSearch.Request.init()
                request.naturalLanguageQuery = mark.name
                let localSearchRequest = MKLocalSearch.init(request: request)
                localSearchRequest.start { (response, error) in
                    if let error = error {
                        print("解析出错了", error)
                    }
                    
                    self.maptItems = response?.mapItems
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.first {
            mapView.setCenter(wgs84ToGcj02(location: userLocation.coordinate), animated: true)
            
            // 需要拿当前的位置做反地理解码
            reverseGeocoder(location: userLocation)
            
            // 停止定位
            self.locationManager.stopUpdatingLocation()
        }
    }
    
}
