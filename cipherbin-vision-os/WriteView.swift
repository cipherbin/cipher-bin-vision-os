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
            Text("Type your message below...")
                .font(.headline)
                .foregroundColor(.white)
                .padding()

            TextEditor(text: $message)
                .frame(minHeight: 300)
                .border(Color.gray, width: 1)
                .padding()

            Button(action: {
                Task {
                    await postMessage()
                }
            }) {
                Text("Encrypt")
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 30)
            }
            .background(Color.blue)
            .cornerRadius(10)
            .buttonStyle(PlainButtonStyle())
            .padding()
            .shadow(radius: 5)

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
        let uuid = UUID().uuidString.lowercased()
        let encryptionKey = generateSecureRandomString(length: 32)

        do {
            guard let encryptedMsg = try? AES256.encrypt(message: message, key: encryptionKey),
                  let url = URL(string: "https://api.cipherb.in/msg") else {
                DispatchQueue.main.async {
                    self.showError = true
                }
                return
            }

            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let payload: [String: Any] = ["uuid": uuid, "message": encryptedMsg]
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            req.httpBody = jsonData

            let (_, response) = try await URLSession.shared.data(for: req)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.showError = true // Show error if the HTTP response status code is not 200
                }
                return
            }

            // If the request is successful, build the final URL
            let oneTimeUrl = "https://cipherb.in/msg?bin=\(uuid);\(encryptionKey)"

            DispatchQueue.main.async {
                self.oneTimeURL = oneTimeUrl
                self.showError = false
                // Copy to clipboard
                UIPasteboard.general.string = oneTimeUrl
            }
        } catch {
            DispatchQueue.main.async {
                self.showError = true // Show error if any other part of the try block fails
            }
            print("Unexpected error: \(error.localizedDescription)")
        }
    }
}
