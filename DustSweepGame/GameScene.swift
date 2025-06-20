//
//  GameScene.swift
//  DustSweepGame
//
//  Created by EMILY on 19/06/2025.
//

import SwiftUI
import SpriteKit

class GameScene: SKScene {
    
    private let backgroundImage = SKSpriteNode(imageNamed: Assets.woodenfloor.rawValue)
    
    private let boxImage = SKSpriteNode(imageNamed: Assets.box.rawValue)
    
    private let dusterImage = SKSpriteNode(imageNamed: Assets.duster.rawValue)
    
    private let dust1 = DustImageNode(dust: .first)
    private let dust2 = DustImageNode(dust: .second)
    private let dust3 = DustImageNode(dust: .third)
    private let dust4 = DustImageNode(dust: .fourth)
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        
        addBackgroundImage()
        addBoxImage()
        addDusterImage()
        addDusts()
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
    
    private func addDusterImage() {
        let width = boxImage.size.width / 4
        let height = width * 1.3
        
        dusterImage.size = CGSize(width: width, height: height)
        dusterImage.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        dusterImage.position = CGPoint(x: size.width - (width / 2) - 25, y: size.height - (height / 2) - 90)
        dusterImage.zPosition = 3
        
        addChild(dusterImage)
    }
    
    private func addDusts() {
        dust1.position = CGPoint(x: boxImage.position.x - 120, y: boxImage.position.y)
        dust2.position = CGPoint(x: boxImage.position.x - 60, y: boxImage.position.y)
        dust3.position = CGPoint(x: boxImage.position.x + 60, y: boxImage.position.y)
        dust4.position = CGPoint(x: boxImage.position.x + 120, y: boxImage.position.y)
        
        [dust1, dust2, dust3, dust4].forEach { addChild($0) }
    }
    
    private var isDusterTouched: Bool = false
}

extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        // calculate the range of current duster's location >> to check if user started touching correct location
        let xRange: ClosedRange<CGFloat> = dusterImage.position.x - dusterImage.size.width / 2 ... dusterImage.position.x + dusterImage.size.width / 2
        let yRange: ClosedRange<CGFloat> = dusterImage.position.y - dusterImage.size.height * 0.2 ... dusterImage.position.y + dusterImage.size.height * 0.3
        
        isDusterTouched = xRange.contains(location.x) && yRange.contains(location.y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        if isDusterTouched {
            dusterImage.position = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDusterTouched = false
    }
}

#Preview {
    ContentView()
}
