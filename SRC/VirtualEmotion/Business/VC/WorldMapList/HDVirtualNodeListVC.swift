//
//  HDWorldMapListVC.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/8/20.
//  Copyright © 2019 Chiery. All rights reserved.
//

import Foundation
import ARKit

class HDVirtualNodeListCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        
        addSubviews()
        layoutStaticSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(model: HDNodeModel?) {
        self.worldMapImageView.image = UIImage.init(data: model?.imageData ?? Data())
        self.worldMapTitleLabel.text = model?.title
        self.virtualCountLabel.text = "10"
        self.worldMapDetailLabel.text = model?.subtitle
    }
    
    func addSubviews() {
        self.addSubview(self.worldMapImageView)
        self.addSubview(self.worldMapTitleLabel)
        self.addSubview(self.virtualCountLabel)
        self.addSubview(self.worldMapDetailLabel)
    }
    
    func layoutStaticSubviews() {
        self.worldMapImageView.snp.makeConstraints { (make) in
            make.left.top.equalTo(10);
            make.width.height.equalTo(80);
        }
        
        self.worldMapTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(self.worldMapImageView.snp_right).offset(10)
            make.right.equalTo(-10)
        }
        
        self.virtualCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.worldMapTitleLabel.snp_bottom).offset(10)
            make.left.equalTo(self.worldMapImageView.snp_right).offset(10)
            make.right.equalTo(-10)
        }
        
        self.worldMapDetailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.virtualCountLabel.snp_bottom).offset(10)
            make.left.equalTo(self.worldMapImageView.snp_right).offset(10)
            make.right.equalTo(-10)
        }
    }
    
    lazy var worldMapImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var worldMapTitleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    lazy var virtualCountLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    lazy var worldMapDetailLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
}

class HDVirtualNodeListVC: HDBaseVC {
    @IBOutlet weak var tableView: UITableView!
    
    var virtualNodes: [HDNodeModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 注册cell
        registerTableViewCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 重新加载数据
        loadData()
    }
    
    // loadData
    private func loadData() {
        HDSQLiteManager.shared.queryVirtualNodesDBTable {[weak self] (tempNodes) in
            self?.virtualNodes = tempNodes
            
            DispatchToMain(task: {
                self?.tableView.reloadData()
            })
        }
    }
    
    // 注册对应的cell
    private func registerTableViewCell() {
        self.tableView.register(HDVirtualNodeListCell.self, forCellReuseIdentifier: "HDWorldMapListCell")
    }
    
}

extension HDVirtualNodeListVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return virtualNodes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: HDVirtualNodeListCell = tableView.dequeueReusableCell(withIdentifier: "HDWorldMapListCell") as? HDVirtualNodeListCell {
            
            if let model = virtualNodes?[indexPath.row] {
                cell.config(model: model)
            }
            return cell
        }
        else {
            return UITableViewCell.init()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 跳转到还原页面
        if let model = virtualNodes?[indexPath.row],
            let worldMapHash = model.worldMapHash {
            // 从数据库取出worldMapData数据
            HDSQLiteManager.shared.queryWorldMapData(hashValue: worldMapHash) { (tempData) in
                if let worldMapData = tempData,
                    let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: worldMapData),
                    let vc = HDBaseVC.instanceFromStoryBoard(storyBoardName: "Main", vcName: "ARKITVC") as? ViewController{
                    vc.isRecording = false
                    vc.worldMap = worldMap
                    vc.worldMapHash = worldMapHash
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
