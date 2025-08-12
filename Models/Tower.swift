//
//  Tower.swift
//  SpaceTD
//
//  Created by Evan Cohen on 8/12/25.
//


import SwiftUI

class Tower: ObservableObject, Identifiable {
    let id = UUID()
    let type: TowerType
    @Published var position: CGPoint
    let damage: Int
    let range: Double
    let fireRate: Double // shots per second
    var lastShotTime: Date = Date.distantPast
    
    init(type: TowerType, position: CGPoint) {
        self.type = type
        self.position = position
        
        switch type {
        case .laser:
            self.damage = 25
            self.range = 100
            self.fireRate = 2
        case .missile:
            self.damage = 75
            self.range = 150
            self.fireRate = 0.5
        case .plasma:
            self.damage = 50
            self.range = 120
            self.fireRate = 1
        }
    }
    
    var canShoot: Bool {
        Date().timeIntervalSince(lastShotTime) >= 1.0 / fireRate
    }
    
    func update() {
        // Any tower-specific updates can go here
    }
}

enum TowerType: CaseIterable {
    case laser, missile, plasma
    
    var name: String {
        switch self {
        case .laser: return "Laser"
        case .missile: return "Missile"
        case .plasma: return "Plasma"
        }
    }
    
    var cost: Int {
        switch self {
        case .laser: return 50
        case .missile: return 100
        case .plasma: return 75
        }
    }
    
    var color: Color {
        switch self {
        case .laser: return .blue
        case .missile: return .red
        case .plasma: return .green
        }
    }
    
    var description: String {
        switch self {
        case .laser: return "Fast firing, low damage"
        case .missile: return "Slow firing, high damage"
        case .plasma: return "Balanced damage and speed"
        }
    }
}