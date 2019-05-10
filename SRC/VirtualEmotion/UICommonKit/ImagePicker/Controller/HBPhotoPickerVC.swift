//
//  HBPhotoPickerVC.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/5/10.
//  Copyright © 2019 Chiery. All rights reserved.
//

import UIKit
import Photos

typealias selectePhotoBlock = (UIImage?) -> Void

class HBPhotoPickerVC: HDBaseVC, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    var selectedPhoto: selectePhotoBlock?
    
    func formAlbum() {
        //判断设置是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            //初始化图片控制器
            let picker = UIImagePickerController()
            //设置背景色
            picker.view.backgroundColor = .white
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //设置是否允许编辑
            picker.allowsEditing = false
            //弹出控制器，显示界面
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }else{
            print("读取相册错误")
        }
    }
    
    //选择图片成功后代理
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //查看info对象
        print(info)
        
        //显示的图片
        let image = info[.originalImage] as? UIImage
        
        selectedPhoto?(image)
        
        //图片控制器退出
        picker.dismiss(animated: true, completion: {
            () -> Void in
        })
        
        //自身dismiss
        self.dismiss(animated: false, completion: nil)
    }
    
    // 取消时的操作
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //图片控制器退出
        picker.dismiss(animated: true, completion: {
            () -> Void in
        })
        
        //自身dismiss
        self.dismiss(animated: false, completion: nil)
    }
}
