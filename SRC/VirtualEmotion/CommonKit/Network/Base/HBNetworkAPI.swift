//
//  HBNetworkAPI.swift
//  HugeBuilding
//
//  Created by HanDong Wang on 2018/4/11.
//  Copyright © 2018年 HanDong Wang. All rights reserved.
//

import Foundation
import Alamofire

public enum HBRequestType : String {
    case json
    case field
    case uploadImage
}

protocol HBNetworkAPI {
    var baseURL: String { get }
    var path: String { get }
    var url: String { get }
    var method: HTTPMethod { get }
    var requestType: HBRequestType { get }
    var bodyData: Data { get }
    var parameters: Parameters { get }
    var encoding: ParameterEncoding { get }
    var headers: [String : String] { get }
}

extension HBNetworkAPI {
    var url: String { return baseURL + path }
    var parameters: Parameters { return Parameters() }
    var encoding: ParameterEncoding { return JSONEncoding() }
    var bodyData: Data { return Data() }
    var method: HTTPMethod { return .post }
    var requestType: HBRequestType { return .json }
    var headers: [String : String] { return [:] }
}
