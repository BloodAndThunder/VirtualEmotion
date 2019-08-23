//
//  QARDetailNode.swift
//  TripStickyInScene
//
//  Created by Leon on 2017/7/12.
//  Copyright © 2017年 qunar. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class QARDetailNode: QARNode {
    override init() {
        super.init()
    }
    init(image: UIImage?, text: String?, voiceUrl: URL?, transform: SCNMatrix4 ) {
        super.init()
        //self.opacity = 0.0
        let detailSKNode = DetailSKScene.init(image: image, text: text, voiceUrl: voiceUrl)
        let plane = SCNPlane(width:1, height: 1)
        plane.firstMaterial?.diffuse.contents = detailSKNode
        plane.firstMaterial?.isDoubleSided = true
        //plane.firstMaterial?.cullMode = .back
        plane.firstMaterial?.normal.intensity = 1.0
        
        let detailNode = QARNode()
        detailNode.geometry = plane
        detailNode.url = voiceUrl
        // 旋转2d scene
        let matrixIdentifier = SCNMatrix4Identity
        let rotate = SCNMatrix4Rotate(matrixIdentifier, Float(Double.pi), 0.0, 1.0, 0.0)
        detailNode.transform = rotate
//        self.scale = SCNVector3Make(0.1, 0.1, 0.1)
        self.transform = transform
        self.addChildNode(detailNode)
        
        /** //skView
         let skView = SKView(frame: CGRect(x: 10, y: 10, width: 200, height: 200))
         skView.presentScene(detailSKNode)
         self.view.addSubview(skView)
         **/
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
