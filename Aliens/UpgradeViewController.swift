//
//  UpgradeViewController.swift
//  Aliens
//
//  Created by Ibrahim Syed on 7/31/17.
//  Copyright © 2017 Ibrahim Syed. All rights reserved.
//

import SpriteKit
import GameplayKit

class UpgradeViewController: UIViewController {
    
    @IBOutlet var speedButton: UIButton!
    @IBOutlet var speedProgressBar: UIProgressView!
    
    override func viewDidLoad() {
        
        speedButton.isHidden = true
        speedProgressBar.isHidden = true
        
        speedProgressBar.progress = 0.1
        speedButton.adjustsImageWhenDisabled = false
        speedButton.setTitle("upgrade speed", for: .highlighted)
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
