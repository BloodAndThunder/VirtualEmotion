//
//  HBAlertView.swift
//  HugeBuilding
//
//  Created by HanDong Wang on 2018/5/29.
//  Copyright © 2018年 HanDong Wang. All rights reserved.
//

import UIKit

class HBAlertViewWindow: NSObject {
    
    static let shareInstance = {
       return HBAlertViewWindow.init()
    }()
    
    override init() {
        super.init()
        self.alertWindow.rootViewController = self.rootViewController
    }
    
    lazy var rootViewController: UIViewController = {
        let rootVC = UIViewController.init()
        rootVC.view.backgroundColor = UIColor.clear
        return rootVC
    }()
    
    lazy var alertWindow: UIWindow = {
        let alertWindow = UIWindow.init(frame: UIScreen.main.bounds)
        alertWindow.windowLevel = UIWindow.Level.alert
        alertWindow.backgroundColor = UIColor.clear
        alertWindow.isHidden = false
        return alertWindow
    }()
    
}

class HBAlertView: NSObject {
    
    class func showAlert(title: String,
                         comfirmButton: String,
                         actionHandle: ((_ action: UIAlertAction, _ index: Int) -> ())?) {
        self.showAlert(title: title, message: nil, otherButtons: [(comfirmButton, .default)], style: .alert, actionHandle: actionHandle)
    }
    
    class func showAlert(message: String,
                         comfirmButton: String,
                         actionHandle: ((_ action: UIAlertAction, _ index: Int) -> ())?) {
        self.showAlert(title: nil, message: message, otherButtons: [(comfirmButton, .default)], style: .alert, actionHandle: actionHandle)
    }
    
    class func showAlert(message: String,
                         comfirmButton: String,
                         cancelButton: String,
                         actionHandle: ((_ action: UIAlertAction, _ index: Int) -> ())?) {
        self.showAlert(title: nil, message: message, otherButtons: [(comfirmButton, .default), (cancelButton, .cancel)], style: .alert, actionHandle: actionHandle)
    }
    
    class func showAlert(title:String,
                         message: String,
                         comfirmButton: String,
                         actionHandle: ((_ action: UIAlertAction, _ index: Int) -> ())?) {
        self.showAlert(title: title, message: message, otherButtons: [(comfirmButton, .default)], style: .alert, actionHandle: actionHandle)
    }
    
    class func showAlert(title:String,
                         message: String,
                         cancelButton: String,
                         actionHandle: ((_ action: UIAlertAction, _ index: Int) -> ())?) {
        self.showAlert(title: title, message: message, otherButtons: [(cancelButton, .cancel)], style: .alert, actionHandle: actionHandle)
    }
    
    class func showAlert(title:String,
                         message: String,
                         comfirmButton: String,
                         cancelButton: String,
                         actionHandle: ((_ action: UIAlertAction, _ index: Int) -> ())?) {
        self.showAlert(title: title, message: message, otherButtons: [(comfirmButton, .default), (cancelButton, .cancel)], style: .alert, actionHandle: actionHandle)
    }
    
    class func showAlert(title: String?,
                         message: String?,
                         otherButtons: [(String, UIAlertAction.Style)]?,
                         style: UIAlertController.Style,
                         actionHandle: ((_ action: UIAlertAction, _ index: Int) -> ())? ) {
        
        // 临时标题，为了防止title与message同时为nil，导致程序崩溃
        var tempTitle = title
        if title == nil && message == nil {
            tempTitle = ""
        }
        
        let alertController = UIAlertController.init(title: tempTitle, message: message, preferredStyle: style)
        
        if let buttonTitles = otherButtons {
            for (index, (name, style)) in buttonTitles.enumerated() {
                let action = UIAlertAction.init(title: name, style: style) { (action) in
                    // 隐藏window
                    HBAlertViewWindow.shareInstance.alertWindow.isHidden = true
                    if actionHandle != nil {
                        actionHandle?(action, index)
                    }
                }
                alertController.addAction(action)
            }
        }
        
        DispatchQueue.main.async {
            HBAlertViewWindow.shareInstance.alertWindow.isHidden = false
            HBAlertViewWindow.shareInstance.rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    class func dismissAlert(_ after: TimeInterval, animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+after) {
            HBAlertViewWindow.shareInstance.rootViewController.presentedViewController?.dismiss(animated: animated, completion: {
                HBAlertViewWindow.shareInstance.alertWindow.isHidden = true
            })
        }
    }
}
