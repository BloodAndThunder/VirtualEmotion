//
//  ViewController+SelectItem.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/8/20.
//  Copyright © 2019 Chiery. All rights reserved.
//

extension ViewController: HDSelectViewDelegate {
    func selectView(_ view: HDSelectVC, didSelectAtIndex: Int) {
        
        // 将save按钮显示出来，用于保存数据
        saveButton.isHidden = false
        
        if didSelectAtIndex == 0, let transform = currentCameraMatrix() {
            //  创建文字节点
            let voiceUrl = Bundle.main.url(forResource: "background", withExtension: "mp3")!
            let node = QARText.init(string: "点击编辑文案", depth: 0.1, voiceUrl: voiceUrl)
            node.transform = transform
            node.setUniformScale(0.004)
            sceneView.scene.rootNode.addChildNode(node)
            
            let model = HDNodeModel.init(title: "主标题", subtitle:"副标题", imageData: nil, transform: matrix4ToString(matrix: transform), worldMapHash: Int64(self.worldMap.hashValue), type: .text)
            // 记录当前node
            currentNode = model
//            datas.append(model)
//            currentNode = model
            radioView.addNode([node], maxRadius: 10)
        }
        else if didSelectAtIndex == 2, let transform = currentCameraMatrix() {
            // 在这里增加一个编辑界面用于用户post content
            let editView = HDTextAndImageView.init(frame: HDScreenFrame)
            self.view.addSubview(editView)
            editView.completion = {[weak self] (text, image) in
                let voiceUrl = Bundle.main.url(forResource: "abc", withExtension: "wav")!
                let node = QARDetailNode(image: image, text: text, voiceUrl: voiceUrl, transform: transform)
                self?.sceneView.scene.rootNode.addChildNode(node)
                editView.removeFromSuperview()
                
                // 创建对应的model
                let model = HDNodeModel.init(title: text, imageData: image.jpegData(compressionQuality: 1.0), transform: matrix4ToString(matrix: transform), worldMapHash: Int64(self?.worldMap.hashValue ?? 0), type: .textAndImage)
                // 记录当前node
                self?.currentNode = model
            }
            
            
            
            /*
             // 图文
             let voiceUrl = Bundle.main.url(forResource: "abc", withExtension: "wav")!
             let image = UIImage(contentsOfFile: Bundle.main.path(forResource: "lake", ofType: "jpg")!)
             let node = QARDetailNode(image: image!, text: "点击编辑文案", voiceUrl: voiceUrl, transform: transform)
             let model = HDNodeModel.init(title: "主标题", subtitle:"副标题", image: "http://d.hiphotos.baidu.com/image/pic/item/e61190ef76c6a7ef7d58560df3faaf51f3de669b.jpg", transform: matrix4ToFloatArray(matrix: transform), type: .textAndImage)
             
             datas.append(model)
             currentNode = model
             
             sceneView.scene.rootNode.addChildNode(node)
             radioView.addNode([node], maxRadius: 10)
             
             //            wavConverter.getPathText(toSpeech: "chiery到此一游", completionHandler: {
             //                path in print("path  \(path!)")
             //                let tmpNode = SCNNode()
             //                tmpNode.transform = transform
             //                let audio = QARAudio(fileName: "", name: "")
             //                let audioNode = audio.startWith(url: URL.init(string: path!)!)
             //                tmpNode.addAudioPlayer(audioNode)
             //                node.addChildNode(tmpNode)
             //                tmpNode.runAction(SCNAction.playAudio(audio.curSource!, waitForCompletion: true))
             //            })
             */
        }
    }
    
}
