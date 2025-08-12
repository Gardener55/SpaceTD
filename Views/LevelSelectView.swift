//
//  LevelSelectView.swift
//  SpaceTD
//
//  Created by Evan Cohen on 8/12/25.
//


import SwiftUI

struct LevelSelectView: View {
    @Binding var currentView: GameState
    @Binding var selectedLevel: Int
    let profileManager: ProfileManager
    
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                Button(action: {
                    currentView = .menu
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("SELECT MISSION")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Placeholder for symmetry
                Image(systemName: "arrow.left.circle.fill")
                    .font(.title)
                    .foregroundColor(.clear)
            }
            
            // Level Grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(1...10, id: \.self) { level in
                        LevelButton(
                            level: level,
                            isUnlocked: level <= profileManager.currentProfile.highestLevel,
                            isBoss: level == 10,
                            selectedLevel: $selectedLevel,
                            currentView: $currentView
                        )
                    }
                }
                .padding()
            }
            
            // Level Info
            if selectedLevel > 0 {
                VStack(spacing: 10) {
                    Text(selectedLevel == 10 ? "BOSS LEVEL" : "LEVEL \(selectedLevel)")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(selectedLevel == 10 ? .red : .white)
                    
                    Text(levelDescription(selectedLevel))
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private func levelDescription(_ level: Int) -> String {
        if level == 10 {
            return "Face the ultimate challenge! Defeat the Space Destroyer to save the galaxy."
        } else {
            return "Defend against \(5 + level) waves of increasingly difficult enemies."
        }
    }
}

struct LevelButton: View {
    let level: Int
    let isUnlocked: Bool
    let isBoss: Bool
    @Binding var selectedLevel: Int
    @Binding var currentView: GameState
    
    var body: some View {
        Button(action: {
            if isUnlocked {
                selectedLevel = level
                currentView = .playing
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(buttonBackground)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(borderColor, lineWidth: 2)
                    )
                
                if isBoss {
                    Image(systemName: "crown.fill")
                        .font(.title)
                        .foregroundColor(.orange)
                } else if isUnlocked {
                    Text("\(level)")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
        }
        .disabled(!isUnlocked)
        .scaleEffect(selectedLevel == level ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: selectedLevel)
    }
    
    private var buttonBackground: LinearGradient {
        if !isUnlocked {
            return LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
        } else if isBoss {
            return LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private var borderColor: Color {
        if !isUnlocked {
            return .gray
        } else if isBoss {
            return .orange
        } else {
            return .blue
        }
    }
}