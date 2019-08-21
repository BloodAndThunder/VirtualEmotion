//
//  HDBaseVC.swift
//  testARKit
//
//  Created by HanDong Wang on 2019/2/26.
//  Copyright © 2019 HanDong Wang. All rights reserved.
//

import UIKit

class HDBaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    class func instanceFromStoryBoard(storyBoardName: String, vcName: String) -> HDBaseVC? {
        let storyBoard = UIStoryboard.init(name: storyBoardName, bundle: nil)
        return storyBoard.instantiateViewController(withIdentifier: vcName) as? HDBaseVC
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
