//
//  GameOverView.swift
//  SpaceTD
//
//  Created by Evan Cohen on 8/12/25.
//


import SwiftUI

struct GameOverView: View {
    @Binding var currentView: GameState
    let profileManager: ProfileManager
    
    var body: some View {
        VStack(spacing: 30) {
            Text("GAME OVER")
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(.red)
            
            Button(action: {
                currentView = .menu
            }) {
                Text("RETURN TO MENU")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: 250, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}