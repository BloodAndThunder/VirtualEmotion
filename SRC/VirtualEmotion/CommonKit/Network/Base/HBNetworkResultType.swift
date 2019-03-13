//
//  HBNetworkResultType.swift
//  HugeBuilding
//
//  Created by HanDong Wang on 2018/4/11.
//  Copyright © 2018年 HanDong Wang. All rights reserved.
//

import Foundation

protocol HBNetworkResultType: HBNetworkAPI {
    associatedtype DataResultType: Codable
}
