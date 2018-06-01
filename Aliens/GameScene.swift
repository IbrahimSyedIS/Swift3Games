/*
 
  GameScene.swift
  Aliens

  Created by Ibrahim Syed on 7/27/17.
  Copyright © 2017 Ibrahim Syed. All rights reserved.

  TODO: The list of goals that I have to accomplish before I can publish
 
  Major TODO: Items(Power Ups), Levels, Rewards + Upgrades, Different Enemy Ships (Bosses?)
 
  Minor TODO: Player Health, More backdrops
 
  Files:
  [GameScene.sks, laserHit.sks, SKEnemyNode.swift, SKCoinNode.swift,
  AppDelegate.swift, GamePhysicsDelegate.swift, BannerADViewDelegate.swift,
  GameScene.swift, GameSceneViewController.swift, GameViewController.swift,
  UpgradeViewController.swift, CreditsViewController.swift, Main.storyboard,
  LaunchScreen.storyboard, Assets.xcassets, Info.plist, Sounds, kenvector_future]

*/

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var spaceship: SKPlayerNode!
    var laserFireSound = SKAction.playSoundFileNamed("Laser_Shoot.mp3", waitForCompletion: false)
    var backgroundMusicNode: SKAudioNode!
    var starParticleEffect: SKEmitterNode!
    
    public var gameViewController: GameSceneViewController!
    public var timer: Timer!
    var physicsContactDelegate: GamePhysicsDelegate!
    private var numSinceLastLevelPush: Int = 0
    
    /** BitMask values that represent what categories and object will physically collide with in \(UInt32) form **/
    var playerMask: UInt32 = 0
    var laserMask: UInt32 = 0
    var enemyMask: UInt32 = 0
    
    // 2D Levels array represents all enemies as ints and each row is a level. [1, 1, 1] -> one level with three type 1 enemies
    var levels: [[Int]] = [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                           [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                           [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]

    //Test Level made until more streamlined 2D level system is made
    private var testLevel: [Int] = [1, 1, 1, 1, 1, 1]
    
    private var playerSpeed: Int = 0
    public var score: Int = 0
    public var gamePaused: Bool = false

    override func didMove(to view: SKView) {
        Global.gameScene = self
        physicsContactDelegate = GamePhysicsDelegate()
        physicsContactDelegate.gameScene = self
        self.physicsWorld.contactDelegate = physicsContactDelegate
        
        // Modifying masks to control what collides with what e.g. laserMask = enemyCat | playerCat -> lasers collide with enemies and players
        playerMask = GamePhysicsDelegate.itemCat
        laserMask = GamePhysicsDelegate.enemyCat | GamePhysicsDelegate.playerCat
        enemyMask = GamePhysicsDelegate.laserCat | GamePhysicsDelegate.enemyCat
        
        spaceship = self.childNode(withName: "spaceship") as! SKPlayerNode
        prepareSpaceship()
        playerSpeed = spaceship.getMoveSpeed()
        starParticleEffect = self.childNode(withName: "Stars") as! SKEmitterNode
        
        backgroundMusicNode = getBackgroundMusic(fileName: "GalaxyForce.wav")
        backgroundMusicNode.run(SKAction.changeVolume(to: 5, duration: 0))
        self.addChild(backgroundMusicNode)
        
        // Beginning the game
        if (enemiesLeft() == 0) {
            beginGame()
        }
    }
    
    private func getBackgroundMusic(fileName: String) -> SKAudioNode {
        let backgroundMusic = SKAudioNode(fileNamed: fileName)
        backgroundMusic.autoplayLooped = true
        return backgroundMusic
    }
    
    private func prepareSpaceship() {
        spaceship.createHealthBar()
        spaceship.physicsBody?.categoryBitMask = GamePhysicsDelegate.playerCat
        
        // Collision bitmask -> physically collides + interacts with
        spaceship.physicsBody?.collisionBitMask = playerMask | GamePhysicsDelegate.enemyCat
        
        // Contact bitmask -> Calls collision method on contact
        spaceship.physicsBody?.contactTestBitMask = playerMask | GamePhysicsDelegate.enemyCat
        spaceship.physicsBody?.allowsRotation = false
        spaceship.coinGravity()
        spaceship.health -= 95
        
        // rockets at bottom of ship
        let spaceshipAnimations = [SKTexture(imageNamed: "Spaceship1.png"), SKTexture(imageNamed: "Spaceship2.png"),
                                   SKTexture(imageNamed: "Spaceship3.png"), SKTexture(imageNamed: "Spaceship4.png"),
                                   SKTexture(imageNamed: "Spaceship5.png"), SKTexture(imageNamed: "Spaceship6.png"),
                                   SKTexture(imageNamed: "Spaceship7.png"), SKTexture(imageNamed: "Spaceship8.png")]
        let spaceshipAnimation = SKAction.repeatForever(SKAction.animate(with: spaceshipAnimations, timePerFrame: 0.05))
        spaceship.run(spaceshipAnimation)
    }

    // Called on user Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let distance = abs(touches.first!.location(in: self).x - spaceship.position.x)
        let actionMove = SKAction.move(to: CGPoint(x: touches.first!.location(in: self).x, y: -450), duration: Double(distance / CGFloat(playerSpeed)))
        spaceship.run(actionMove)
    }
    
    // Called when player moves finger
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let distance = abs(touch.location(in: self).x - spaceship.position.x)
            let actionMove = SKAction.move(to: CGPoint(x: touch.location(in: self).x, y: -450), duration: Double(distance / CGFloat(playerSpeed)))
            spaceship.run(actionMove)
        }
    }
    
    // Called once every frame
    override func update(_ currentTime: TimeInterval) {
        numSinceLastLevelPush += 1
        if (enemiesLeft() == 0 && numSinceLastLevelPush >= 25 && !self.gamePaused) {
            nextLevel()
            numSinceLastLevelPush = 0
        }
    }

    private func enemiesLeft() -> Int {
        var count = 0;
        for child in children {
            if let enemy = child as? SKEnemyNode {
                if (enemy.parent != nil) {
                    count += 1
                }
            }
        }
        return count
    }
    
    public func updateMoney(with add: Int) {
        gameViewController.updateMoney(with: add)
    }
    
    // Beginning the game, will be revamped later
    func beginGame() {
        nextLevel()
    }
    
    private func nextLevel() {
        if (testLevel.count <= 0) {
            return
        }
        Global.currentWave += 1
        let waveLabel = createWaveLabel(wave: Global.currentWave)
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        let wait = SKAction.wait(forDuration: 4)
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let disappear = SKAction.removeFromParent()
        let labelSequence = SKAction.sequence([fadeIn, wait, fadeOut, disappear])
        waveLabel.move(toParent: self)
        waveLabel.run(labelSequence) {
            waveLabel.removeFromParent()
        }
        let sep = self.size.width / CGFloat(3)
        let firstX = 0 - sep
        for enemy in 0..<3 {
            self.spawnEnemy(at: CGPoint(x: firstX + (sep * CGFloat(enemy)), y : 750), ofType: testLevel[0])
            Global.currentMaxScore += testLevel.remove(at: 0) * 100
        }
    }
    
    private func createWaveLabel(wave: Int) -> SKLabelNode {
        let waveLabel = SKLabelNode(text: "Wave \(wave)")
        waveLabel.position = CGPoint(x: 0, y: 450)
        waveLabel.fontSize = 50
        waveLabel.alpha = 0
        waveLabel.fontName = "kenvector_future"
        return waveLabel
    }
    
    private func endlessMode() {
        // TODO
    }
    
    func spawnEnemy(at position: CGPoint, ofType type: Int) {
        var enemy: SKEnemyNode
        var enemyAnimations: [SKTexture]
        switch type {
        case 1:
            enemy = SKEnemyNode(imageNamed: "enemy")
            enemyAnimations = [SKTexture(imageNamed: "enemy0"), SKTexture(imageNamed: "enemy1"),
                               SKTexture(imageNamed: "enemy2"), SKTexture(imageNamed: "enemy3"),
                               SKTexture(imageNamed: "enemy4"), SKTexture(imageNamed: "enemy5"),
                               SKTexture(imageNamed: "enemy6"), SKTexture(imageNamed: "enemy7"),
                               SKTexture(imageNamed: "enemy8")]
            enemy.xScale = 0.4
            enemy.yScale = 0.4
        case 2:
            enemy = SKEnemyNode(imageNamed: "enemy")
            enemyAnimations = []
        default:
            enemy = SKEnemyNode(imageNamed: "enemy")
            enemyAnimations = []
        }
        enemy = prepareEnemy(enemy: enemy)
        enemy.run(SKAction.repeatForever(SKAction.animate(with: enemyAnimations, timePerFrame: 0.1)))
        enemy.move(toParent: self)
        enemy.position = position
        let enemyMove = SKAction.move(to: CGPoint(x: enemy.position.x, y: CGFloat(-750)), duration: 23)
        enemy.run(SKAction.sequence([enemyMove, SKAction.removeFromParent()]), withKey: "enemyMove")
        enemy.autoFire()
    }
    
    private func prepareEnemy(enemy: SKEnemyNode) -> SKEnemyNode {
        enemy.createHealthBar()
        enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = GamePhysicsDelegate.enemyCat
        enemy.physicsBody?.collisionBitMask = enemyMask
        enemy.physicsBody?.contactTestBitMask = enemyMask
        enemy.physicsBody?.fieldBitMask = 0
        return enemy
    }
    
    public func pauseGame() {
        gamePaused = true
        backgroundMusicNode.run(SKAction.changeVolume(to: 0.0, duration: 0.3))
        starParticleEffect.isPaused = true
        
        for child in children {
            if let enemy = child as? SKEnemyNode {
                enemy.pauseEnemy()
            }
            if let action = child.action(forKey: "enemyMove") {
                action.speed = 0
                if let subChild = child.children.first {
                    subChild.action(forKey: "enemyMove")?.speed = 0
                }
            }
        }
    }
    
    func resumeGame() {
        gamePaused = false
        backgroundMusicNode.run(SKAction.changeVolume(to: 5, duration: 0.3))
        starParticleEffect.isPaused = false
        for child in self.children {
            if let action = child.action(forKey: "enemyMove") {
                action.speed = 1
            }
        }
    }
    
    public func spaceshipFire() {
        let laser = getLaser()
        laser.move(toParent: self)
        laser.position = CGPoint(x: spaceship.position.x, y: spaceship.position.y + 100)
        run(laserFireSound)
        let laserAction = SKAction.moveBy(x: CGFloat(0), y: CGFloat(1200), duration: 1)
        let laserActions = SKAction.sequence([laserAction, SKAction.removeFromParent()])
        laser.run(laserActions, withKey: "enemyMove")
    }
    
    private func getLaser() -> SKSpriteNode {
        let laser: SKSpriteNode = SKSpriteNode(imageNamed: "Laser")
        laser.physicsBody = SKPhysicsBody(texture: laser.texture!, size: laser.size)
        laser.physicsBody?.affectedByGravity = false
        laser.physicsBody?.categoryBitMask = GamePhysicsDelegate.laserCat
        laser.physicsBody?.collisionBitMask = laserMask
        laser.physicsBody?.contactTestBitMask = laserMask
        laser.physicsBody?.fieldBitMask = 0
        return laser
    }
}
