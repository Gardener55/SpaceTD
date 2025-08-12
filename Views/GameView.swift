//
//  GameView.swift
//  SpaceTD
//
//  Created by Evan Cohen on 8/12/25.
//


import SwiftUI

struct GameView: View {
    @Binding var currentView: GameState
    @StateObject private var gameModel: GameModel
    let profileManager: ProfileManager
    
    init(currentView: Binding<GameState>, level: Int, profileManager: ProfileManager) {
        self._currentView = currentView
        self._gameModel = StateObject(wrappedValue: GameModel(level: level))
        self.profileManager = profileManager
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Game Area
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        handleTap(at: location, in: geometry)
                    }
                
                // Enemy Path Visualization
                Path { path in
                    for (index, point) in gameModel.enemyPath.enumerated() {
                        if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: 40)
                
                // Towers
                ForEach(gameModel.towers) { tower in
                    TowerView(tower: tower)
                }
                
                // Enemies
                ForEach(gameModel.enemies) { enemy in
                    EnemyView(enemy: enemy)
                }
                
                // Projectiles
                ForEach(gameModel.projectiles) { projectile in
                    ProjectileView(projectile: projectile)
                }
                
                // UI Overlay
                VStack {
                    // Top HUD
                    HStack {
                        Button(action: {
                            currentView = .levelSelect
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 20) {
                            HUDItem(icon: "heart.fill", value: "\(gameModel.health)", color: .red)
                            HUDItem(icon: "dollarsign.circle.fill", value: "\(gameModel.coins)", color: .yellow)
                            HUDItem(icon: "star.fill", value: "\(gameModel.score)", color: .white)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    
                    Spacer()
                    
                    // Bottom HUD - Tower Selection
                    HStack(spacing: 15) {
                        ForEach(TowerType.allCases, id: \.self) { towerType in
                            TowerButton(
                                towerType: towerType,
                                isSelected: gameModel.selectedTowerType == towerType,
                                canAfford: gameModel.coins >= towerType.cost
                            ) {
                                gameModel.selectedTowerType = 
                                    gameModel.selectedTowerType == towerType ? nil : towerType
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                }
                
                // Game State Messages
                if gameModel.gameState == .waiting {
                    VStack {
                        Text("Wave \(gameModel.wave) Incoming...")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                    }
                } else if gameModel.gameState == .won {
                    GameResultView(
                        title: "MISSION COMPLETE!",
                        subtitle: "Level \(gameModel.level) Cleared",
                        score: gameModel.score,
                        color: .green
                    ) {
                        handleGameEnd(won: true)
                    }
                } else if gameModel.gameState == .lost {
                    GameResultView(
                        title: "MISSION FAILED",
                        subtitle: "Base Destroyed",
                        score: gameModel.score,
                        color: .red
                    ) {
                        handleGameEnd(won: false)
                    }
                }
            }
        }
    }
    
    private func handleTap(at location: CGPoint, in geometry: GeometryProxy) {
        guard let towerType = gameModel.selectedTowerType,
              gameModel.coins >= towerType.cost else { return }
        
        // Check if location is not on the path
        let pathWidth: CGFloat = 40
        for pathPoint in gameModel.enemyPath {
            if location.distance(to: pathPoint) < pathWidth {
                return // Too close to path
            }
        }
        
        // Check if location is not too close to existing towers
        for tower in gameModel.towers {
            if location.distance(to: tower.position) < 60 {
                return // Too close to existing tower
            }
        }
        
        gameModel.placeTower(at: location, type: towerType)
        gameModel.selectedTowerType = nil
    }
    
    private func handleGameEnd(won: Bool) {
        if won {
            profileManager.updateProfile(
                level: gameModel.level,
                score: gameModel.score
            )
        }
        currentView = .levelSelect
    }
}

struct HUDItem: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

struct TowerButton: View {
    let towerType: TowerType
    let isSelected: Bool
    let canAfford: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Circle()
                    .fill(towerType.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                    )
                
                Text("$\(towerType.cost)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(canAfford ? .white : .gray)
            }
        }
        .disabled(!canAfford)
    }
}

struct GameResultView: View {
    let title: String
    let subtitle: String
    let score: Int
    let color: Color
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
            
            Text("Score: \(score)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.yellow)
            
            Button(action: onContinue) {
                Text("CONTINUE")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(color)
                    .cornerRadius(10)
            }
        }
        .padding(30)
        .background(Color.black.opacity(0.8))
        .cornerRadius(15)
    }
}

struct TowerView: View {
    @ObservedObject var tower: Tower
    
    var body: some View {
        Circle()
            .fill(tower.type.color)
            .frame(width: 30, height: 30)
            .position(tower.position)
            .overlay(
                Circle()
                    .stroke(tower.type.color.opacity(0.2), lineWidth: 2)
                    .frame(width: tower.range * 2, height: tower.range * 2)
                    .position(tower.position)
            )
    }
}

struct EnemyView: View {
    @ObservedObject var enemy: Enemy
    
    var body: some View {
        ZStack {
            // Enemy body
            Circle()
                .fill(enemy.type.color)
                .frame(width: enemy.type.size, height: enemy.type.size)
            
            // Health bar
            if enemy.healthPercentage < 1.0 {
                VStack {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: enemy.type.size, height: 4)
                        .overlay(
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: enemy.type.size * enemy.healthPercentage, height: 4),
                            alignment: .leading
                        )
                    Spacer()
                }
                .frame(height: enemy.type.size)
            }
        }
        .position(enemy.position)
    }
}

struct ProjectileView: View {
    @ObservedObject var projectile: Projectile
    
    var body: some View {
        Circle()
            .fill(Color.cyan)
            .frame(width: 6, height: 6)
            .shadow(color: .cyan, radius: 3)
            .position(projectile.position)
    }
}