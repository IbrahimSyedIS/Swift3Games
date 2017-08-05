/*
 
  GameViewController.swift
  Aliens

  Created by Ibrahim Syed on 7/27/17.
  Copyright © 2017 Ibrahim Syed. All rights reserved.
 
*/

// Getting all the essentials for the GameViewController
import UIKit
import SpriteKit
import GameplayKit
import AVFoundation
import GoogleMobileAds

// GameViewController is a subclass of UIViewController
class GameViewController: UIViewController {
    
    // titleText: UILabel that displays title on Main Menu and score on the pause menu
    @IBOutlet var titleText: UILabel!
    
    // playButton: Button that triggers the start of the game
    @IBOutlet var playButton: UIButton!
    
    // settingsButton: Button that triggers the settings page
    @IBOutlet var settingsButton: UIButton!
    
    // creditsButton: Button that triggers credits and attributions for art and music
    @IBOutlet var creditsButton: UIButton!
    
    // enemyShipImage: Image that shows the enemy ship on the main menu
    @IBOutlet var enemyShipImage: UIImageView!
    
    // laserImage: Image that shows the laser on the main menu
    @IBOutlet var laserImage: UIImageView!
    
    // playerShipImage: Image that shows the player on the main Menu
    @IBOutlet var playerShipImage: UIImageView!
    
    // backgroundImageView: Image that shows the background image on the main menu
    @IBOutlet var backgroundImageView: UIImageView!
    
    // bannerView: A Google Ads Banner ad to display ads
    var bannerView: GADBannerView!
    
    private let bannerADViewDelegate = BannerADViewDelegate()
    
    // backgroundMusic: Audio object that allows the game to play music in the background; I got it from SO so I don't really know what it means
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
    
    // Main Function that runs when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Global.gameViewController = self
        
        // Plays background music
        backgroundMusic?.play()
        
        // Setting up the bannerView to display ads
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.isAutoloadEnabled = true
        self.view.addSubview(bannerView)
        bannerView.adUnitID = "ca-app-pub-3480761636950180/7011555517"
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
    
    // Function for when the play button is pressed
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
    
    // Just a function to tell the device we don't want it to autorotate
    override var shouldAutorotate: Bool {
        return false
    }

    // Function telling the device we only want the game to play in portrait
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    // Function for when we receive a mem warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // Function to tell the device we want to hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
