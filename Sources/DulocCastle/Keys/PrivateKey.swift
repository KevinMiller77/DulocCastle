//
//  PrivateKey.swift
//  
//
//  Created by Kevin Miller on 7/16/22.
//

import Foundation

struct PrivateKey: Key {
    var mRef: SecKey

    let mClass: KeyClass = KeyClass.PRIVATE
    var mType: KeyType
    
    var identifier: Pem.ObjectIdentifier
    var der: Data
    
    /// Create key initialized uses the Apple SecKey generation methods.
    /// Params:
    ///     tag  : Text identifier for retrieving and storing this key
    ///     type: Type of key (RSA/EC)
    ///     bits : Size of key in bits
    ///     persist: Store to the Apple Keychain
    ///     biometric: Require biometrics for key usage
    init(
        tag: String,
        type: KeyType,
        bits: Int? = nil,
        persist: Bool = false,
        biometric: Bool = false
    ) throws {
        mType = type
        
        // Select default bits using the type
        var defaultBits: Int
        
        switch(mType) {
        case(.RSA):
            defaultBits = 4096
            identifier = .RSA
        case(.EC):
            defaultBits = 256
            identifier = .ECPRIVATEKEY
        }
        
        
        // Create access rules
        var accessFlags = SecAccessControlCreateFlags()
        accessFlags.insert(.privateKeyUsage)
        
        if (biometric) {
            if #available(iOS 11.3, *) {
                accessFlags.insert(.biometryCurrentSet)
            } else {
                // Fallback on earlier versions
                accessFlags.insert(.touchIDCurrentSet)
            }
        }
        
        
        var err: Unmanaged<CFError>?
        
        guard let access = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            accessFlags,
            &err
        ) else {
            print("[Key Gen][Access Control]: \(err!.takeRetainedValue().localizedDescription)")
            throw err!.takeRetainedValue() as Error
        }
        
        let privateKeyAttrs: [String: Any] = [
            kSecAttrIsPermanent     as String:   persist,
            kSecAttrApplicationTag  as String:   tag.data(using: .utf8)!,
            kSecAttrAccessControl   as String:   access
        ]
        
        let attrs: [String: Any] = [
            kSecAttrKeyType         as String:  type.toSec(),
            kSecAttrKeySizeInBits   as String:  bits ?? defaultBits,
            kSecPrivateKeyAttrs     as String:  privateKeyAttrs
        ]
        
        guard let key = SecKeyCreateRandomKey(attrs as CFDictionary, &err) else {
            throw err!.takeRetainedValue() as Error
        }
        
        mRef = key
        
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(key, &error) as? Data else {
            throw error!.takeRetainedValue() as Error
        }
        
        der = data
    }
    
    init(
        copyRef: SecKey
    ) throws {
        // Get copy key class and ensure it's the correct type
        guard let copyClass = copyRef.getClass() else {
            throw KeyError.InvalidClassErr
        }

        if copyClass != KeyClass.PRIVATE {
            throw KeyError.InvalidClassErr
        }
        
        guard let copyType = copyRef.getType() else {
            throw KeyError.InvalidTypeErr
        }
        
        switch(copyType) {
        case(KeyType.RSA):
            identifier = .RSA
        case(KeyType.EC):
            identifier = .ECPRIVATEKEY
        }
        
        mType   = copyType
        mRef    = copyRef
        
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(copyRef, &error) as? Data else {
            throw error!.takeRetainedValue() as Error
        }
        
        der = data
    }
    
    func getPublicKey() -> PublicKey? {
        var pubKey: PublicKey? = nil
        do {
            try pubKey = PublicKey(priKey: mRef)
        } catch {
            print("[Key][Public Key Generation]: \(error)")
        }
        
        return pubKey
    }
    
    static func storeToKeychain(tag: String, key: PrivateKey) throws {
        let addQuery: [String: Any]  = [
            kSecClass               as String: kSecClassKey,
            kSecAttrApplicationTag  as String: tag.data(using: .utf8)!,
            kSecValueRef            as String: key.mRef
        ]
        
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeyError.KeychainAddErr }
    }
    
    static func fromKeychain(_ tag: String) throws -> PrivateKey {
        let getQuery: [String: Any] = [
            kSecClass               as String: kSecClassKey,
            kSecAttrApplicationTag  as String: tag.data(using: .utf8)!,
            kSecReturnRef           as String: true
        ]
        
        var keyRef: CFTypeRef?
        let status = SecItemCopyMatching(getQuery as CFDictionary, &keyRef)
        guard status == errSecSuccess else { throw KeyError.KeychainGetErr }
        
        let key = keyRef as! SecKey
        return try PrivateKey(copyRef: key)
    }
}
