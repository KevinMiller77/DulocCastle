//
//  Asn1ObjectIdentifierTests.swift
//  
//
//  Created by Kevin Miller on 7/24/22.
//

import XCTest
@testable import DulocCastle

final class Asn1ObjectIdentifierTests: XCTestCase {

    func testAllBuiltInsExist() throws {
        
        Asn1OidBuiltIn.allCases.forEach { builtInUuid in
            let _ = builtInUuid.getOid()
        }
        
    }
    
}
