//
//  Projectile.swift
//  SpaceTD
//
//  Created by Evan Cohen on 8/12/25.
//


import SwiftUI

class Projectile: ObservableObject, Identifiable {
    let id = UUID()
    @Published var position: CGPoint
    let damage: Int
    let speed: Double
    var hasHit: Bool = false
    
    private let velocity: CGPoint
    
    init(position: CGPoint, target: CGPoint, damage: Int, speed: Double) {
        self.position = position
        self.damage = damage
        self.speed = speed
        
        // Calculate velocity towards target
        let direction = CGPoint(
            x: target.x - position.x,
            y: target.y - position.y
        )
        let length = sqrt(direction.x * direction.x + direction.y * direction.y)
        
        if length > 0 {
            self.velocity = CGPoint(
                x: (direction.x / length) * speed,
                y: (direction.y / length) * speed
            )
        } else {
            self.velocity = CGPoint.zero
        }
    }
    
    func move() {
        let deltaTime = 1.0/60.0
        position = CGPoint(
            x: position.x + velocity.x * deltaTime,
            y: position.y + velocity.y * deltaTime
        )
    }
}