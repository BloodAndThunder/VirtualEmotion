//
//  Alamofire+Reachability.swift
//  HugeBuilding
//
//  Created by HanDong Wang on 2018/8/14.
//  Copyright © 2018年 HanDong Wang. All rights reserved.
//

import UIKit
import Alamofire

class HBNetworkReachabilityManager: NSObject {

    static let shareInstance = {
       return HBNetworkReachabilityManager.init()
    }()
    
    override init() {
        super.init()
    }
    
    open func currentCanReachable() -> Bool {
        if let netReacableManager = self.netReachabilityManager, netReacableManager.isReachable {
            switch netReacableManager.networkReachabilityStatus {
                case .unknown, .notReachable :
                    HDToastManager.shareInstance.toast(text: "当前网络状态不稳定", delayTime: 2000, location: .top)
                    break
                default:
                    HBPrint("这里什么都不做")
                    break
            }
            return true
        }
        else {
            HBAlertView.showAlert(title: "网络连接失败", message: "检测到网络权限可能未开启，您可以在“设置”中检查网络相关设置", comfirmButton: "设置", cancelButton: "取消") { (action, actionIndex) in
                if actionIndex == 0 {
                    if let url = URL.init(string: UIApplication.openSettingsURLString) {
                        DispatchQueue.main.async {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
                else if actionIndex == 1 {
                    // 这里什么都不做
                }
            }
            return false
        }
    }
    
    
    lazy var netReachabilityManager : NetworkReachabilityManager? = {
       return NetworkReachabilityManager.init()
    }()
    
}
