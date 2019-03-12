//
//  QARPlane.swift
//  TripStickyInScene
//
//  Created by Leon on 2017/7/11.
//  Copyright © 2017年 qunar. All rights reserved.
//

import SceneKit
import AVFoundation

class QARNode: SCNNode {
    var source: SCNAudioSource?
    var audioPlayer: AVAudioPlayer?
    var scnaudioPlayer: SCNAudioPlayer?
    var playAction: SCNAction?
    var url: URL? {
        didSet {
            if (url != nil) {
                let tmpSource =  SCNAudioSource(url: url!)
                tmpSource!.isPositional = true
                tmpSource!.loops = false
                //tmpSource!.reverbBlend = 0.5
                tmpSource!.shouldStream = false
                tmpSource?.load()
                source = tmpSource
            }
        }
    }
    
    var avurl: URL? {
        didSet {
            do {
                try audioPlayer = AVAudioPlayer.init(contentsOf: url!)
                audioPlayer?.volume = 1
                audioPlayer?.numberOfLoops = 0
            } catch {
                print("audio player error",error)
            }
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
    
    var isAudioPlaying: Bool? = false {
        didSet {
            if (!isAudioPlaying!) {
                audioPlayer?.play()
            } else {
                audioPlayer?.stop()
            }
        }
    }
    override init() {
        super.init()
        self.name = "QARNode"        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

