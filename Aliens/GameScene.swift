/*
 
  GameScene.swift
  Aliens

  Created by Ibrahim Syed on 7/27/17.
  Copyright © 2017 Ibrahim Syed. All rights reserved.

  TODO: The list of goals that I have to accomplish before I can publish
 
  Major TODO: Items(Power Ups), Levels, Rewards + Upgrades, Different Enemy Ships (Bosses?)
 
  Minor TODO: Player Health, More backdrops

*/

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var spaceship: SKPlayerNode!
    var backgroundMusicNode: SKAudioNode!
    var starParticleEffect: SKEmitterNode!
    
    public var gameViewController: SpaceViewController!
    public var timer: Timer!
    private var numSinceLastLevelPush: Int = 0
    
    private var physicsContactDelegate: GamePhysicsDelegate!
    
    /** BitMask values that represent what categories and object will physically collide with in \(UInt32) form **/
    
    // 2D Levels array represents all enemies as ints and each row is a level. [1, 1, 1] -> one level with three type 1 enemies
    private var levels: [[Int]] = [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                                   [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                                   [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]

    //Test Level made until more streamlined 2D level system is made
    private var testLevel: [Int] = [1, 2, 1, 1, 2, 1, 2, 3, 2]
    
    private var playerSpeed: Int = 0
    public var score: Int = 0
    public var gamePaused: Bool = false

    override func didMove(to view: SKView) {
        physicsContactDelegate = GamePhysicsDelegate(to: self)
        self.physicsWorld.contactDelegate = physicsContactDelegate
        spaceship = self.childNode(withName: "spaceship") as! SKPlayerNode
        prepareSpaceship()
        playerSpeed = spaceship.getMoveSpeed()
        starParticleEffect = self.childNode(withName: "Stars") as! SKEmitterNode
        backgroundMusicNode = getBackgroundMusic(fileName: "GalaxyForce.wav")
        backgroundMusicNode.run(SKAction.changeVolume(to: 5, duration: 0))
        self.addChild(backgroundMusicNode)
        
        // Beginning the game
//        startDialogue()
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
        spaceship.updateHealthBar()
        spaceship.physicsBody?.categoryBitMask = GamePhysicsDelegate.playerCat
        
        // Collision bitmask -> physically collides + interacts with
        spaceship.physicsBody?.collisionBitMask = GamePhysicsDelegate.playerMask
        
        // Contact bitmask -> Calls collision method on contact
        spaceship.physicsBody?.contactTestBitMask = GamePhysicsDelegate.playerMask | GamePhysicsDelegate.enemyCat
        spaceship.physicsBody?.allowsRotation = false
        spaceship.coinGravity()
        
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
            // TODO: CHANGE THIS BACK WHEN YOU ARE DONE TESTING SKDIALOGUENODE + SKBOSSNODE
            numSinceLastLevelPush = 0
        }
    }

    /**
     # Number of Enemies Left
     
     Tells you how many enemies are left at any given moment.
     
     - Returns: The number of remaining enemies
     */
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
    
    // Beginning the game, will be revamped later
    func beginGame() {
        nextLevel()
    }
    
    private func nextLevel() {
        if (testLevel.count <= 0) {
            endlessMode()
            return
        }
        Global.currentWave += 1
        let waveLabel = createWaveLabel(wave: Global.currentWave)
        let labelSequence = SKAction.sequence([SKAction.fadeIn(withDuration: 1),
                                               SKAction.wait(forDuration: 4),
                                               SKAction.fadeOut(withDuration: 1),
                                               SKAction.removeFromParent()])
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
        waveLabel.fontName = "KenVector Future"
        return waveLabel
    }
    
    private func startDialogue() {
        let dNode = SKDialogueNode(texture: SKTexture(imageNamed: "buttonBlue"), size: CGSize(width: 680, height: 140), dialogue: "Welcome!")
        self.addChild(dNode)
        dNode.showDialogue()
    }
    
    private func endlessMode() {
        // TODO: Do This
        Global.currentWave += 1
        let sep = self.size.width / CGFloat(4)
        let firstX = 0 - (self.size.width / CGFloat(3))
        for enemy in 0..<4 {
            self.spawnEnemy(at: CGPoint(x: firstX + (sep * CGFloat(enemy)), y: 750), ofType: Int(arc4random_uniform(3) + 1))
            Global.currentMaxScore += 100
        }
    }
    
    func spawnEnemy(at position: CGPoint, ofType type: Int) {
        var enemy: SKEnemyNode
        switch type {
        case 1:
//            enemyAnimations = [SKTexture(imageNamed: "enemy0"), SKTexture(imageNamed: "enemy1"),
//                               SKTexture(imageNamed: "enemy2"), SKTexture(imageNamed: "enemy3"),
//                               SKTexture(imageNamed: "enemy4"), SKTexture(imageNamed: "enemy5"),
//                               SKTexture(imageNamed: "enemy6"), SKTexture(imageNamed: "enemy7"),
//                               SKTexture(imageNamed: "enemy8")]
            enemy = SKEnemyNode(imageNamed: "enemy", animations: [])
            enemy.xScale = 0.15
            enemy.yScale = 0.15
        case 2:
            enemy = SKEnemyNode(imageNamed: "blackship1", animations: [])
            enemy.normalTexture = SKTexture(imageNamed: "blackship1normal")
        case 3:
            enemy = SKEnemyNode(imageNamed: "blackship2", animations: [])
            enemy.normalTexture = SKTexture(imageNamed: "blackship2normal")
        default:
            enemy = SKEnemyNode(imageNamed: "enemy", animations: [])
        }
        enemy.move(toParent: self)
        enemy.position = position
        enemy.startMoving()
    }
    
    public func pauseGame() {
        gamePaused = true
        backgroundMusicNode.run(SKAction.changeVolume(to: 0.0, duration: 0.3))
        starParticleEffect.isPaused = true
        children.forEach { (child) in
            (child as? SKCharacterNode)?.pause()
            (child as? SKCoinNode)?.action(forKey: "enemyMove")?.speed = 0
        }
    }
    
    func resumeGame() {
        gamePaused = false
        backgroundMusicNode.run(SKAction.changeVolume(to: 5, duration: 0.3))
        starParticleEffect.isPaused = false
        children.forEach { (child) in
            child.action(forKey: "enemyMove")?.speed = 1
        }
    }
}
