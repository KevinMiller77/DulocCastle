//
//  Asn1IntegerUtilsTests.swift
//  
//
//  Created by Kevin Miller on 7/23/22.
//

import XCTest
@testable import DulocCastle

final class Asn1IntegerUtilsTests: XCTestCase {

    func readWriteAsn1IntegerTestEngine(
        _ bytes: [UInt8],
        _ int  : Int
    ) throws {
        var mutableBytes = bytes
        
        let testBytes = Asn1IntegerUtils.write(int)
        let testInt   = Asn1IntegerUtils.read(&mutableBytes, mutableBytes.count)
        
        XCTAssert(bytes == testBytes)
        XCTAssert(int == testInt)
    }
    
    func testAsn1IntegerUtilsReadWrite() throws {
        
        var bytes : [UInt8]
        var int   : Int

        // Test Case 1
        bytes = [ 0b11000101, 0b01000101 ]
        int = -15035
        
        try readWriteAsn1IntegerTestEngine(bytes, int)
        
        // Test Case 2
        bytes = [ 0b11111111, 0b01000101, 0b01000101 ]
        int = -47803
        
        try readWriteAsn1IntegerTestEngine(bytes, int)

        // Test Case 3
        bytes = [ 0b00100100, 0b01010101 ]
        int = 9301
        
        try readWriteAsn1IntegerTestEngine(bytes, int)
        
        // Test Case 4
        bytes = [ 0b00000000, 0b10011100, 0b01010110, 0b01000010 ]
        int = 10245698
        
        try readWriteAsn1IntegerTestEngine(bytes, int)
        
        
        
    }
    
}
