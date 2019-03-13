//
//  HBNetworkCustomer.swift
//  HugeBuilding
//
//  Created by HanDong Wang on 2018/4/11.
//  Copyright © 2018年 HanDong Wang. All rights reserved.
//

import Foundation
import Alamofire

// 当前网络的地址
// swift server 路径
// let localServerBaseUrl = "http://0.0.0.0:8181"
// 李晓晨 提供的路径

#if DEBUG

let localServerBaseUrl = "http://127.0.0.1:5000/api"
#else
let localServerBaseUrl = "http://39.96.219.235/api"
#endif


protocol HBNetworkCustomer: HBNetworkResultType {
    
}

extension HBNetworkCustomer {
    var baseURL: String {
        return localServerBaseUrl
    }
    // 基本上保持不变就可以了，增加token标签，在token存在的时候会主动追加
    var headers: [String : String] {
        var tempHaders = ["Accept": "application/json"]
        return tempHaders
    }
}
