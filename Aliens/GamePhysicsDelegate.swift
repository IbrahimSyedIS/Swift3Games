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
    
    let noCat: UInt32 = 0b1
    let playerCat: UInt32 = 0b1 << 1
    let enemyCat: UInt32 = 0b1 << 2
    let laserCat: UInt32 = 0b1 << 3
    let itemCat: UInt32 = 0b1 << 4
    let enemyLaserCat: UInt32 = 0b1 << 5
    
    public static let NO_CAT: UInt32 = 0b1
    public static let PLAYER_CAT: UInt32 = 0b1 << 1
    public static let ENEMY_CAT: UInt32 = 0b1 << 2
    public static let LASER_CAT: UInt32 = 0b1 << 3
    public static let ITEM_CAT: UInt32 = 0b1 << 4
    public static let ENEMY_LASER_CAT: UInt32 = 0b1 << 5
    
    var laserHitSound = SKAction.playSoundFileNamed("laserBlast.mp3", waitForCompletion: false)
    public var gameScene: GameScene!
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let laserHit = SKEmitterNode(fileNamed: "laserHit")!
        let enemyDie = SKEmitterNode(fileNamed: "Explosion")!
        
        if (contact.bodyA.categoryBitMask == laserCat) || (contact.bodyB.categoryBitMask == laserCat) {
            let laserNode = contact.bodyA.categoryBitMask == laserCat ? contact.bodyA.node : contact.bodyB.node
            let enemyNode = contact.bodyA.categoryBitMask == laserCat ? contact.bodyB.node : contact.bodyA.node
            if laserNode?.parent == nil {
                return
            }
            gameScene.run(laserHitSound)
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
            gameScene.run(laserSequence)
            laserNode?.removeFromParent()
            if let enemyNode: SKEnemyNode = enemyNode as? SKEnemyNode {
                enemyNode.takeDamage(25)
                if enemyNode.health <= 0 {
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
                    gameScene.run(sequence) {
                        enemyNode.removeAllActions()
                        enemyNode.removeFromParent()
                    }
                    gameScene.score += 100
                    gameScene.gameViewController.updateScoreLabel()
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
            if laserNode?.parent == nil {
                return
            }
            gameScene.run(laserHitSound)
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
            gameScene.run(laserSequence)
            laserNode?.removeFromParent()
            if playerNode.health > 0 {
                playerNode.takeDamage(2)
            } else {
                playerNode.die()
                Global.gameSceneViewController.gameOver()
                Global.gameScene.pauseGame()
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
                gameScene.run(sequence)
                if playerNode.health > 0 {
                    playerNode.takeDamage(10)
                } else {
                    playerNode.die()
                    Global.gameSceneViewController.gameOver()
                    self.gameScene.pauseGame()
                }
            }
        }
    }
}
