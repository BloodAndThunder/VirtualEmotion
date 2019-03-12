//
//  HDNodeDataIO.swift
//  testARKit
//
//  Created by HanDong Wang on 2019/2/27.
//  Copyright © 2019 HanDong Wang. All rights reserved.
//

import UIKit

class HDNodeDataIO: NSObject {
    
    var savePath: String = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last)! + "/virtureNodeData"
    let fileManage = FileManager.default
    let queue = DispatchQueue(label: "com.chiery.virtureNode", attributes: .concurrent)
    
    static let shareInstance  = HDNodeDataIO()
    
    private override init() {
        super.init()
    }
    
    func save(model: [HDNodeModel]?) {
        self.queue.async(flags: .barrier) {
            if let model = model {
                let jsonEncoder = JSONEncoder()
                if let jsonData = try? jsonEncoder.encode(model) {
                    let success = self.fileManage.createFile(atPath: self.savePath, contents: jsonData, attributes: nil)
                    //假如保存失败，有可能导致草稿箱数据丢失，要重新保存
                    if success == false {
                        HDToastManager.shareInstance.toast(text: "存储虚拟标签数据失败", delayTime: 2000, location: .middle)
                    }
                    else {
                        HDToastManager.shareInstance.toast(text: "存储虚拟标签数据成功", delayTime: 2000, location: .middle)
                    }
                }
            }
        }
    }
    
    func read(completion: @escaping (_ model: [HDNodeModel]? ) -> Void) {
        // 只有在登录的时候才能取出对应的数据
        self.queue.async(flags: .barrier) {
            if self.fileManage.fileExists(atPath: self.savePath) {
                if let modelData = self.fileManage.contents(atPath: self.savePath),
                    let jsonData = try? JSONDecoder().decode([HDNodeModel].self, from: modelData) {
                    HDToastManager.shareInstance.toast(text: "读取虚拟标签数据成功", delayTime: 2000, location: .middle)
                    completion(jsonData)
                }
                else {
                    HDToastManager.shareInstance.toast(text: "读取虚拟标签数据失败", delayTime: 2000, location: .middle)
                    completion(nil)
                }
            }
            else {
                HDToastManager.shareInstance.toast(text: "读取虚拟标签数据失败", delayTime: 2000, location: .middle)
                completion(nil)
            }
        }
    }
}
