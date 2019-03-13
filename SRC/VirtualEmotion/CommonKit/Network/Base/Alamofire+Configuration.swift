//
//  Alamofire+Configuration.swift
//  HugeBuilding
//
//  Created by HanDong Wang on 2018/4/11.
//  Copyright © 2018年 HanDong Wang. All rights reserved.
//

import Foundation
import Alamofire

let HBCancelCurrentNetworkTaskKey = "HBCancelCurrentNetworkTaskKey"
class AlamofireSingleton{
    static let sharedInstance: SessionManager = {
        let configuration = URLSessionConfiguration.default
        var cookies = HTTPCookieStorage.shared
        configuration.httpCookieStorage = cookies
        configuration.timeoutIntervalForResource = 10
        configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        let sessionManager: SessionManager = Alamofire.SessionManager(configuration: configuration)
                
        // 验证HTTPS
        sessionManager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = sessionManager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
        return sessionManager
    }()
    
    class func cancelCurrentRequest(urls: [String]?) {
        if let cancelUrls = urls, cancelUrls.count > 0 {
            AlamofireSingleton.sharedInstance.session.getAllTasks { tasks in
                if tasks.count > 0 {
                    tasks.forEach({ (task) in
                        if let request = task.currentRequest, let urlString = request.url?.absoluteString, urlString.count > 0 {
                            cancelUrls.forEach({ (currentUrlString) in
                                if currentUrlString.count > 0, urlString.contains(currentUrlString) {
                                    task.cancel()
                                    
                                    // 拿到系统时间
                                    let currentTime = AlamofireSingleton.getTimeMillis()
                                    
                                    var action:[String:String] = [String:String]()
                                    action["currentTime"] = "\(currentTime)"
                                    action["url"]        = urlString
                                    action["reason"]     = NetworkResponse.cancelRequest.rawValue
                                }
                            })
                        }
                    })
                }
            }
        }
    }
    // 拿到当前系统时间 毫秒单位
    fileprivate class func getTimeMillis() -> Int64 {
        var darwinTime : timeval = timeval(tv_sec: 0, tv_usec: 0)
        gettimeofday(&darwinTime, nil)
        return (Int64(darwinTime.tv_sec) * 1000) + Int64(darwinTime.tv_usec / 1000)
    }
    
    class func cancelAllRequest() {
        AlamofireSingleton.sharedInstance.session.getAllTasks { (tasks) in
            tasks.forEach{ $0.cancel() }
        }
    }
}
