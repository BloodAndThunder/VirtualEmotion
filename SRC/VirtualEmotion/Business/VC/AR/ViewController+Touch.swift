//
//  ViewController+Touch.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/8/20.
//  Copyright © 2019 Chiery. All rights reserved.
//
import SceneKit
import ARKit

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: sceneView)
        // 检查当前哪个节点在当前的视图内，以当前视图的中心为例
        
        let viewCenter = sceneView.center
        visibleNode =  nil
        // 当前视图中，可视化的对象，同时需要检测节点的类型
        if let visibleNode = sceneView.hitTest(viewCenter, options: nil).first?.node,
            visibleNode.name == "QARNode" {
            // 能找到对应的虚拟节点
            self.visibleNode = visibleNode
        }
        else {
            // 没有获得的话，这里需要置空处理
            self.visibleNode = nil
        }
        
        
        /*
         // 触摸事件处理
         let hitResults = sceneView.hitTest(location, options: nil)
         if let result = hitResults.first {
         handleTouchFor(node: result.node)
         } else {
         // 弹出浮层
         }
         */
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 判断是否获得了当前的可视node
        guard let visibleNode = self.visibleNode else {
            return;
        }
        
        // 判断是否是两指触摸
        if(touches.count == 2){
            let touchArray = Array.init(touches)
            let p1:CGPoint = touchArray.first!.location(in: self.sceneView)
            let p2:CGPoint = touchArray[1].location(in: self.sceneView)
            
            let xx = p1.x-p2.x
            let yy = p1.y-p2.y
            
            // 勾股定理算出两指之间的距离
            let currentDistance = sqrt(xx*xx+yy*yy)
            
            // 判断是否第一次触摸
            if(self.lastDistance == 0.0){
                self.lastDistance = currentDistance
            }else{
                // 不是第一次触摸，则开始和上次的记录的距离进行判断
                // 假定一个临界值为5，差距比上次小5，视为缩小
                if(self.lastDistance-currentDistance > 5){
                    NSLog("缩小")
                    self.lastDistance = currentDistance
                    // 重新设置UIImageView.transform,通过CGAffineTransformScale实现缩小，这里缩小为原来的0.9倍
                    visibleNode.scale = SCNVector3.init(visibleNode.scale.x * 0.9, visibleNode.scale.y * 0.9, visibleNode.scale.z)
                }else if(self.lastDistance-currentDistance < -5){
                    //差距比上次大5，视为方法
                    NSLog("放大")
                    self.lastDistance = currentDistance
                    // 重新设置UIImageView.transform,通过CGAffineTransformScale实现放大，这里放大为原来的1.1倍
                    visibleNode.scale = SCNVector3.init(visibleNode.scale.x * 1.1, visibleNode.scale.y * 1.1, visibleNode.scale.z)
                }
            }
        }
    }
    
    func handleTouchFor(node: SCNNode) {
        print("touch node: \(node) \(String(describing: node.name))")
        // 增加缩放手势
        
        
        
        //        if node.name == "QARNode" {
        //            print("QARNode Touched")
        //            let tmpNode = node as! QARNode
        //            if ((tmpNode.url ) != nil && !tmpNode.isPlaying!) {
        //                tmpNode.isPlaying = true
        //                tmpNode.scnaudioPlayer?.didFinishPlayback = {
        //                    tmpNode.isPlaying = false
        //                    print("play end")
        //                }
        //            } else {
        //                print("isPlaying")
        //            }
        //        } else if node.name ==  "QARText" {
        //            print("QARText Touched")
        //            let tmpNode = node as! QARText
        //            if ((tmpNode.curVoiceUrl) != nil && !tmpNode.isPlaying!) {
        //                tmpNode.isPlaying = true
        //                tmpNode.scnaudioPlayer?.didFinishPlayback = {
        //                    tmpNode.isPlaying = false
        //                    print("play end")
        //                }
        //            } else {
        //                print("isPlaying")
        //            }
        //        }
    }
}

