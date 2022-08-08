//
//  Asn1IntegerUtils.swift
//  
//
//  Created by Kevin Miller on 7/23/22.
//

import Foundation

/// Since somebody decided it would be a good idea to have
/// custom length 2s compliment Integers (it wasn't), we need
/// a parse specifically for this. Maybe the scope of this file
/// will change to include other difficult edge case type but
/// for now it's just for the integers

struct Asn1IntegerUtils {
    
    private init() {
    }
    
    static func read(_ bytes: inout [UInt8], _ length: Int) -> Int {
        let leadingByte = bytes.removeFirst()
        let negative = leadingByte & 0b10000000 > 0
                
        // Push number into a UInt
        var rawNum   : UInt = UInt(leadingByte)

        for _ in 1 ..< length {
            rawNum <<= 8
            rawNum  |= UInt(bytes.removeFirst())
        }
        
        // If the first bit is 1, number needs conversion
        
        if (!negative) {
            return Int(rawNum)
        }
        
        // ---------- Negative Case -----------
        // 2's compliment Int is calculated by
        //      1. Flippling all bytes
        //      2. Adding one
        //      3. Negating the result
        
        var xorBytes: UInt = 0
        for _ in 0 ..< length {
            xorBytes <<= 8
            xorBytes  |= 0xFF
        }
        
        let compliement: UInt = (rawNum ^ xorBytes) + 1
        
        return -Int(compliement)
    }
    
    
    static func write(_ num: Int) -> [UInt8] {
        let rawNum = UInt(bitPattern: num)

        // A sliding window representing the byte we're looking at
        // and bit offset to find how to shift current window to UInt8
        var bitOffset   : UInt = UInt(UInt.bitWidth - 8)
        var window      : UInt = 0xFF << bitOffset
        

        /// https://www.itu.int/ITU-T/studygroups/com17/languages/X.690-0207.pdf
        /// 8.3.2 If the contents octets of an integer value encoding consist of more than one octet, then the bits of the first octet
        /// and bit 8 of the second octet:
        ///     a) shall not all be ones; and
        ///     b) shall not all be zero.
        
        // ie   11111111 11111111 11000101 01000101 => ignore 2
        //      11111111 11111111 01000101 01000101 => only ignore 1 (else lose info)
        
        let ignoreByte : UInt8  = num < 0 ? 0xff : 0x00
        let ignoreMSB  : UInt8 = ignoreByte >> 7
        
        var out: [UInt8] = []
        
        var ignoring: Bool = true
        while(true) {
            // Last byte always matters
            if (window == 0xFF) {
                out.append(UInt8(rawNum & 0xFF))
                break
            }
            
            let curByte  = UInt8((rawNum & window) >> bitOffset)
            let nextByte = UInt8((rawNum & (window >> 8)) >> (bitOffset - 8))
 
            if (ignoring) {
                let nextByteMSB = nextByte >> 7
                ignoring = (curByte == ignoreByte) && (nextByteMSB == ignoreMSB)
            }
            
            if (!ignoring) {
                out.append(curByte)
            }
            
            window   >>= 8
            bitOffset -= 8
        }
        
        return out
    }
}
