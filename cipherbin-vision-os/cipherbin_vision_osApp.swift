//
//  cipherbin_vision_osApp.swift
//  cipherbin-vision-os
//
//  Created by bradford lamson-scribner on 2/19/24.
//

import SwiftUI

@main
struct cipherbin_vision_osApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(CGSize(width: 700, height: 900))
        
        ImmersiveSpace(id: "lockSpace") {
            LockView()
        }
        .defaultSize(CGSize(width: 200, height: 200))
    }
}
