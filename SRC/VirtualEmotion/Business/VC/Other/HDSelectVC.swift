//
//  HDSelectVC.swift
//  testARKit
//
//  Created by HanDong Wang on 2019/2/26.
//  Copyright © 2019 HanDong Wang. All rights reserved.
//

import UIKit

class HDSelectVC: HDBaseVC, UITableViewDelegate, UITableViewDataSource {

    private var tableView: UITableView!
    private var size: CGSize!
    private var selectedRow: Int = -1
    weak var delegate: HDSelectViewDelegate?
    var selectContent: [String] = [
        "文字",
        "声音",
        "图文",
        "骆驼",
        "3D模型",
        "创建新节点"
    ]
    
    init(size: CGSize) {
        super.init(nibName: nil, bundle: nil)
        self.size = size
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        tableView.frame = CGRect(origin: CGPoint.zero, size: self.size)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.bounces = false
        self.preferredContentSize = self.size
        self.view.addSubview(tableView)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == selectedRow {
            delegate?.selectView!(self)
        } else {
            delegate?.selectView(self, didSelectAtIndex: indexPath.row)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIsSelected = indexPath.row == selectedRow
        
        // Create a table view cell.
        let cell = UITableViewCell()
        let label = UILabel(frame: CGRect(x: 53, y: 10, width: 200, height: 30))
        let icon = UIImageView(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        let vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight))
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = cell.contentView.frame
        cell.contentView.insertSubview(vibrancyView, at: 0)
        vibrancyView.contentView.addSubview(label)
        vibrancyView.contentView.addSubview(icon)
        
        if cellIsSelected {
            cell.accessoryType = .checkmark
        }
        
        // Fill up the cell with data from the object.
        let title = selectContent[indexPath.row]
        label.text = title
        //        var thumbnailImage = object.thumbImage!
        //        if let invertedImage = thumbnailImage.inverted() {
        //            thumbnailImage = invertedImage
        //        }
        //        icon.image = thumbnailImage
        return cell
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.clear
    }
    
}

// MARK: - SelectViewDelegate
@objc protocol HDSelectViewDelegate: class{
    func selectView(_ view: HDSelectVC, didSelectAtIndex: Int)
    
    @objc optional func selectView(_ view: HDSelectVC)

}
