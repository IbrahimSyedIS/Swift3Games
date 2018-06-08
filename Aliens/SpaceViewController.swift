//
//  SpaceViewController.swift
//  Aliens
//
//  Created by Ibrahim Syed on 7/30/17.
//  Copyright © 2017 Ibrahim Syed. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class SpaceViewController: UIViewController {
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var pauseScoreLabel: UILabel!
    @IBOutlet var moneyLabel: UILabel!
    var gameOverLabel: UILabel!

    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var homeButton: UIButton!

    @IBOutlet var coinImage: UIImageView!
    @IBOutlet var coinXImage: UIImageView!

    @IBOutlet var blurEffect: UIVisualEffectView!
    
    var gameScene: GameScene? = nil

    var mainView: SKView!

    let userDefaults = UserDefaults.standard

    var highScore: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Global.spaceViewController = self
        highScore = userDefaults.integer(forKey: "highScore")
        scoreLabel.numberOfLines = 2
        scoreLabel.text = "Score: 0\nHigh Score: \(highScore!)"
        startHiddens()
        mainView = self.view as! SKView
        mainView.ignoresSiblingOrder = true
        mainView.showsNodeCount = true
        presentScene(named: "GameScene")
    }
    
    func startHiddens() {
        pauseScoreLabel.isHidden = true
        homeButton.isHidden = true
        pauseButton.isHidden = false
        scoreLabel.isHidden = false
        coinImage.isHidden = false
        coinXImage.isHidden = false
        moneyLabel.isHidden = false
        blurEffect.alpha = 0
    }
    
    func endHiddens() {
        homeButton.isHidden = false
        pauseScoreLabel.isHidden = false
        scoreLabel.isHidden = true
        pauseButton.isHidden = true
        coinImage.isHidden = true
        coinXImage.isHidden = true
        moneyLabel.isHidden = true
    }
    
    func presentScene(named fileName: String) {
        let scene = SKScene(fileNamed: fileName)
        scene?.scaleMode = .aspectFit
        self.mainView?.presentScene(scene)
        self.gameScene = scene as? GameScene
        if fileName == "GameScene" {
            let newScene = scene as! GameScene
            newScene.gameViewController = self
            newScene.spaceship.autoFire()
        }
    }
    
    func updateScoreLabel() {
        guard let gameScene = gameScene else {
            return
        }
        if gameScene.score > highScore {
            highScore = gameScene.score
            userDefaults.set(gameScene.score, forKey: "highScore")
        }
        scoreLabel.text = "Score: \(gameScene.score)\nHigh Score: \(highScore!)"
        pauseScoreLabel.text = "Score: \(gameScene.score)"
    }
    
    public func updateMoney(with add: Int) {
        moneyLabel.text = String(Int(moneyLabel.text!)! + add)
    }
    
    public func gameOver() {
        guard let gameScene = gameScene else {
            return
        }
        if (gameScene.gamePaused) {
            return
        }
        gameScene.pauseGame()
        endHiddens()
        gameOverLabel = UILabel()
        gameOverLabel.text = "Game Over"
        gameOverLabel.font = UIFont(name: "kenvector_future.ttf", size: CGFloat(50))
        gameOverLabel.textAlignment = .center
        self.view.addSubview(gameOverLabel)
    }
    
    @IBAction func homeButtonPressed(_ sender: Any) {
        guard let gameScene = gameScene else {
            return
        }
        gameScene.pauseGame()
        dismiss(animated: true, completion: nil)
        let mainViewController = self.storyboard?.instantiateInitialViewController()
        let mainGameViewController = mainViewController as! MainMenuViewController
        mainGameViewController.reStartBackgroundMusic()
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        guard let gameScene = gameScene else {
            return
        }
        if (!gameScene.gamePaused) {
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
            gameScene.pauseGame()
            pauseScoreLabel.text = "Score: \(gameScene.score)"
        } else {
            UIView.animate(withDuration: 0.2) {
                self.blurEffect.alpha = 0
            }
            pauseButton.setImage(UIImage(named: "PauseButton.png"), for: .normal)
            gameScene.spaceship.autoFire()
            gameScene.resumeGame()
            startHiddens()
        }
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
