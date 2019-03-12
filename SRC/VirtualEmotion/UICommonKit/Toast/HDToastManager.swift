//
//  HBToastManager.swift
//  HugeBuilding
//
//  Created by HanDong Wang on 2018/5/17.
//  Copyright © 2018年 HanDong Wang. All rights reserved.
//

import UIKit
import SnapKit

let HBToastDisplayDuration = 2000

enum HDToastLocation {
    case bottom
    case middle
    case top
}

class HDToastManager: NSObject {
    static let shareInstance: HDToastManager = {
        return HDToastManager.init()
    }()
    
    lazy var toastView = HBToastView.init(frame: HDScreenFrame)
    var toastViewIsHidden = true
    
    /// 广厦1.2版本toast提示
    ///
    /// - Parameters:
    ///   - text: 支持换行，需要手动输入"\n",eg：toast有3行，每行都展示字母a，可传入字符串"a\na\na"
    ///   - delayTime: 消失的时间单位是毫秒
    ///   - location: toast竖直方向位置：bottom、middle、top
    func toast(text: String, delayTime: Int, location:HDToastLocation) {
        DispatchToMain {
            self.toastView.toast(text: text, location: location)
            if self.toastViewIsHidden {
                // 获取当前keyWindow来做底部的视图，
                if let keyWindow = UIApplication.shared.keyWindow {
                    self.toastViewIsHidden = false
                    if self.toastView.superview == nil {
                        keyWindow.addSubview(self.toastView)
                        keyWindow.bringSubviewToFront(self.toastView)
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(delayTime)) {
                    self.toastViewIsHidden = true
                    if self.toastView.superview != nil {
                        self.toastView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func close() {
        if !self.toastViewIsHidden {
            self.toastViewIsHidden = true
            DispatchToMain {
                if self.toastView.superview != nil {
                    self.toastView.removeFromSuperview()
                }
            }
        }
    }
}

fileprivate let HBToastViewTopMargin: CGFloat = 40
fileprivate let HBToastViewBottomMargin: CGFloat = -40
fileprivate let HBToastViewTextTopAndLeftMargin: CGFloat = 15
fileprivate let HBToastViewTextBottomAndRightMargin: CGFloat = -15
fileprivate let HBToastViewTextViewHeight: CGFloat = 16
//广厦1.2版本UI：文字居中显示，大小14px
fileprivate let HBToastViewTextFont = UIFont .systemFont(ofSize: 14)
fileprivate let HBToastViewMaxWidth:CGFloat = 200

fileprivate let HBToastViewMaskViewCornerRadius: CGFloat = 4

class HBToastView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubviews()
        self.layoutStaticSubviews()
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
    
    func toast(text: String, location: HDToastLocation) {
        self.toastText.text = text
        let size = sizeForToastTextConstraint(text: text)
        let margin:CGFloat = 35
        let height = size.height + margin
        let width = size.width + margin
        switch location {
        case .top:
            self.toastMaskView.snp.remakeConstraints { (make) in
                make.centerX.equalTo(self)
                make.top.equalTo(HBToastViewTopMargin)
                make.height.equalTo(height)
                make.width.equalTo(width)
            }
        case .bottom:
            self.toastMaskView.snp.remakeConstraints { (make) in
                make.centerX.equalTo(self)
                make.bottom.equalTo(HBToastViewBottomMargin)
                make.height.equalTo(height)
                make.width.equalTo(width)
            }
        case .middle:
            self.toastMaskView.snp.remakeConstraints { (make) in
                make.center.equalTo(self)
                make.height.equalTo(height)
                make.width.equalTo(width)
            }
        }
    }
    func sizeForToastTextConstraint(text: String)->CGSize {
        let maxSize = CGSize(width: HBToastViewMaxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(.font, value: self.toastText.font, range: NSMakeRange(0, attributedString.length))
        let size = attributedString.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil).size
        return size
    }
    func addSubviews() {
        self.addSubview(self.toastMaskView)
        self.toastMaskView.addSubview(self.toastText)
    }
    
    func layoutStaticSubviews() {
        self.toastText.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(HBToastViewTextTopAndLeftMargin)
            make.bottom.right.equalToSuperview().offset(HBToastViewTextBottomAndRightMargin)
        }
    }
    
    lazy var toastMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        view.layer.cornerRadius = HBToastViewMaskViewCornerRadius
        return view
    }()
    
    lazy var toastText: UILabel = {
        let label = UILabel()
        label.text = "出错了！！！"
        label.textColor = UIColor.white
        label.font = HBToastViewTextFont
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
}
