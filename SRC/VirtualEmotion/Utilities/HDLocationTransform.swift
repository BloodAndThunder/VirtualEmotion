//
//  HDLocationTransform.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/9/11.
//  Copyright © 2019 Chiery. All rights reserved.
//

import UIKit
import CoreLocation

func LAT_OFFSET_0(x: Double,y: Double) -> Double { return (-100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))) }
func LAT_OFFSET_1(x: Double) -> Double { return (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0 }
func LAT_OFFSET_2(y: Double) -> Double { return (20.0 * sin(y * Double.pi) + 40.0 * sin(y / 3.0 * Double.pi)) * 2.0 / 3.0 }
func LAT_OFFSET_3(y: Double) -> Double { return (160.0 * sin(y / 12.0 * Double.pi) + 320 * sin(y * Double.pi / 30.0)) * 2.0 / 3.0 }

func LON_OFFSET_0(x :Double, y: Double) -> Double { return 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x)) }
func LON_OFFSET_1(x: Double) -> Double { return (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0 }
func LON_OFFSET_2(x: Double) -> Double { return (20.0 * sin(x * Double.pi) + 40.0 * sin(x / 3.0 * Double.pi)) * 2.0 / 3.0 }
func LON_OFFSET_3(x: Double) -> Double { return (150.0 * sin(x / 12.0 * Double.pi) + 300.0 * sin(x / 30.0 * Double.pi)) * 2.0 / 3.0 }

let RANGE_LON_MAX = 137.8347
let RANGE_LON_MIN = 72.004
let RANGE_LAT_MAX = 55.8271
let RANGE_LAT_MIN = 0.8293
// jzA = 6378245.0, 1/f = 298.3
// b = a * (1 - f)
// ee = (a^2 - b^2) / a^2;
let jzA = 6378245.0
let jzEE = 0.00669342162296594323


func transformLat(x :Double, y:Double) -> Double
{
    var ret = LAT_OFFSET_0(x: x, y: y);
    ret += LAT_OFFSET_1(x: x);
    ret += LAT_OFFSET_2(y: y);
    ret += LAT_OFFSET_3(y: y);
    return ret;
}

func transformLon(x: Double, y:Double) -> Double
{
    var ret = LON_OFFSET_0(x: x, y: y);
    ret += LON_OFFSET_1(x: x);
    ret += LON_OFFSET_2(x: x);
    ret += LON_OFFSET_3(x: x);
    return ret;
}
    
func outOfChina(lat: Double, lon:Double) -> Bool
{
    if (lon < RANGE_LON_MIN || lon > RANGE_LON_MAX) {
        return true;
    }
    if (lat < RANGE_LAT_MIN || lat > RANGE_LAT_MAX) {
        return true;
    }
    return false;
}

func gcj02Encrypt(ggLat: Double, ggLon:Double) -> CLLocationCoordinate2D
{
    var mgLat: Double
    var mgLon: Double
    if (outOfChina(lat: ggLat, lon: ggLon)) {
        return CLLocationCoordinate2D.init(latitude: ggLat, longitude: ggLon);
    }
    var dLat = transformLat(x: ggLon - 105.0, y: ggLat - 35.0);
    var dLon = transformLon(x: ggLon - 105.0, y: ggLat - 35.0);
    let radLat = ggLat / 180.0 * Double.pi;
    var magic = sin(radLat);
    magic = 1 - jzEE * magic * magic;
    let sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((jzA * (1 - jzEE)) / (magic * sqrtMagic) * Double.pi);
    dLon = (dLon * 180.0) / (jzA / sqrtMagic * cos(radLat) * Double.pi);
    mgLat = ggLat + dLat;
    mgLon = ggLon + dLon;
    
    return CLLocationCoordinate2D.init(latitude: mgLat, longitude: mgLon);

}
    
func gcj02Decrypt(gjLat: Double, gjLon: Double) -> CLLocationCoordinate2D {
    let gPt = gcj02Encrypt(ggLat: gjLat, ggLon: gjLon);
    let dLon = gPt.longitude - gjLon;
    let dLat = gPt.latitude - gjLat;
    return CLLocationCoordinate2D.init(latitude: gjLat - dLat, longitude: gjLon - dLon);
}
        
func bd09Decrypt(bdLat: Double, bdLon: Double) -> CLLocationCoordinate2D
{
    let x = bdLon - 0.0065, y = bdLat - 0.006;
    let z = sqrt(x * x + y * y) - 0.00002 * sin(y * Double.pi);
    let theta = atan2(y, x) - 0.000003 * cos(x * Double.pi);
    return CLLocationCoordinate2D.init(latitude: z * cos(theta), longitude: z * sin(theta));

}

func bd09Encrypt(ggLat: Double, ggLon: Double) -> CLLocationCoordinate2D
{
    let x = ggLon, y = ggLat;
    let z = sqrt(x * x + y * y) + 0.00002 * sin(y * Double.pi);
    let theta = atan2(y, x) + 0.000003 * cos(x * Double.pi);
    return CLLocationCoordinate2D.init(latitude: z * cos(theta) + 0.0065, longitude: z * sin(theta) + 0.006);
}
    
    
func wgs84ToGcj02(location :CLLocationCoordinate2D) -> CLLocationCoordinate2D
{
    return gcj02Encrypt(ggLat: location.latitude, ggLon: location.longitude);
}
    
func gcj02ToWgs84(location: CLLocationCoordinate2D) -> CLLocationCoordinate2D
{
    return gcj02Decrypt(gjLat: location.latitude, gjLon: location.longitude);
}
    
    
func wgs84ToBd09(location: CLLocationCoordinate2D) -> CLLocationCoordinate2D
{
    let gcj02Pt = gcj02Encrypt(ggLat: location.latitude, ggLon: location.longitude);
    return bd09Encrypt(ggLat: gcj02Pt.latitude, ggLon: gcj02Pt.longitude);
}
    
func gcj02ToBd09(location :CLLocationCoordinate2D) -> CLLocationCoordinate2D
{
    return bd09Encrypt(ggLat: location.latitude, ggLon: location.longitude);
}
    
func bd09ToGcj02(location: CLLocationCoordinate2D) -> CLLocationCoordinate2D
{
    return bd09Decrypt(bdLat: location.latitude, bdLon: location.longitude);
}
    
func bd09ToWgs84(location: CLLocationCoordinate2D) -> CLLocationCoordinate2D
{
    let gcj02 = bd09ToGcj02(location: location);
    return gcj02Decrypt(gjLat: gcj02.latitude, gjLon: gcj02.longitude);
}

