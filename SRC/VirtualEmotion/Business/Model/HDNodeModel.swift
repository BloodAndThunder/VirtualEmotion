//
//  HDNodeModel.swift
//  testARKit
//
//  Created by HanDong Wang on 2019/2/27.
//  Copyright © 2019 HanDong Wang. All rights reserved.
//

import UIKit

enum HDNodeModelType: Int, Codable {
    case text
    case textAndImage
}

class HDNodeModel: Codable {

    var title: String?
    var image: Data?
    var transform: [Float]?
    var type: HDNodeModelType?

    init(title: String? = "请输入文案", image: Data? = nil, transform: [Float]? = nil, type: HDNodeModelType? = .text) {
        self.title = title
        self.image = image
        self.transform = transform
        self.type = type
    }
}
