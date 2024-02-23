//
//  ReadView.swift
//  cipherbin-vision-os
//
//  Created by bradford lamson-scribner on 2/19/24.
//

import Foundation
import SwiftUI

struct ReadView: View {
    @State private var inputURL: String = ""
    @State private var message: String?
    @State private var error: String?

    var body: some View {
        VStack(spacing: 20) {
            TextField("Paste cipherb.in link here", text: $inputURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Decrypt Message") {
                let binValue = extractBinValue(from: inputURL)
                fetchAndDecryptMessage(binValue: binValue)
            }

            if let message = message {
                Text(message)
                    .padding()
            } else if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }

    func extractBinValue(from url: String) -> String {
        // URL format: "https://cipherb.in/msg?bin=some_uuid;encryption_key"
        guard let urlComponents = URLComponents(string: url),
              let queryItems = urlComponents.queryItems,
              let binItem = queryItems.first(where: { $0.name == "bin" }) else {
            return ""
        }
        return binItem.value ?? ""
    }

    func fetchAndDecryptMessage(binValue: String) {
        let parts = binValue.split(separator: ";").map(String.init)
        guard parts.count == 2, let uuid = parts.first, let encryptionKey = parts.last else {
            self.error = "Sorry, this seems to be an invalid link"
            return
        }
        guard let url = URL(string: "https://api.cipherb.in/msg?bin=\(uuid)") else {
            self.error = "Invalid URL format"
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.error = "Sorry, there was an error! \(error.localizedDescription)"
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,
                  let data = data else {
                DispatchQueue.main.async {
                    self.error = "Error fetching message"
                }
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let encryptedMessage = jsonResponse["message"] as? String,
                   let decryptedMessage = try? AES256.decrypt(message: encryptedMessage, key: encryptionKey) {
                    DispatchQueue.main.async {
                        self.message = decryptedMessage
                        self.error = nil
                    }
                } else {
                    DispatchQueue.main.async {
                        self.error = "Error decoding response"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = "Decryption failed: \(error.localizedDescription)"
                }
            }
        }

        task.resume()
    }
}
