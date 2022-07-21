//
//  PublicKey.swift
//  
//
//  Created by Kevin Miller on 7/16/22.
//

import Foundation

struct PublicKey: Key {
    var mRef: SecKey
    
    var mClass: KeyClass = KeyClass.PUBLIC
    var mType: KeyType
    
    var identifier: Pem.ObjectIdentifier
    var der: Data
    
    init (priKey: SecKey) throws {
        // Ensure the incoming key is a private key
        guard let priClass = priKey.getClass() else {
            throw KeyError.InvalidClassErr
        }

        if priClass != KeyClass.PRIVATE {
            throw KeyError.InvalidClassErr
        }
        
        // Find out the type of key
        guard let priType = priKey.getType() else {
            throw KeyError.InvalidTypeErr
        }
        
        switch(priType) {
        case(KeyType.RSA):
            identifier = .RSA_PUBLIC
        case(KeyType.EC):
            identifier = .PUBLIC
        }
        
        guard let pubKey = SecKeyCopyPublicKey(priKey) else {
            throw KeyError.CreateErr
        }
        
        mType = priType
        mRef  = pubKey
        
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(pubKey, &error) as? Data else {
            throw error!.takeRetainedValue() as Error
        }
        
        der = data
    }
}
