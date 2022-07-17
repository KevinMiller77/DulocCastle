//
//  DistinguishedNameTests.swift
//
//
//  Created by Kevin Miller on 7/16/22.
//

import XCTest
@testable import SwiftyScep

final class DistinguishedNameTests: XCTestCase {
    func testDistinguishedName() throws {
        let testStr = "CN=Name,O=Org,OU=OrgUnit,L=Seattle,S=WA,C=US"
        
        let testCN = "Name"
        let testO  = "Org"
        let testOU = "OrgUnit"
        let testS  = "WA"
        let testL  = "Seattle"
        let testC  = "US"
        
        let testParams = [
            DistingiushedName.NameFields.CN : testCN,
            DistingiushedName.NameFields.O  : testO,
            DistingiushedName.NameFields.OU : testOU,
            DistingiushedName.NameFields.S  : testS,
            DistingiushedName.NameFields.L  : testL,
            DistingiushedName.NameFields.C  : testC,
        ]
        
        let dnParams = DistingiushedName(
            cn: testCN,
            o:  testO,
            ou: testOU,
            l:  testL,
            s:  testS,
            c:  testC
        )
        
        let dnString = try DistingiushedName(name: testStr)
        XCTAssert(dnParams.nameString == testStr)
        XCTAssert(dnString.nameString == testStr)
        XCTAssert(dnParams.nameString == dnString.nameString)
        
        XCTAssert(dnParams.nameParams == testParams)
        XCTAssert(dnParams.nameParams == testParams)
        XCTAssert(dnParams.nameParams == dnString.nameParams)
    }
}
