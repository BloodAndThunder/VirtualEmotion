//
//  QARText.swift
//  TripStickyInScene
//
//  Created by Leon on 2017/6/30.
//  Copyright © 2017年 qunar. All rights reserved.
//
// 文字
import Foundation
import SceneKit
import SpriteKit

class QARText: SCNNode {
    var backView: UIView?
    var source: SCNAudioSource?
    var scnaudioPlayer: SCNAudioPlayer?
    var playAction: SCNAction?

    var curVoiceUrl: URL? {
        didSet {
            let tmpSource =  SCNAudioSource(url: curVoiceUrl!)
            tmpSource!.isPositional = true
            tmpSource!.loops = false
            tmpSource!.shouldStream = false
            tmpSource?.load()
            source = tmpSource
        }
    }
    var isPlaying: Bool? = false {
        didSet {
            print("isPlaying \(String(describing: isPlaying))")
            if isPlaying == true {
                let player = SCNAudioPlayer(source: source!)
                self.addAudioPlayer(player)
                scnaudioPlayer = player
                playAction = SCNAction.playAudio(source!, waitForCompletion: true)
                self.runAction(playAction!, forKey: "playAudio")
            } else {
                //playAction?.reversed()
                //playAction?.duration = 0.0
                //self.runAction(SCNAction.playAudio(source!, waitForCompletion: false), forKey: "playAudio")
                //self.removeAudioPlayer(scnaudioPlayer!)
                //self.removeAllActions()
            }
        }
    }

    init (string: String, depth: CGFloat, voiceUrl: URL? ) {
        super.init()
        let text = SCNText.init(string: string, extrusionDepth: depth)
        text.font = UIFont.systemFont(ofSize: 16)
        text.isWrapped = true
        text.containerFrame = CGRect.init(x: 0, y: 0, width: 300, height: 200)
        text.alignmentMode = CATextLayerAlignmentMode.natural.rawValue
        text.truncationMode = CATextLayerTruncationMode.end.rawValue
        
        text.flatness = 0.5
        text.chamferRadius = 0.3
        text.firstMaterial?.shininess = 0.4
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.firstMaterial?.specular.contents = UIColor.orange
        self.name = "QARText"
//        self.geometry = text
        self.curVoiceUrl = voiceUrl
    
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 280, height: 200))
        view.backgroundColor = UIColor(hexColor: "#0463A5", alpha: 0.5)
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 0.5

        let leftLinePath = UIBezierPath()
        leftLinePath.move(to: CGPoint(x: 10, y: 0))
        leftLinePath.addLine(to: CGPoint(x: 0, y: 0))
        leftLinePath.addLine(to: CGPoint(x: 0, y: 10))
        leftLinePath.close()

        let rightLinePath = UIBezierPath()
        rightLinePath.move(to: CGPoint(x: 290, y: 200))
        rightLinePath.addLine(to: CGPoint(x: 300, y: 200))
        rightLinePath.addLine(to: CGPoint(x: 300, y: 190))
        rightLinePath.close()

        let leftShapeLayer = CAShapeLayer()
        leftShapeLayer.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        leftShapeLayer.path = leftLinePath.cgPath
        leftShapeLayer.fillColor = UIColor.white.cgColor
        view.layer.addSublayer(leftShapeLayer)

        let rightShapeLayer = CAShapeLayer()
        rightShapeLayer.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        rightShapeLayer.path = rightLinePath.cgPath
        rightShapeLayer.fillColor = UIColor.white.cgColor
        view.layer.addSublayer(rightShapeLayer)
        
        let line = UIBezierPath()
        line.move(to: CGPoint(x: 0, y: 200))
        line.addLine(to: CGPoint(x: 0, y: 210))
        
        let lineLayer = CAShapeLayer()
        lineLayer.frame = CGRect(x: 0, y: 200, width: 1, height: 10)
        lineLayer.path = line.cgPath
        lineLayer.fillColor = UIColor.red.cgColor
        view.layer.addSublayer(lineLayer)
        
        //let tmpView = QInfoView(rect: CGRect(x: 0, y: 0, width: 300, height: 200))
        //        let blurEffect = UIBlurEffect(style: .light)
        //        let blurView = UIVisualEffectView(effect: blurEffect)
        //        blurView.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        //        view.addSubview(blurView)

        backView = view
        
        //        let skScene = SKScene(size: CGSize(width: 300, height:200))
        //        if let effectNode = skScene.childNode(withName: "EffectNode") as? SKEffectNode {
        //            let  blur = CIFilter(name:"CIGaussianBlur",withInputParameters: ["inputRadius": 10.0]);
        //            effectNode.filter = blur;
        //            effectNode.shouldRasterize = true;
        //            effectNode.shouldEnableEffects = true;
        //        }
        
        let plane = SCNPlane(width: 300, height: 210)
        plane.firstMaterial?.ambient.contents = backView?.layer
        plane.firstMaterial?.emission.contents = backView?.layer
        plane.firstMaterial?.diffuse.contents = backView?.layer
        plane.firstMaterial?.isDoubleSided = true
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(0, 0, 0)
        self.addChildNode(planeNode)
        
        let textNode = SCNNode.init(geometry: text)
        textNode.position = SCNVector3Make(-150, -105, 0)
        self.addChildNode(textNode)

        let  blur = CIFilter(name: "CIGaussianBlur")
        blur?.setValue(10.0, forKey: "inputRadius")
        // planeNode.filters = [blur!, blur!]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
