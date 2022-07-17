//
//  Pem.swift
//
//
//  Created by Kevin Miller on 7/16/22.
//

import Foundation

// A collection of static PEM Utils.
// Converts data to and from PEM formats

struct Pem {
    enum ObjectIdentifier: String {
        case X509_OLD         = "X509 CERTIFICATE"
        case X509             = "CERTIFICATE"
        case X509_PAIR        = "CERTIFICATE PAIR"
        case X509_TRUSTED     = "TRUSTED CERTIFICATE"
        case X509_REQ_OLD     = "NEW CERTIFICATE REQUEST"
        case X509_REQ         = "CERTIFICATE REQUEST"
        case X509_CRL         = "X509 CRL"
        case EVP_PKEY         = "ANY PRIVATE KEY"
        case PUBLIC           = "PUBLIC KEY"
        case RSA              = "RSA PRIVATE KEY"
        case RSA_PUBLIC       = "RSA PUBLIC KEY"
        case DSA              = "DSA PRIVATE KEY"
        case DSA_PUBLIC       = "DSA PUBLIC KEY"
        case PKCS7            = "PKCS7"
        case PKCS7_SIGNED     = "PKCS #7 SIGNED DATA"
        case PKCS8            = "ENCRYPTED PRIVATE KEY"
        case PKCS8INF         = "PRIVATE KEY"
        case DHPARAMS         = "DH PARAMETERS"
        case DHXPARAMS        = "X9.42 DH PARAMETERS"
        case SSL_SESSION      = "SSL SESSION PARAMETERS"
        case DSAPARAMS        = "DSA PARAMETERS"
        case ECDSA_PUBLIC     = "ECDSA PUBLIC KEY"
        case ECPARAMETERS     = "EC PARAMETERS"
        case ECPRIVATEKEY     = "EC PRIVATE KEY"
        case PARAMETERS       = "PARAMETERS"
        case CMS              = "CMS"
    }
    
    // DER to PEM
    static func d2p(_ der: Data,   type: ObjectIdentifier) -> String {
        return b2p(der.base64EncodedString(), type: type)
    }

    // Base64 Contiguous String to PEM
    static func b2p(_ b64: String, type: ObjectIdentifier) -> String {
        return [
            "-----BEGIN " + type.rawValue + "-----",
            b64.inserting(str: "\n", every: 64),
            "-----END " + type.rawValue + "-----"
        ].joined(separator: "\n")
    }
    
    // PEM to Base64 Contiguours String
    static func p2b(_ pem: String) -> String {
        var lines = pem.split(separator: "\n")
        lines.remove(at: 0)
        lines.remove(at: lines.count - 1)
        
        return lines.joined(separator: "")
    }
    
    // PEM to DER
    static func p2d(_ pem: String) -> Data? {
        return Data(base64Encoded: p2b(pem))
    }
}
