//
//  HBNetwork.swift
//  HugeBuilding
//
//  Created by HanDong Wang on 2018/4/11.
//  Copyright © 2018年 HanDong Wang. All rights reserved.
//

import Foundation

struct HBNetwork { }

struct HBNetworkResultRootModel<T : Codable>: Codable {
    let error_code: Int64
    let error_msg: String?
    let request_id: Int64?
    let uniq_id: String?
    let server_ip: String?
    let data: T?
}
