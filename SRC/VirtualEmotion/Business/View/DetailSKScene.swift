//
//  DetailView.swift
//  TripStickyInScene
//
//  Created by Leon on 2017/7/9.
//  Copyright © 2017年 qunar. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation
import UIKit

class DetailSKScene: SKScene {
    var audioNode: SKAudioNode?
    
    init(image: UIImage?, text: String?, voiceUrl: URL?, size: CGSize) {
        super.init(size: size)
        self.scaleMode = .aspectFit
        self.backgroundColor = UIColor(hexColor: "#0463A5", alpha: 0.6)
        self.isUserInteractionEnabled = true
        
        let shape = SKShapeNode()
        shape.path = UIBezierPath(roundedRect: CGRect(x:0, y:0, width: size.width, height: size.height), cornerRadius: 10.0).cgPath
        shape.lineWidth = 5.0
        shape.isAntialiased = true
        shape.strokeColor = UIColor(white: 1.0, alpha: 1.0)
        shape.physicsBody = SKPhysicsBody(rectangleOf: size)
        shape.physicsBody?.isDynamic = false
        shape.physicsBody?.allowsRotation = false
        self.addChild(shape)
        
        if (image != nil) {
            let imageTexture = SKTexture(image: image!)
            let imageNode = SKSpriteNode(texture: imageTexture)
            print("image size \(imageNode.frame.size)")
            var width = imageNode.frame.size.width
            var height = imageNode.frame.size.height
            
            if (width/(size.width-20) > height/(size.height-50) ) {
                if (width >= size.width-20){
                    height = height * (size.width-20)/width;
                    width = size.width-20;
                }
            } else {
                if (height >= size.height-50){
                    width = imageNode.frame.size.width * (size.height-50)/height;
                    height = size.height-50
                }
            }
            imageNode.scale(to: CGSize(width: width, height: height))
            imageNode.position = CGPoint(x: size.width/2, y: (size.height/2+25))
            imageNode.zRotation = CGFloat(Float(Double.pi))
            imageNode.isUserInteractionEnabled = true
            self.addChild(imageNode)
        }
        
        let labelNode = SKLabelNode(fontNamed: "Chalkduster")
        labelNode.text = text
        labelNode.name = "title"
        labelNode.fontSize = 20
        labelNode.fontColor = UIColor.white
        print("labelSize \(labelNode.frame.size)")
        labelNode.position = CGPoint(x: size.width/2, y: 40)
        labelNode.zRotation = CGFloat(Float(Double.pi))
        labelNode.isUserInteractionEnabled = true
        self.addChild(labelNode)
        
        //        if (voiceUrl != nil) {
        //            let voiceNode = SKAudioNode(url: voiceUrl!)
        //            voiceNode.autoplayLooped = true
        //            voiceNode.isUserInteractionEnabled = true
        //            voiceNode.name = "audio"
        //            self.addChild(voiceNode)
        //        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch  = touches.first
        touch?.location(in: self)
        if (audioNode != nil ) {
            audioNode?.run(SKAction.play())
        }
    }
    
    override func didMove(to view: SKView) {
        if (audioNode != nil ) {
            audioNode?.run(SKAction.play())
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        
    }
}
