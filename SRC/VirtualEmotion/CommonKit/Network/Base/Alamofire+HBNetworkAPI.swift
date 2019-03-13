
//
//  Alamofire+HBNetworkAPI.swift
//  HugeBuilding
//
//  Created by HanDong Wang on 2018/4/11.
//  Copyright © 2018年 HanDong Wang. All rights reserved.
//

import UIKit

import Foundation
import Alamofire

// 统一请求入口
func request<T: HBNetworkResultType>(_ api: T,
                                     _ success: @escaping (HBNetworkResultRootModel<T.DataResultType>) -> Void,
                                     _ failure: @escaping (String) -> Void,
                                     _ uploadProgress: ((Int64, Int64) -> Void)? = nil) {
    
    if !HBNetworkReachabilityManager.shareInstance.currentCanReachable() {
        failure("网络连接错误")
        return
    }
    
    // 分流处理
    switch api.requestType {
    case .json:
        jsonRequest(api, success, failure)
    case .field:
        fieldRequest(api, success, failure)
    case .uploadImage:
        uploadImage(api, success, failure, uploadProgress)
    }
}

// 统一的回调入口
private func response<T: HBNetworkResultType>(_ api: T,
                                              _ responseData: Alamofire.DataResponse<Any>,
                                              _ success: @escaping (HBNetworkResultRootModel<T.DataResultType>) -> Void,
                                              _ failure: @escaping (String) -> Void) {
    
    func errorHandler(requestHeaders:[String:String], error: Error, _ errorString: String, _ requestSuccess: Bool) {
        failure(errorString)
    }
    
    if let error = responseData.error {
        errorHandler(requestHeaders: api.headers, error: error, "请检查你的网络设置", false)
    }
    else if let response = responseData.response {
        let result = handleNetworkResponse(response)
        switch result {
        case .success:
            guard let responseData = responseData.data else {
                let error = NSError.init(domain: "com.chiery.network.error", code: 2006, userInfo: ["message": NetworkResponse.noData.rawValue]);
                errorHandler(requestHeaders: api.headers, error: error, NetworkResponse.noData.rawValue, true)
                return
            }
            do {
                // 解密
                let responseDataDict = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any]
                let decryptDict = HDCrypto.decrypt(responseDataDict);
                let decryptDictData = try JSONSerialization.data(withJSONObject: decryptDict, options: .prettyPrinted)
                
                let apiResponse: HBNetworkResultRootModel<T.DataResultType> = try JSONDecoder().decode(HBNetworkResultRootModel<T.DataResultType>.self, from: decryptDictData)
                
                // 401接口拦截
                if apiResponse.error_code == 401 {
                    // 额外处理
                }
                else {
                    success(apiResponse)
                }
            }catch {
                errorHandler(requestHeaders: api.headers, error: error, NetworkResponse.unableToDecode.rawValue, false)
            }
        case .failure(let networkFailureError):
            let error = NSError.init(domain: "com.chiery.network.error", code: 2006, userInfo: ["message": networkFailureError]);
            errorHandler(requestHeaders: api.headers, error: error, NetworkResponse.unableToDecode.rawValue, false)
        }
    }
    else {
        let error = NSError.init(domain: "com.chiery.network.error", code: 2006, userInfo: ["message": NetworkResponse.unableToDecode.rawValue]);
        errorHandler(requestHeaders: api.headers, error: error, NetworkResponse.unableToDecode.rawValue, false)
    }
    
}

// json 请求
private func jsonRequest<T: HBNetworkResultType>(_ api: T,
                                                 _ success: @escaping (HBNetworkResultRootModel<T.DataResultType>) -> Void,
                                                 _ failure: @escaping (String) -> Void) {
    let params = HDCrypto.encrypt(api.parameters) as? [String: Any]
    AlamofireSingleton.sharedInstance.request(api.url,
                                              method: api.method,
                                              parameters: params,
                                              encoding: api.encoding,
                                              headers: api.headers)
        .validate()
        .validate(contentType: ["application/json"])
        .responseJSON(completionHandler: { (responseData) in
            response(api, responseData, success, failure)
        })
}

// 表单请求
private func fieldRequest<T: HBNetworkResultType>(_ api: T,
                                                  _ success: @escaping (HBNetworkResultRootModel<T.DataResultType>) -> Void,
                                                  _ failure: @escaping (String) -> Void) {
    AlamofireSingleton.sharedInstance.upload(multipartFormData:{ multipartFormData in
        for (key,value) in api.parameters {
            // TODO: 这里写的有问题，value的值不止String一种类型，需要优化
            multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
        }},
                                             usingThreshold:UInt64.init(),
                                             to: api.url,
                                             method:api.method,
                                             headers:api.headers,
                                             encodingCompletion: {
                                                encodingResult in
                                                switch encodingResult {
                                                case .success(let upload, _, _):
                                                    upload.responseJSON(completionHandler: {(responseData) in
                                                        response(api, responseData, success, failure)
                                                    })
                                                case .failure(_):
                                                    failure(NetworkResponse.unableToDecode.rawValue)
                                                }
    })
}

// 上传图片
private func uploadImage<T: HBNetworkResultType>(_ api: T,
                                                 _ success: @escaping (HBNetworkResultRootModel<T.DataResultType>) -> Void,
                                                 _ failure: @escaping (String) -> Void,
                                                 _ uploadProgress: ((Int64, Int64) -> Void)? = nil) {
    AlamofireSingleton.sharedInstance.upload(multipartFormData: { (multipartFormData) in
        // 转换成图片流
        let stream = InputStream.init(data: api.bodyData)
        
        // 图片流的大小
        let streamSize = api.bodyData.count
        
        // 文件名称
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let str = formatter.string(from: Date())
        let fileName = str + ".jpg"
        
        // 加入到表单中去
        multipartFormData.append(stream, withLength: UInt64(streamSize), name: "name", fileName: fileName, mimeType: "image/jpeg")
    },usingThreshold: UInt64.init(),
      to: api.url,
      method: api.method,
      headers: api.headers,
      encodingCompletion: { (encodingResult) in
        switch encodingResult {
        case .success(let upload, _, _):
            upload.uploadProgress(closure: { (progress) in
                uploadProgress?(progress.completedUnitCount, progress.totalUnitCount)
            })
            upload.responseJSON(completionHandler: { (responseData) in
                response(api, responseData, success, failure)
            })
        case .failure(_):
            // 这里也从completionHandler反馈
            failure(NetworkResponse.unableToDecode.rawValue)
        }
    })
}

