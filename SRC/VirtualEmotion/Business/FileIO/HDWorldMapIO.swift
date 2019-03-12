//
//  HDWorldMapIO.swift
//  testARKit
//
//  Created by HanDong Wang on 2019/2/27.
//  Copyright © 2019 HanDong Wang. All rights reserved.
//

import UIKit
import ARKit

class HDWorldMapIO: NSObject {
    
    var savePath: String = (NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last)! + "/worldMapData"
    let fileManage = FileManager.default
    let queue = DispatchQueue(label: "com.chiery.arworldmap", attributes: .concurrent)
    
    static let shareInstance  = HDWorldMapIO()
    
    private override init() {
        super.init()
    }
    
    func save(model: ARWorldMap?) {
        self.queue.async(flags: .barrier) {
            if let model = model, let data = try? NSKeyedArchiver.archivedData(withRootObject: model, requiringSecureCoding: true) {
                let success = self.fileManage.createFile(atPath: self.savePath, contents: data, attributes: nil)
                //假如保存失败，有可能导致草稿箱数据丢失，要重新保存
                if success == false {
                    HDToastManager.shareInstance.toast(text: "存储地图数据失败", delayTime: 2000, location: .middle)
                }
                else {
                    HDToastManager.shareInstance.toast(text: "存储地图数据成功", delayTime: 2000, location: .middle)
                }
            }
        }
    }
    
    func read(completion: @escaping (_ model: ARWorldMap? ) -> Void) {
        // 只有在登录的时候才能取出对应的数据
        self.queue.async(flags: .barrier) {
            if self.fileManage.fileExists(atPath: self.savePath) {
                if let modelData = self.fileManage.contents(atPath: self.savePath),
                    let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: modelData) {
                    HDToastManager.shareInstance.toast(text: "读取地图数据成功", delayTime: 2000, location: .middle)
                    completion(worldMap)
                }
                else {
                    HDToastManager.shareInstance.toast(text: "读取地图数据失败", delayTime: 2000, location: .middle)
                    completion(nil)
                }
            }
            else {
                HDToastManager.shareInstance.toast(text: "读取地图数据失败", delayTime: 2000, location: .middle)
                completion(nil)
            }
        }
    }
}
