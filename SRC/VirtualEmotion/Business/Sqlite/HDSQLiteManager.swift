//
//  HDSQLiteManager.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/8/20.
//  Copyright © 2019 Chiery. All rights reserved.
//

import UIKit
import FMDB

class HDSQLiteManager: NSObject {

    // 单例,线程安全的
    public static let shared =  HDSQLiteManager.init()
    
    //懒加载FMDatabaseQueue
    fileprivate lazy var dbQueue:FMDatabaseQueue = {
        let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last! as NSString
        let path = documentPath.appendingPathComponent("com.chiery.virtual.sqlite")
        let dbQueue =  FMDatabaseQueue(path: path)
        return dbQueue ?? FMDatabaseQueue.init()
    }()
    
    override init() {
        super.init()
        
        createWorldMapDBTable()
        createVirtualNodeDBTable()
    }
    
    //／MARK:创建表
    open func createWorldMapDBTable(){
        let sql = "CREATE TABLE IF NOT EXISTS WORLDMAPDATABASE ('Id' INTEGER PRIMARY KEY AUTOINCREMENT, 'CreateTime' DATETIME, 'WorldMapHash' INTEGER, 'WorldMapData' BLOB, 'ImageData' BLOB, 'LocationLatitude' DOUBLE, 'LocationLongitude' DOUBLE, 'LocationName' TEXT, 'Description' TEXT)"
        dbQueue.inDatabase { (db) in
            let result = db.executeUpdate(sql, withArgumentsIn: [])
            if result {
                print("创表worldmap成功")
            }else{
                print("创表worldmap失败")
            }
        }
    }
    
    open func createVirtualNodeDBTable(){
        let sql = "CREATE TABLE IF NOT EXISTS VIRTUALNODEDATABASE ('Id' INTEGER PRIMARY KEY AUTOINCREMENT, 'CreateTime' DATETIME, 'WorldMapHash' INTEGER, 'Title' TEXT, 'Subtitle' TEXT, 'ImageData' BLOB, 'VideoData' BLOB, 'AudioData' BLOB, 'Transform' TEXT, 'Type' INTERGE)"
        dbQueue.inDatabase { (db) in
            let result = db.executeUpdate(sql, withArgumentsIn: [])
            if result {
                print("创表virtualNodes成功")
            }else{
                print("创表virtualNodes失败")
            }
        }
    }
    
    //／MARK:插入表数据
    open func insertWorldMapNode(worldMapNode: HDWorldMapNodeModel) {
        let sql = "insert into WORLDMAPDATABASE (CreateTime, WorldMapHash, WorldMapData, ImageData, LocationLatitude, LocationLongitude, LocationName, Description) values(?,?,?,?,?,?,?,?)"
        dbQueue.inDatabase { (db) in
            let args = [currentTime(),
                        worldMapNode.worldMapHash ?? NSNull.init(),
                        worldMapNode.worldMapData ?? NSNull.init(),
                        worldMapNode.imageData ?? NSNull.init(),
                        worldMapNode.locationLatitude ?? NSNull.init(),
                        worldMapNode.locationLongitude ?? NSNull.init(),
                        worldMapNode.locationName ?? NSNull.init(),
                        worldMapNode.title ?? NSNull.init()
                ] as [Any]
            let result = db.executeUpdate(sql, withArgumentsIn: args)
            if result {
                print("插入worldMapNode数据成功")
            }else{
                print("插入worldMapNode数据失败")
            }
        }
    }
    
    open func insertVirtualNode(virtualNode: HDNodeModel) {
        let sql = "insert into VIRTUALNODEDATABASE (CreateTime, WorldMapHash, Title, Subtitle, ImageData, VideoData, AudioData, Transform, Type) values(?,?,?,?,?,?,?,?,?)"
        dbQueue.inDatabase { (db) in
            let args = [currentTime(),
                        virtualNode.worldMapHash ?? NSNull.init(),
                        virtualNode.title ?? NSNull.init(),
                        virtualNode.subtitle ?? NSNull.init(),
                        virtualNode.imageData ?? NSNull.init(),
                        virtualNode.videoData ?? NSNull.init(),
                        virtualNode.audioData ?? NSNull.init(),
                        virtualNode.transform ?? NSNull.init(),
                        virtualNode.type?.rawValue ?? NSNull.init()] as [Any]
            let result = db.executeUpdate(sql, withArgumentsIn: args)
            if result {
                print("插入virtualNode数据成功")
            }else{
                print("插入virtualNode数据失败")
            }
        }
    }
    
    //／MARK:查询表数据
    open func queryVirtualNodesDBTable(completion: @escaping (_ model: [HDNodeModel]? ) -> Void) {
        let sql = "select * from VIRTUALNODEDATABASE order by CreateTime desc"
        dbQueue.inDatabase { (db) in
            guard let resultSet = db.executeQuery(sql, withArgumentsIn: []) else {
                completion(nil)
                return
            }
            
            var virtualModels = [HDNodeModel]()
            
            while resultSet.next() == true {
                let idValue = resultSet.string(forColumn: "Id")
                let createTime = resultSet.string(forColumn: "CreateTime")
                let worldMapHash = resultSet.longLongInt(forColumn: "WorldMapHash")
                let title = resultSet.string(forColumn: "Title")
                let subtitle = resultSet.string(forColumn: "Subtitle")
                let imageData = resultSet.data(forColumn: "ImageData")
                let videoData = resultSet.data(forColumn: "VideoData")
                let audioData = resultSet.data(forColumn: "AudioData")
                let transform = resultSet.string(forColumn: "Transform")
                let type = resultSet.int(forColumn: "Type")

                let model = HDNodeModel.init(id: idValue, title: title, subtitle: subtitle, imageData: imageData, videoData: videoData, audioData: audioData, transform: transform, worldMapHash: worldMapHash, createTime: createTime, type: HDNodeModelType(rawValue: type))
                
                virtualModels.append(model)
            }
            completion(virtualModels)
        }
    }
    
    open func queryAllVirtualNodesWithHashValue(hashValue:Int64, completion: @escaping (_ model: [HDNodeModel]? ) -> Void) {
        let sql = "select * from VIRTUALNODEDATABASE where WorldMapHash = \(hashValue)"
        dbQueue.inDatabase { (db) in
            guard let resultSet = db.executeQuery(sql, withArgumentsIn: []) else {
                completion(nil)
                return
            }
            
            var virtualModels = [HDNodeModel]()
            
            while resultSet.next() == true {
                let idValue = resultSet.string(forColumn: "Id")
                let createTime = resultSet.string(forColumn: "CreateTime")
                let worldMapHash = resultSet.longLongInt(forColumn: "WorldMapHash")
                let title = resultSet.string(forColumn: "Title")
                let subtitle = resultSet.string(forColumn: "Subtitle")
                let imageData = resultSet.data(forColumn: "ImageData")
                let videoData = resultSet.data(forColumn: "VideoData")
                let audioData = resultSet.data(forColumn: "AudioData")
                let transform = resultSet.string(forColumn: "Transform")
                let type = resultSet.int(forColumn: "Type")
                
                let model = HDNodeModel.init(id: idValue, title: title, subtitle: subtitle, imageData: imageData, videoData: videoData, audioData: audioData, transform: transform, worldMapHash: worldMapHash, createTime: createTime, type: HDNodeModelType(rawValue: type))
                
                virtualModels.append(model)
            }
            completion(virtualModels)
        }
    }
    
    open func queryWorldMapData(hashValue:Int64, completion: @escaping(_ data: Data?) -> Void) {
        let sql = "select WorldMapData from WORLDMAPDATABASE where WorldMapHash = \(hashValue)"
        dbQueue.inDatabase { (db) in
            guard let resultSet = db.executeQuery(sql, withArgumentsIn: []) else {
                completion(nil)
                return
            }
            
            var data:Data?
            
            while resultSet.next() == true {
                data = resultSet.data(forColumn: "WorldMapData")
            }
            completion(data)
        }
    }
    
    //／MARK:执行多sql语句
    open func executeStms
        (){
        let sql = "insert into t_stu(name,age) values ('google',21);insert into t_stu(name,age) values ('apple',23);"
        dbQueue.inDatabase { (db) in
            db.executeStatements(sql)
        }
    }
    //／MARK:事务操作
    open func transaction(){
        let sql1 = "insert into t_stu(name,age) values ('google',21)"
        let sql2 = "insert into1 t_stu(name,age) values ('apple',15)"
        dbQueue.inTransaction { (db, rollback) in
            let r1 = db.executeUpdate(sql1, withArgumentsIn: [])
            let r2 = db.executeUpdate(sql2, withArgumentsIn: [])
            if r1  && r2 {
                print("事务操作成功")
            }else{
                print("数据出错,回滚")
                rollback.pointee  = true
            }
        }
    }

    
    ///MARK: 辅助函数
    private func currentTime() -> String {
        return  "\(Int64(NSDate().timeIntervalSince1970 * 1000))"
    }
}
