//
//  UpgradeViewController.swift
//  Aliens
//
//  Created by Ibrahim Syed on 7/31/17.
//  Copyright © 2017 Ibrahim Syed. All rights reserved.
//

import SpriteKit
import GameplayKit
import GoogleMobileAds

class UpgradeViewController: UIViewController, GADInterstitialDelegate {
    
    @IBOutlet var speedButton: UIButton!
    @IBOutlet var speedProgressBar: UIProgressView!
    var interstitial: GADInterstitial!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if interstitial != nil && interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        }
        
    }
    
    override func viewDidLoad() {
        
        speedButton.isHidden = true
        speedProgressBar.isHidden = true
        
        speedProgressBar.progress = 0.1
        speedButton.adjustsImageWhenDisabled = false
        speedButton.setTitle("upgrade speed", for: .highlighted)
        
        interstitial = createAndLoadInterstitial()
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitialT = GADInterstitial(adUnitID: "ca-app-pub-3480761636950180/7107542838")
        interstitialT.delegate = self
        let requestT = GADRequest()
        requestT.testDevices = [ kGADSimulatorID ]
        interstitialT.load(requestT)
        return interstitialT
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }
    
    @IBAction func goBackPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upgradeSpeed(_ sender: UIButton) {
        if speedProgressBar.progress < 1 {
            speedProgressBar.progress += 0.1
        }
        if speedProgressBar.progress == 1 {
            speedButton.setTitle("MAX SPEED", for: .normal)
            speedButton.setTitle("MAX SPEED", for: .highlighted)
            speedButton.setTitle("MAX SPEED", for: .disabled)
            speedButton.isEnabled = false
        }
    }
    
    // Function to tell the device we want to hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
