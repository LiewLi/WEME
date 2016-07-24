//
//  Audio.swift
//  WEME
//
//  Created by liewli on 2016-01-20.
//  Copyright © 2016 li liew. All rights reserved.
//

import UIKit
import CoreAudio

enum AudioState{
    case Recording
    case Playing
    case Recorded
    case Played
    case Empty
}

class AudioRecordVC:UIViewController {
    
    var audioPlot:EZAudioPlotGL!
    var timeLabel:UILabel!
    var recorder:EZRecorder!
    var player:EZAudioPlayer!
    var microphone:EZMicrophone!
    var controlButton:UIButton!
    var statusLabel:UILabel!
    var infoLabel:UILabel!
    
    var currentState:AudioState = .Empty
    var cancelButton:UIButton!
    var redoButton:UIButton!
    var doneButton:UIButton!
    
    let theme_color = THEME_COLOR//UIColor(red: 0.569, green: 0.82, blue: 0.478, alpha: 1.0)
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        navigationController?.navigationBar.hidden = true
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        navigationController?.navigationBar.hidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
        }
        catch {
            print(error)
        }
        
        audioPlot = EZAudioPlotGL(frame: CGRectZero)
        audioPlot.backgroundColor = theme_color
//        audioPlot.color = UIColor.whiteColor()
        audioPlot.plotType = EZPlotType.Rolling
        audioPlot.shouldFill = true
        audioPlot.shouldMirror = true
        
        view.addSubview(audioPlot)
        
        microphone = EZMicrophone(delegate: self)
        player = EZAudioPlayer(delegate: self)
        
        setupUI()
        redoButton.alpha = 0.0
        microphone.startFetchingAudio()
    }
    
    func cancel(sender:AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    func done(sender:AnyObject) {
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL().path!) {
            if let t = token, id = myId{
                upload(.POST, UPLOAD_AVATAR_URL, multipartFormData: { multipartFormData in
                    let dd = "{\"token\":\"\(t)\", \"type\":\"-12\"}"
                    let jsonData = dd.dataUsingEncoding(NSUTF8StringEncoding)
                    multipartFormData.appendBodyPart(data:jsonData!, name:"json")
                    multipartFormData.appendBodyPart(fileURL: self.fileURL(), name: "avatar", fileName: "voice.m4a", mimeType: "audio/mp4")
                    
                    }, encodingCompletion: { encodingResult in
                        switch encodingResult {
                        case .Success(let upload, _ , _):
                            upload.responseJSON { response in
                                if let d = response.result.value {
                                    let j = JSON(d)
                                    if j["state"].stringValue  == "successful" {
                                       let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                                        hud.mode = .CustomView
                                        hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                                        hud.labelText = "上传录音成功"
                                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
                                        dispatch_after(delayTime, dispatch_get_main_queue()) { () -> Void in
                                            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
                                        }
                                    }
                                    else {
                                        self.messageAlert("上载录音失败")
                                    }
                                }
                                else if let _ = response.result.error {
                                    self.messageAlert("上载录音失败")
                                    
                                }
                            }
                            
                        case .Failure:
                            break
                            
                        }
                    
                    }
            
                )
            }
          
        }
    }
    
    func redo(sender:AnyObject) {
        currentState = .Empty
        timeLabel.text = ""
        statusLabel.text = "点击按钮开始录音"
        controlButton.setBackgroundImage(UIImage(named: "audio_record")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        audioPlot.clear()
        audioPlot.resumeDrawing()
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
        }
        catch {
            print(error)
        }
    }
    
    func setupUI() {
        audioPlot.translatesAutoresizingMaskIntoConstraints = false
        audioPlot.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(view.snp_top)
            make.height.equalTo(view.snp_height).multipliedBy(2.0/3.0)
        }
        
        timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textAlignment = .Center
        timeLabel.font = UIFont.systemFontOfSize(30)
        timeLabel.textColor = UIColor.whiteColor()
        view.addSubview(timeLabel)
        timeLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.bottom.equalTo(audioPlot.snp_bottom).offset(-20)
        }
        
        let back = UIView()
        back.backgroundColor = BACK_COLOR
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)
        back.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(audioPlot.snp_bottom)
            make.bottom.equalTo(view.snp_bottom)
        }
        
        controlButton = UIButton()
        controlButton.translatesAutoresizingMaskIntoConstraints = false
        controlButton.setBackgroundImage(UIImage(named: "audio_record")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        controlButton.addTarget(self, action: "record:", forControlEvents: .TouchUpInside)
        back.addSubview(controlButton)
        controlButton.tintColor = theme_color
        controlButton.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(back.snp_centerX)
            make.centerY.equalTo(back.snp_centerY)
            make.width.height.equalTo(back.snp_width).multipliedBy(0.2)
        }
        
        infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.textAlignment = .Center
        back.addSubview(infoLabel)
        infoLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
        infoLabel.textColor = TEXT_COLOR
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .ByWordWrapping
        infoLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(back.snp_left)
            make.right.equalTo(back.snp_right)
            make.top.equalTo(back.snp_top)
        }
        infoLabel.text = "录一段语音介绍自己吧，让更多人了解你，你可以在发现中查看其它WEME用户的录音哦"
        
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .Center
        statusLabel.textColor = UIColor.whiteColor()
        statusLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        statusLabel.text = "点击按钮开始录音"
        view.addSubview(statusLabel)
        statusLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_left)
            make.right.equalTo(view.snp_right)
            make.top.equalTo(view.snp_top).offset(20)
        }
        
        cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("取消", forState: .Normal)
        cancelButton.addTarget(self, action: "cancel:", forControlEvents: .TouchUpInside)
        cancelButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        view.addSubview(cancelButton)
        
        redoButton = UIButton()
        redoButton.translatesAutoresizingMaskIntoConstraints = false
        redoButton.setTitle("重新录制", forState: .Normal)
        redoButton.addTarget(self, action: "redo:", forControlEvents: .TouchUpInside)
        redoButton.setTitleColor(theme_color, forState: .Normal)
        redoButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        back.addSubview(redoButton)
        
        doneButton = UIButton()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.setTitle("完成", forState: .Normal)
        doneButton.addTarget(self, action: "done:", forControlEvents: .TouchUpInside)
        doneButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        view.addSubview(doneButton)
        
        cancelButton.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(view.snp_leftMargin)
            make.centerY.equalTo(statusLabel.snp_centerY)
        }
        
        doneButton.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(view.snp_rightMargin)
            make.centerY.equalTo(cancelButton.snp_centerY)
        }
        
        redoButton.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(back.snp_bottomMargin)
            make.centerX.equalTo(back.snp_centerX)
        }
        
    }
    
    func record(sender:AnyObject) {
        if case .Empty = currentState {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try session.setActive(true)
            }
            catch {
                print(error)
            }
            audioPlot.clear()
            recorder = EZRecorder(URL: fileURL(), clientFormat: microphone.audioStreamBasicDescription(), fileType: EZRecorderFileType.M4A, delegate: self)
            currentState = .Recording
            statusLabel.text = "录音中..."
            controlButton.setBackgroundImage(UIImage(named: "audio_stop")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        else if case .Recording = currentState {
            audioPlot.pauseDrawing()
            currentState = .Recorded
            statusLabel.text = "录音结束"
            redoButton.alpha = 1.0
            controlButton.setBackgroundImage(UIImage(named: "audio_play")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        else if case .Recorded = currentState {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(AVAudioSessionCategoryPlayback)
                try session.setActive(true)
            }
            catch {
                print(error)
            }
            audioPlot.clear()
            audioPlot.resumeDrawing()
            statusLabel.text = "播放中..."
            redoButton.alpha = 0.0
            currentState = .Playing
            recorder.closeAudioFile()
            player.playAudioFile(EZAudioFile(URL: fileURL()))
            controlButton.setBackgroundImage(UIImage(named: "audio_stop")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        else if case .Playing = currentState {
            audioPlot.pauseDrawing()
            player.pause()
            currentState = .Recorded
            redoButton.alpha = 1.0
            statusLabel.text = "播放结束"
            controlButton.setBackgroundImage(UIImage(named: "audio_play")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        }
        else if case .Played = currentState {
            
        }
    }
    
    func fileURL()->NSURL {
        let document = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true)[0]
        let audioFile = "voice.m4a"
        return NSURL(fileURLWithPath: "\(document)/\(audioFile)")
    }
}

extension AudioRecordVC: EZMicrophoneDelegate, EZAudioPlayerDelegate, EZRecorderDelegate {
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) { [weak self]() -> Void in
            if let S = self {
                switch S.currentState {
                case .Recording, .Playing:
                    S.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
                default:
                    break
                }
                
            }
        }
    }
    
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        if case .Recording = currentState {
            recorder.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
        }
    }
    
    func recorderDidClose(recorder: EZRecorder!) {
        recorder.delegate = nil
    }
    
    func recorderUpdatedCurrentTime(recorder: EZRecorder!) {
        let timeStr = recorder.formattedCurrentTime
        dispatch_async(dispatch_get_main_queue()) { [weak self]() -> Void in
            if let S = self {
                S.timeLabel.text = timeStr
            }
        }
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue()) { [weak self]() -> Void in
            if let S = self {
                S.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
            }
        }
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue()) { [weak self]() -> Void in
            if let S = self {
                S.timeLabel.text = audioPlayer.formattedCurrentTime
            }
        }
    }
    func audioPlayer(audioPlayer: EZAudioPlayer!, reachedEndOfAudioFile audioFile: EZAudioFile!) {
        if case .Playing = currentState {
            dispatch_async(dispatch_get_main_queue(), { [weak self]() -> Void in
                if let S = self {
                    S.audioPlot.pauseDrawing()
                    S.currentState = .Recorded
                    S.statusLabel.text = "播放结束"
                    S.controlButton.setBackgroundImage(UIImage(named: "audio_play")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
                    S.redoButton.alpha = 1.0
                }
            })
           
        }
    }
}


