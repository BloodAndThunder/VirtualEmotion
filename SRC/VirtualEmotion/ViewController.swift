//
//  ViewController.swift
//  testARKit
//
//  Created by HanDong Wang on 2019/2/22.
//  Copyright © 2019 HanDong Wang. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加子视图
        addSubviews()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // 调用出debug视觉数据
        sceneView.debugOptions = [.showFeaturePoints]
        
        // 创建一个场景
        let scene = SCNScene.init()
        //        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // 初始化数据
        loadData()
        
        // 加载历史数据
        HDWorldMapIO.shareInstance.read { (worldMap) in
            if let tempWorldMap = worldMap {
                configuration.initialWorldMap = tempWorldMap
                self.worldMapLoadDone = true
            }
            
            // Run the view's session
            DispatchToMain(task: {
                self.sceneView.session.run(configuration)
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // 添加视图
    private func addSubviews() {
        self.view.addSubview(addButton)
        self.view.addSubview(worldMapStatus)
        self.view.addSubview(saveButton)
        self.view.addSubview(saveWorldMapButton)
        self.view.addSubview(radioView)
        self.view.addSubview(editView)
    }
    
    // 初始化数据
    private func loadData() {
        self.worldMapLoadDone = false
        self.virtureNodeLoadDone = false
        DispatchToMain {
            self.sceneView.scene.rootNode.childNodes.forEach { node in
                node.removeFromParentNode()
            }
        }
    }
    
    private func loadVirtureNodes() {
        self.virtureNodeLoadDone = true
        HDNodeDataIO.shareInstance.read { (nodes) in
            if let tempNodes = nodes, tempNodes.count > 0 {
                for node in tempNodes {
                    // 数据回填
                    self.datas.append(node)
                    
                    if let floatTransform = node.transform,
                        let transform = matrixFloatArrayToMatrix4(floatTransform),
                        let type = node.type {
                        switch type {
                        case .text:
                            let voiceUrl = Bundle.main.url(forResource: "background", withExtension: "mp3")!
                            let node = QARText.init(string: node.title ?? "点击编辑文案", depth: 0.1, voiceUrl: voiceUrl)
                            node.transform = transform
                            node.setUniformScale(0.004)
                            self.sceneView.scene.rootNode.addChildNode(node)
                            self.radioView.addNode([node], maxRadius: 10)
                        case .textAndImage:
                            let voiceUrl = Bundle.main.url(forResource: "abc", withExtension: "wav")!
                            let image = UIImage(contentsOfFile: Bundle.main.path(forResource: "lake", ofType: "jpg")!)
                            let node = QARDetailNode(image: image!, text:node.title ?? "点击编辑文案", voiceUrl: voiceUrl, transform: transform)
                            self.sceneView.scene.rootNode.addChildNode(node)
                            self.radioView.addNode([node], maxRadius: 10)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // 实时检测worldMap状态
        listeningWorldMapStatus()
        
        // 实时刷新雷达的位置
        listeningRadio()
    }
    
    @objc func addFunction() {
        // 添加对应的node到当前的世界坐标系中
        
        let rowHeight = 45
        let popoverSize = CGSize(width: 250, height: rowHeight * 3)
        
        let selectView = HDSelectVC(size: popoverSize)
        selectView.delegate = self
        selectView.modalPresentationStyle = .popover
        selectView.popoverPresentationController?.delegate = self
        self.present(selectView, animated: true, completion: nil)
        selectView.popoverPresentationController?.sourceView = addButton
        selectView.popoverPresentationController?.sourceRect = addButton.bounds
    }
    
    private func listeningRadio() {
        DispatchToMain {
            if self.worldMapLoadDone, self.virtureNodeLoadDone {
                self.radioView.updateRotate(self.sceneView.session.currentFrame?.camera)
            }
        }
    }
    
    private func listeningWorldMapStatus() {
        if let mappingStatus = sceneView.session.currentFrame?.worldMappingStatus {
            DispatchToMain {
                switch mappingStatus {
                case .notAvailable:
                    self.worldMapStatus.text = "差"
                    self.worldMapStatus.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                case .limited:
                    self.worldMapStatus.text = "一般"
                    self.worldMapStatus.backgroundColor = UIColor.purple.withAlphaComponent(0.5)
                case .extending:
                    self.worldMapStatus.text = "好"
                    self.worldMapStatus.backgroundColor = UIColor.orange.withAlphaComponent(0.5)
                    if self.worldMapLoadDone, self.virtureNodeLoadDone == false {
                        self.loadVirtureNodes()
                    }
                case .mapped:
                    self.worldMapStatus.text = "完美"
                    self.worldMapStatus.backgroundColor = UIColor.green.withAlphaComponent(0.5)
                    if self.worldMapLoadDone, self.virtureNodeLoadDone == false {
                        self.loadVirtureNodes()
                    }
                }
            }
        }
    }
    
    private func currentCameraMatrix() -> SCNMatrix4? {
        if let camera = sceneView.session.currentFrame?.camera {
            var translation = matrix_identity_float4x4;
            translation.columns.3.z = -0.2;
            
            // 在当前的摄像头的位置添加一个
            let transform = matrix_multiply(camera.transform, translation);
            
            // 这里先拿到camera在世界坐标系中沿着Y轴的旋转角度
            let cameraRotateYByWorldCoordinate = camera.eulerAngles.y
            
            // camera在世界坐标系中的位置
            let cameraPositionInWorldCoordinate = SCNVector3.positionFromTransform(transform)
            
            // 将上述的信息进行组装
            let matrixIdentifier = SCNMatrix4Identity
            
            // 加上旋转角度
            let rotateMatrix = SCNMatrix4Rotate(matrixIdentifier, cameraRotateYByWorldCoordinate, 0, 1, 0)
            
            // 加上移动
            let translateMatrix = SCNMatrix4Translate(rotateMatrix, cameraPositionInWorldCoordinate.x, cameraPositionInWorldCoordinate.y, cameraPositionInWorldCoordinate.z)
            
            // 返回对饮的矩阵
            return translateMatrix
        }
        return nil
    }
    
    @objc func saveLocalData() {
        if let currentNodeData = currentNode,
            let title = currentNodeData.title,
            let subtitle = currentNodeData.subtitle,
            let image = currentNodeData.image,
            let transform = currentNodeData.transform,
            let type = currentNodeData.type {
            HBNetwork.sendNodeInfo.init(title: title, subtitle: subtitle, image: image, transform: transform, type: type).request(success: { (result) in
                HBPrint(result)
                HDToastManager.shareInstance.toast(text: "数据上传成功", delayTime: 2000, location: .middle)
            }, failure: { (errorString) in
                HBPrint(errorString)
                HDToastManager.shareInstance.toast(text: "数据上传失败", delayTime: 2000, location: .middle)
            })
        }
        HDNodeDataIO.shareInstance.save(model: datas)
        saveButton.isHidden = true
    }
    
    @objc func saveWorldMapData() {
        // 获取当前worldMap
        sceneView.session.getCurrentWorldMap(completionHandler: { (worldMap, error) in
            HDWorldMapIO.shareInstance.save(model: worldMap)
        })
    }
    
    // worldMap是否加载成功
    private var worldMapLoadDone: Bool = false
    
    // 虚拟标记是否加载完成
    private var virtureNodeLoadDone: Bool = false
    
    // 这里可以暂时虚拟一个对象，做测试使用
    lazy var tempNode: SCNNode = {
        let node = SCNNode(geometry: SCNBox(width:0.1,height:0.1,length:0.1,chamferRadius: 0))
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        return node;
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: self.view.bounds.width - 80,
                                                      y: self.view.bounds.height - 70,
                                                      width: 60,
                                                      height: 44))
        button.setTitle("保存", for: .normal)
        button.setTitleColor(.purple, for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(saveLocalData), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.isHidden = true
        return button
    }()
    
    lazy var saveWorldMapButton: UIButton = {
        let button = UIButton.init(frame: CGRect.init(x: 20,
                                                      y: self.view.bounds.height - 70,
                                                      width: 80,
                                                      height: 44))
        button.setTitle("保存地图", for: .normal)
        button.setTitleColor(.purple, for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(saveWorldMapData), for: .touchUpInside)
        button.layer.cornerRadius = 4
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.clipsToBounds = true
        return button
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(frame: CGRect(x: self.view.bounds.width - 50,
                                            y: self.view.bounds.height - 70,
                                            width: 44,
                                            height: 44));
        button.center.x = self.view.center.x
        let image = UIImage(named:"Add")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(addFunction), for: .touchUpInside)
        return button
    }()
    
    lazy var worldMapStatus: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: self.view.bounds.width - 80,
                                                    y: HDStatusBarHeight + 120 ,
                                                    width: 60,
                                                    height: 60))
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "无效状态"
        label.textColor = .white
        label.backgroundColor = .white
        label.layer.cornerRadius = 30
        label.textAlignment = .center
        label.numberOfLines = 0
        label.clipsToBounds = true
        return label;
    }()
    
    lazy var wavConverter: iFlyWavConverter = {
        return iFlyWavConverter.init()
    }()
    
    var datas: [HDNodeModel] = [HDNodeModel]()
    var currentNode: HDNodeModel?
    
    lazy var radioView: QARRadioView = {
        let arRadioView = QARRadioView.init(frame: CGRect.init(x: self.view.bounds.width - 110, y: HDStatusBarHeight + 10, width: 90, height: 90))
        return arRadioView
    }()
    
    lazy var editView: HDTextAnImageView = {
        let view = HDTextAnImageView.init(frame: HDScreenFrame)
        return view
    }()
    
    var visibleNode: SCNNode?
    
    private var lastDistance: CGFloat = 0.0
}

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
            let model = HDNodeModel.init(title: "主标题", subtitle:"副标题", image: nil, transform: matrix4ToFloatArray(matrix: transform), type: .text)
            datas.append(model)
            currentNode = model
            radioView.addNode([node], maxRadius: 10)
        }
        else if didSelectAtIndex == 2, let transform = currentCameraMatrix() {
            // 在这里增加一个编辑界面用于用户post content
            
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
        }
    }
    
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension ViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: sceneView)
        // 检查当前哪个节点在当前的视图内，以当前视图的中心为例
        
        let viewCenter = sceneView.center
        visibleNode =  nil
        // 当前视图中，可视化的对象
        if let visibleNode = sceneView.hitTest(viewCenter, options: nil).first?.node {
            // 能找到对应的虚拟节点
            self.visibleNode = visibleNode
        }
        else {
            // 没有获得的话，这里需要置空处理
            self.visibleNode = nil
        }
        
        
        // 触摸事件处理
        let hitResults = sceneView.hitTest(location, options: nil)
        if let result = hitResults.first {
            handleTouchFor(node: result.node)
        } else {
            // 弹出浮层
        }
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
