//
//  HDNodeModel.swift
//  testARKit
//
//  Created by HanDong Wang on 2019/2/27.
//  Copyright © 2019 HanDong Wang. All rights reserved.
//

import UIKit
import Alamofire

enum HDNodeModelType: Int, Codable {
    case text
    case textAndImage
}

class HDNodeModel: Codable {

    var id: String?
    var title: String?
    var subtitle: String?
    var image: String?
    var transform: [Float]?
    var type: HDNodeModelType?

    init(id: String? = nil,
         title: String? = "请输入文案",
         subtitle: String? = nil,
         image: String? = nil,
         transform: [Float]? = nil,
         type: HDNodeModelType? = .text) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.transform = transform
        self.type = type
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
