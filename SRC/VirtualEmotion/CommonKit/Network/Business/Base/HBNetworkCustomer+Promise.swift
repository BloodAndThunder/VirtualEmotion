//
//  HBNetworkCustomer+Promise.swift
//  HugeBuilding
//
//  Created by HanDong Wang on 2018/4/11.
//  Copyright © 2018年 HanDong Wang. All rights reserved.
//

import Foundation
import Alamofire

extension HBNetworkCustomer {
    
    func request(success: @escaping (HBNetworkResultRootModel<DataResultType>) -> Void,
                 failure: @escaping (String) -> Void,
                 uploadProgress: ((Int64, Int64) -> Void)? = nil) {
        VirtualEmotion.request(self, success, failure, uploadProgress)
    }

}
