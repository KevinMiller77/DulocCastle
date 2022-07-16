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
        
        guard let pubKey = SecKeyCopyPublicKey(priKey) else {
            throw KeyError.CreateErr
        }
        
        mType = priType
        mRef  = pubKey
    }
}
