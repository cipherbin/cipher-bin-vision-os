//
//  ReadView.swift
//  cipherbin-vision-os
//
//  Created by bradford lamson-scribner on 2/19/24.
//

import Foundation
import SwiftUI

struct ReadView: View {
    @State private var cipherbinURL: String = ""
    @State private var decryptedMsg: String?

    var body: some View {
        VStack {
            TextField("Enter your cipherb.in URL", text: $cipherbinURL).padding().border(Color.gray, width: 1)

            Button("Decrypt Message") {
                // TODO: call API to fetch and decrypt the message
                // This is a placeholder for actual network call
                decryptedMsg = "Decrypted message will be shown here."
            }.padding()
        }
    }
}
