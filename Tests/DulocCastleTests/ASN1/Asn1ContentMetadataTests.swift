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
        _ ident: Asn1ContentMetadata
    ) throws {
        var bytesMutate = bytes
        
        let mockRead = Asn1ContentMetadata.read(&bytesMutate)
        let mockWrite = ident.write()

        XCTAssert(mockRead == ident)
        XCTAssert(mockWrite == bytes)
    }
    
    func testAsn1IdentifierReadWriteCases() throws {
        
        // Test 1: Universal, Primitive, Custom, Tag = 269, Indef length
        try readWriteAsn1ContentIdentifierTestEngine(
            
            // Outline your """Raw BER Identifier"""
            [ 0b00011111, 0b11111110, 0b11111110, 0b00010001, 0b10000000 ],
            
            // Outline the corresponding Swift struct
            Asn1ContentMetadata(
                idClass: .UNIVERSAL,
                idMethod: .PRIMITIVE,
                idUniTag: .BER_CUSTOM_TAG,
                idRawTag: 269
            )
        )
        
        
        // Test 2: Application, Constructed, OID, 7000 length
        try readWriteAsn1ContentIdentifierTestEngine(
            
            [ 0b01100110, 0b10000010, 0b00011011, 0b01011000 ],
            
            Asn1ContentMetadata(
                idClass: .APPLICATION,
                idMethod: .CONSTRUCTED,
                idUniTag: .BER_OID,
                idRawTag: UInt(Asn1IdUniversalTag.BER_OID.rawValue),
                contentLength: 7000
            )
        )
        
        // Test 3: Contextual, Primitive, Octet String, 24 length
        try readWriteAsn1ContentIdentifierTestEngine(
            
            [ 0b10000100, 0b00011000 ],
            
            Asn1ContentMetadata(
                idClass: .CONTEXTUAL,
                idMethod: .PRIMITIVE,
                idUniTag: .BER_OCTET_STRING,
                idRawTag: UInt(Asn1IdUniversalTag.BER_OCTET_STRING.rawValue),
                contentLength: 24
            )
        )
        
        // Test 4: Private, Constructed, Integer, 1999999999999999999 length
        try readWriteAsn1ContentIdentifierTestEngine(

            [ 0b11100010, 0b10001000, 0b00011011, 0b11000001, 0b01101101, 0b01100111, 0b01001110, 0b11000111, 0b11111111, 0b11111111 ],
            
            Asn1ContentMetadata(
                idClass: .PRIVATE,
                idMethod: .CONSTRUCTED,
                idUniTag: .BER_INTEGER,
                idRawTag: UInt(Asn1IdUniversalTag.BER_INTEGER.rawValue),
                contentLength: 1999999999999999999
            )
        )
    }

}
