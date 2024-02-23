//
//  AES256.swift
//  cipherbin-vision-os
//
//  Created by bradford lamson-scribner on 2/23/24.
//

import Foundation
import CryptoSwift

class AES256 {
    static func encrypt(message: String, key: String) throws -> String {
        guard let keyData = key.data(using: .utf8), let messageData = message.data(using: .utf8) else {
            throw EncryptionError.initializationFailed
        }

        do {
            let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: AES.randomIV(AES.blockSize)), padding: .pkcs7)
            let encryptedBytes = try aes.encrypt(messageData.bytes)
            return encryptedBytes.toHexString()
        } catch {
            throw error // Propagate the error
        }
    }

    static func decrypt(message: String, key: String) throws -> String {
        guard let data = Data(base64Encoded: message),
              let keyData = key.data(using: .utf8) else {
            throw DecryptionError.initializationFailed
        }
        let iv = data.prefix(16)
        let encryptedDataBytes = data.dropFirst(16)

        do {
            let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: Array(iv)), padding: .pkcs7)
            let decryptedBytes = try aes.decrypt(Array(encryptedDataBytes))
            guard let decryptedMessage = String(data: Data(decryptedBytes), encoding: .utf8) else {
                throw DecryptionError.decodingFailed
            }
            return decryptedMessage
        } catch {
            throw error
        }
    }
    
    enum EncryptionError: Error {
        case initializationFailed
    }
    
    enum DecryptionError: Error {
        case initializationFailed
        case decodingFailed
    }
}
