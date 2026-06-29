//
//  ContentView.swift
//  GoGoGo
//
//  Created by br3nd4nt on 28.06.2026.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var networking = DittoNetworking.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "network")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text("GoGoGo")
                .font(.title2)

            Text(networking.syncStatus)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(networking.remotePeerCount) remote peer(s)")
                .font(.headline)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
