//
//  GameSceneViewController.swift
//  Aliens
//
//  Created by Ibrahim Syed on 7/30/17.
//  Copyright © 2017 Ibrahim Syed. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameSceneViewController: UIViewController {
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var pauseScoreLabel: UILabel!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var blurEffect: UIVisualEffectView!
    @IBOutlet var homeButton: UIButton!
    
    var gameScene: SKScene? = nil
    var mainView: SKView? = nil
    
    var timer: Timer!
    
    let userDefaults = UserDefaults.standard
    
    var highScore: Int!
    
    private var fireRate = 0.4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        highScore = userDefaults.integer(forKey: "highScore")
        
        scoreLabel.text = "Score: 0                                        High Score: \(highScore!)"
        
        blurEffect.alpha = 0
        
        pauseScoreLabel.isHidden = true
        homeButton.isHidden = true
        
        if let view = self.view as! SKView? {
            self.mainView = view
            view.ignoresSiblingOrder = true
            view.showsNodeCount = true
            presentScene(named: "GameScene")
        }
    }
    
    func presentScene(named fileName: String) {
        if let scene = SKScene(fileNamed: fileName) {
            scene.scaleMode = .aspectFit
            self.mainView?.presentScene(scene)
            self.gameScene = scene
            if fileName == "GameScene" {
                let newScene = scene as! GameScene
                newScene.gameViewController = self
                autoFire()
            }
        }
    }
    
    // Function to update the score label within the game
    func updateScoreLabel() {
        
        // Getting the GameScene
        let newScene = gameScene as! GameScene
        
        // Checking if the new score is higher than the high score
        if newScene.score > highScore {
            
            // If it is than update high score
            highScore = newScene.score
            
            // And store the value
            userDefaults.set(newScene.score, forKey: "highScore")
        }
        
        // Updating the label on-screen
        scoreLabel.text = "Score: \(newScene.score)                                        High Score: \(highScore!)"
    }
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        let newGameScene = gameScene as! GameScene
        newGameScene.pause()
        dismiss(animated: true, completion: nil)
        let mainViewController = self.storyboard?.instantiateInitialViewController()
        let mainGameViewController = mainViewController as! GameViewController
        mainGameViewController.reStartBackgroundMusic()
    }
    
    // Function for when the pause button is pressed
    @IBAction func pauseButtonPressed(_ sender: Any) {
        
        // Getting the gameScene
        let newGameScene = gameScene as! GameScene
        
        // Checking if the game is paused
        if (!newGameScene.gamePaused) {
            
            // If the game is running, first we animate in the blur effect
            UIView.animate(withDuration: 0.1, animations: {
                
                // By Setting the alpha to 1 to show it
                self.blurEffect.alpha = 1
            }, completion: { (nil) in
                
                // We show the relevant buttons
                self.pauseScoreLabel.isHidden = false
            })
            
            // Then we make the pause button a return button
            pauseButton.setImage(UIImage(named: "backButton.png"), for: .normal)
            
            // We hide the irrelevant stuff label
            scoreLabel.isHidden = true
            homeButton.isHidden = false
            
            // We stop the autofire by invalidating the timer that automatically fires
            timer.invalidate()
            
            // We pause the GameScene
            newGameScene.pause()
            
            // We make the title text a score text
            pauseScoreLabel.text = "Score: \(newGameScene.score)"
        } else {
            
            // If the game is paused, then the button was already pressed, so we animate out the blur effect
            UIView.animate(withDuration: 0.2) {
                self.blurEffect.alpha = 0
            }
            
            // Then we make the return button a pause button
            pauseButton.setImage(UIImage(named: "PauseButton.png"), for: .normal)
            
            // We restart the autofire
            autoFire()
            
            // Unpause the GameScene
            newGameScene.unPause()
            
            // We show the relevant items again
            scoreLabel.isHidden = false
            homeButton.isHidden = true
            
            // We hide the buttons from the pause screen
            pauseScoreLabel.isHidden = true
        }
    }
    
    // Function for ship's continuous automatic fire
    func autoFire() {
        
        // This is basically a timer that every \(fireRate) tells the user's ship to fire a laser
        timer = Timer.scheduledTimer(withTimeInterval: fireRate, repeats: true, block: { (nil) in
            
            // The function that tells the ship to fire is called
            self.fireLaser()
        })
    }
    
    // Function for firing the ship's laser
    func fireLaser() {
        
        // First we get the GameScene
        let newGameScene = gameScene as! GameScene
        
        // Then we call the function in the GameScene that fires the ship's laser
        newGameScene.spaceshipFire()
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
