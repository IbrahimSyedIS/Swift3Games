/*
 
  GameScene.swift
  Aliens

  Created by Ibrahim Syed on 7/27/17.
  Copyright © 2017 Ibrahim Syed. All rights reserved.
 
*/

/*

 TODO: The list of goals that I have to accomplish before I can publish
 
 Major TODO: Items(Power Ups), Levels, Rewards + Upgrades, Different Enemy Ships (Bosses?)
 
 Minor TODO: Player Health, More backdrops

*/

/*

 Journal:
 
 First Entry, Mon Jul 31st:
    So today I managed to make all the buttons work and added in some coins. I separated the physics delegate and moved the gamescene to a different view controller. I also managed to add in Google Ads but since I'm too afraid to use anything other than the test id, I won't know if it works until release. Coins are still a work in progress, I need to get them to spin and add noises for their collection. As of today, the Aliens folder files are as follows: [GameScene.sks, laserHit.sks, SKEnemyNode.swift, SKCoinNode.swift, AppDelegate.swift, GamePhysicsDelegate.swift, BannerADViewDelegate.swift, GameScene.swift, GameSceneViewController.swift, GameViewController.swift, UpgradeViewController.swift, CreditsViewController.swift, Main.storyboard, LaunchScreen.storyboard, Assets.xcassets, Info.plist, Sounds, kenvector_future]. Targetted release date is sometime before school starts. I still need to fully document all the code in the new files for later reference. Finally, I have to make the enemies shoot back and add in different enemies soon. If all goes well, I should be able to request the developer account while in Kolkata and submit the app for review before we leave India.
 
 Tue August 1st:
 
 
*/
 
// Importing the essentials
import SpriteKit
import GameplayKit

// GameScene is a subclass of SKScene
class GameScene: SKScene {
    
    // spaceship: Reference to the player spaceship sprite in the GameScene
    var spaceship: SKSpriteNode!
    
    // laserFireSound: An action that plays the laser fire sound
    var laserFireSound = SKAction.playSoundFileNamed("Laser_Shoot.mp3", waitForCompletion: false)
    
    // backgroundMusicNode: An Audio Node that plays the background music for the game
    var backgroundMusicNode: SKAudioNode!
    
    // starParticleEffect: Reference to the Star Particle Effect in the GameScene
    var starParticleEffect: SKEmitterNode!
    
    // gameViewController: A reference to the GameViewController that called this GameScene
    public var gameViewController: GameSceneViewController!
    
    private var timer: Timer!
    
    // physicsContactDelegate: A variable that holds the delegate for the contact 
    var physicsContactDelegate: GamePhysicsDelegate!
    
    /** BitShifted binary values that represent the categories of the physics bodies in \(UInt32) form **/
    
    // BitMask for objects that won't collide with anything
    let noCat: UInt32 = 0b1
    
    // BitMask for the payer object
    let playerCat: UInt32 = 0b1 << 1
    
    // BitMask for enemy objects
    let enemyCat: UInt32 = 0b1 << 2

    // BitMask for laser objects
    let laserCat: UInt32 = 0b1 << 3
    
    // BitMask for items/powerups (See Major TODO)
    let itemCat: UInt32 = 0b1 << 4
    
    /** BitMask values that represent what categories and object will physically collide with in \(UInt32) form **/
    
    // BitMask for the player object
    var playerMask: UInt32 = 0
    
    // BitMask for laser objects
    var laserMask: UInt32 = 0
    
    // BitMask for enemy objects
    var enemyMask: UInt32 = 0
    
    /* The levels array is special. It tells the program how to start the levels. When a "WAIT" is present, the game waits for the previous enemies to be killed. I still have to think of a way to check for that. Anyways, I'll have 10 different types of enemies.  */
    
    // 2 Dimensional Array of Integer Arrays that represents the order of the levels
    var levels: [[Int]] = [[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                           [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
                           [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]]
    
    // Private Int that represents the speed of the player in pixels per second
    private var playerSpeed = 625
    
    // Public Int that represents the score of the player
    public var score: Int = 0
    
    // Public Bool that tells the GameScene and all other relevant objects that the game is paused
    public var gamePaused: Bool = false

    // Function that is called when the GameScene is presented
    override func didMove(to view: SKView) {
        
        // Assigning the instance variable for the contact delegate to a new instance of the Game Physics Delegate
        physicsContactDelegate = GamePhysicsDelegate()
        
        // Specifying that the gameScene delegating over the collision handling is this gameScene
        physicsContactDelegate.gameScene = self
        
        // Assigning this physics world's physics delegate to the GamePhysicsDelegate so that we can handle coliisions
        self.physicsWorld.contactDelegate = physicsContactDelegate
        
        // Assigning the playerMask to itemCat so that the player will only trigger collisions with items
        playerMask = itemCat
        
        // Assigning the laserMask to enemyCat so that it only triggers collisions with enemies
        laserMask = enemyCat | playerCat
        
        // Assigning the enemyMask to laserCat and enemyCat so that it triggers collisions with lasers and enemies
        enemyMask = laserCat | enemyCat
        
        // Assigning the spaceship reference to the player ship sprite in the GameScene
        spaceship = self.childNode(withName: "spaceship") as! SKSpriteNode
        
        // Assigning the starParticleEffect reference to the Emitter Node in the GameScene
        starParticleEffect = self.childNode(withName: "Stars") as! SKEmitterNode
        
        /** Assigning the spaceships physics properties to previously calculated values **/
        
        // Assigning the spaceship's categoryMask to the player category
        spaceship.physicsBody?.categoryBitMask = playerCat
        
        // Assigning the colision bit mask to 0 so that the ship physically collides with nothing, but...
        spaceship.physicsBody?.collisionBitMask = playerMask | enemyCat
        
        // ...Assigning the contact bit mask to the playerMask from before so that it calls the collision function when it collides with items/powerups
        spaceship.physicsBody?.contactTestBitMask = playerMask | enemyCat
        
        spaceship.physicsBody?.allowsRotation = false
        
        
        
        let specialShip = spaceship as! SKPlayerNode
        specialShip.coinGravity()
        
        // Creating an array that holds the textures for the spaceship animations (rocket fire)
        let spaceshipAnimations = [SKTexture(imageNamed: "Spaceship1.png"), SKTexture(imageNamed: "Spaceship2.png"),
                                   SKTexture(imageNamed: "Spaceship3.png"), SKTexture(imageNamed: "Spaceship4.png"),
                                   SKTexture(imageNamed: "Spaceship5.png"), SKTexture(imageNamed: "Spaceship6.png"),
                                   SKTexture(imageNamed: "Spaceship7.png"), SKTexture(imageNamed: "Spaceship8.png")]
        
        // Creating the animation action with texture array
        let spaceshipAnimation = SKAction.repeatForever(SKAction.animate(with: spaceshipAnimations, timePerFrame: 0.1))
        
        // Telling the spaceship to run the animation so that it looks alive
        spaceship.run(spaceshipAnimation)
        
        // Creating an audio node for the background music in game
        let backgroundMusic = SKAudioNode(fileNamed: "GalaxyForce.wav")
        
        // Making the background music loop
        backgroundMusic.autoplayLooped = true
        
        // Assigning the instance variable to the method variable
        backgroundMusicNode = backgroundMusic
        
        // Increasing the volume of the backgound music node since it's pretty quite compared to the laser sounds
        backgroundMusicNode.run(SKAction.changeVolume(to: 5, duration: 0))
        
        // Adding the audio node to the GameScene
        self.addChild(backgroundMusic)
        
        // Beginning the game
        beginGame()
    }

    // Function for when the user touches the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Calculating the distance between touch location and the spaceship
        let distance = abs(touches.first!.location(in: self).x - spaceship.position.x)
        
        // Creating an action that changes the spaceships x at the player speed but keeps the y
        let actionMove = SKAction.move(to: CGPoint(x: touches.first!.location(in: self).x, y: -450), duration: Double(distance / CGFloat(playerSpeed)))
        
        // Adds said action to the spaceship to move it
        spaceship.run(actionMove)
    }
    
    // Function for when the player moves their finger on the screen
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Looping through the touches in the passed in set
        for touch in touches {
            
            // See /(touchesBegan())
            let distance = abs(touch.location(in: self).x - spaceship.position.x)
            let actionMove = SKAction.move(to: CGPoint(x: touch.location(in: self).x, y: -450), duration: Double(distance / CGFloat(playerSpeed)))
            spaceship.run(actionMove)
        }
    }
    
    // Function called every frame
    override func update(_ currentTime: TimeInterval) {
        // Called once every frame
    }
    
    public func updateMoney(with add: Int) {
        gameViewController.updateMoney(with: add)
    }
    
    // Beginning the game, will be revamped later
    func beginGame() {
        nextLevel()
        timer = Timer.scheduledTimer(withTimeInterval: 56, repeats: true, block: { (nil) in
            if self.levels.count > 0 {
                self.nextLevel()
            } else {
                self.timer.invalidate()
                return
            }
        })
    }
    
    private func nextLevel() {
        var level = levels.first!
        
        Global.currentWave += 1
        
        let waveLabel = SKLabelNode(text: "Wave \(Global.currentWave)")
        waveLabel.position = CGPoint(x: 0, y: 450)
        waveLabel.fontSize = 50
        waveLabel.alpha = 0
        waveLabel.fontName = "kenvector_future"
        let fadeIn = SKAction.fadeIn(withDuration: 1)
        let wait = SKAction.wait(forDuration: 4)
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let disappear = SKAction.removeFromParent()
        let labelSequence = SKAction.sequence([fadeIn, wait, fadeOut, disappear])
        waveLabel.move(toParent: self)
        waveLabel.run(labelSequence)
        
        for wave in 0..<Int(level.count / 3) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + TimeInterval(wave * 14), execute: {
                let separation = self.size.width / CGFloat(3)
                let firstX = 0 - separation
                for enemy in 0..<3 {
                    self.spawnEnemy(at: CGPoint(x: firstX + (separation * CGFloat(enemy)), y: 750), ofType: level[enemy])
                    Global.currentMaxScore += level[enemy] * 100
                }
                level.removeFirst(3)
            })
        }
        
        
        
        levels.removeFirst()
         
    }
    
    private func endlessMode() {
        
    }
    
    // Function for spawning an enemy
    func spawnEnemy(at position: CGPoint, ofType type: Int) {
        // Creating an SKEnemyNode with the enemy texture
        var enemy = SKEnemyNode(imageNamed: "enemy")
        
        // Making animation for the enemy, see spaceship animations
        var enemyAnimations = [SKTexture(imageNamed: "enemy0"), SKTexture(imageNamed: "enemy1"),
                               SKTexture(imageNamed: "enemy2"), SKTexture(imageNamed: "enemy3"),
                               SKTexture(imageNamed: "enemy4"), SKTexture(imageNamed: "enemy5"),
                               SKTexture(imageNamed: "enemy6"), SKTexture(imageNamed: "enemy7"),
                               SKTexture(imageNamed: "enemy8")]
        
        switch type {
        case 2:
            enemy = SKEnemyNode(imageNamed: "enemy")
            enemyAnimations = []
        default:
            print("leaving alone")
        }
        
        // Creating the health bar
        enemy.createHealthBar()
        
        // Scaling the enemy to 40% size
        enemy.xScale = 0.4
        enemy.yScale = 0.4
        
        // Making the physics body of the enemy match the texture and size
        enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
        
        // Making the enemy not affected by gravity
        enemy.physicsBody?.affectedByGravity = false
        
        // Assigning the bitmask values for the enemy, see spaceship bitmasks above
        enemy.physicsBody?.categoryBitMask = enemyCat
        enemy.physicsBody?.collisionBitMask = enemyMask
        enemy.physicsBody?.contactTestBitMask = enemyMask
        enemy.physicsBody?.fieldBitMask = 0
        
        let enemyAnimation = SKAction.repeatForever(SKAction.animate(with: enemyAnimations, timePerFrame: 0.1))
        enemy.run(enemyAnimation)
        
        // Moving the enemy to the GameScene
        enemy.move(toParent: self)
        
        // Spawning the enemy at a random position at the top of the screen
//        enemy.position = CGPoint(x: CGFloat(Int(arc4random_uniform(700)) - 350), y: CGFloat(750))
        enemy.position = position
        
        // Making the enemy move towards the bottom of the screen
        let enemyMove = SKAction.move(to: CGPoint(x: enemy.position.x, y: CGFloat(-750)), duration: 23)
        let enemyMovements = SKAction.sequence([enemyMove, SKAction.removeFromParent()])
        enemy.run(enemyMovements, withKey: "enemyMove")
        enemy.autoFire()
    }
    
    // Function for pausing the game
    public func pause() {
        
        // Updating the instance Bool
        gamePaused = true
        
        // Quickly fading out the background music
        backgroundMusicNode.run(SKAction.changeVolume(to: 0.0, duration: 0.3))
        
        // Pausing the star particles
        starParticleEffect.isPaused = true
        
        // Looping through all the children of the GameScene
        for child in self.children {
            
            // If any are enemies then...
            if let action = child.action(forKey: "enemyMove") {
                
                // ...Pause their movements
                action.speed = 0
                if let subChild = child.children.first {
                    subChild.action(forKey: "laserShoot")?.speed = 0
                }
            }
        }
    }
    
    // Function for unpausing the game
    func unPause() {
        
        // Updating the instance Bool
        gamePaused = false
        
        // Quickly fading in the background music
        backgroundMusicNode.run(SKAction.changeVolume(to: 5, duration: 0.3))
        
        // Replaying the star particles
        starParticleEffect.isPaused = false
        
        // Looping through the children and...
        for child in self.children {
            if let action = child.action(forKey: "enemyMove") {
                
                // ...Restarting all the enemies
                action.speed = 1
            }
        }
    }
    
    
    // Function for firing the spaceship, primarily used in the GameViewController
    public func spaceshipFire() {
        
        // Creating the laser object
        let laser: SKSpriteNode = SKSpriteNode(imageNamed: "Laser")
        
        // Scaling it to 1/10 size needed for old laser but not anymore
        laser.xScale = 1
        laser.yScale = 1
        
        // Making the physical body match the texture and size
        laser.physicsBody = SKPhysicsBody(texture: laser.texture!, size: laser.size)
        
        // Making the laser immune to gravity
        laser.physicsBody?.affectedByGravity = false
        
        // Assigning the laser bitmasks
        laser.physicsBody?.categoryBitMask = laserCat
        laser.physicsBody?.collisionBitMask = laserMask
        laser.physicsBody?.contactTestBitMask = laserMask
        laser.physicsBody?.fieldBitMask = 0
        
        // Adding the laser to the scene
        laser.move(toParent: self)
        
        // Moving the laser to in front of the player
        laser.position = CGPoint(x: spaceship.position.x, y: spaceship.position.y + 100)
        
        // Playing the laser fire sound
        run(laserFireSound)
        
        // Adding an action that makes the laser move up quickly
        let laserAction = SKAction.moveBy(x: CGFloat(0), y: CGFloat(1200), duration: 1)
        let laserActions = SKAction.sequence([laserAction, SKAction.removeFromParent()])
        laser.run(laserActions, withKey: "enemyMove")
    }
}
