//
//  HDChooseLocationVC+Mapview.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/8/30.
//  Copyright © 2019 Chiery. All rights reserved.
//

import UIKit
import MapKit

extension HDChooseLocationVC: CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    func addAnnotationInMapView() {
        if let selectedLocationItem = selectedLocationItem {
            if mapView.annotations.count > 0 {
                mapView.removeAnnotations(mapView.annotations)
            }
            
            let selectedLocation = MKPointAnnotation()
            selectedLocation.coordinate = selectedLocationItem.placemark.coordinate
            mapView.addAnnotation(selectedLocation)
            
            // 居中处理
            mapView.setCenter(selectedLocationItem.placemark.coordinate, animated: true)
        }
    }
    
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = false
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.view.endEditing(true)
    }
}
