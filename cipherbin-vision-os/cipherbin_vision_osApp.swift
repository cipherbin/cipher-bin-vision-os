//
//  cipherbin_vision_osApp.swift
//  cipherbin-vision-os
//
//  Created by bradford lamson-scribner on 2/19/24.
//

import SwiftUI

enum ActiveView {
    case write, read
}

@main
struct cipherbin_vision_osApp: App {
    @State private var activeView: ActiveView = .write
    
    var body: some Scene {
        WindowGroup {
            VStack {
                Picker("Select View", selection: $activeView) {
                    Text("Write").tag(ActiveView.write)
                    Text("Read").tag(ActiveView.read)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
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
