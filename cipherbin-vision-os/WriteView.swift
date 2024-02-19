//
//  WriteView.swift
//  cipherbin-vision-os
//
//  Created by bradford lamson-scribner on 2/19/24.
//

import Foundation
import SwiftUI

struct WriteView: View {
    @State private var message: String = ""
    @State private var encryptedLink: String?
    
    var body: some View {
        VStack {
            TextEditor(text: $message)
                .padding()
                .border(Color.gray, width: 1)
            
            Button("Encrypt and Generate Link") {
                // TODO: call API to encrypt the message and generate a link
                // This is a placeholder for actual network call
                encryptedLink = "https://cipherb.in/encryptedLink"
            }
            .padding()
            
            if let encryptedLink = encryptedLink {
                Text("Your encrypted link: \(encryptedLink)").padding()
            }
        }
        .padding()
    }
}
