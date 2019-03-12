//
//  QARAudio.swift
//  TripStickyInScene
//
//  Created by Leon on 2017/6/30.
//  Copyright © 2017年 qunar. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit
import AVFoundation

class QARAudio {
    var sounds:[String:SCNAudioSource] = [:]
    var curSource: SCNAudioSource?
    init(fileName: String, name: String) {
        if let sound = SCNAudioSource(fileNamed: fileName) {
            sound.load()
            curSource = sound
            sounds[name] = sound
        }
    }
    
    func startWith(url: URL) -> SCNAudioPlayer {
        var source =  SCNAudioSource(url: url)
        source?.volume = 1
        source!.isPositional = true
        source!.loops = false
        source!.shouldStream = false
        source?.load()
        curSource = source
        let node = SCNAudioPlayer(source: curSource!)
        return node
    }
    
    static func startWith2D(url: URL?) -> SKAudioNode {
        let audioNode = SKAudioNode(url: url!)
        audioNode.isPositional = true
        return audioNode
    }
    
    func playSound(node: SCNNode, name: String) {
        let sound = sounds[name]
        node.runAction(SCNAction.playAudio(sound!, waitForCompletion: false))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Audio {
    let engine: AVAudioEngine = AVAudioEngine()
    
    func createBuffer(url: URL) -> AVAudioPCMBuffer {
        let audioFile = try! AVAudioFile(forReading: url)
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: UInt32(audioFile.length))
        try! audioFile.read(into: buffer!)
        return (buffer)!
    }
    
    func createPlayer(url: URL?) -> AVAudioPlayerNode {
        
        let player = AVAudioPlayerNode()
        //let audioFile = try! AVAudioFile(forReading: url!)
        //player.scheduleFile(audioFile, at: nil, completionHandler: nil)
        let buffer = self.createBuffer(url: url!)
        player.volume = 1.0
        engine.attach(player)
        engine.connect(player, to: engine.outputNode, format: buffer.format)
        engine.prepare()
        try! engine.start()
        
        return player
    }
    
}
