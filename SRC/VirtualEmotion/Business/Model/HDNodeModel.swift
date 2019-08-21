//
//  HDNodeModel.swift
//  testARKit
//
//  Created by HanDong Wang on 2019/2/27.
//  Copyright © 2019 HanDong Wang. All rights reserved.
//

import UIKit
import Alamofire

enum HDNodeModelType: Int32, Codable {
    case text
    case textAndImage
}

class HDNodeModel: Codable {

    var id: String?
    var title: String?
    var subtitle: String?
    var imageData: Data?
    var transform: String?
    var type: HDNodeModelType?
    var worldMapHash: Int64?
    var videoData: Data?
    var audioData: Data?
    var createTime: String?

    init(id: String? = nil,
         title: String? = "请输入文案",
         subtitle: String? = nil,
         imageData: Data? = nil,
         videoData: Data? = nil,
         audioData: Data? = nil,
         transform: String? = nil,
         worldMapHash: Int64? = nil,
         createTime: String? = nil,
         type: HDNodeModelType? = .text) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageData = imageData
        self.videoData = videoData
        self.audioData = audioData
        self.transform = transform
        self.type = type
        self.worldMapHash = worldMapHash
        self.createTime = createTime
    }
}

extension HBNetwork {
    struct sendNodeInfo: HBNetworkCustomer {
        typealias DataResultType = String
        
        var path: String = "/node"
        
        let title:String
        let subtitle:String
        let image:String
        let transform:[Float]
        let type: HDNodeModelType

        init(title: String, subtitle: String, image: String, transform: [Float], type: HDNodeModelType) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.transform = transform
            self.type = type
        }
        
        var parameters: Parameters {
            return ["title": title,
                    "subtitle": subtitle,
                    "image": image,
                    "transform": transform,
                    "type": type.rawValue]
        }
        
    }
}
