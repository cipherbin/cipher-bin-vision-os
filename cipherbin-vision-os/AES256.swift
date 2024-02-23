//
//  AES256.swift
//  cipherbin-vision-os
//
//  Created by bradford lamson-scribner on 2/23/24.
//

import Foundation
import CryptoSwift

class AES256 {
    static let blockSize = 16 // AES.BlockSize

    static func encrypt(message: String, key: String) throws -> String {
        guard let keyData = key.data(using: .utf8), let messageData = message.data(using: .utf8) else {
            throw AES256Error.invalidInput
        }
        guard let iv = generateRandomBytes(count: AES.blockSize) else {
            throw AES256Error.ivGenerationFailed
        }

        do {
            let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: iv), padding: .pkcs7)
            let encryptedBytes = try aes.encrypt(messageData.bytes)

            return (iv + encryptedBytes).toHexString()
        } catch {
            throw error
        }
    }

    static func decrypt(hexString: String, key: String) throws -> String {
        guard let data = hexString.hexaToBytes, let keyData = key.data(using: .utf8) else {
            throw AES256Error.invalidInput
        }
        let iv = [UInt8](data.prefix(AES.blockSize))
        let encryptedDataBytes = [UInt8](data.dropFirst(AES.blockSize))

        do {
            let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: iv), padding: .pkcs7)
            let decryptedBytes = try aes.decrypt(encryptedDataBytes)
            guard let decryptedMessage = String(bytes: decryptedBytes, encoding: .utf8) else {
                throw AES256Error.decodingFailed
            }
            return decryptedMessage
        } catch {
            throw error
        }
    }

    // Helper method to generate random bytes
    private static func generateRandomBytes(count: Int) -> [UInt8]? {
        var randomBytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &randomBytes)
        return status == errSecSuccess ? randomBytes : nil
    }

    // Custom error types for AES256 operations
    enum AES256Error: Error {
        case invalidInput
        case ivGenerationFailed
        case decodingFailed
    }
}

extension String {
    var hexaToBytes: [UInt8]? {
        var startIndex = self.startIndex
        return stride(from: 0, to: count, by: 2).compactMap { _ in
            let endIndex = self.index(startIndex, offsetBy: 2)
            guard endIndex <= self.endIndex else { return nil }
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}
