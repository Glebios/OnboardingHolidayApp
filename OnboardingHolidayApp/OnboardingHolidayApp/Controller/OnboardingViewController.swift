//
//  ViewController.swift
//  OnboardingHolidayApp
//
//  Created by Gleb on 15.11.2020.
//

import UIKit
import AVFoundation
import Combine

class OnboardingViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var getStartedButton:UIButton!
    @IBOutlet weak var darkView:UIView!
    
    
    //MARK: - Property
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let notificationCenter = NotificationCenter.default
    private var appEventSubscribers = [AnyCancellable]()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        observAppEvents()
        setupPlayerIfNeeded()
        restartVideo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        removeAppEventSubscribers()
        removePlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Private func
    private func setupUI() {
        getStartedButton.layer.masksToBounds = true
        getStartedButton.layer.cornerRadius = getStartedButton.frame.height / 2
        darkView.backgroundColor = UIColor.init(white: 0.085, alpha: 0.4)
    }
    
    private func buildPlayer() -> AVPlayer? {
        ///Set path to file
        guard let videoPath = Bundle.main.path(forResource: "bg_video", ofType: "mp4")
        else {return nil }
        ///Adding file with url for player
        let url = URL(fileURLWithPath: videoPath)
        ///Adding url for player
        let player = AVPlayer(url: url)
        ///The player should be nothing
        player.actionAtItemEnd = .none
        ///Player audio is muted
        player.isMuted = true
        return player
    }
    
    private func buildPlayerLayer() -> AVPlayerLayer? {
        let layer = AVPlayerLayer(player:player)
        ///Preserve aspect ratio; fill layer bounds.
        layer.videoGravity = .resizeAspectFill
        return layer
    }
    
    private func playVideo() {
        player?.play()
    }
    
    private func restartVideo() {
        ///Sets the current playback video
        player?.seek(to: .zero)
        playVideo()
    }
    
    private func pauseVideo() {
        player?.pause()
    }
    
    private func setupPlayerIfNeeded() {
        player = buildPlayer()
        playerLayer = buildPlayerLayer()
        
        if let layer  = self.playerLayer,
           view.layer.sublayers?.contains(layer) == false  {
            view.layer.insertSublayer(layer, at: 0)
        }
    }
    
    private func removePlayer() {
        player?.pause()
        player = nil
        
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
    private func observAppEvents() {
        notificationCenter.publisher(for: .AVPlayerItemDidPlayToEndTime).sink { [weak self]_ in
            self?.restartVideo()
        }.store(in: &appEventSubscribers)
        
        notificationCenter.publisher(for: UIApplication.willResignActiveNotification).sink { [weak self]_  in
            self?.pauseVideo()
        }.store(in: &appEventSubscribers)
        
        notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification).sink { [weak self]_  in
            self?.playVideo()
        }.store(in: &appEventSubscribers)
    }
    
    private func removeAppEventSubscribers() {
        appEventSubscribers.forEach { subscriber in
            subscriber.cancel()
        }
    }
}


