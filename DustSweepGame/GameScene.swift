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
        
        for _ in 1...170 {
            addDusts()
        }
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
        let dustName = Dust.allCases.randomElement() ?? .fourth
        
        let xRange: ClosedRange<CGFloat> = 55...(size.width - 55)
        let yOffset = (size.height - boxImage.size.width) / 2
        let yRange: ClosedRange<CGFloat> = (yOffset + 30)...(yOffset + boxImage.size.height - 30)
    
        let x = CGFloat.random(in: xRange)
        let y = CGFloat.random(in: yRange)
        
        let dust = DustImageNode(dust: dustName)
        dust.position = CGPoint(x: x, y: y)
        
        addChild(dust)
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
