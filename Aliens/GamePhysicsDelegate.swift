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
    
    public static let noCat: UInt32 = 0b1
    public static let playerCat: UInt32 = 0b1 << 1
    public static let enemyCat: UInt32 = 0b1 << 2
    public static let laserCat: UInt32 = 0b1 << 3
    public static let itemCat: UInt32 = 0b1 << 4
    public static let enemyLaserCat: UInt32 = 0b1 << 5
    
    // Represents the SKScene that the game is being played in
    public var gameScene: GameScene!
    
    /**
     # Collisions
     
     Called when something in the game collides with something else
     - Parameter contact: SKPhysicsContact object that provides info about the collision such as position, force, and the nodes involved
     */
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Checking to make sure that both of the nodes are still in the scene
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil) {
            return
        }
        
        // Handling a collision between an item and player
        if (contact.bodyA.categoryBitMask == GamePhysicsDelegate.itemCat || contact.bodyB.categoryBitMask == GamePhysicsDelegate.itemCat) &&
            (contact.bodyA.categoryBitMask == GamePhysicsDelegate.playerCat || contact.bodyB.categoryBitMask == GamePhysicsDelegate.playerCat) {
            handleItemCollision(playerNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.playerCat ? contact.bodyA.node as? SKPlayerNode : contact.bodyB.node as? SKPlayerNode, itemNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.itemCat ? contact.bodyA.node as? SKCoinNode : contact.bodyB.node as? SKCoinNode)
        }
        
        // Handling a collision between an enemy's laser and a player
        if (contact.bodyA.categoryBitMask == GamePhysicsDelegate.enemyLaserCat || contact.bodyB.categoryBitMask == GamePhysicsDelegate.enemyLaserCat) &&
            (contact.bodyA.categoryBitMask == GamePhysicsDelegate.playerCat || contact.bodyB.categoryBitMask == GamePhysicsDelegate.playerCat) {
            handleLaserOfEnemyPlayerCollison(playerNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.playerCat ? contact.bodyA.node as? SKPlayerNode : contact.bodyB.node as? SKPlayerNode, laserNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.enemyLaserCat ? contact.bodyA.node as? SKWeaponNode: contact.bodyB.node as? SKWeaponNode)
        }
        
        // Handling a colission between an enemy and a player
        if (contact.bodyA.categoryBitMask == GamePhysicsDelegate.enemyCat || contact.bodyB.categoryBitMask == GamePhysicsDelegate.enemyCat) &&
            (contact.bodyA.categoryBitMask == GamePhysicsDelegate.playerCat || contact.bodyB.categoryBitMask == GamePhysicsDelegate.playerCat) {
            handleEnemyPlayerCollision(playerNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.playerCat ? contact.bodyA.node as? SKPlayerNode : contact.bodyB.node as? SKPlayerNode, enemyNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.enemyCat ? contact.bodyA.node as? SKEnemyNode: contact.bodyB.node as? SKEnemyNode)
        }
        
        // Handling a collision between an enemy and a laser
        if (contact.bodyA.categoryBitMask == GamePhysicsDelegate.enemyCat || contact.bodyB.categoryBitMask == GamePhysicsDelegate.enemyCat) &&
            (contact.bodyA.categoryBitMask == GamePhysicsDelegate.laserCat || contact.bodyB.categoryBitMask == GamePhysicsDelegate.laserCat) {
            handleLaserEnemyColision(enemyNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.enemyCat ? contact.bodyA.node as? SKEnemyNode : contact.bodyB.node as? SKEnemyNode, laserNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.laserCat ? contact.bodyA.node as? SKWeaponNode: contact.bodyB.node as? SKWeaponNode)
        }
    }
    
    /**
     # Enemy Laser Colission
     
     Handles enemies being hit by lasers. Enemy takes damage and laser is removed.
     
     If the enemy dies in this collision, the enemy death method is called.
     
     - Parameter enemyNodeO: The enemy being hit
     - Parameter laserNodeO: The laser hitting the enemy
     */
    private func handleLaserEnemyColision(enemyNodeO: SKEnemyNode?, laserNodeO: SKWeaponNode?) {
        guard let laserNode = laserNodeO, let enemyNode = enemyNodeO else {
            return
        }
        let laserHit = SKEmitterNode(fileNamed: "laserHit")!
        let laserHitSound = SKAction.playSoundFileNamed("laserBlast.mp3", waitForCompletion: false)
        gameScene.run(laserHitSound)
        laserHit.position = laserNode.position
        let laserSequence = SKAction.sequence([SKAction.run({ self.gameScene.addChild(laserHit) }),
                                               SKAction.wait(forDuration: TimeInterval(CGFloat(laserHit.numParticlesToEmit) * laserHit.particleLifetime)),
                                               SKAction.run({ laserHit.removeFromParent() })])
        gameScene.run(laserSequence)
        laserNode.removeFromParent()
        enemyNode.takeDamage(laserNode.getDamage())
        if enemyNode.health <= 0 {
            enemyHasDied(enemyNode: enemyNode)
            let newCoin = createCoin(position: enemyNode.position)
            gameScene.addChild(newCoin)
            let distance = abs(newCoin.position.y - (gameScene.childNode(withName: "spaceship")?.position.y)!)
            let coinMove = SKAction.move(to: CGPoint(x: newCoin.position.x, y:(gameScene.childNode(withName: "spaceship")?.position.y)! - 250),
                                         duration: Double(distance / CGFloat(350)))
            let coinActions = SKAction.sequence([coinMove, SKAction.removeFromParent()])
            newCoin.run(coinActions, withKey: "enemyMove")
        }
    }
    
    /**
     # Enemy Death
     
     Handles the death of an enemy by placing an explosion as well as removing them from the scene.
     The score is also updated and a coin is added.
     
     - Parameter enemyNode: The enemy node itself to be removed
     */
    private func enemyHasDied(enemyNode: SKEnemyNode) {
        let enemyDie = SKEmitterNode(fileNamed: "Explosion")!
        enemyDie.position = enemyNode.position
        let emitterAction = SKAction.run({
            self.gameScene.addChild(enemyDie)
        })
        let emitterDuration = CGFloat(enemyDie.numParticlesToEmit) * enemyDie.particleLifetime
        let remove = SKAction.run({
            enemyDie.removeFromParent()
        })
        let sequence = SKAction.sequence([emitterAction, SKAction.wait(forDuration: TimeInterval(emitterDuration)), remove])
        gameScene.run(sequence)
        enemyNode.removeAllActions()
        enemyNode.removeFromParent()
        gameScene.score += 100
        gameScene.gameViewController.updateScoreLabel()
    }
    
    /**
     # Create Coin
     
     This method takes a position and returns a new coin pre-set to be placed in the given position. Animations are applied as well
     
     - Parameter position: The CGPoint that represents the position that the coin should be placed
     
     - Returns: A Coin node that is set to be in the given position
     */
    private func createCoin(position: CGPoint) -> SKCoinNode {
        let newCoin: SKCoinNode = SKCoinNode(imageNamed: "Gold_21")
        let coinAnimationTextures = [SKTexture(imageNamed: "Gold_21"), SKTexture(imageNamed: "Gold_22"), SKTexture(imageNamed: "Gold_23"),
                                     SKTexture(imageNamed: "Gold_24"), SKTexture(imageNamed: "Gold_25"), SKTexture(imageNamed: "Gold_26"),
                                     SKTexture(imageNamed: "Gold_27"), SKTexture(imageNamed: "Gold_28"), SKTexture(imageNamed: "Gold_29"),
                                     SKTexture(imageNamed: "Gold_30")]
        let coinAnimation = SKAction.repeatForever(SKAction.animate(with: coinAnimationTextures, timePerFrame: 0.1))
        newCoin.run(coinAnimation)
        newCoin.initCoin()
        newCoin.position = position
        newCoin.xScale = 0.12
        newCoin.yScale = 0.12
        return newCoin
    }
    
    /**
     # Item Collision
     
     Handles the collision of an item with a player.
     
     - Parameter playerNodeO: The player
     - Parameter itemNodeO: The node representing the item
     */
    private func handleItemCollision(playerNodeO: SKPlayerNode?, itemNodeO: SKCoinNode?) {
        guard let itemNode = itemNodeO, let playerNode = playerNodeO else {
            return
        }
        // Right now just assuming all the items are coins (since they are) -> Come back here and change this when more items are added
        let coinSound = SKAction.playSoundFileNamed("coinCollect.mp3", waitForCompletion: false)
        Global.money += itemNode.value
        let gameScene = playerNode.parent as! GameScene
        gameScene.updateMoney(with: itemNode.value)
        gameScene.run(coinSound)
        itemNode.removeFromParent()
    }
    
    /**
     # Player Collides with Enemy Laser
     
     Handles the collision of a player with the laser of an enemy
     
     - Parameter playerNodeO: The player
     - Parameter laserNodeO: The node representing the laser
     */
    private func handleLaserOfEnemyPlayerCollison(playerNodeO: SKPlayerNode?, laserNodeO: SKWeaponNode?) {
        let laserHit = SKEmitterNode(fileNamed: "laserHit")!
        let laserHitSound = SKAction.playSoundFileNamed("laserBlast.mp3", waitForCompletion: false)
        guard let laserNode = laserNodeO, let playerNode = playerNodeO else {
            return
        }
        gameScene.run(laserHitSound)
        laserHit.position = laserNode.position
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
        laserNode.removeFromParent()
        if playerNode.health > 0 {
            playerNode.takeDamage(laserNode.getDamage())
        } else {
            playerNode.die()
            Global.gameSceneViewController.gameOver()
            Global.gameScene.pauseGame()
        }
    }
    
    /**
     # Enemy and Player Collide
     
     Handles the collision of the player and an enemy
     
     - Parameter playerNodeO: The player
     - Parameter enemyNodeO: The enemy
     */
    private func handleEnemyPlayerCollision(playerNodeO: SKPlayerNode?, enemyNodeO: SKEnemyNode?) {
        let enemyDie = SKEmitterNode(fileNamed: "Explosion")!
        guard let enemyNode = enemyNodeO, let playerNode = playerNodeO else {
            return
        }
        enemyNode.removeAllActions()
        enemyNode.removeFromParent()
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
