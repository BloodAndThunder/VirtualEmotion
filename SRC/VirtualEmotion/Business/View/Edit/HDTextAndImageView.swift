//
//  HDTextAnImageView.swift
//  VirtualEmotion
//
//  Created by HanDong Wang on 2019/5/9.
//  Copyright © 2019 Chiery. All rights reserved.
//

import UIKit
import MapKit

private enum HDTextAndImageViewFlag {
    case add
    case user
}

public enum HDTextAndImageViewType {
    case virtualNode
    case worldMap
}

typealias HDTextAndImageViewCallBack = (String, UIImage, MKMapItem?) -> Void
typealias HDTextAndImageViewClickLocation = ()->Void

class HDTextAndImageView: UIView {
    
    public var completion: HDTextAndImageViewCallBack?
    public var clickLocation: HDTextAndImageViewClickLocation?
    public var seletedLocationItem: MKMapItem?
    
    private var type: HDTextAndImageViewType = .virtualNode
    
    init(frame: CGRect, type: HDTextAndImageViewType = .virtualNode) {
        super.init(frame: frame)
        self.type = type
        self.addSubviews()
        self.layoutStaticSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.layoutStaticSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addSubviews() {
        self.addSubview(self.maskControl)
        self.addSubview(self.contentView)
        self.contentView.addSubview(self.textContentView)
        self.textContentView.addSubview(self.textView)
        self.textContentView.addSubview(self.placeHolderLabel)
        self.textContentView.addSubview(self.numbersLabel)
        self.contentView.addSubview(addImageView)
        if type == .worldMap {
            self.contentView.addSubview(locationImageView)
            self.contentView.addSubview(locationLabel)
        }
        self.contentView.addSubview(submmitButton)
    }
    
    func layoutStaticSubviews() {
        self.maskControl.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.contentView.snp.makeConstraints { (make) in
            make.left.equalTo(40)
            make.right.equalTo(-40)
            make.centerY.equalToSuperview()
            make.height.equalTo(type == .virtualNode ? 406 : 440)
        }
        
        self.textContentView.snp.makeConstraints { (make) in
            make.top.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(122)
        }
        
        self.placeHolderLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(10)
        }
        
        self.placeHolderLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.placeHolderLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.placeHolderLabel.setContentHuggingPriority(.required, for: .vertical)
        self.placeHolderLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.textView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalToSuperview()
            make.right.bottom.equalTo(-10)
        }
        
        self.numbersLabel.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(-10)
        }
        
        self.numbersLabel.setContentHuggingPriority(.required, for: .horizontal)
        self.numbersLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.numbersLabel.setContentHuggingPriority(.required, for: .vertical)
        self.numbersLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.addImageView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(self.textContentView.snp.bottom).offset(10)
            make.right.equalTo(-10)
            make.height.equalTo(200)
        }
        
        if type == .worldMap {
            
            self.locationImageView.snp.makeConstraints { (make) in
                make.top.equalTo(self.addImageView.snp.bottom).offset(10)
                make.left.equalTo(10)
                make.width.height.equalTo(24)
            }
            
            self.locationLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self.addImageView.snp.bottom).offset(10)
                make.left.equalTo(self.locationImageView.snp.right).offset(10)
                make.right.equalTo(-10)
                make.height.equalTo(24)
            }
            
            self.submmitButton.snp.makeConstraints { (make) in
                make.top.equalTo(self.locationImageView.snp.bottom).offset(10)
                make.left.equalTo(10)
                make.right.equalTo(-10)
                make.height.equalTo(44)
            }
        }
        else {
            self.submmitButton.snp.makeConstraints { (make) in
                make.top.equalTo(self.addImageView.snp.bottom).offset(10)
                make.left.equalTo(10)
                make.right.equalTo(-10)
                make.height.equalTo(44)
            }
        }
        
    }
    
    @objc private func hiddenKeyboard() {
        self.endEditing(true)
        updateSubmmitButtonStatus()
    }
    
    @objc private func addImageFunction() {
        // end editing
        textView.resignFirstResponder()
        
        HBAlertView.showAlert(title: "选择图片来源", message: nil, otherButtons: [("从相册选择", .default), ("拍照获取", .default)], style: .actionSheet, actionHandle: { (alertView, index) in
            let photoPicker = HBPhotoPickerVC()
            getTopVC { (topvc) in
                if let top = topvc {
                    top.present(photoPicker, animated: false, completion: {
                        if index == 0 { photoPicker.fromAlbum() }
                        else { photoPicker.fromCamera() }
                        photoPicker.selectedPhoto = {[weak self] image in
                            if let userImage = image {
                                self?.addImageView.image = userImage
                                self?.imageFlag = .user
                                self?.addImageView.contentMode = .scaleAspectFill
                                self?.updateSubmmitButtonStatus()
                            }
                        }
                    })
                }
            }
        });
    }
    
    @objc private func submmit() {
        // 可以提交的时候，这里返回需要的数据
        completion?(self.textView.text, self.addImageView.image!, seletedLocationItem)
    }
    
    @objc private func jumpToLocation() {
        clickLocation?()
    }
    
    private func checkDataIsReady() -> Bool {
        if self.textView.text.count > 0, self.imageFlag == .user {
            return true
        }
        return false
    }
    
    private func updateSubmmitButtonStatus() {
        if checkDataIsReady() {
            submmitButton.isEnabled = true
            submmitButton.backgroundColor = .white
        }
        else {
            submmitButton.isEnabled = false
            submmitButton.backgroundColor = HDButtonGrayColor
        }
    }
    
    private var imageFlag: HDTextAndImageViewFlag = .add
    
    lazy var maskControl: UIControl = {
       let control = UIControl.init()
        control.backgroundColor = .clear
        control.addTarget(self, action: #selector(hiddenKeyboard), for: .touchUpInside)
        return control
    }()
    
    lazy var contentView: UIView = {
        let view = UIView.init()
        view.backgroundColor = .white
        view.layer.cornerRadius = 4.0
        return view
    }()
    
    lazy var textContentView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 2
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.init(hex: "D5D5D5").cgColor
        view.layer.borderWidth = HDPixelWidth
        return view
    }()
    
    lazy var textView: UITextView = {
        let view = UITextView.init()
        view.backgroundColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor.init(hex: "333333")
        view.delegate = self
        return view
    }()
    
    lazy var placeHolderLabel: UILabel = {
        let view = UILabel.init()
        view.font = UIFont.systemFont(ofSize: 14)
        view.backgroundColor = UIColor.white
        view.textColor = UIColor.init(hex: "9B9B9B")
        view.text = self.type == .virtualNode ? "此时此刻，留下足迹..." : "添加地理位置的详细描述"
        return view
    }()
    
    lazy var numbersLabel: UILabel = {
        let view = UILabel.init()
        view.font = UIFont.systemFont(ofSize: 14)
        view.backgroundColor = UIColor.white
        view.textColor = UIColor.init(hex: "9B9B9B")
        view.text = "0/200"
        return view
    }()
    
    lazy var addImageView: UIImageView = {
        let imageView = UIImageView.init(image: #imageLiteral(resourceName: "AddImage"))
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(addImageFunction))
        imageView.addGestureRecognizer(tap)
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var locationImageView: UIImageView = {
        let imageView = UIImageView.init(image: #imageLiteral(resourceName: "Location"))
        return imageView
    }()
    
    lazy var locationLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = HDTextGrayColor
        label.text = "您需要添加一个地理位置"
        label.backgroundColor = .white
        label.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(jumpToLocation))
        label.addGestureRecognizer(tap)
        
        return label
    }()
    
    lazy var submmitButton: UIButton = {
       let button = UIButton.init()
        button.setTitle("提交", for: .normal)
        button.setTitleColor(HDButtonTextColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.layer.cornerRadius = 4
        button.layer.borderColor = HDButtonGrayColor.cgColor
        button.layer.borderWidth = HDPixelWidth
        button.addTarget(self, action: #selector(submmit), for: .touchUpInside)
        button.backgroundColor = HDButtonGrayColor
        button.isEnabled = false
        return button
    }()
}

extension HDTextAndImageView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.placeHolderLabel.isHidden = true
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.count > 0 {
            self.placeHolderLabel.isHidden = true
        }
        else {
            self.placeHolderLabel.isHidden = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 数量上做限制
        if textView.text.utf16.count > 50 {
            // 这里需要处理临界值,如果emoji表情长度大于1，需要循环取值
            var tempResult: String = ""
            for index in 0 ... 200 {
                if let stringValue = String(textView.text.utf16.prefix(200 - index)), stringValue.count > 0 {
                    tempResult = stringValue
                    break
                }
            }
            
            textView.text = tempResult
        }
        
        // 更新下面的数据
        self.numbersLabel.text = "\(textView.text.utf16.count)/200"
    }
}
