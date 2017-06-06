//
//  VideoViewController.swift
//  VaporTalk
//
//  Created by 이상윤 on 2017. 4. 5..
//  Copyright © 2017년 이상윤. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoViewController: UIViewController {
    
    let vaporTimePickerView: UIDatePicker = UIDatePicker()
    let pickerBackgroundView: UIView = UIView()
    let playButton: UIButton = UIButton()
    private var vaporTimePickerIsHidden = false
    private var isPlay = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var videoURL: URL
    var player: AVPlayer?
    var playerController : AVPlayerViewController?
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func timeValueChanged() {
        print(vaporTimePickerView.countDownDuration)
    }
    
    func timePickerSwitchTouched() {
        self.vaporTimePickerView.isHidden = !vaporTimePickerIsHidden
        self.pickerBackgroundView.isHidden = !vaporTimePickerIsHidden
        vaporTimePickerIsHidden = !vaporTimePickerIsHidden
    }
    
    func playButtonTouched() {
        if isPlay { pause() }
        else { play() }
    }
    
    func play() {
        playButton.setImage(#imageLiteral(resourceName: "pause-button"), for: UIControlState())
        playButton.alpha = 0.5
        isPlay = !isPlay
        player?.play()
    }
    
    func pause() {
        playButton.setImage(#imageLiteral(resourceName: "movie-player-play-button"), for: UIControlState())
        playButton.alpha = 1
        isPlay = !isPlay
        player?.pause()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        player = AVPlayer(url: videoURL)
        playerController = AVPlayerViewController()
        
        guard player != nil && playerController != nil else {
            return
        }
        playerController!.showsPlaybackControls = false
        
        playerController!.player = player!
        self.addChildViewController(playerController!)
        self.view.addSubview(playerController!.view)
        playerController!.view.frame = view.frame
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
        
        let cancelButton = UIButton(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
        cancelButton.setImage(#imageLiteral(resourceName: "camera_close"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        let okButton = UIButton(frame: CGRect(x: self.view.frame.width - 40, y: 10, width: 30, height: 30))
        okButton.setImage(#imageLiteral(resourceName: "send_blue_50"), for: UIControlState())
        okButton.addTarget(self, action: #selector(ok), for: .touchUpInside)
        
        pickerBackgroundView.frame = CGRect(x: 10, y: self.view.frame.height - 200, width: self.view.frame.width / 1.5, height: 150)
        pickerBackgroundView.backgroundColor = UIColor.white
        pickerBackgroundView.alpha = 0.6
        pickerBackgroundView.layer.cornerRadius = 5
        pickerBackgroundView.layer.masksToBounds = true
        
        vaporTimePickerView.frame = CGRect(x: 20, y: self.view.frame.height - 190, width: self.view.frame.width / 1.5 - 20, height: 130)
        vaporTimePickerView.alpha = 0.8
        vaporTimePickerView.datePickerMode = UIDatePickerMode.countDownTimer
        vaporTimePickerView.countDownDuration = 300.0
        vaporTimePickerView.addTarget(self, action: #selector(timeValueChanged), for: UIControlEvents.valueChanged)
        
        let vaporTimePickerSwitchButton = UIButton(frame: CGRect(x: 10, y: self.view.frame.height - 40, width: 30, height: 30))
        vaporTimePickerSwitchButton.setImage(#imageLiteral(resourceName: "timer"), for: UIControlState())
        vaporTimePickerSwitchButton.addTarget(self, action: #selector(timePickerSwitchTouched), for: .touchUpInside)
        
        playButton.frame = CGRect(x: self.view.frame.width / 2 - 37.5, y: self.view.frame.height / 2 - 37.5, width: 75, height: 75)
        playButton.setImage(#imageLiteral(resourceName: "movie-player-play-button"), for: UIControlState())
        playButton.addTarget(self, action: #selector(playButtonTouched), for: .touchUpInside)
        
        view.addSubview(pickerBackgroundView)
        view.addSubview(vaporTimePickerView)
        view.addSubview(vaporTimePickerSwitchButton)
        view.addSubview(okButton)
        view.addSubview(cancelButton)
        view.addSubview(playButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //player?.play()
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func ok() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let friendChoiceViewController = storyboard.instantiateViewController(withIdentifier: "FriendChoiceViewController") as! FriendChoiceViewController
        self.present(friendChoiceViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: kCMTimeZero)
            playButton.setImage(#imageLiteral(resourceName: "movie-player-play-button"), for: UIControlState())
            isPlay = false
        }
    }
}
