//
//  ContentView.swift
//  DustSweepGame
//
//  Created by EMILY on 19/06/2025.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    var scene: SKScene = GameScene()
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
