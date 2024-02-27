//
//  LockView.swift
//  cipherbin-vision-os
//
//  Created by bradford lamson-scribner on 2/27/24.
//

import Foundation
import SwiftUI
import RealityKit
import RealityKitContent

struct LockView: View {
    @State var enlarge = false

    var body: some View {
        VStack {
            RealityView { content in
                if let scene = try? await Entity(named: "Padlock") {
                    content.add(scene)
                }
            } update: { content in
                if let scene = content.entities.first {
                    let uniformScale: Float = enlarge ? 0.04 : 0.02
                    scene.transform.scale = [uniformScale, uniformScale, uniformScale]
                }
            }
            .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
                enlarge.toggle()
            })

            VStack {
                Toggle("Enlarge Content", isOn: $enlarge).toggleStyle(.button)
            }
            .padding()
        }
    }
}
