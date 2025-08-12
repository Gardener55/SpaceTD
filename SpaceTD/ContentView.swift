//
//  ContentView.swift
//  SpaceTD
//
//  Created by Evan Cohen on 8/12/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var profileManager = ProfileManager()
    @State private var currentView: GameState = .menu
    @State private var selectedLevel = 1
    
    var body: some View {
        ZStack {
            // Space background
            LinearGradient(
                colors: [.black, .purple.opacity(0.3), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Stars background
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.white)
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .opacity(Double.random(in: 0.3...1.0))
            }
            
            // Main content
            switch currentView {
            case .menu:
                MenuView(
                    currentView: $currentView,
                    profileManager: profileManager
                )
            case .levelSelect:
                LevelSelectView(
                    currentView: $currentView,
                    selectedLevel: $selectedLevel,
                    profileManager: profileManager
                )
            case .playing:
                GameView(
                    currentView: $currentView,
                    level: selectedLevel,
                    profileManager: profileManager
                )
            case .gameOver:
                GameOverView(
                    currentView: $currentView,
                    profileManager: profileManager
                )
            }
        }
        .onAppear {
            profileManager.loadProfile()
        }
    }
}

enum GameState {
    case menu, levelSelect, playing, gameOver
}

#Preview {
    ContentView()
}
