//
//  Pem.swift
//  
//
//  Created by Kevin Miller on 7/16/22.
//

import XCTest
@testable import SwiftyScep

final class PemTests: XCTestCase {
    func testPemConverters() throws {
        let testPemType = Pem.ObjectIdentifier.PKCS7
        let testPemChars = [
            "a2pyYm5xYnBlb2FqcmhicGFldGpibnBxd2tqYm5hcHNrYmpibnZ3cnRwYmpud3Bi",
            "am53cGZkb2p2bnBvZGZhanZqcG9haWZqYnI7ZXFvaWdqcXB3cm9panBvaWpwb2lu",
            "cHF2aWpyZW5mcHZxaWplcm52cHNqbnZwZXJqbnBvbm9xZWlidm9xZXZvaXdlYm5s",
            "YmpuYXNwYWtidm5hc1BrYm5hZDtibnFhcGl2bnE7ZXJrZ252cGVudnBlaWpuYnBl",
            "aXdqbnZwcWVhaWpybmJ2cHFla252cHFlaW52YnBxZWlqdm5xcGVvcm52cHFlb2pi",
            "bnZwcWVyb2pibnZxcGVya2JudnBxb2pvam9qcm9qcWFlcmdvanFhb3JnajtxZWtq",
            "Zzt2cWxrZW52cHFlb2Frb29qb2Zqb2VnanFyb2VkbWc="
        ]
        
        let testPemB64 = testPemChars.joined(separator: "")
        
        let testDer = Data(base64Encoded: testPemB64)
        let testPem = [
            "-----BEGIN " + testPemType.rawValue + "-----",
            testPemChars.joined(separator: "\n"),
            "-----END " + testPemType.rawValue + "-----",
        ].joined(separator: "\n")
        
        let b2p = Pem.b2p(testPemB64, type: testPemType)
        let d2p = Pem.d2p(testDer!, type: testPemType)
        
        XCTAssert(testPem == b2p)
        XCTAssert(testPem == d2p)
        
        let p2b = Pem.p2b(testPem)
        let p2d = Pem.p2d(testPem)
        
        XCTAssert(p2b == testPemB64)
        XCTAssert(p2d == testDer)
    }
}
