//
//  Dust.swift
//  DustSweepGame
//
//  Created by EMILY on 20/06/2025.
//

import Foundation

enum Dust {
    case first
    case second
    case third
    case fourth
    
    var imageName: String {
        switch self {
        case .first:
            return "dust1"
        case .second:
            return "dust2"
        case .third:
            return "dust3"
        case .fourth:
            return "dust4"
        }
    }
    
    var size: CGSize {
        switch self {
        case .first:
            return CGSize(width: 60, height: 20)
        case .second, .third:
            return CGSize(width: 60, height: 40)
        case .fourth:
            return CGSize(width: 50, height: 25)
        }
    }
}
