//
//  SKWeaponNode.swift
//  Aliens
//
//  Created by Ibrahim Syed on 5/31/18.
//  Copyright © 2018 Ibrahim Syed. All rights reserved.
//

import Foundation
import SpriteKit

// TODO Make the weapon node
class SKWeaponNode: SKSpriteNode {
    
    private var damage: Int
    
    public override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        damage = 25
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        damage = 25
        super.init(coder: aDecoder)
    }
    
    public init(imageNamed: String, damage: Int) {
        self.damage = 25
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
    }
    
    public func setDamage(to dam: Int) {
        damage = dam
    }
    
    public func getDamage() -> Int {
        return damage
    }
}
