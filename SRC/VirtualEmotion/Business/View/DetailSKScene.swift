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
    
    init(image: UIImage?, text: String?, voiceUrl: URL?) {
        let size = computeContextSize(image: image)
        
        super.init(size: size)
        
        self.scaleMode = .aspectFit
        self.backgroundColor = UIColor(hex: "#0463A5", alpha: 0.6)
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
        
        if let originalImage = image,
            let cgImage = originalImage.cgImage {
            // 拿到旋转之后的图片
            let imageToDisplay = UIImage.init(cgImage: cgImage, scale: originalImage.scale, orientation: .up)
            let imageTexture = SKTexture(image: imageToDisplay)
            let imageNode = SKSpriteNode(texture: imageTexture)
            
            imageNode.position = CGPoint(x: size.width/2, y: ((size.height - 106) / 2.0 + 96))
            imageNode.zRotation = CGFloat(Float(Double.pi))
            imageNode.scale(to: CGSize(width: size.width - 20, height: size.height - 106))
            imageNode.isUserInteractionEnabled = true
            self.addChild(imageNode)
        }
        
        let labelNode = SKLabelNode(fontNamed: "Chalkduster")
        labelNode.text = text
        labelNode.name = "title"
        labelNode.fontSize = 20
        labelNode.fontColor = UIColor.white
        labelNode.position = CGPoint(x: size.width/2, y: 50)
        labelNode.zRotation = CGFloat(Float(Double.pi))
        labelNode.preferredMaxLayoutWidth = size.width - 20
        labelNode.numberOfLines = 0
        labelNode.isUserInteractionEnabled = true
        
        adjustLabelFontSizeToFitRect(labelNode: labelNode, rect: CGRect.init(x: 10, y: 10, width: size.width - 20, height: 80))
        
        self.addChild(labelNode)
        
        //        if (voiceUrl != nil) {
        //            let voiceNode = SKAudioNode(url: voiceUrl!)
        //            voiceNode.autoplayLooped = true
        //            voiceNode.isUserInteractionEnabled = true
        //            voiceNode.name = "audio"
        //            self.addChild(voiceNode)
        //        }
    }
    
    
    
    func adjustLabelFontSizeToFitRect(labelNode:SKLabelNode, rect:CGRect) {
        
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(rect.width / labelNode.frame.width, rect.height / labelNode.frame.height)
        
        // Change the fontSize.
        labelNode.fontSize *= scalingFactor
        
        // Optionally move the SKLabelNode to the center of the rectangle.
        labelNode.position = CGPoint(x: rect.midX, y: 90 - (rect.midY - labelNode.frame.height / 2.0))
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


private func computeContextSize(image: UIImage?) -> CGSize {
    // 制定画布的大小
    var contextSize = CGSize.init(width: 200, height: 80)
    
    // 如果图片不为空
    if let image = image {
        
        // 取最大边嘴比较
        let delta = Float( image.size.width / image.size.height )
        
        // 图片宽度大于高度
        if delta > 1 {
            
            // 如果图片宽度 + 20 > 800, 用800 做最大宽度
            if image.size.width > 780 {
                contextSize = CGSize.init(width: 800, height: image.size.height * (780.0 / image.size.width) + 20 + 80 + 6)
            }
                // 用 图片宽度加 20 做宽度
            else {
                contextSize = CGSize.init(width: image.size.width + 20, height: image.size.height + 20 + 80 + 6)
            }
            
        }
        else {
            
            // 如果图片宽度 + 20 > 800, 用800 做最大宽度
            if image.size.height > 886 {
                contextSize = CGSize.init(width: image.size.width * (886.0 / image.size.height) + 20, height: 886)
            }
                // 用 图片宽度加 20 做宽度
            else {
                contextSize = CGSize.init(width: image.size.width + 20, height: image.size.height + 20 + 80 + 6)
            }
            
        }
        
    }
    
    return contextSize
}
