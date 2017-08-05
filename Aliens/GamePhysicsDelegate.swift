//
//  GamePhysicsDelegate.swift
//  Aliens
//
//  Created by Ibrahim Syed on 7/30/17.
//  Copyright © 2017 Ibrahim Syed. All rights reserved.
//

import SpriteKit
import GameplayKit

class GamePhysicsDelegate: NSObject, SKPhysicsContactDelegate {
    
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
    
    // BitMask for enemy laser objects
    let enemyLaserCat: UInt32 = 0b1 << 5
    
    // This is the same thing just static form for access elsewhere; See Above
    public static let NO_CAT: UInt32 = 0b1
    public static let PLAYER_CAT: UInt32 = 0b1 << 1
    public static let ENEMY_CAT: UInt32 = 0b1 << 2
    public static let LASER_CAT: UInt32 = 0b1 << 3
    public static let ITEM_CAT: UInt32 = 0b1 << 4
    public static let ENEMY_LASER_CAT: UInt32 = 0b1 << 5
    
    // laserHitSound: An action that plays the laser hit sound
    var laserHitSound = SKAction.playSoundFileNamed("laserBlast.mp3", waitForCompletion: false)
    
    // gameScene: The Game scene that delegated the physics contact handling here
    public var gameScene: GameScene!
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Creating Emitter Nodes for laser hits and enemy explosions
        let laserHit = SKEmitterNode(fileNamed: "laserHit")!
        let enemyDie = SKEmitterNode(fileNamed: "Explosion")!
        
        // Checking if either one of the colliding objects is a laser
        if (contact.bodyA.categoryBitMask == laserCat) || (contact.bodyB.categoryBitMask == laserCat) {
            
            // Ternary Conditional Operation to get the laser and enemy physical nodes
            let laserNode = contact.bodyA.categoryBitMask == laserCat ? contact.bodyA.node : contact.bodyB.node
            let enemyNode = contact.bodyA.categoryBitMask == laserCat ? contact.bodyB.node : contact.bodyA.node
            
            // Making sure the laser hasn't already been removed preventing 4 or 5 calls from one collision
            if laserNode?.parent == nil {
                return
            }
            
            // Playing the laser hit sound
            gameScene.run(laserHitSound)
                
            // Setting the position of the laserhit effect to the position of the laser
            laserHit.position = laserNode!.position
            
            let laserAction = SKAction.run({
                self.gameScene.addChild(laserHit)
            })
            
            let laserDuration = CGFloat(laserHit.numParticlesToEmit) * laserHit.particleLifetime
                
            let laserWait = SKAction.wait(forDuration: TimeInterval(laserDuration))
                
            let laserRemove = SKAction.run({
                laserHit.removeFromParent()
            })
            
            let laserSequence = SKAction.sequence([laserAction, laserWait, laserRemove])
                
            // Adding the laserhit effect to the scene
            gameScene.run(laserSequence)
                
            // Removing the laser from the scene
            laserNode?.removeFromParent()
                
            // Casting the other object to an enemy
            if let enemyNode: SKEnemyNode = enemyNode as? SKEnemyNode {
                    
                // Subtracting from the enemies health
                enemyNode.takeDamage(25)
                    
                // Checking if the enemy is now dead
                if enemyNode.health <= 0 {
                        
                    // If it is then we move the explosion to the enemy position
                    enemyDie.position = enemyNode.position
                        
                    let emitterAction = SKAction.run({
                        self.gameScene.addChild(enemyDie)
                    })
                
                    let emitterDuration = CGFloat(enemyDie.numParticlesToEmit) * enemyDie.particleLifetime
                    
                    let wait = SKAction.wait(forDuration: TimeInterval(emitterDuration))
                        
                    let remove = SKAction.run({
                        enemyDie.removeFromParent()
                    })
                        
                    let sequence = SKAction.sequence([emitterAction, wait, remove])
                        
                    // Then we add it to the scene
                    gameScene.run(sequence)
                        
                    // Then we remove the the enemy
                    enemyNode.removeAllActions()
                    enemyNode.removeFromParent()
                        
                    // Then we increase the score
                    gameScene.score += 100
                        
                    // Then we update the score label
                    gameScene.gameViewController.updateScoreLabel()
                        
                    // Then we add a coin in its place
                    let newCoin: SKCoinNode = SKCoinNode(imageNamed: "Gold_21")
                    let coinAnimationTextures = [SKTexture(imageNamed: "Gold_21"), SKTexture(imageNamed: "Gold_22"),
                                                 SKTexture(imageNamed: "Gold_23"), SKTexture(imageNamed: "Gold_24"),
                                                 SKTexture(imageNamed: "Gold_25"), SKTexture(imageNamed: "Gold_26"),
                                                 SKTexture(imageNamed: "Gold_27"), SKTexture(imageNamed: "Gold_28"),
                                                 SKTexture(imageNamed: "Gold_29"), SKTexture(imageNamed: "Gold_30")]
                    let coinAnimation = SKAction.repeatForever(SKAction.animate(with: coinAnimationTextures, timePerFrame: 0.1))
                    newCoin.run(coinAnimation)
                    newCoin.initCoin()
                    newCoin.position = enemyNode.position
                    newCoin.xScale = 0.12
                    newCoin.yScale = 0.12
                    gameScene.addChild(newCoin)
                    
                    let distance = abs(newCoin.position.y - (gameScene.childNode(withName: "spaceship")?.position.y)!)
                        
                    let coinMove = SKAction.move(to: CGPoint(x: newCoin.position.x, y:(gameScene.childNode(withName: "spaceship")?.position.y)! - 250),
                                                     duration: Double(distance / CGFloat(350)))
                    let coinActions = SKAction.sequence([coinMove, SKAction.removeFromParent()])
                    newCoin.run(coinActions, withKey: "enemyMove")
                }
            }
                
            if enemyNode?.name == "spaceship" {
                print("player collides with laser")
            }
            
        }
        
        if contact.bodyA.categoryBitMask == itemCat || contact.bodyB.categoryBitMask == itemCat {
            let itemNode = contact.bodyA.categoryBitMask == itemCat ? contact.bodyA.node : contact.bodyB.node
            let playerNode = contact.bodyA.categoryBitMask == itemCat ? contact.bodyB.node as! SKPlayerNode : contact.bodyA.node as! SKPlayerNode
            
            if itemNode?.parent == nil {
                return
            }
            
            if let coinNode = itemNode as? SKCoinNode {
                let coinSound = SKAction.playSoundFileNamed("coinCollect.mp3", waitForCompletion: false)
                Global.money += coinNode.value
                let gameScene = playerNode.parent as! GameScene
                gameScene.updateMoney(with: coinNode.value)
                gameScene.run(coinSound)
            }
            itemNode?.removeFromParent()
            
        }
        
        if contact.bodyA.categoryBitMask == enemyLaserCat || contact.bodyB.categoryBitMask == enemyLaserCat {
            let laserNode = contact.bodyA.categoryBitMask == enemyLaserCat ? contact.bodyA.node : contact.bodyB.node
            let playerNode = contact.bodyA.categoryBitMask == enemyLaserCat ? contact.bodyB.node as! SKPlayerNode : contact.bodyA.node as! SKPlayerNode
            
            // Making sure the laser hasn't already been removed preventing 4 or 5 calls from one collision
            if laserNode?.parent == nil {
                return
            }
            // Playing the laser hit sound
            gameScene.run(laserHitSound)
            
            // Setting the position of the laserhit effect to the position of the laser
            laserHit.position = laserNode!.position
            
            let laserAction = SKAction.run({
                self.gameScene.addChild(laserHit)
            })
            
            let laserDuration = CGFloat(laserHit.numParticlesToEmit) * laserHit.particleLifetime
            
            let laserWait = SKAction.wait(forDuration: TimeInterval(laserDuration))
                
            let laserRemove = SKAction.run({
                laserHit.removeFromParent()
            })
                
            let laserSequence = SKAction.sequence([laserAction, laserWait, laserRemove])
                
            // Adding the laserhit effect to the scene
            gameScene.run(laserSequence)
                
            // Removing the laser from the scene
            laserNode?.removeFromParent()
                
            if playerNode.health > 0 {
                playerNode.takeDamage(2)
            } else {
                playerNode.die()
            }
            
        }
        
        if contact.bodyA.categoryBitMask == enemyCat || contact.bodyB.categoryBitMask == enemyCat {
            let enemyNode = contact.bodyA.categoryBitMask == enemyCat ? contact.bodyA.node : contact.bodyB.node
            let otherNode = contact.bodyB.categoryBitMask == enemyCat ? contact.bodyA.node : contact.bodyB.node
            
            if enemyNode?.parent == nil {
                return
            }
            
            if let playerNode = otherNode as? SKPlayerNode {
                
                enemyNode?.removeAllActions()
                enemyNode?.removeFromParent()
                
                // If it is then we move the explosion to the enemy position
                enemyDie.position = (enemyNode?.position)!
                
                let emitterAction = SKAction.run({
                    self.gameScene.addChild(enemyDie)
                })
                
                let emitterDuration = CGFloat(enemyDie.numParticlesToEmit) * enemyDie.particleLifetime
                
                let wait = SKAction.wait(forDuration: TimeInterval(emitterDuration))
                
                let remove = SKAction.run({
                    enemyDie.removeFromParent()
                })
                
                let sequence = SKAction.sequence([emitterAction, wait, remove])
                
                // Then we add it to the scene
                gameScene.run(sequence)
                
                if playerNode.health > 0 {
                    playerNode.takeDamage(10)
                } else {
                    playerNode.die()
                }
            }
        }
    }
    
}
