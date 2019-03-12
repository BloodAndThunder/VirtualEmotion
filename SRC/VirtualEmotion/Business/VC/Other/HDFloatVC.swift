//
//  HDFloatVC.swift
//  testARKit
//
//  Created by HanDong Wang on 2019/2/26.
//  Copyright © 2019 HanDong Wang. All rights reserved.
//

import UIKit
import UIKit
import AVFoundation

typealias saveDataBlock = (String, String, String?, UIImage?, URL?, URL?) ->()
class HDFloatVC: HDBaseVC, UITextViewDelegate, AVAudioPlayerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var radius: CGFloat!
    var isShow: Bool = false
    var floatView: UIView?
    var textView: UITextView?
    var imageView: UIImageView?
    var recordButton: UIButton?
    var playButton: UIButton?
    var saveButton: UIButton?
    var dismissGesture: UITapGestureRecognizer?
    var qsaveDataBlock: saveDataBlock?
    
    var wavConverter: iFlyWavConverter?
    
    // MARK: - 数据
    var audioSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var audioSetting: Dictionary<String, Any>?
    
    var audioPath: URL?
    var image: UIImage?
    var imageUrl: URL?
    var voiceUrl: URL?
    var text: String?
    var voice: NSData?
    var isRecord: Bool = false {
        didSet {
            if (isRecord) {
                recordButton?.setTitle("停止留言", for: .normal)
            } else {
                recordButton?.setTitle("开始留言", for: .normal)
            }
        }
    }
    var isPlay: Bool = false {
        didSet {
            if (isPlay) {
                playButton?.setTitle("停止播放", for: .normal)
            } else {
                playButton?.setTitle("听声音", for: .normal)
            }
        }
    }
    
    init(frame: CGRect){
        super.init(nibName: nil, bundle: nil)
        self.view.frame = frame
        self.view.backgroundColor = UIColor.clear
        radius = 5.0
        self.initSubView()
        self.initSession()
        wavConverter = iFlyWavConverter.init()
        text = "这一刻的想法..."
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initSession() {
        var dirPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let date = NSDate(timeIntervalSinceNow: 0)
        print("current date \(date.description)")
        audioPath = dirPaths[0].appendingPathComponent("record\(date).caf")
        
        audioSetting = getAudioSetting()
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .default, options: [])
        } catch {
            print("audio record session", error)
        }
        do {
            try audioSession?.setActive(true)
        } catch {
            print("audio record session active", error)
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: audioPath!, settings: audioSetting!)
            self.audioRecorder?.prepareToRecord()
            let urlString = audioPath?.absoluteString
            
            print("audio urlString \(String(describing: urlString)) ")
            audioRecorder?.isMeteringEnabled = true
            
        } catch {
            print("audio record error", error)
        }
    }
    
    // MARK: - function
    
    @objc func submit() {
        //TODO: 提交信息 image text voice
        let date = normalTime
        qsaveDataBlock!("data\(date)", "title", text, image, imageUrl, voiceUrl)
        dismissVC()
    }
    
    func dismissVC() {
        self.view.removeFromSuperview()
    }
    
    @objc func dismissGesture(_ tap: UITapGestureRecognizer) {
        self.view.removeFromSuperview()
    }
    
    @objc func nullGesture(_ tap: UITapGestureRecognizer) {
        print("无动作")
    }
    
    @objc func chooseImage() {
        //TODO: 截屏 or 选择当前界面
        let pickerVC = UIImagePickerController.init()
        pickerVC.allowsEditing = true;
        pickerVC.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        pickerVC.sourceType =  .savedPhotosAlbum;//图片分组列表样式
        //let window = UIApplication.shared.delegate?.window
        //window??.rootViewController?.present(pickerVC, animated: true, completion: nil)
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    @objc func transVoice() {
        print("curText \(text)")
        if let curText = text {
            wavConverter?.getPathText(toSpeech: curText, completionHandler: {
                path in print(path!)
                let url = URL.init(string: path!)
                //let audioNode =  QARAudio.startWith(url: url)
                
            })
        }
    }
    
    @objc func recordVoice() {
        if (!isRecord) {
            audioSession?.requestRecordPermission({ (granted) in
                if(granted) {
                    self.audioRecorder?.record()
                } else {
                    print("需要访问您的麦克分")
                }
            })
            
        } else {
            audioRecorder?.stop()
            let data = NSData(contentsOfFile: (audioPath?.path)!)
            if (data != nil) {
                print("recorder data length\(String(describing: data?.length))")
            }
        }
        isRecord = !isRecord
    }
    
    @objc  func playVoice() {
        do {
            try audioPlayer = AVAudioPlayer.init(contentsOf: audioPath!)
            audioPlayer?.volume = 10
            audioPlayer?.numberOfLoops = 0
        } catch {
            print("audio player error",error)
        }
        
        if (!isPlay) {
            audioPlayer?.play()
        } else {
            audioPlayer?.stop()
        }
        isPlay = !isPlay
    }
    
    @objc func resignView() {
        textView?.resignFirstResponder()
    }
    
    
    func getAudioSetting() -> Dictionary<String, Any> {
        let dict:[String:Any] = [
            //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
            AVFormatIDKey: kAudioFormatLinearPCM,
            //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
            AVSampleRateKey: 44100.0,
            //录音通道数  1 或 2
            AVNumberOfChannelsKey: 2,
            //线性采样位数  8、16、24、32
            AVLinearPCMBitDepthKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        return dict
    }
    
    func initSubView() {
        let size = self.view.frame.size
        let maskView = UIView(frame: self.view.frame)
        maskView.backgroundColor = UIColor.clear
        self.view.addSubview(maskView)
        
        floatView = UIView(frame: CGRect(x: 20, y: 50, width: size.width-40, height: size.height-100))
        floatView?.backgroundColor = UIColor.white
        floatView?.alpha = 1.0
        floatView?.layer.cornerRadius = radius
        floatView?.layer.borderWidth = 0.4
        floatView?.layer.borderColor =  UIColor.lightGray.cgColor
        self.view.addSubview(floatView!)
        
        let submitBtn  = UIButton(type: .custom)
        submitBtn.frame = CGRect(x: size.width-110 , y: 5, width: 60, height: 30)
        submitBtn.layer.cornerRadius = 2.0
        submitBtn.layer.borderWidth = 1.0
        submitBtn.layer.borderColor = UIColor.blue.cgColor
        submitBtn.setTitle("提交", for: .normal)
        submitBtn.setTitleColor(UIColor.blue, for: .normal)
        submitBtn.addTarget(self, action: #selector(submit), for: .touchUpInside)
        floatView?.addSubview(submitBtn)
        
        textView = UITextView(frame:CGRect(x: 10, y: 40, width: size.width-60, height: 160))
        textView?.text = "这一刻的想法..."
        textView?.font = UIFont.systemFont(ofSize: 16.0)
        textView?.returnKeyType = UIReturnKeyType.default
        textView?.layer.borderColor = UIColor.lightGray.cgColor
        floatView?.addSubview(textView!)
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: size.width, height: 44))
        toolBar.isUserInteractionEnabled = true
        let doneItem = UIBarButtonItem.init(title: "完成", style: UIBarButtonItem.Style.done, target: self, action: #selector(resignView))
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolBar.items = [spaceItem, doneItem]
        textView?.inputAccessoryView =  toolBar
        
        let imageBtn = UIButton(type: .custom)
        imageBtn.frame = CGRect(x: 10, y: 210, width: size.width-60, height: 200)
        imageBtn.backgroundColor = .clear
        imageBtn.layer.borderWidth = 0.4
        imageBtn.layer.borderWidth = 0.4
        imageBtn.layer.borderColor = UIColor.lightGray.cgColor
        imageBtn.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        floatView?.addSubview(imageBtn)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width-60, height: 200))
        let lakePath = Bundle.main.path(forResource: "lake", ofType: "jpg")
        imageView?.image = UIImage(contentsOfFile: lakePath!)
        imageView?.backgroundColor = UIColor.clear
        imageBtn.addSubview(imageView!)
        
        recordButton = UIButton(type: UIButton.ButtonType.custom)
        recordButton?.frame = CGRect(x: 30, y: 430, width: 60, height: 40)
        recordButton?.backgroundColor = UIColor(hexColor: "0x00bcd4", alpha: 1.0)
        recordButton?.tintColor = UIColor.white
        recordButton?.layer.cornerRadius = 4.0
        recordButton?.setTitle("按住留言", for: .normal)
        recordButton?.addTarget(self, action: #selector(recordVoice), for: .touchUpInside)
        floatView?.addSubview(recordButton!)
        
        playButton = UIButton(type: UIButton.ButtonType.custom)
        playButton?.frame = CGRect(x: 135, y: 430, width: 60, height: 40)
        playButton?.backgroundColor = UIColor(hexColor: "0x00bcd4", alpha: 1.0)
        playButton?.tintColor = UIColor.white
        playButton?.layer.cornerRadius = 4.0
        playButton?.setTitle("听声音", for: .normal)
        playButton?.addTarget(self, action: #selector(playVoice), for: .touchUpInside)
        floatView?.addSubview(playButton!)
        
        let transButton = UIButton(type: UIButton.ButtonType.custom)
        transButton.frame = CGRect(x: 230, y: 430, width: 60, height: 40)
        transButton.backgroundColor = UIColor(hexColor: "0x00bcd4", alpha: 1.0)
        transButton.tintColor = UIColor.white
        transButton.layer.cornerRadius = 4.0
        transButton.setTitle("转声音", for: .normal)
        transButton.addTarget(self, action: #selector(transVoice), for: .touchUpInside)
        floatView?.addSubview(transButton)
        
        dismissGesture = UITapGestureRecognizer.init(target: self, action: #selector(dismissGesture(_:)))
        maskView.addGestureRecognizer(dismissGesture!)
        
        let nullGesture = UITapGestureRecognizer.init(target: self, action: #selector(dismissGesture(_:)))
        floatView?.addGestureRecognizer(nullGesture)
    }
    
    
    // MARK: - AVAudioPlay Delegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (flag) {
            isPlay = !isPlay
        } else {
            print("is playing")
        }
    }
    
    // MARK: - UIImagePicker delegate
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if(picker.sourceType == .savedPhotosAlbum) {
            let curImage = info[UIImagePickerController.InfoKey.editedImage.rawValue]
            print("image info \(info)")
            if (curImage != nil) {
                imageView?.image = (curImage as! UIImage)
                image = (curImage as! UIImage)
                picker.dismiss(animated: true, completion: nil)
                if let data = image?.jpegData(compressionQuality: 0.8) {
                    let date = NSDate(timeIntervalSinceNow: 0)
                    let filename = getDocumentsDirectory().appendingPathComponent("image\(date).png")
                    try? data.write(to: filename)
                    imageUrl = filename
                }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        text = textView.text
    }

}
