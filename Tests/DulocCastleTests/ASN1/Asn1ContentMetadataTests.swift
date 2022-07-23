//
//  Asn1ContentMetadataTests.swift
//  
//
//  Created by Kevin Miller on 7/23/22.
//

import XCTest
@testable import DulocCastle

final class Asn1ContentMetadataTests: XCTestCase {

    // Not an actual test, just assists with the below test cases
    // do not start this function name with 'test'
    func readWriteAsn1ContentIdentifierTestEngine(
        _ bytes: [UInt8],
        _ ident: Asn1ContentIdentifier
    ) throws {
        var bytesMutate = bytes
        
        let mockRead = Asn1ContentIdentifier.read(&bytesMutate)
        let mockWrite = ident.write()

        XCTAssert(mockRead == ident)
        XCTAssert(mockWrite == bytes)
    }
    
    func testAsn1IdentifierReadWriteCases() throws {
        
        // Test 1: Universal, Primitive, Custom, Tag = 269
        try readWriteAsn1ContentIdentifierTestEngine(
            
            // Outline your """Raw BER Identifier"""
            [ 0b00011111, 0b11111110, 0b11111110, 0b00010001 ],
            
            // Outline the corresponding Swift struct
            Asn1ContentIdentifier(
                idClass: .UNIVERSAL,
                idMethod: .PRIMITIVE,
                idUniTag: .BER_CUSTOM_TAG,
                idRawTag: 269
            )
        )
        
        
        // Test 2: Application, Constructed, OID
        try readWriteAsn1ContentIdentifierTestEngine(
            
            [ 0b01100110 ],
            
            Asn1ContentIdentifier(
                idClass: .APPLICATION,
                idMethod: .CONSTRUCTED,
                idUniTag: .BER_OID,
                idRawTag: UInt(Asn1IdUniversalTag.BER_OID.rawValue)
            )
        )
        
        // Test 3: Contextual, Primitive, Octet String
        try readWriteAsn1ContentIdentifierTestEngine(
            
            [ 0b10000100 ],
            
            Asn1ContentIdentifier(
                idClass: .CONTEXTUAL,
                idMethod: .PRIMITIVE,
                idUniTag: .BER_OCTET_STRING,
                idRawTag: UInt(Asn1IdUniversalTag.BER_OCTET_STRING.rawValue)
            )
        )
        
        // Test 4: Private, Constructed, Integer
        try readWriteAsn1ContentIdentifierTestEngine(

            [ 0b11100010 ],
            
            Asn1ContentIdentifier(
                idClass: .PRIVATE,
                idMethod: .CONSTRUCTED,
                idUniTag: .BER_INTEGER,
                idRawTag: UInt(Asn1IdUniversalTag.BER_INTEGER.rawValue)
            )
        )
    }

}
