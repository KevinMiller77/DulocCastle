//
//  Asn1ObjectIdentifier.swift
//  
//
//  Created by Kevin Miller on 7/23/22.
//

import Foundation

/// We will have 4 required UNIQUE fields for every OID
///     * OBJ (Array)   => [1, 2, 840, 113549, 1, 11]
///     * STR (String)  => "1.2.840.113549.1.11"
///     * UUID (Int)      => Int identifier for each OID which is its' key in our OID repo
///     * NAME (Srint) => "pkcs-11"
///
///     The above is a "child" of the OID "pkcs" = "1.2.840.113.549.1"
///     Which itself is a child of the OID "rsadsi" = "1.2.840.113549"
///
///     We should have a way to make RelativeOIDs
///     * "pkcs-11" = { "pkcs", [ 11 ] }
///     * "pkcs-11" = { "rsadsi", [ 1, 11] }
///     * etc
///
struct Asn1Oid {
    var obj: [UInt16]
    var str:  String
    var name: String
    
    // Built In UUID will be 0x0000 - 0x1FFF
    // Custom UUID can be 0x2000 - 0xFFFF
    var uuid: UInt
    
    fileprivate init(
        _ obj: [UInt16],
        _ str: String,
        _ name: String,
        _ uuid: UInt
    ) {
        self.obj = obj
        self.str = str
        self.name = name
        self.uuid = uuid
    }
}

enum Asn1OidAccessError: Error {
    case OidNotFoundErr
    case OidInUseErr
    case OidUuidNotAllowedErr
    case UnexpectedOidErr(message: String, code: Int? = nil)
}

// The registry stores all of our OID objects within dictionaries
// for easy access using all 4 identifiers
struct Asn1OidRegistry {
    static private var implObjRegistry :  [String : Asn1Oid] = [:]
    static private var implNameRegistry:  [String : Asn1Oid] = [:]
    static private var implUuidRegistry:  [UInt  : Asn1Oid] = [:]
    
    // Methods for registering OIDs
    // These are the only way that you can construct an OID
    // OIDs may not use the Built In UUIDs
    static func registerOid(
        obj: [UInt16],
        _ name: String,
        _ uuid: UInt
    ) throws -> Asn1Oid {
        let str = obj2str(obj)
        return try registerOid(str: str, name, uuid)
    }
    
    static func registerOid(
        str: String,
        _ name: String,
        _ uuid: UInt
    ) throws -> Asn1Oid {
        let obj = try str2obj(str)
        
        let oid = Asn1Oid(obj, str, name, uuid)
        
        if (!oidIsAvailable(oid)) {
            throw Asn1OidAccessError.OidUuidNotAllowedErr
        }

        performRegistration(oid: oid)
        
        return oid
    }
    
    // Methods for registering relative OIDs
    static func registerOid(
        parent: Asn1Oid,
        obj: [UInt16],
        _ name: String,
        _ uuid: UInt
    ) throws -> Asn1Oid {
        let str = parent.str + "." + obj2str(obj)
        return try registerOid(str: str, name, uuid)
    }
    
    static func registerOid(
        parent: Asn1Oid,
        str: String,
        _ name: String,
        _ uuid: UInt
    ) throws -> Asn1Oid {
        let childStr = parent.str + "." + str
        let obj = try str2obj(childStr)
        
        let oid = Asn1Oid(obj, childStr, name, uuid)
        
        if (!oidIsAvailable(oid)) {
            throw Asn1OidAccessError.OidUuidNotAllowedErr
        }

        performRegistration(oid: oid)
        
        return oid
    }
    
    // File private version of registration can
    // use reserved uuids and overwrite OIDs
    fileprivate static func _registerOid(
        obj: [UInt16],
        _ name: String,
        _ uuid: UInt
    ) throws -> Asn1Oid {
        let str = obj2str(obj)
        return try _registerOid(str: str, name, uuid)
    }
    
    fileprivate static func _registerOid(
        str: String,
        _ name: String,
        _ uuid: UInt
    ) throws -> Asn1Oid {
        let obj = try str2obj(str)
        let oid = Asn1Oid(obj, str, name, uuid)
        
        performRegistration(oid: oid)
        
        return oid
    }
    
    // Methods for registering relative OIDs
    static func _registerOid(
        parent: Asn1Oid,
        obj: [UInt16],
        _ name: String,
        _ uuid: UInt
    ) throws -> Asn1Oid {
        let str = parent.str + "." + obj2str(obj)
        return try _registerOid(str: str, name, uuid)
    }
    
    static func _registerOid(
        parent: Asn1Oid,
        str: String,
        _ name: String,
        _ uuid: UInt
    ) throws -> Asn1Oid {
        let childStr = parent.str + "." + str
        let obj = try str2obj(childStr)
        
        return try _registerOid(obj: obj, name, uuid)
    }
    
    // Performs the persist on OIDs being registered
    private static func performRegistration(oid: Asn1Oid) {
        implObjRegistry[oid.str] = oid
        implNameRegistry[oid.name] = oid
        implUuidRegistry[oid.uuid] = oid
    }
    
    // Registry accessors
    static func getOid(obj: [UInt16]) -> Asn1Oid? {
        return getOid(str: obj2str(obj))
    }

    static func getOid(str: String) -> Asn1Oid? {
        return implObjRegistry[str]
    }

    static func getOid(name: String) -> Asn1Oid? {
        return implNameRegistry[name]
    }

    static func getOid(uuid: UInt) -> Asn1Oid? {
        return implUuidRegistry[uuid]
    }
    
    
    // Registry Helpers
    static func oidIsAvailable(_ oid: Asn1Oid) -> Bool {
        var available = false

        if (oid.uuid < 0x1FFF) {
            available = false
        }
        if (implUuidRegistry[oid.uuid] != nil) {
            available = false
        }

        if (implObjRegistry[oid.str] != nil ) {
            available = false
        }
        if (implNameRegistry[oid.name] != nil ) {
            available = false
        }
        
        return available
    }
    
    enum OidConversionError: Error {
        case InvalidStringRepresentationGivenErr
        case UnexpectedOidConversionError(message: String, code: Int? = nil)
    }
    
    static func obj2str(_ obj: [UInt16]) -> String {
        return obj.map { num in
            return String(num)
        }.joined(separator: ".")
    }
    
    static func str2obj(_ str: String) throws -> [UInt16] {
        return try str.split(separator: ".").map { str in
            guard let num = UInt16(str) else {
                throw OidConversionError.InvalidStringRepresentationGivenErr
            }
            
            return num
        }
    }
}

