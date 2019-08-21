//
//  HDUtilities.swift
//  testARKit
//
//  Created by HanDong Wang on 2019/2/22.
//  Copyright © 2019 HanDong Wang. All rights reserved.
//

import UIKit
import SceneKit

func HBPrint(_ anyItem: Any...) {
    #if DEBUG
    print(anyItem)
    #else
    // 这里就什么也不做了，如果有需要做的可以在这里做些什么,可能在调试的时候你需要将下面的注释打开
    //    print(anyItem)
    #endif
}

/// 主线程安全调度
///
/// - Parameter task: 当前需要执行的任务
public func DispatchToMain(task: (()->())?) {
    if Thread.isMainThread {
        task?()
    }
    else {
        DispatchQueue.main.async {
            task?()
        }
    }
}

extension UIColor {
    convenience init(hex: String, alpha: Float = 1.0) {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            // 不是长度为6的字符，给出红色的字
            self.init(red: 1.0, green: 0, blue: 0, alpha: 1)
        }
        else {
            var rgbValue:UInt32 = 0
            Scanner(string: cString).scanHexInt32(&rgbValue)
            
            self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                      alpha: CGFloat(alpha))
        }
    }
}

extension UIView {
    var x:CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            self.frame.origin.x = newValue
        }
    }
    var y:CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            self.frame.origin.y = newValue
        }
    }
    var height:CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            self.frame.size.height = newValue
        }
    }
    var width:CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            self.frame.size.width = newValue
        }
    }
}

func matrix4ToFloatArray(matrix:SCNMatrix4) -> [Float] {
    var tempValue:[Float] = [Float]()
    tempValue.append(matrix.m11)
    tempValue.append(matrix.m12)
    tempValue.append(matrix.m13)
    tempValue.append(matrix.m14)
    tempValue.append(matrix.m21)
    tempValue.append(matrix.m22)
    tempValue.append(matrix.m23)
    tempValue.append(matrix.m24)
    tempValue.append(matrix.m31)
    tempValue.append(matrix.m32)
    tempValue.append(matrix.m33)
    tempValue.append(matrix.m34)
    tempValue.append(matrix.m41)
    tempValue.append(matrix.m42)
    tempValue.append(matrix.m43)
    tempValue.append(matrix.m44)
    return tempValue
}

func matrixFloatArrayToString(floatArray: [Float]) -> String {
    let stringArray = floatArray.map{ String($0) }
    return stringArray.joined(separator: ",")
}

func matrixStringToFloatArray(matrixString: String) -> [Float] {
    let stringArray = matrixString.split(separator: ",");
    return stringArray.map{ ($0 as NSString).floatValue }
}

func matrix4ToString(matrix: SCNMatrix4) -> String {
    return "\(matrix.m11),\(matrix.m12),\(matrix.m13),\(matrix.m14),\(matrix.m21),\(matrix.m22),\(matrix.m23),\(matrix.m24),\(matrix.m31),\(matrix.m32),\(matrix.m33),\(matrix.m34),\(matrix.m41),\(matrix.m42),\(matrix.m43),\(matrix.m44)"
}

func matrix4StringToObjc(matrixString: String) -> SCNMatrix4? {
    let tempArray = matrixString.split(separator: ",")
    var floats = [Float]()
    if tempArray.count == 16 {
        for value in tempArray {
            let floatValue = (value as NSString).floatValue
            floats.append(floatValue)
        }
        if floats.count == 16 {
            let matrix4 = SCNMatrix4.init(m11: floats[0], m12: floats[1], m13: floats[2], m14: floats[3], m21: floats[4], m22: floats[5], m23: floats[6], m24: floats[7], m31: floats[8], m32: floats[9], m33: floats[10], m34: floats[11], m41: floats[12], m42: floats[13], m43: floats[14], m44: floats[15])
            return matrix4
        }
    }
    return nil
}

func matrixFloatArrayToMatrix4(_ floats:[Float]) -> SCNMatrix4? {
    if floats.count == 16 {
        let matrix4 = SCNMatrix4.init(m11: floats[0], m12: floats[1], m13: floats[2], m14: floats[3], m21: floats[4], m22: floats[5], m23: floats[6], m24: floats[7], m31: floats[8], m32: floats[9], m33: floats[10], m34: floats[11], m41: floats[12], m42: floats[13], m43: floats[14], m44: floats[15])
        return matrix4
    }
    return nil
}

var normalTime:String{
    let formatter = DateFormatter()
    formatter.dateFormat = "MMddHHmmss"
    return formatter.string(from: Date())
}


extension SCNNode {
    
    func setUniformScale(_ scale: Float) {
        self.scale = SCNVector3Make(scale, scale, scale)
    }
    
    func renderOnTop() {
        self.renderingOrder = 2
        if let geom = self.geometry {
            for material in geom.materials {
                material.readsFromDepthBuffer = false
            }
        }
        for child in self.childNodes {
            child.renderOnTop()
        }
    }
}

// MARK: - SCNVector3 extensions

extension SCNVector3 {
    
    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    func friendlyString() -> String {
        return "(\(String(format: "%.2f", x)), \(String(format: "%.2f", y)), \(String(format: "%.2f", z)))"
    }
    
    func dot(_ vec: SCNVector3) -> Float {
        return (self.x * vec.x) + (self.y * vec.y) + (self.z * vec.z)
    }
    
    func cross(_ vec: SCNVector3) -> SCNVector3 {
        return SCNVector3(self.y * vec.z - self.z * vec.y, self.z * vec.x - self.x * vec.z, self.x * vec.y - self.y * vec.x)
    }
    
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    func distanceTo(_ point: SCNVector3) -> Float {
        return (self - point).length()
    }
}

func SCNVector3Uniform(_ value: Float) -> SCNVector3 {
    return SCNVector3Make(value, value, value)
}

func SCNVector3Uniform(_ value: CGFloat) -> SCNVector3 {
    return SCNVector3Make(Float(value), Float(value), Float(value))
}

func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

func += (left: inout SCNVector3, right: SCNVector3) {
    left = left + right
}

func -= (left: inout SCNVector3, right: SCNVector3) {
    left = left - right
}

func / (left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

func * (left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

func /= (left: inout SCNVector3, right: Float) {
    left = left / right
}

func *= (left: inout SCNVector3, right: Float) {
    left = left * right
}

// MARK: - 查找顶层控制器、
// 获取顶层控制器 根据window
func getTopVC(completion: @escaping (_ vc: UIViewController?) -> Void) {
    DispatchToMain {
        var window = UIApplication.shared.keyWindow
        //是否为当前显示的window
        if window?.windowLevel != UIWindow.Level.normal{
            let windows = UIApplication.shared.windows
            for  windowTemp in windows{
                if windowTemp.windowLevel == UIWindow.Level.normal{
                    window = windowTemp
                    break
                }
            }
        }
        
        let vc = window?.rootViewController
        completion(getTopVC(withCurrentVC: vc))
    }
}

//根据控制器获取 顶层控制器
func getTopVC(withCurrentVC VC :UIViewController?) -> UIViewController? {
    
    if VC == nil {
        HBPrint("找不到顶层控制器")
        return nil
    }
    
    if let presentVC = VC?.presentedViewController {
        //modal出来的 控制器
        return getTopVC(withCurrentVC: presentVC)
    }
    else if let tabVC = VC as? UITabBarController {
        // tabBar 的跟控制器
        if let selectVC = tabVC.selectedViewController {
            return getTopVC(withCurrentVC: selectVC)
        }
        return nil
    } else if let naiVC = VC as? UINavigationController {
        // 控制器是 nav
        return getTopVC(withCurrentVC:naiVC.visibleViewController)
    }
    else {
        // 返回顶控制器
        return VC
    }
}

