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
    @IBOutlet var coinImage: UIImageView!
    @IBOutlet var coinXImage: UIImageView!
    @IBOutlet var moneyLabel: UILabel!
    
    var gameOverLabel: UILabel!
    var gameScene: SKScene? = nil
    var mainView: SKView? = nil
    var timer: Timer!
    let userDefaults = UserDefaults.standard
    var highScore: Int!
    private var fireRate = 0.4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Global.gameSceneViewController = self
        highScore = userDefaults.integer(forKey: "highScore")
        scoreLabel.text = "Score: 0                                        High Score: \(highScore!)"
        blurEffect.alpha = 0
        pauseScoreLabel.isHidden = true
        homeButton.isHidden = true
        pauseButton.isHidden = false
        scoreLabel.isHidden = false
        coinImage.isHidden = false
        coinXImage.isHidden = false
        moneyLabel.isHidden = false
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
    
    func updateScoreLabel() {
        let newScene = gameScene as! GameScene
        if newScene.score > highScore {
            highScore = newScene.score
            userDefaults.set(newScene.score, forKey: "highScore")
        }
        scoreLabel.text = "Score: \(newScene.score)                                        High Score: \(highScore!)"
        pauseScoreLabel.text = "Score: \(newScene.score)"
    }
    
    public func updateMoney(with add: Int) {
        moneyLabel.text = String(Int(moneyLabel.text!)! + add)
    }
    
    public func gameOver() {
        if let newGameScene = gameScene as? GameScene {
            if (newGameScene.gamePaused) {
                return
            }
            newGameScene.pauseGame()
            homeButton.isHidden = false
            pauseScoreLabel.isHidden = false
            scoreLabel.isHidden = true
            pauseButton.isHidden = true
            coinImage.isHidden = true
            coinXImage.isHidden = true
            moneyLabel.isHidden = true
            timer.invalidate()
            gameOverLabel = UILabel()
            gameOverLabel.text = "Game Over"
            gameOverLabel.font = UIFont(name: "kenvector_future", size: CGFloat(50))
            gameOverLabel.textAlignment = .center
            self.view.addSubview(gameOverLabel)
        }
        
    }
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        let newGameScene = gameScene as! GameScene
        newGameScene.pauseGame()
        dismiss(animated: true, completion: nil)
        let mainViewController = self.storyboard?.instantiateInitialViewController()
        let mainGameViewController = mainViewController as! GameViewController
        mainGameViewController.reStartBackgroundMusic()
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        let newGameScene = gameScene as! GameScene
        if (!newGameScene.gamePaused) {
            UIView.animate(withDuration: 0.1, animations: {
                self.blurEffect.alpha = 1
            }, completion: { (nil) in
                self.pauseScoreLabel.isHidden = false
                self.homeButton.isHidden = false
            })
            pauseButton.setImage(UIImage(named: "backButton.png"), for: .normal)
            scoreLabel.isHidden = true
            coinImage.isHidden = true
            coinXImage.isHidden = true
            moneyLabel.isHidden = true
            timer.invalidate()
            newGameScene.pauseGame()
            pauseScoreLabel.text = "Score: \(newGameScene.score)"
        } else {
            UIView.animate(withDuration: 0.2) {
                self.blurEffect.alpha = 0
            }
            pauseButton.setImage(UIImage(named: "PauseButton.png"), for: .normal)
            autoFire()
            newGameScene.resumeGame()
            scoreLabel.isHidden = false
            coinImage.isHidden = false
            coinXImage.isHidden = false
            moneyLabel.isHidden = false
            homeButton.isHidden = true
            pauseScoreLabel.isHidden = true
        }
    }
    
    func autoFire() {
        timer = Timer.scheduledTimer(withTimeInterval: fireRate, repeats: true, block: { (nil) in
            self.fireLaser()
        })
    }
    
    func fireLaser() {
        let newGameScene = gameScene as! GameScene
        newGameScene.spaceshipFire()
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
