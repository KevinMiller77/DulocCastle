//
//  KeyPair.swift
//  
//
//  Created by Kevin Miller on 7/16/22.
//

import Foundation

struct KeyPair {
    var pri: PrivateKey
    var pub: PublicKey?
    
    init(
        tag: String,
        type: KeyType,
        bits: Int? = nil,
        persist: Bool = false,
        biometric: Bool = false
    ) throws {
        pri = try PrivateKey(tag: tag, type: type, bits: bits, persist: persist, biometric: biometric)
        pub = pri.getPublicKey()
    }
    
    init(
        copyRef: SecKey
    ) throws {
        pri = try PrivateKey(copyRef: copyRef)
        pub = pri.getPublicKey()
    }
}
