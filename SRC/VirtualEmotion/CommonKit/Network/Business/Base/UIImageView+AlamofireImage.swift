//
//  UIImageView+AlamofireImage.swift
//  HugeBuilding
//
//  Created by HanDong Wang on 2018/4/11.
//  Copyright © 2018年 HanDong Wang. All rights reserved.
//

import UIKit
import AlamofireImage

extension UIImageView {
    func image(url: URL,placeholderImage: UIImage?) {
        self.af_setImage(withURL: url, placeholderImage: placeholderImage)
    }
    
    func image(urlString: String? ,placeholderImage: UIImage?, errorImage: UIImage?) {

        if let tmpUrlString = urlString, tmpUrlString.count > 0 {
            if let tmpUrl = URL.init(string: tmpUrlString) {
                self.af_setImage(withURL: tmpUrl, placeholderImage: placeholderImage)
            }
            else {
               self.image = errorImage
            }
        }
        else {
            self.image = errorImage
        }
    }
}
