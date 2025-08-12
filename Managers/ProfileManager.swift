//
//  ProfileManager.swift
//  SpaceTD
//
//  Created by Evan Cohen on 8/12/25.
//


import SwiftUI

class ProfileManager: ObservableObject {
    @Published var currentProfile: PlayerProfile
    
    private let profileKey = "PlayerProfile"
    
    init() {
        self.currentProfile = PlayerProfile()
    }
    
    func loadProfile() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let profile = try? JSONDecoder().decode(PlayerProfile.self, from: data) {
            self.currentProfile = profile
        }
    }
    
    func saveProfile() {
        if let data = try? JSONEncoder().encode(currentProfile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }
    
    func updateProfile(level: Int, score: Int) {
        if level >= currentProfile.highestLevel {
            currentProfile.highestLevel = min(level + 1, 10)
        }
        
        if score > currentProfile.highScore {
            currentProfile.highScore = score
        }
        
        saveProfile()
    }
}

struct PlayerProfile: Codable {
    var highestLevel: Int = 1
    var highScore: Int = 0
}