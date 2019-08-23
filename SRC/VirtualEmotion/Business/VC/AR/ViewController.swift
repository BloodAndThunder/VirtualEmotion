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

class ViewController: HDBaseVC, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    // 当前进入的类型是录制吗，还是还原
    public var isRecording: Bool = true
    
    // 在还原场景下，需要入口传入地图信息
    public var worldMap: ARWorldMap?
    
    // worldMapHash
    public var worldMapHash: Int64?
    
    // worldMap数据是否存储成功了
    private var worldMapDataSavedDone: Bool = false
    
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
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        if isRecording {
            // 这里什么都不做
        }
        else {
            if let tempWorldMap = worldMap {
                configuration.initialWorldMap = tempWorldMap
                self.worldMapLoadDone = true
            }
        }
        self.sceneView.session.run(configuration)

        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // 添加视图
    private func addSubviews() {
        self.view.addSubview(addButton)
        self.view.addSubview(worldMapStatus)
        self.view.addSubview(saveButton)
        self.view.addSubview(saveWorldMapButton)
        self.view.addSubview(radioView)
        self.view.addSubview(closeButton)
    }
    
    private func loadVirtureNodes() {
        // 从数据库中获取数据
        if let currentWorldMapHashValue = worldMapHash {
            HDSQLiteManager.shared.queryAllVirtualNodesWithHashValue(hashValue: currentWorldMapHashValue) { (models) in
                if let virtualNodes = models, virtualNodes.count > 0 {
                    for node in virtualNodes {
                        if let floatTransform = node.transform,
                            let transform = matrix4StringToObjc(matrixString: floatTransform),
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
                                    let node = QARDetailNode(image: UIImage.init(data: node.imageData ?? Data()), text:node.title, voiceUrl: nil, transform: transform)
                                    self.sceneView.scene.rootNode.addChildNode(node)
                                    self.radioView.addNode([node], maxRadius: 10)
                                }
                        }
                    }
                }
                self.virtureNodeLoadDone = true
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
    
    @objc func closeFunction() {
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
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
                case .mapped:
                    self.worldMapStatus.text = "完美"
                    self.worldMapStatus.backgroundColor = UIColor.green.withAlphaComponent(0.5)
                    
                    // 只有在最好的环境下，才可以添加地图data
                    if self.isRecording, !self.worldMapDataSavedDone {
                        self.saveWorldMapButton.isHidden = false
                    }
                    
                    // 只有在最好的环境下，才去还原场景
                    if !self.isRecording, self.worldMapLoadDone, self.virtureNodeLoadDone == false {
                        self.loadVirtureNodes()
                    }
                }
            }
        }
    }
    
    func currentCameraMatrix() -> SCNMatrix4? {
        if let camera = sceneView.session.currentFrame?.camera {
            var translation = matrix_identity_float4x4;
            translation.columns.3.z = -1;
            
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
//        if let currentNodeData = currentNode,
//            let title = currentNodeData.title,
//            let subtitle = currentNodeData.subtitle,
//            let image = currentNodeData.image,
//            let transform = currentNodeData.transform,
//            let type = currentNodeData.type {
//            HBNetwork.sendNodeInfo.init(title: title, subtitle: subtitle, image: image, transform: transform, type: type).request(success: { (result) in
//                HBPrint(result)
//                HDToastManager.shareInstance.toast(text: "数据上传成功", delayTime: 2000, location: .middle)
//            }, failure: { (errorString) in
//                HBPrint(errorString)
//                HDToastManager.shareInstance.toast(text: "数据上传失败", delayTime: 2000, location: .middle)
//            })
//        }
        
        if let currentNodeData = currentNode {
            // 存储到本地数据库
            HDSQLiteManager.shared.insertVirtualNode(virtualNode: currentNodeData)
        }
        
//        HDNodeDataIO.shareInstance.save(model: datas)
        
        // 无论如何隐藏saveButton
        saveButton.isHidden = true
    }
    
    @objc func saveWorldMapData() {
        // 获取当前worldMap
        sceneView.session.getCurrentWorldMap(completionHandler: {[weak self] (worldMap, error) in
            if let model = worldMap, let data = try? NSKeyedArchiver.archivedData(withRootObject: model, requiringSecureCoding: true) {
                
                // 拿到当前地图数据，组装对应的model
                let worldMapModel = HDWorldMapNodeModel.init(worldMapHash: worldMap.hashValue, worldMapData: data)
                
                // 缓存当前worldMap
                self?.worldMap = model
                
                // 存储到本地数据库
                HDSQLiteManager.shared.insertWorldMapNode(worldMapNode: worldMapModel)
                
                // 更改状态
                self?.worldMapDataSavedDone = true
                
                // 地图数据存储成功，可以添加虚拟坐标，存储本地mapbutton hidden
                self?.addButton.isHidden = false
                self?.saveWorldMapButton.isHidden = true
            }
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
        button.isHidden = true
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
        button.isHidden = true
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 20,
                                            y: 45,
                                            width: 44,
                                            height: 44));
        let image = UIImage(named:"Close")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(closeFunction), for: .touchUpInside)
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
    
    var visibleNode: SCNNode?
    
    var lastDistance: CGFloat = 0.0
}
