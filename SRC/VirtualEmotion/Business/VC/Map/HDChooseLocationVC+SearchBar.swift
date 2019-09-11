//
//  HDChooseLocationVC+SearchBar.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/8/30.
//  Copyright © 2019 Chiery. All rights reserved.
//

import UIKit
import MapKit

extension HDChooseLocationVC: UISearchBarDelegate {
    
    func geocodeAddressString(keyword: String) {
        
        let request = MKLocalSearch.Request.init()
        request.naturalLanguageQuery = keyword
        let localSearchRequest = MKLocalSearch.init(request: request)
        localSearchRequest.start { (response, error) in
            if let error = error {
                print("解析出错了", error)
            }
            
            self.maptItems = response?.mapItems
            self.tableView.reloadData()
        }
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 在这里开始范地理编码
        geocodeAddressString(keyword: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        geocodeAddressString(keyword: searchBar.text ?? "")
    }

}
