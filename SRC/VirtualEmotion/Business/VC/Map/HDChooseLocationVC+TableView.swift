//
//  HDChooseLocationVC+TableView.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/8/30.
//  Copyright © 2019 Chiery. All rights reserved.
//

import UIKit

extension HDChooseLocationVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.maptItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "defaultCellIdentifier")
        if cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "defaultCellIdentifier");
        }
        
        // 拿到对应的model
        let maptItem = self.maptItems![indexPath.row]
        cell?.textLabel?.text = maptItem.name
        cell?.detailTextLabel?.text = maptItem.placemark.thoroughfare
        cell?.selectionStyle = .none
        cell?.accessoryType = ( selectedLocationItem == maptItem ) ? .checkmark : .none
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedLocationItem = self.maptItems?[indexPath.row] {
            self.selectedLocationItem = selectedLocationItem
        }
        else {
            self.selectedLocationItem = nil
        }
        
        // 添加大头针
        addAnnotationInMapView()
        
        tableView.reloadData()
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            self.view.endEditing(true)
        }
    }
    
}
