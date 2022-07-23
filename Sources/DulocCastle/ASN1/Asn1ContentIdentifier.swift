//
//  Asn1ContentIdentifier.swift
//  
//
//  Created by Kevin Miller on 7/23/22.
//

import Foundation

enum Asn1IdentifierBitmask: UInt8 {
    // Initial Byte
    case CLASS    = 0b11000000
    case METHOD   = 0b00100000
    case TAG      = 0b00011111
    
    // Length Parsing
    case LEN_CONTINUE = 0b10000000
    case LEN_CONTENT  = 0b01111111
}

enum Asn1IdClass: UInt8 {
    case UNIVERSAL      = 0x00
    case APPLICATION    = 0x01
    case CONTEXTUAL     = 0x02
    case PRIVATE        = 0x03
    
    init(leadingByte: UInt8) {
        let masked = (leadingByte & Asn1IdentifierBitmask.CLASS.rawValue) >> 6
        
        // Force unwrap is safe due to bitmask
        self = Asn1IdClass(rawValue: masked)!
    }
}

enum Asn1IdMethod: UInt8 {
    case PRIMITIVE      = 0x00
    case CONSTRUCTED    = 0x01
    
    init(leadingByte: UInt8) {
        let masked = (leadingByte & Asn1IdentifierBitmask.METHOD.rawValue) >> 5
        
        // Force unwrap is safe due to bitmask
        self = Asn1IdMethod(rawValue: masked)!
    }
}

enum Asn1IdUniversalTag: UInt8 {
    case BER_EOC                = 0x00
    case BER_BOOLEAN            = 0x01
    case BER_INTEGER            = 0x02
    case BER_BIT_STR            = 0x03
    case BER_OCTET_STRING       = 0x04
    case BER_NULL               = 0x05
    case BER_OID                = 0x06
    case BER_OBJ_DESC           = 0x07
    case BER_EXTERNAL           = 0x08
    case BER_REAL               = 0x09
    case BER_ENUM               = 0x0A
    case BER_EMBED_PDV          = 0x0B
    case BER_UTF8_STRING        = 0x0C
    case BER_RELATIVE_OID       = 0x0D
    case BER_OLD_TIME           = 0x0E
    case ISO_FUTURE_USAGE       = 0x0F
    case BER_SEQUENCE           = 0x10
    case BER_SET                = 0x11
    case BER_NUMERIC_STRING     = 0x12
    case BER_PRINT_STRING       = 0x13
    case BER_T61_STRING         = 0x14
    case BER_VIDEOTEX_STRING    = 0x15
    case BER_IA5_STRING         = 0x16
    case BER_UTC_TIME           = 0x17
    case BER_GENERAL_TIME       = 0x18
    case BER_GRAPHIC_STRING     = 0x19
    case BER_ISO646_STIRNG      = 0x1A
    case BER_GENERAL_STRING     = 0x1B
    case BER_UNIVERSAL_STRING   = 0x1C
    case BER_CHARACTER_STRING   = 0x1D
    case BER_BMP_STRING         = 0x1E
    case BER_CUSTOM_TAG         = 0x1F
    
    init(leadingByte: UInt8) {
        let masked = leadingByte & Asn1IdentifierBitmask.TAG.rawValue
        
        // Force unwrap is safe due to bitmask
        self = Asn1IdUniversalTag(rawValue: masked)!
    }
}


struct Asn1ContentIdentifier {
    var idClass  : Asn1IdClass
    var idMethod : Asn1IdMethod
    
    // For the tag do we want a seperate var for the enum type
    // and for the raw value? Or just use Int?
    var idUniTag : Asn1IdUniversalTag
    var idRawTag    : Int
    
    /// Read the content identifier information and move the pointer by that length.
    /// We should expect to be pointing to the content length when we leave this function.
    static func read(_ bytes: inout [UInt8]) -> Asn1ContentIdentifier {
        let leadingByte = bytes.removeFirst()
        
        let classEnum   = Asn1IdClass(leadingByte: leadingByte)
        let methodEnum  = Asn1IdMethod(leadingByte: leadingByte)
        let tagEnum     = Asn1IdUniversalTag(leadingByte: leadingByte)
        
        // TODO: (KevinMiller77) Decide what to do if we ever encounter tag == 0x0F
        // According to the ISO it is reserved for future uses
        // https://tinyurl.com/3expmjb2
        
        // If the tag is not custom, return now
        if (tagEnum != .BER_CUSTOM_TAG) {
            return Asn1ContentIdentifier(
                idClass:    classEnum,
                idMethod:   methodEnum,
                idUniTag:   tagEnum,
                idRawTag:      Int(tagEnum.rawValue)
            )
        }
        
        var customTag: Int = 0
        
        while (true) {
            let nextByte = bytes.removeFirst()

            customTag += Int(nextByte & Asn1IdentifierBitmask.LEN_CONTENT.rawValue)
            
            if(nextByte & Asn1IdentifierBitmask.LEN_CONTINUE.rawValue == 0) {
                break;
            }
        }
        
        return Asn1ContentIdentifier(
            idClass:    classEnum,
            idMethod:   methodEnum,
            idUniTag:   tagEnum,
            idRawTag:      customTag
        )
    }
    
    /// Write function to output an instance of this class to an array
    func write() -> [UInt8] {
        var leadingByte: UInt8 = 0x00

        leadingByte |= (idClass.rawValue << 6)
        leadingByte |= (idMethod.rawValue << 5)
        leadingByte |= (idUniTag.rawValue)
        
        var out: [UInt8] = [leadingByte]
        
        // If the tag is not custom, we're done
        if (idUniTag != .BER_CUSTOM_TAG) {
            return out
        }
        
        var tagRemaining = idRawTag
        
        while(true) {
            // If we're on the last byte, just add the remaing tag number and return
            if (tagRemaining <= Int(Asn1IdentifierBitmask.LEN_CONTENT.rawValue)) {
                out.append(UInt8(tagRemaining))
                break
            }

            // More bytes to come, fill this byte to indicate more will follow
            // This method ensures we use the least number of bytes for the tag
            tagRemaining -= Int(Asn1IdentifierBitmask.LEN_CONTENT.rawValue)
            out.append(0xFF)
        }
        
        return out
    }
    
    // Comparator needed for test validation
    static func ==(lhs: Asn1ContentIdentifier, rhs: Asn1ContentIdentifier) -> Bool {
        let classMatch  = lhs.idClass == rhs.idClass
        let methodMatch = lhs.idMethod == rhs.idMethod
        let uniTagMatch = lhs.idUniTag == rhs.idUniTag
        let rawTagMatch    = lhs.idRawTag == rhs.idRawTag
        
        return (classMatch && methodMatch) && (uniTagMatch && rawTagMatch)
    }
}
