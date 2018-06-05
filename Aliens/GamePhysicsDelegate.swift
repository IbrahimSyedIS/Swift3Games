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
    
    /** BitShifted binary values that represent the categories and masks of the physics bodies in \(UInt32) form **/
    
    public static let noCat: UInt32 = 0b1
    public static let playerCat: UInt32 = 0b1 << 1
    public static let enemyCat: UInt32 = 0b1 << 2
    public static let laserCat: UInt32 = 0b1 << 3
    public static let itemCat: UInt32 = 0b1 << 4
    
    public static let playerMask: UInt32 = GamePhysicsDelegate.itemCat
    public static let laserMask: UInt32 = GamePhysicsDelegate.enemyCat | GamePhysicsDelegate.playerCat
    public static let enemyMask: UInt32 = GamePhysicsDelegate.laserCat | GamePhysicsDelegate.enemyCat
    
    // Represents the SKScene that the game is being played in
    public var gameScene: GameScene!
    
    public init(to scene: GameScene) {
        gameScene = scene
    }
    
    /**
     # Collisions
     
     Called when something in the game collides with something else
     - Parameter contact: SKPhysicsContact object that provides info about the collision such as position, force, and the nodes involved
     */
    func didBegin(_ contact: SKPhysicsContact) {
        
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        
        // Checking to make sure that both of the nodes are still in the scene
        if (nodeA?.parent == nil || nodeB?.parent == nil) { return }
        
        // Handling a collision between an item and player
        if (containsCatMask(contact: contact, mask: GamePhysicsDelegate.itemCat)) &&
           (containsCatMask(contact: contact, mask: GamePhysicsDelegate.playerCat)) {
            handleItemCollision(playerNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.playerCat ? nodeA as? SKPlayerNode : nodeB as? SKPlayerNode, itemNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.itemCat ? nodeA as? SKCoinNode : nodeB as? SKCoinNode)
        }
        
        // Handling a collision between a laser and a character
        if (containsCatMask(contact: contact, mask: GamePhysicsDelegate.laserCat)) &&
           (nodeA is SKCharacterNode || nodeB is SKCharacterNode) {
            print("Handling Collision between laser and character")
            handleLaserCharacterCollision(laserNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.laserCat ? nodeA as? SKWeaponNode : nodeB as? SKWeaponNode, otherNodeO: nodeA is SKCharacterNode ? nodeA as? SKCharacterNode: nodeB as? SKCharacterNode)
        }
        
        // Handling a colission between an enemy and a player
        if (containsCatMask(contact: contact, mask: GamePhysicsDelegate.enemyCat)) &&
           (containsCatMask(contact: contact, mask: GamePhysicsDelegate.playerCat)) {
            handleEnemyPlayerCollision(playerNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.playerCat ? nodeA as? SKPlayerNode : nodeB as? SKPlayerNode, enemyNodeO: contact.bodyA.categoryBitMask == GamePhysicsDelegate.enemyCat ? nodeA as? SKEnemyNode: nodeB as? SKEnemyNode)
        }
    }
    
    /**
     # Mask in Contact
     
     Determines whether either of the two nodes in the contact event had the given Category Bit Mask
     
     - Parameter contact: The contact physics event
     - Parameter mask: The mask to check
     
     - Returns: Whether the mask is in the contact nodes
     */
    private func containsCatMask(contact: SKPhysicsContact, mask: UInt32) -> Bool {
        return (contact.bodyA.categoryBitMask == mask || contact.bodyB.categoryBitMask == mask)
    }
    
    /**
     # Laser Character Collision
     
     Handles the collision between a laser and any character on the screen.
     
     - Parameter laserNodeO: The laser node
     - Parameter otherNodeO: The character node
     */
    private func handleLaserCharacterCollision(laserNodeO: SKWeaponNode?, otherNodeO: SKCharacterNode?) {
        guard let laserNode = laserNodeO, let otherNode = otherNodeO else { return }
//        print("Handling collsion between laser and a character")
        let laserHit = SKEmitterNode(fileNamed: "laserHit")!
        let laserHitSound = SKAction.playSoundFileNamed("laserBlast.mp3", waitForCompletion: false)
        gameScene.run(laserHitSound)
        laserHit.position = laserNode.position
        let laserSequence = SKAction.sequence([SKAction.run({ self.gameScene.addChild(laserHit) }),
                                               SKAction.wait(forDuration: TimeInterval(CGFloat(laserHit.numParticlesToEmit) * laserHit.particleLifetime)),
                                               SKAction.run({ laserHit.removeFromParent() })])
        gameScene.run(laserSequence)
        laserNode.removeFromParent()
        otherNode.takeDamage(laserNode.getDamage())
        if otherNode.health <= 0 {
            if otherNode is SKPlayerNode {
                Global.spaceViewController.gameOver()
                gameScene.pauseGame()
            } else if otherNode is SKEnemyNode {
                let newCoin = createCoin(position: otherNode.position)
                gameScene.addChild(newCoin)
                let distance = abs(newCoin.position.y - (gameScene.childNode(withName: "spaceship")?.position.y)!)
                let coinMove = SKAction.move(to: CGPoint(x: newCoin.position.x,
                                                         y:(gameScene.childNode(withName: "spaceship")?.position.y)! - 250),
                                             duration: Double(distance / CGFloat(350)))
                let coinActions = SKAction.sequence([coinMove, SKAction.removeFromParent()])
                newCoin.run(coinActions, withKey: "enemyMove")
            }
        }
    }
    
    /**
     # Create Coin
     
     This method takes a position and returns a new coin pre-set to be placed in the given position. Animations are applied as well
     
     - Parameter position: The CGPoint that represents the position that the coin should be placed
     
     - Returns: A Coin node that is set to be in the given position
     */
    private func createCoin(position: CGPoint) -> SKCoinNode {
        let newCoin: SKCoinNode = SKCoinNode(imageNamed: "Gold_21")
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
        guard let itemNode = itemNodeO, let playerNode = playerNodeO else { return }
        // Right now just assuming all the items are coins (since they are) -> Come back here and change this when more items are added
        let coinSound = SKAction.playSoundFileNamed("coinCollect.mp3", waitForCompletion: false)
        Global.money += itemNode.value
        Global.spaceViewController.updateMoney(with: itemNode.value)
        (playerNode.parent as! GameScene).run(coinSound)
        itemNode.removeFromParent()
    }
    
    /**
     # Enemy and Player Collide
     
     Handles the collision of the player and an enemy
     
     - Parameter playerNodeO: The player
     - Parameter enemyNodeO: The enemy
     */
    private func handleEnemyPlayerCollision(playerNodeO: SKPlayerNode?, enemyNodeO: SKEnemyNode?) {
        guard let enemyNode = enemyNodeO, let playerNode = playerNodeO else { return }
        let enemyDie = SKEmitterNode(fileNamed: "Explosion")!
        enemyNode.removeAllActions()
        enemyNode.removeFromParent()
        enemyDie.position = enemyNode.position
        let sequence = SKAction.sequence([SKAction.run({ self.gameScene.addChild(enemyDie) }),
                                          SKAction.wait(forDuration: TimeInterval(CGFloat(enemyDie.numParticlesToEmit) * enemyDie.particleLifetime)),
                                          SKAction.run({ enemyDie.removeFromParent() })])
        gameScene.run(sequence)
        if playerNode.health > 0 {
            playerNode.takeDamage(10)
        } else {
            playerNode.die()
            Global.spaceViewController.gameOver()
            self.gameScene.pauseGame()
        }
    }
    
}
