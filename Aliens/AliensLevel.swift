//
//  AliensLevel.swift
//  Aliens
//
//  Created by Ibrahim Syed on 6/4/18.
//  Copyright © 2018 Ibrahim Syed. All rights reserved.
//

import Foundation
import SpriteKit

class AliensLevel {
    
    private var level: [Int]!
    
    private var enemiesInLevel: [SKEnemyNode]!
    
    public init(enemies: [Int]) {
        level = enemies
        
        level.forEach { (i) in
//            enemiesInLevel.append(newElement: createEnemy(at: CGPoint(0, 0), ofType: i))
        }
        
    }
    
    func createEnemy(at position: CGPoint, ofType type: Int) -> SKEnemyNode {
        var enemy: SKEnemyNode
        var enemyAnimations: [SKTexture]
        switch type {
        case 1:
            enemyAnimations = [SKTexture(imageNamed: "enemy0"), SKTexture(imageNamed: "enemy1"),
                               SKTexture(imageNamed: "enemy2"), SKTexture(imageNamed: "enemy3"),
                               SKTexture(imageNamed: "enemy4"), SKTexture(imageNamed: "enemy5"),
                               SKTexture(imageNamed: "enemy6"), SKTexture(imageNamed: "enemy7"),
                               SKTexture(imageNamed: "enemy8")]
            enemy = SKEnemyNode(imageNamed: "enemy", animations: enemyAnimations)
            enemy.xScale = 0.4
            enemy.yScale = 0.4
        case 2:
            enemyAnimations = []
            enemy = SKEnemyNode(imageNamed: "enemy", animations: enemyAnimations)
        default:
            enemyAnimations = []
            enemy = SKEnemyNode(imageNamed: "enemy", animations: enemyAnimations)
        }
        enemy.position = position
        return enemy
    }
    
}

public enum typeOfEnemy {
    case firstBasic
    case secondBasic
    case thirdBasic
    case fourthBasic
}
