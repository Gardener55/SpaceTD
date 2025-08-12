//
//  MenuView.swift
//  SpaceTD
//
//  Created by Evan Cohen on 8/12/25.
//


import SwiftUI

struct MenuView: View {
    @Binding var currentView: GameState
    let profileManager: ProfileManager
    
    var body: some View {
        VStack(spacing: 40) {
            // Title
            Text("SPACE TOWER DEFENSE")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .shadow(color: .blue, radius: 10)
            
            // Subtitle
            Text("Defend the Galaxy")
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(.gray)
            
            VStack(spacing: 20) {
                // Play Button
                Button(action: {
                    currentView = .levelSelect
                }) {
                    Text("START MISSION")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .frame(width: 250, height: 60)
                        .background(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(15)
                        .shadow(color: .blue.opacity(0.5), radius: 10)
                }
                
                // Profile Info
                VStack(spacing: 10) {
                    Text("Commander Stats")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text("Level")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(profileManager.currentProfile.highestLevel)")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        VStack {
                            Text("High Score")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(profileManager.currentProfile.highScore)")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
            }
            
            Spacer()
            
            // Instructions
            VStack(alignment: .leading, spacing: 5) {
                Text("MISSION BRIEFING:")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.yellow)
                
                Text("• Tap to place defense towers")
                Text("• Stop enemies from reaching your base")
                Text("• Defeat the final boss on Level 10")
                Text("• Earn coins to buy more towers")
            }
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(10)
        }
        .padding()
    }
}