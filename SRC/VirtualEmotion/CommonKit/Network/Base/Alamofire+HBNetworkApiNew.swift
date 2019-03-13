//
//  Alamofire+HBNetworkApiNew.swift
//  HugeBuilding
//
//  Created by HanDong Wang on 2018/9/26.
//

import UIKit
import Foundation
import Alamofire

enum NetworkResponse:String {
    case success
    case authenticationError = "网络没有授权"
    case badRequest = "请求无效"
    case outdated = "请求过期"
    case failed = "网络请求失败"
    case noData = "网络返回为空"
    case unableToDecode = "解析数据出错"
    case cancelRequest = "请求取消"
}

func handleNetworkResponse(_ response: HTTPURLResponse) -> ResponseResult<String>{
    switch response.statusCode {
    case 200...299: return .success
    case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
    case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
    case 600: return .failure(NetworkResponse.outdated.rawValue)
    default: return .failure(NetworkResponse.failed.rawValue)
    }
}

enum ResponseResult<String>{
    case success
    case failure(String)
}

// 新结构封装，之后的请求方式尽量按照这种方式进行， 之前的请求也会做相应的修改
func request<T: HBNetworkResultType>(_ api: T, _ success: @escaping ((HBNetworkResultRootModel<T.DataResultType>) -> Void), _ failure: @escaping ((String) -> Void)) {
    // 这里采用HttpBody的方式上传数据
    
    // 这里需要组装request
    if let url = URL.init(string: api.url) {
        let request = NSMutableURLRequest.init(url: url)
        
        // 设置header
        request.allHTTPHeaderFields = api.headers
        
        // 设置请求方式
        request.httpMethod = api.method.rawValue
        
        // 设置请求体
        request.httpBody = api.bodyData
        
        
        AlamofireSingleton.sharedInstance.request(request as! URLRequestConvertible).responseJSON { (responseData) in
            if responseData.error != nil {
                failure("Please check your network connection.")
            }
            
            if let response = responseData.response {
                let result = handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = responseData.data else {
                        failure(NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        HBPrint(responseData)
                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                        HBPrint(jsonData)
                        let apiResponse = try JSONDecoder().decode(HBNetworkResultRootModel<T.DataResultType>.self, from: responseData)
                        success(apiResponse)
                    }catch {
                        HBPrint(error)
                        failure(NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let networkFailureError):
                    failure(networkFailureError)
                }
            }
        }
    }
    else {
        failure("url init failed")
    }
    
}
