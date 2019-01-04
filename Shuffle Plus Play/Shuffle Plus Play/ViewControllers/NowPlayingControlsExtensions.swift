//
//  NowPlayingControlsExtensions.swift
//  Shuffle Plus Play
//
//  Created by Tyler Phillips on 1/3/19.
//  Copyright © 2019 Thom Pheijffer. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

//MARK: - Play / Pause / Prev / Next Buttons
extension NowPlayingViewController {
    
    @objc func setNowPlayingInfo() {
        
        if musicPlayer.playbackState == .playing {
            albumImageView.image = musicPlayer.nowPlayingItem?.artwork?.image(at: albumImageView.bounds.size)
            nowPlayingLabel.text = musicPlayer.nowPlayingItem?.title
            artistLabel.text = musicPlayer.nowPlayingItem?.artist
            
            albumImageView.isHidden = false
            nowPlayingLabel.isHidden = false
            artistLabel.isHidden = false
            logoImageView.isHidden = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.albumImageView.image = self.musicPlayer.nowPlayingItem?.artwork?.image(at: self.albumImageView.bounds.size)
            self.nowPlayingLabel.text = self.musicPlayer.nowPlayingItem?.title
            self.artistLabel.text = self.musicPlayer.nowPlayingItem?.artist
        }
    }
    
    func setupNowPlayingInfoCenter() {
        UIApplication.shared.beginReceivingRemoteControlEvents();
        MPRemoteCommandCenter.shared().playCommand.addTarget {event in
            self.musicPlayer.play()
            self.setupNowPlayingInfoCenter()
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {event in
            self.musicPlayer.pause()
            return .success
        }
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget {event in
            self.musicPlayer.skipToNextItem()
            return .success
        }
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget {event in
            self.musicPlayer.skipToPreviousItem()
            return .success
        }
    }
    
    //MARK: - PlayButtonTapped Method
    @objc func playButtonTapped(_ sender: UIButton) {
        
        let name = Notification.Name.albumArtNotifacationKey
        NotificationCenter.default.post(name: name, object: nil)
        
        let artistName = Notification.Name.artistNotifacationKey
        NotificationCenter.default.post(name: artistName, object: nil)
        
        let trackName = Notification.Name.trackTitleNotifactionKey
        NotificationCenter.default.post(name: trackName, object: nil)
        
        setNowPlayingInfo()
        musicPlayer.shuffleMode = .songs
        createObservers()
        sender.pulsate()
        musicPlayer.play()
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.albumImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        }
        
        
    }
    
    //MARK: - PauseButtonTapped Method
    @objc func pauseButtonTapped(_ sender: UIButton) {
        let albumArt = Notification.Name.albumArtNotifacationKey
        NotificationCenter.default.post(name: albumArt, object: nil)
        
        let artistName = Notification.Name.artistNotifacationKey
        NotificationCenter.default.post(name: artistName, object: nil)
        
        let trackName = Notification.Name.trackTitleNotifactionKey
        NotificationCenter.default.post(name: trackName, object: nil)
        
        setNowPlayingInfo()
        sender.pulsate()
        musicPlayer.pause()
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.albumImageView.transform = .identity
            }
        }
        
        
    }
    
    //MARK: - PreviousButtonTapped Method
    @objc func previousButtonTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            
            self.musicPlayer.skipToPreviousItem()
            
            let name = Notification.Name.albumArtNotifacationKey
            NotificationCenter.default.post(name: name, object: nil)
            
            let artistName = Notification.Name.artistNotifacationKey
            NotificationCenter.default.post(name: artistName, object: nil)
            
            let trackName = Notification.Name.trackTitleNotifactionKey
            NotificationCenter.default.post(name: trackName, object: nil)
            
            self.setNowPlayingInfo()
            sender.pulsate()
        }
        
    }
    
    //MARK: - NextButtonTapped Method
    @objc func nextButtonTapped(_ sender: UIButton) {
        
        DispatchQueue.main.async {
            self.musicPlayer.skipToNextItem()
            //Keys for Observers
            let name = Notification.Name.albumArtNotifacationKey
            NotificationCenter.default.post(name: name, object: nil)
            
            let artistName = Notification.Name.artistNotifacationKey
            NotificationCenter.default.post(name: artistName, object: nil)
            
            let trackName = Notification.Name.trackTitleNotifactionKey
            NotificationCenter.default.post(name: trackName, object: nil)
            
            self.setNowPlayingInfo()
            
            sender.pulsate()
        }
    }
    
    //MARK: - Update Album Art
    @objc func updateAlbumArt(notifacation: NSNotification) {
        albumImageView.image = musicPlayer.nowPlayingItem?.artwork?.image(at: albumImageView.bounds.size)
    }
    
    //MARK: - Update Artist
    @objc func updateArtist(notifacation: NSNotification) {
        artistLabel.text = musicPlayer.nowPlayingItem?.artist
    }
    
    //MARK: - Update Track Title
    @objc func updateTrackTitle(notifaction: NSNotification) {
        nowPlayingLabel.text = musicPlayer.nowPlayingItem?.title
    }
    
    //MARK: - Observer for nowPlayingItemDidChange
    @objc func nowPlayingItemDidChange() {
        setNowPlayingInfo()
    }
    
    //MARK: - Set Notification Observer for nowPlayingInfo
    func createObservers() {
        
        //Album
        NotificationCenter.default.addObserver(self, selector: #selector(updateAlbumArt(notifacation:)), name: Notification.Name.albumArtNotifacationKey, object: nil)
        
        //Artist
        NotificationCenter.default.addObserver(self, selector: #selector(updateArtist(notifacation:)), name: Notification.Name.artistNotifacationKey, object: nil)
        
        //Track
        NotificationCenter.default.addObserver(self, selector: #selector(updateTrackTitle(notifaction:)), name: Notification.Name.trackTitleNotifactionKey, object: nil)
        
        //GenreButtonTapped
        NotificationCenter.default.addObserver(self, selector: #selector(genreButtonTapped(_:)), name: Notification.Name.genreButtonTapped, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingItemDidChange), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingItemDidChange()), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
    }
    
    //MARK: - genreButtonTapped Method
    @objc func genreButtonTapped(_ notification: Notification) {
        guard let genre = notification.userInfo?["genre"] as? String else { fatalError("Can't get the genre") }
        
        DispatchQueue.global().async {
            MPMediaLibrary.requestAuthorization { (status) in
                if status == .authorized{
                    DispatchQueue.main.async {
                        self.playGenre(genre: genre)
                    }
                }
            }
        }
        
        setNowPlayingInfo()
        
        DispatchQueue.main.async {
            self.animateTransitionIfNeeded(state: self.nextState, duration: 1.5)
            UIView.animate(withDuration: 0.5) {
                self.albumImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        }
    }
    
    //MARK: - playGenre Method
    func playGenre(genre: String) {
        
        DispatchQueue.global().async {
            MPMediaLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    self.musicPlayer.stop()
                    let query = MPMediaQuery()
                    let predicate = MPMediaPropertyPredicate(value: genre, forProperty: MPMediaItemPropertyGenre)
                    
                    query.addFilterPredicate(predicate)
                    
                    self.musicPlayer.setQueue(with: query)
                    self.musicPlayer.shuffleMode = .songs
                    self.musicPlayer.play()
                }
            })
        }
        
        DispatchQueue.main.async {
            self.setNowPlayingInfo()
        }
        
    }
    
}
