//
//  PkiObjects.swift
//  
//
//  Created by Kevin Miller on 7/16/22.
//

import Foundation

protocol PkiObject {
    var identifier: Pem.ObjectIdentifier { get }
    var der: Data { get }
}

extension PkiObject {
    func pem() -> String {
        return Pem.d2p(der, type: identifier)
    }
}

/// The following structures are commonly used in PkiOperations for SCEP
struct X509: PkiObject {
    var identifier = Pem.ObjectIdentifier.X509
    var der: Data
    
    init(_ der: Data) {
        self.der = der
    }
}

struct Pkcs10: PkiObject {
    var identifier = Pem.ObjectIdentifier.X509_REQ
    var der: Data
    
    init(_ der: Data) {
        self.der = der
    }
}

struct Pkcs7: PkiObject {
    var identifier = Pem.ObjectIdentifier.PKCS7
    var der: Data
    
    init(_ der: Data) {
        self.der = der
    }
}
