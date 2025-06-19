//
//  GameScene.swift
//  DustSweepGame
//
//  Created by EMILY on 19/06/2025.
//

import SpriteKit

class GameScene: SKScene {
    
    private let backgroundImage = SKSpriteNode(imageNamed: Assets.woodenfloor.rawValue)
    
    private let boxImage = SKSpriteNode(imageNamed: Assets.box.rawValue)
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        
        addBackgroundImage()
        addBoxImage()
    }
    
    private func addBackgroundImage() {
        backgroundImage.size = size
        backgroundImage.anchorPoint = .zero
        backgroundImage.zPosition = -1
        
        addChild(backgroundImage)
    }
    
    private func addBoxImage() {
        let width = size.width - 50
        
        boxImage.size = CGSize(width: width, height: width)
        boxImage.position = CGPoint(x: size.width / 2, y: size.height / 2)
        boxImage.zPosition = 1
        
        addChild(boxImage)
    }
}
