//
//  ControlPanelView.swift
//  GoGoGo
//
//  Created by br3nd4nt on 16.07.2026.
//

import SwiftUI

struct ControlPanelView: View {
    @ObservedObject var game: GoGame
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    var body: some View {
        VStack(spacing: 12) {
            
            // MARK: - player info
            
            HStack {
                Circle()
                    .fill(game.currentPlayer == .black ? Color.black : Color.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: game.currentPlayer == .white ? 1 : 0)
                    )
                
                Text("\(game.currentPlayer == .black ? "Black" : "White")'s turn")
                    .font(.headline)
                    .foregroundColor(game.currentPlayer == .black ? .black : .primary)
            }
            
            // MARK: - captures
            
            HStack(spacing: 30) {
                VStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 20, height: 20)
                    Text("\(game.capturedStones[.black] ?? 0)")
                        .font(.caption)
                        .bold()
                }
                
                VStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    Text("\(game.capturedStones[.white] ?? 0)")
                        .font(.caption)
                        .bold()
                }
            }
            
            // MARK: - button
            
            HStack(spacing: 10) {
                Button(action: handlePass) {
                    Text("Pass")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(game.isGameOver ? Color.gray : Color.blue)
                        .cornerRadius(8)
                }
                .disabled(game.isGameOver)
                
                Button(action: handleResign) {
                    Text("Resign")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(game.isGameOver ? Color.gray : Color.red)
                        .cornerRadius(8)
                }
                .disabled(game.isGameOver)
            }
            
            Button(action: handleNewGame) {
                Text("New Game")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .padding(.vertical, 8)
    }
    
    private func handlePass() {
        if game.pass() {
            if game.isGameOver {
                let scores = game.calculateScore()
                let black = scores[.black] ?? 0
                let white = scores[.white] ?? 0
                let winner = black > white ? "Black" : white > black ? "White" : "Draw"
                alertMessage = "Game Over!\nBlack: \(black)\nWhite: \(white)\nWinner: \(winner)"
                showAlert = true
                NotificationCenter.default.post(name: .gameOver, object: nil, userInfo: ["message": alertMessage])
            }
        }
    }
    
    private func handleResign() {
        let playerName = game.currentPlayer == .black ? "Black" : "White"
        let winner = game.currentPlayer.opposite
        alertMessage = "\(playerName) resigns!\n\(winner == .black ? "Black" : "White") wins!"
        showAlert = true
        game.isGameOver = true
        NotificationCenter.default.post(name: .gameOver, object: nil, userInfo: ["message": alertMessage])
    }
    
    private func handleNewGame() {
        game.reset()
        NotificationCenter.default.post(name: .resetGame, object: nil)
    }
}
