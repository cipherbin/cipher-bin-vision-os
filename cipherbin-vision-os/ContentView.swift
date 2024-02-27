//
//  ContentView.swift
//  cipherbin-vision-os
//
//  Created by bradford lamson-scribner on 2/23/24.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var activeView: ActiveView = .write
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        VStack {
            Button("Start AR Experience") {
                Task {
                  await openImmersiveSpace(id: "lockSpace")
                }
            }

            Image("cipherbin_logo_small.png")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 100)
                .padding(.top, 20)

            // Tab switch bar at the top
            Picker("Select View", selection: $activeView) {
                Text("Write").tag(ActiveView.write)
                Text("Read").tag(ActiveView.read)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Content view below the tab switch bar
            ScrollView {
                switch activeView {
                case .write:
                    WriteView()
                case .read:
                    ReadView()
                }
            }
        }
    }
}

enum ActiveView {
    case write, read
}
