//
//  GameModel.swift
//  SpaceTD
//
//  Created by Evan Cohen on 8/12/25.
//


import SwiftUI
import Combine

class GameModel: ObservableObject {
    @Published var enemies: [Enemy] = []
    @Published var towers: [Tower] = []
    @Published var projectiles: [Projectile] = []
    @Published var health: Int = 100
    @Published var coins: Int = 150
    @Published var score: Int = 0
    @Published var wave: Int = 1
    @Published var gameState: GamePhase = .waiting
    @Published var selectedTowerType: TowerType?
    
    let level: Int
    let maxWaves: Int
    private var waveTimer: Timer?
    private var gameTimer: Timer?
    private var enemySpawnTimer: Timer?
    private var currentWaveEnemies: Int = 0
    private var enemiesSpawned: Int = 0
    
    // Path for enemies (simple straight line for this example)
    let enemyPath: [CGPoint]
    
    init(level: Int) {
        self.level = level
        self.maxWaves = level == 10 ? 1 : 5 + level // Boss level has 1 wave
        
        // Create a simple path from left to right
        var path: [CGPoint] = []
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let pathY = screenHeight / 2
        
        for x in stride(from: -50, to: screenWidth + 50, by: 20) {
            path.append(CGPoint(x: x, y: pathY))
        }
        self.enemyPath = path
        
        startGame()
    }
    
    func startGame() {
        gameState = .playing
        startGameLoop()
        startNextWave()
    }
    
    private func startGameLoop() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { _ in
            self.updateGame()
        }
    }
    
    private func updateGame() {
        moveEnemies()
        moveTowers()
        moveProjectiles()
        checkCollisions()
        removeDeadObjects()
        checkGameState()
    }
    
    private func startNextWave() {
        guard wave <= maxWaves else {
            if level == 10 {
                // Spawn boss
                spawnBoss()
            } else {
                gameState = .won
            stopGame()
            }
            return
        }
        
        gameState = .wave
        currentWaveEnemies = level == 10 ? 1 : 5 + wave * 2
        enemiesSpawned = 0
        
        enemySpawnTimer = Timer.scheduledTimer(withTimeInterval: level == 10 ? 0 : 1.0, repeats: true) { _ in
            self.spawnEnemy()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.wave < self.maxWaves {
                self.wave += 1
            }
        }
    }
    
    private func spawnEnemy() {
        guard enemiesSpawned < currentWaveEnemies else {
            enemySpawnTimer?.invalidate()
            return
        }
        
        let enemy: Enemy
        if level == 10 && enemiesSpawned == 0 {
            // This is the boss
            return // Boss is spawned separately
        } else {
            enemy = Enemy(
                type: EnemyType.allCases.randomElement() ?? .basic,
                path: enemyPath,
                level: level
            )
        }
        
        enemies.append(enemy)
        enemiesSpawned += 1
    }
    
    private func spawnBoss() {
        let boss = Enemy(type: .boss, path: enemyPath, level: level)
        enemies.append(boss)
        enemiesSpawned = 1
        currentWaveEnemies = 1
    }
    
    private func moveEnemies() {
        for enemy in enemies {
            enemy.move()
            
            // Check if enemy reached the end
            if enemy.pathIndex >= enemyPath.count - 1 {
                health -= enemy.damage
                enemy.health = 0 // Mark for removal
            }
        }
    }
    
    private func moveTowers() {
        for tower in towers {
            tower.update()
            
            if tower.canShoot {
                if let target = findNearestEnemy(to: tower) {
                    shoot(from: tower, to: target)
                }
            }
        }
    }
    
    private func moveProjectiles() {
        for projectile in projectiles {
            projectile.move()
        }
    }
    
    private func findNearestEnemy(to tower: Tower) -> Enemy? {
        return enemies
            .filter { $0.health > 0 }
            .filter { tower.position.distance(to: $0.position) <= tower.range }
            .min { tower.position.distance(to: $0.position) < tower.position.distance(to: $1.position) }
    }
    
    private func shoot(from tower: Tower, to enemy: Enemy) {
        let projectile = Projectile(
            position: tower.position,
            target: enemy.position,
            damage: tower.damage,
            speed: 300
        )
        projectiles.append(projectile)
        tower.lastShotTime = Date()
    }
    
    private func checkCollisions() {
        for projectile in projectiles {
            for enemy in enemies {
                if projectile.position.distance(to: enemy.position) < 20 && enemy.health > 0 {
                    enemy.takeDamage(projectile.damage)
                    projectile.hasHit = true
                    
                    if enemy.health <= 0 {
                        coins += enemy.reward
                        score += enemy.reward * 10
                    }
                }
            }
        }
    }
    
    func removeDeadObjects() {
        enemies.removeAll { $0.health <= 0 }
        projectiles.removeAll { $0.hasHit || $0.position.x > UIScreen.main.bounds.width + 50 }
    }
    
    func checkGameState() {
        if health <= 0 {
            gameState = .lost
            stopGame()
        } else if enemies.isEmpty && gameState == .wave {
            gameState = .waiting
            wave += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.startNextWave()
            }
        }
    }
    
    func placeTower(at position: CGPoint, type: TowerType) {
        guard coins >= type.cost else { return }
        
        let tower = Tower(type: type, position: position)
        towers.append(tower)
        coins -= type.cost
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        waveTimer?.invalidate()
        enemySpawnTimer?.invalidate()
    }
    
    deinit {
        stopGame()
    }
}

enum GamePhase {
    case waiting, wave, playing, won, lost
}