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
    
}
