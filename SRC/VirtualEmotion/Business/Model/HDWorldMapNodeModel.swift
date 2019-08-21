//
//  HDWorldMapNodeModel.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/8/20.
//  Copyright © 2019 Chiery. All rights reserved.
//

import UIKit
import ARKit

class HDWorldMapNodeModel: Codable {
    var id: String?
    var title: String?
    var createTime: String?
    var worldMapHash: Int?
    var imageData: Data?
    var virtualCount: Int?
    var worldMapData: Data?
    
    init(id: String? = nil,
         title: String? = "请输入文案",
         createTime: String? = nil,
         virtualCount: Int? = nil,
         imageData: Data? = nil,
         worldMapHash: Int? = nil,
         worldMapData: Data? = nil) {
        self.id = id
        self.title = title
        self.imageData = imageData
        self.createTime = createTime
        self.worldMapHash = worldMapHash
        self.virtualCount = virtualCount
        self.worldMapData = worldMapData
    }
}
