//
//  DustImageNode.swift
//  DustSweepGame
//
//  Created by EMILY on 20/06/2025.
//

import SpriteKit

class DustImageNode: SKSpriteNode {
    init(dust: Dust) {
        let texture = SKTexture(imageNamed: dust.imageName)
        let size = dust.size
        super.init(texture: texture, color: .clear, size: size)
        zPosition = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
