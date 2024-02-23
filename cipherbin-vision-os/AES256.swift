//
//  AES256.swift
//  cipherbin-vision-os
//
//  Created by bradford lamson-scribner on 2/23/24.
//

import Foundation
import CryptoSwift

class AES256 {
    static func encrypt(message: String, key: String) -> String? {
        guard let keyData = key.data(using: .utf8), let messageData = message.data(using: .utf8) else {
            return nil
        }
        
        do {
            let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: AES.randomIV(AES.blockSize)), padding: .pkcs7)
            let encryptedBytes = try aes.encrypt(messageData.bytes)
            
            return encryptedBytes.toHexString()
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }

    func decrypt(hexString: String, key: String) -> String? {
        guard let keyData = key.data(using: .utf8) else {
            return nil
        }
        let encryptedData = Data(hex: hexString)
        let iv = Array(encryptedData[0..<AES.blockSize])
        let encryptedBytes = Array(encryptedData[AES.blockSize...])
        
        do {
            let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: iv), padding: .pkcs7)
            let decryptedBytes = try aes.decrypt(encryptedBytes)
            
            return String(bytes: decryptedBytes, encoding: .utf8)
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }
}
