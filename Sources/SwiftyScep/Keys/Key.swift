//
//  Key.swift
//  
//
//  Created by Kevin Miller on 7/16/22.
//

import Foundation

enum KeyError: Error {
    case InvalidTypeErr
    case InvalidClassErr
    case CreateErr
    case ConversionErr
    
    case KeychainAddErr
    case KeychainGetErr
    
    case UnexpectedKeyError(message: String, code: Int)
}

enum KeyClass {
    case PRIVATE
    case PUBLIC
    case SYMMETRIC
    
    func toSec() -> String {
        switch(self) {
        case(.PRIVATE):
            return kSecAttrKeyClassPrivate as String
        case(.PUBLIC):
            return kSecAttrKeyClassPublic as String
        case(.SYMMETRIC):
            return kSecAttrKeyClassSymmetric as String
        }
        
    }
    
    static func fromSec(_ sec: CFString) -> KeyClass? {
        switch(sec){
        case(kSecAttrKeyClassPrivate):
            return .PRIVATE
        case(kSecAttrKeyClassPublic):
            return .PUBLIC
        case(kSecAttrKeyClassSymmetric):
            return .SYMMETRIC
        default:
            return nil
        }
    }
}

enum KeyType {
    case RSA
    case EC
    
    func toSec() -> String {
        switch(self) {
        case(.RSA):
            return kSecAttrKeyTypeRSA as String
        case(.EC):
            return kSecAttrKeyTypeEC as String
        }
        
    }
    
    static func fromSec(_ sec: CFString) -> KeyType? {
        switch(sec){
        case(kSecAttrKeyTypeRSA):
            return .RSA
        case(kSecAttrKeyTypeEC):
            return .EC
        default:
            return nil
        }
    }
}

protocol Key {
    var mRef: SecKey { get }
    
    var mClass: KeyClass { get }
    var mType: KeyType { get }
}

extension SecKey {
    func getkSecClass() -> String? {
        guard let attribs = SecKeyCopyAttributes(self) as? [CFString: Any],
              let keyClass = attribs[kSecAttrKeyClass] as? String else {
            return nil
        }
        
        return keyClass
    }
    
    func getkSecType() -> String? {
        guard let attribs = SecKeyCopyAttributes(self) as? [CFString: Any],
              let keyType = attribs[kSecAttrKeyType] as? String else {
            return nil
        }
        
        return keyType
    }
    
    func getClass() -> KeyClass? {
        guard let kSecClass = getkSecClass() else {
            return nil
        }
        
        return KeyClass.fromSec(kSecClass as CFString)
    }
    
    func getType() -> KeyType? {
        guard let kSecType = getkSecType() else {
            return nil
        }
        
        return KeyType.fromSec(kSecType as CFString)
    }
    
    func isOfClass(_ c: String) -> Bool {
        return c == getkSecClass()
    }
    
    func isOfType(_ t: String) -> Bool {
        return t == getkSecType()
    }
    
    func isOfTypeAndClass(_ t: String, _ c: String) -> Bool {
        return isOfType(t) && isOfClass(c)
    }
}
