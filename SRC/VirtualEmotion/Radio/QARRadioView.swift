//
//  QARRadioView.swift
//  TripStickyInScene
//
//  Created by chiery on 2017/7/11.
//  Copyright © 2017年 qunar. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class QARRadioView: UIView {
    
    lazy var pointsLocationArray:[UIView] = {
        return [UIView]()
    }()
    
    lazy var currentNodes:[SCNNode] = {
        return [SCNNode]()
    }()
    
    var maxRadiusStatic: CGFloat = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSelf()
        addBackgroundLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clear
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.addSublayer(self.shapeLayer1!)
        self.layer.addSublayer(self.shapeLayer2!)
        self.layer.addSublayer(self.shapeLayer3!)
        self.addSubview(self.pointsView!)
        self.addSubview(self.fanView!)
        self.fanView?.layer.addSublayer(self.fanShapeLayer!)
        self.configFanShaperLayer()
    }
    
    func updateRotate(_ camera: ARCamera?) {
        if let camera = camera {
            DispatchQueue.main.async {
                self.fanView?.layer.transform = CATransform3DMakeRotation(CGFloat(camera.eulerAngles.y), 0, 0, 1.0)
                self.updateNodesLocation(camera)
            }
        }
    }
    
    func updateNodesLocation(_ camera: ARCamera?) {
        if let camera = camera {
            if currentNodes.count > 0 && pointsLocationArray.count > 0 {
                if let points = pointsWithDatas(currentNodes, maxRadius: maxRadiusStatic, camera: camera) {
                    if points.count == pointsLocationArray.count {
                        for index in 0 ..< (points.count) {
                            let point = points[index]
                            let view = pointsLocationArray[index]
                            view.center = point
                        }
                    }
                }
            }
        }
    }
    
    func initSelf() {
        self.shapeLayer1 = generateShapeLayer()
        self.shapeLayer2 = generateShapeLayer()
        self.shapeLayer3 = generateShapeLayer()
        self.fanShapeLayer = generateFanShapeLayer()
        
        self.fanView = generateView()
        self.pointsView = generateView()
    }
    
    func addNode(_ nodes:[SCNNode]?, maxRadius:CGFloat) {
        DispatchToMain {
            if let nodes = nodes {
                self.currentNodes.append(contentsOf: nodes)
                self.maxRadiusStatic = maxRadius
                if nodes.count > 0 && maxRadius > 0{
                    self.drawPoints(self.pointsWithDatas(nodes, maxRadius: maxRadius))
                }
            }
        }
    }
    
    func drawPoints(_ points: [CGPoint]?) {
        if let points = points {
            if points.count > 0 {
                points.forEach({ (point) in
                    let pointView = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 4, height: 4)))
                    pointView.center = point
                    pointView.backgroundColor = UIColor.white
                    pointView.layer.cornerRadius = 2
                    pointView.clipsToBounds = true
                    
                    self.pointsView?.addSubview(pointView)
                    pointsLocationArray.append(pointView)
                })
            }
            self.bringSubviewToFront(self.pointsView!)
            self.bringSubviewToFront(self.fanView!)
        }
    }
    
    func pointsWithDatas(_ datas: [SCNNode], maxRadius:CGFloat) -> [CGPoint]? {
        return pointsWithDatas(datas, maxRadius: maxRadius, camera: nil)
    }
    
    func pointsWithDatas(_ datas: [SCNNode], maxRadius:CGFloat, camera:ARCamera?) -> [CGPoint]? {
        if datas.count > 0 {
            var points:[CGPoint] = [CGPoint]()
            
            let centerX = self.bounds.size.width / 2.0
            let centerY = self.bounds.size.height / 2.0
            
            let radius = CGFloat.minimum(centerX, centerY)
            
            datas.forEach({ (node) in
                var distance = CGFloat(node.position.length())
                var firstPoint = CGPoint.zero
                if let camera = camera {
                    firstPoint = CGPoint.init(x: CGFloat(SCNVector3.positionFromTransform(camera.transform).x), y: CGFloat(-SCNVector3.positionFromTransform(camera.transform).z))
                    distance = CGFloat(node.position.distanceTo(SCNVector3.positionFromTransform(camera.transform)))
                    if distance > 10 {
                        distance = 10
                    }
                }
                let decareDegrees = CGFloat(angleBetweenPoints(first: firstPoint, second: CGPoint.init(x: CGFloat(node.worldPosition.x), y: CGFloat(-node.worldPosition.z)))) - CGFloat.pi/2.0
                
                // 默认只在10m范围内有效
                let scale = distance / maxRadius
                
                let height = sin(decareDegrees) * scale * radius
                let width = cos(decareDegrees) * scale * radius
                
                let point = CGPoint.init(x: centerX + width, y: centerY + height)
                points.append(point)
            })
            return points
        }
        return nil
    }
    
    func configFanShaperLayer() {
        let center = CGPoint.init(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        let radius = CGFloat.minimum(self.bounds.size.width, self.bounds.size.height)/2.0
        let fanPath = UIBezierPath.init()
        fanPath.move(to: center)
        fanPath.addArc(withCenter: center, radius: radius, startAngle: -CGFloat.pi/4.0, endAngle: CGFloat.pi/4.0, clockwise: true)
        self.fanShapeLayer?.path = fanPath.cgPath
    }
    
    func addBackgroundLayer() {
        let center = CGPoint.init(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        let radius = CGFloat.minimum(self.bounds.size.width, self.bounds.size.height)/2.0
        let path1 = UIBezierPath.init(arcCenter: center, radius: radius, startAngle: -CGFloat.pi/2.0, endAngle: CGFloat.pi * 2 - CGFloat.pi/2.0, clockwise: true)
        let path2 = UIBezierPath.init(arcCenter: center, radius: radius/3.0*2.0, startAngle: -CGFloat.pi/2.0, endAngle: CGFloat.pi * 2 - CGFloat.pi/2.0, clockwise: true)
        let path3 = UIBezierPath.init(arcCenter: center, radius: radius/3.0, startAngle: -CGFloat.pi/2.0, endAngle: CGFloat.pi * 2 - CGFloat.pi/2.0, clockwise: true)
        
        self.shapeLayer1?.path = path1.cgPath
        self.shapeLayer2?.path = path2.cgPath
        self.shapeLayer3?.path = path3.cgPath
    }
    
    
    var shapeLayer1: CAShapeLayer?
    var shapeLayer2: CAShapeLayer?
    var shapeLayer3: CAShapeLayer?
    var fanShapeLayer: CAShapeLayer?
    var fanView: UIView?
    var pointsView: UIView?
    
    
    // MARK: 生成函数
    func generateShapeLayer() -> CAShapeLayer  {
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.lineWidth = 1.0
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        return shapeLayer
    }
    
    func generateFanShapeLayer() -> CAShapeLayer {
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.lineWidth = 1.0
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = UIColor.init(red: 0, green: 0.5, blue: 0.5, alpha: 0.3).cgColor
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        return shapeLayer
    }
    
    func generateView() -> UIView {
        let view = UIView.init(frame: self.bounds)
        view.backgroundColor = UIColor.clear
        return view;
    }
}

func angleBetweenPoints(first: CGPoint, second: CGPoint) -> Float {
    let height = second.y - first.y;
    let width = second.x - first.x;
    let rads = Float(atan(height/width));
    
    if height > 0 {
        if width > 0 {
            return rads
        }
        else if width == 0 {
            return Float(Float.pi/2)
        }
        else {
            return Float.pi + rads
        }
    }
    else if height == 0 {
        if width > 0 {
            return 0;
        }
        else {
            return Float.pi
        }
    }
    else {
        if width > 0 {
            return Float.pi * 2 + rads
        }
        else if width == 0 {
            return Float(Float.pi/2*3)
        }
        else {
            return Float.pi + rads
        }
    }
}
