//
//  Enemy.swift
//  SpaceTD
//
//  Created by Evan Cohen on 8/12/25.
//


import SwiftUI

class Enemy: ObservableObject, Identifiable {
    let id = UUID()
    @Published var position: CGPoint
    @Published var health: Int
    let maxHealth: Int
    let speed: Double
    let reward: Int
    let damage: Int
    let type: EnemyType
    
    private let path: [CGPoint]
    var pathIndex: Int = 0
    private var progress: Double = 0
    
    init(type: EnemyType, path: [CGPoint], level: Int) {
        self.type = type
        self.path = path
        self.position = path.first ?? CGPoint.zero
        
        // Scale stats based on level
        let levelMultiplier = 1.0 + (Double(level - 1) * 0.3)
        
        switch type {
        case .basic:
            self.maxHealth = Int(50 * levelMultiplier)
            self.speed = 50
            self.reward = 10
            self.damage = 10
        case .fast:
            self.maxHealth = Int(30 * levelMultiplier)
            self.speed = 100
            self.reward = 15
            self.damage = 5
        case .heavy:
            self.maxHealth = Int(150 * levelMultiplier)
            self.speed = 25
            self.reward = 25
            self.damage = 20
        case .boss:
            self.maxHealth = Int(1000 * levelMultiplier)
            self.speed = 30
            self.reward = 200
            self.damage = 50
        }
        
        self.health = maxHealth
    }
    
    func move() {
        guard pathIndex < path.count - 1 else { return }
        
        let currentPoint = path[pathIndex]
        let nextPoint = path[pathIndex + 1]
        
        let deltaTime = 1.0/60.0
        let distance = speed * deltaTime
        
        let direction = CGPoint(
            x: nextPoint.x - currentPoint.x,
            y: nextPoint.y - currentPoint.y
        )
        let length = sqrt(direction.x * direction.x + direction.y * direction.y)
        
        if length > 0 {
            let normalizedDirection = CGPoint(
                x: direction.x / length,
                y: direction.y / length
            )
            
            let newPosition = CGPoint(
                x: position.x + normalizedDirection.x * distance,
                y: position.y + normalizedDirection.y * distance
            )
            
            position = newPosition
            
            // Check if we've reached the next waypoint
            if position.distance(to: nextPoint) < 10 {
                pathIndex += 1
            }
        }
    }
    
    func takeDamage(_ damage: Int) {
        health = max(0, health - damage)
    }
    
    var healthPercentage: Double {
        return Double(health) / Double(maxHealth)
    }
}

enum EnemyType: CaseIterable {
    case basic, fast, heavy, boss
    
    var color: Color {
        switch self {
        case .basic: return .red
        case .fast: return .yellow
        case .heavy: return .purple
        case .boss: return .orange
        }
    }
    
    var size: CGFloat {
        switch self {
        case .basic: return 20
        case .fast: return 15
        case .heavy: return 30
        case .boss: return 50
        }
    }
}