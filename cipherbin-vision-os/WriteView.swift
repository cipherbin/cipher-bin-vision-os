//
//  WriteView.swift
//  cipherbin-vision-os
//
//  Created by bradford lamson-scribner on 2/19/24.
//

import Foundation
import SwiftUI
import UIKit
import Security

struct WriteView: View {
    @State private var message: String = ""
    @State private var oneTimeURL: String?
    @State private var showError: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $message)
                .border(Color.gray, width: 1)
                .padding()

            Button("Encrypt and Generate Link") {
                Task {
                    await postMessage()
                }
            }

            if let oneTimeURL = oneTimeURL {
                Text("Your one-time URL: \(oneTimeURL)")
                    .padding()
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = oneTimeURL
                        }) {
                            Label("Copy to Clipboard", systemImage: "doc.on.doc")
                        }
                    }
            }

            if showError {
                Text("Failed to generate the link. Please try again.")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    func generateSecureRandomString(length: Int) -> String {
        let charset = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        var randString = ""
        var randomBytes = [UInt8](repeating: 0, count: length)
        let result = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if result == errSecSuccess {
            randomBytes.forEach { byte in
                let index = Int(byte) % charset.count
                randString.append(charset[index])
            }
        } else {
            print("Error generating random bytes")
        }

        return randString
    }

    func postMessage() async {
        let uuid = UUID().uuidString
        let message = "encrypted message"

        guard let url = URL(string: "https://api.cipherb.in/msg") else {
            print("Invalid URL")
            self.showError = true
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = ["uuid": uuid, "message": message]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            req.httpBody = jsonData

            let (_, resp) = try await URLSession.shared.data(for: req)

            guard let httpResp = resp as? HTTPURLResponse, httpResp.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.showError = true
                }
                return
            }

            // If the request is successful, build the final URL
            let encryptionKey = generateSecureRandomString(length: 32)
            let oneTimeUrl = "https://cipherb.in/msg?bin=\(uuid);\(encryptionKey)"

            DispatchQueue.main.async {
                self.oneTimeURL = oneTimeUrl
                self.showError = false
                // Copy to clipboard
                UIPasteboard.general.string = oneTimeUrl
            }

            return
        } catch {
            DispatchQueue.main.async {
                self.showError = true
            }
        }
    }
}
