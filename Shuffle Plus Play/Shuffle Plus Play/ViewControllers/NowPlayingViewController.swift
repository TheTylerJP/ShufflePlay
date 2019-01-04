//
//  NowPlayingViewController.swift
//  Shuffle Plus Play
//
//  Created by Thom Pheijffer on 28/10/2018.
//  Copyright © 2018 Thom Pheijffer. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class NowPlayingViewController: UIViewController {
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    var genresCardViewController: GenresCardViewController!
    //var visualEffectView:UIVisualEffectView!
    
    var cellHeight: CGFloat! = 40//40
    var cardHeight: CGFloat = 100 + 40 * 6 + 7 * 30
    
    let cardHandleAreaHeight: CGFloat = 56
    
    var cardVisible = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    let myMediaQuery = MPMediaQuery.songs()
    var audioSession = AVAudioSession.sharedInstance()
    
    let nowPlaying = MPNowPlayingInfoCenter.default().nowPlayingInfo
    
    //Album Image View
    var albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        imageView.layer.masksToBounds = false
        imageView.layer.shadowRadius = 3.0
        imageView.layer.shadowOpacity = 1.0
        imageView.layer.cornerRadius = 5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //Song Label
    var nowPlayingLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.isUserInteractionEnabled = false
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //Artist Label
    var artistLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.isUserInteractionEnabled = false
        label.textColor = UIColor.white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //Logo Image View
    var logoImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "SPEmoji"))
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        imageView.layer.masksToBounds = false
        imageView.layer.shadowRadius = 3.0
        imageView.layer.shadowOpacity = 1.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //Previous
    let previousButton: UIButton = {
        let button = UIButton.musicButton()
        
        if let homeImage  = UIImage(named: "previous-white") {
            button.setImage(homeImage, for: .normal)
            button.tintColor = UIColor.black
        }
        button.addTarget(self, action: #selector(previousButtonTapped(_:)), for:.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
//    let playPauseButton: PlayView = {
//        let playView = PlayView()
//        //playView.fractionComplete = 1
//        playView.iconSize = 25
//        playView.lineWidth = 3
//        playView.translatesAutoresizingMaskIntoConstraints = false
//
//        playView.layer.shadowColor = UIColor.black.cgColor
//        playView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
//        playView.layer.masksToBounds = false
//        playView.layer.shadowRadius = 3.0
//        playView.layer.shadowOpacity = 1.0
//
//        return playView
//    }()
    
    //Play
    let playPauseButton: UIButton = {
        let button = UIButton.musicButton()
        if let homeImage  = UIImage(named: "play-white") {
            button.setImage(homeImage, for: .normal)
            button.tintColor = UIColor.black
        }
        button.addTarget(self, action: #selector(playButtonTapped), for:.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Next
    let nextButton: UIButton = {
        let button = UIButton.musicButton()
        if let homeImage  = UIImage(named: "next-white") {
            button.setImage(homeImage, for: .normal)
            button.tintColor = UIColor.black
        }
        button.addTarget(self, action: #selector(nextButtonTapped(_:)), for:.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Pause
    let pauseButton: UIButton = {
        let button = UIButton.musicButton()
        if let homeImage  = UIImage(named: "pause-white3") {
            button.setImage(homeImage, for: .normal)
            button.tintColor = UIColor.black
        }
        button.addTarget(self, action: #selector(pauseButtonTapped), for:.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Trying to get lockscreen now playing info to work. HALP.
        try! self.audioSession.setCategory(.playback, mode: .default, options: [])
        try! self.audioSession.setActive(true)
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        
        cellHeight = self.view.frame.width * 0.375 / 3
        
        let spacingRoomBetweenCells = 7 * 30
        cardHeight = 100 + cellHeight * 6 + CGFloat(spacingRoomBetweenCells)
        // * 6 because 11 /2 = 6
        // * 7 because 6 + 1 extra room undernaeat
        //30 = spacing between cells
        
        setupViews()
        setupCard()
        createObservers()
        setupNowPlayingInfoCenter()
        setNowPlayingInfo()
        
        self.genresCardViewController.view.layer.cornerRadius = 12
        self.genresCardViewController.view.clipsToBounds = true
        
        self.view.backgroundColor = .red
        self.view.backgroundColor = UIColor(r: 70, g: 136, b: 241, a: 1)
        
        let parentVc = self.parent as! PageViewController
        parentVc.pageControl.currentPage = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if musicPlayer.playbackState == .playing {
            albumImageView.image = musicPlayer.nowPlayingItem?.artwork?.image(at: albumImageView.bounds.size)
            nowPlayingLabel.text = musicPlayer.nowPlayingItem?.title
            artistLabel.text = musicPlayer.nowPlayingItem?.artist
            
            albumImageView.isHidden = false
            nowPlayingLabel.isHidden = false
            artistLabel.isHidden = false
            logoImageView.isHidden = true
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        playPauseButton.fractionComplete = 1
//        playPauseButton.button.isUserInteractionEnabled = false
//        playPauseButton.playHandler = { [weak self] in
//            self?.playButtonTapped()
//        }
//        playPauseButton.stopHandler = { [weak self] in
//            self?.pauseButtonTapped()
//        }
//
//    }
            
    func setupViews() {
        self.view.addSubview(albumImageView)
        self.view.addSubview(nowPlayingLabel)
        self.view.addSubview(artistLabel)
        self.view.addSubview(logoImageView)
        self.view.addSubview(previousButton)
        self.view.addSubview(playPauseButton)
        self.view.addSubview(nextButton)
        self.view.addSubview(pauseButton)
        
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 125).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 225).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 225).isActive = true
        
        albumImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        albumImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 125).isActive = true
        albumImageView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        albumImageView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        nowPlayingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nowPlayingLabel.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 75).isActive = true
        nowPlayingLabel.widthAnchor.constraint(equalToConstant: 275).isActive = true
        nowPlayingLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        artistLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        artistLabel.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 55).isActive = true
        artistLabel.widthAnchor.constraint(equalToConstant: 225).isActive = true
        artistLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        //MARK: - Buttons
        playPauseButton.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 150).isActive = true
        playPauseButton.widthAnchor.constraint(equalToConstant: 57).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 57).isActive = true
        playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 50).isActive = true
        
        previousButton.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 150).isActive = true
        previousButton.widthAnchor.constraint(equalToConstant: 55).isActive = true
        previousButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        previousButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        
        nextButton.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 150).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 55).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        pauseButton.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 150).isActive = true
        pauseButton.widthAnchor.constraint(equalToConstant: 55).isActive = true
        pauseButton.heightAnchor.constraint(equalToConstant: 55).isActive = true
        pauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -50).isActive = true
    }
    
}
