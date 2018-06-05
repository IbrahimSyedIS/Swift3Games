//
//  SKDialogueNode.swift
//  Aliens
//
//  Created by Ibrahim Syed on 6/5/18.
//  Copyright © 2018 Ibrahim Syed. All rights reserved.
//

import Foundation
import SpriteKit

class SKDialogueNode: SKSpriteNode {
    
    private var dialogue: String!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dialogue = ""
    }
    
    public init(texture: SKTexture, size: CGSize, dialogue: String) {
        super.init(texture: texture, color: UIColor.clear, size: size)
        self.dialogue = dialogue
    }
    
    public func showDialogue() {
        position = CGPoint(x: 0, y: -720)
        let moveUp = SKAction.move(to: CGPoint(x: 0, y: CGFloat(-565)), duration: 0.4)
        moveUp.timingMode = SKActionTimingMode.easeOut
        run(SKAction.sequence([moveUp, SKAction.move(to: CGPoint(x: 0, y: -590), duration: 0.1)]))
    }
    
}
