/*
 
  MainMenuViewController.swift
  Aliens

  Created by Ibrahim Syed on 7/27/17.
  Copyright © 2017 Ibrahim Syed. All rights reserved.
 
*/

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import GoogleMobileAds

class MainMenuViewController: UIViewController {
    @IBOutlet var titleText: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var creditsButton: UIButton!
    @IBOutlet var enemyShipImage: UIImageView!
    @IBOutlet var laserImage: UIImageView!
    @IBOutlet var playerShipImage: UIImageView!
    @IBOutlet var backgroundImageView: UIImageView!
    var bannerView: GADBannerView!
    
    private let bannerADViewDelegate = BannerADViewDelegate()
    
    // backgroundMusic: Audio object that allows the game to play music in the background; I got it from Stack Overflow so I don't really know what it means
    public lazy var backgroundMusic: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "StealthMode", withExtension: "wav") else {
            return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        } catch {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Global.currentWave = 0
        backgroundMusic?.play()
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.isAutoloadEnabled = true
        self.view.addSubview(bannerView)
        bannerView.adUnitID = "ca-app-pub-8218224422686435/7478295344"
        bannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = [ kGADSimulatorID ]
        bannerView.load(request)
        bannerView.delegate = bannerADViewDelegate
        bannerView.frame = CGRect(x:0.0,
                                  y:self.view.frame.size.height - bannerView.frame.size.height,
                                  width:bannerView.frame.size.width,
                                  height:bannerView.frame.size.height)
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        backgroundMusic?.stop()
    }
    
    public func reStartBackgroundMusic() {
        backgroundMusic?.stop()
        backgroundMusic = nil
        backgroundMusic = {
            guard let url = Bundle.main.url(forResource: "StealthMode", withExtension: "wav") else {
                return nil
            }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = -1
                return player
            } catch {
                return nil
            }
        }()
        backgroundMusic?.play()
        print(backgroundMusic?.isPlaying as Any)
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
