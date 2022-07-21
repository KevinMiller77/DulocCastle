//
//  StringTests.swift
//  
//
//  Created by Kevin Miller on 7/16/22.
//

import XCTest
@testable import DulocCastle

class StringTests: XCTestCase {
    func testStringInserter() throws {
        let testString = "01234567890123456789012345678901234567890123456789"
        let testSplit =  "0123456789 0123456789 0123456789 0123456789 0123456789"
        
        let execSplit = testString.inserting(str: " ", every: 10)
        
        XCTAssert(testSplit == execSplit)
    }
}
