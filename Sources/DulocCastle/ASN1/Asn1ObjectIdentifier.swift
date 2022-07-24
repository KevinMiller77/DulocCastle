//
//  Asn1ObjectIdentifier.swift
//  
//
//  Created by Kevin Miller on 7/23/22.
//

import Foundation

enum Asn1OidAccessError: Error {
    case OidNotFoundErr
    case OidInUseErr
    case OidUuidNotAllowedErr
    case UnexpectedOidErr(message: String, code: Int? = nil)
}

enum OidConversionError: Error {
    case InvalidStringRepresentationGivenErr
    case UnexpectedOidConversionError(message: String, code: Int? = nil)
}

// Asn.1 Object Identifier (This will be codable)
struct Asn1Oid {
    var obj: [UInt]
    var str:  String
    var name: String
    
    // Built In UUID will be 0x0000 - 0x1FFF
    // Custom UUID can be 0x2000 - 0xFFFF
    var uuid: UInt
    
    fileprivate init(
        _ obj: [UInt],
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


/// The registry stores all of our OID objects within dictionaries for easy access using all of the identifiers.
/// This also ensures that there is only one source of truth for the available OIDs
/// For someone using the library, they will register their custom OID with the registry and
/// it will be verifed. Upon verification, they can get it using any identifier.
struct Asn1OidRegistry {
    static private var implObjRegistry :  [String : Asn1Oid] = [:]
    static private var implNameRegistry:  [String : Asn1Oid] = [:]
    static private var implUuidRegistry:  [UInt  : Asn1Oid] = [:]
    
    // Methods for registering OIDs
    // These are the only way that you can construct an OID publicly
    static func register(str: String, _ name: String, _ uuid: UInt) throws -> Asn1Oid {
        let obj = try str2obj(str)
        
        let oid = Asn1Oid(obj, str, name, uuid)
        
        if (!oidIsAvailable(oid)) {
            throw Asn1OidAccessError.OidUuidNotAllowedErr
        }
        performRegistration(oid: oid)
        
        return oid
    }
    
    static func register(obj: [UInt], _ name: String, _ uuid: UInt) throws -> Asn1Oid {
        return try register(str: obj2str(obj), name, uuid)
    }
    
    // Methods for registering relative OIDs
    static func register(parent: Asn1Oid, str: String, _ name: String, _ uuid: UInt) throws -> Asn1Oid {
        let oidStr = parent.str + "." + str
        let obj = try str2obj(oidStr)
        
        let oid = Asn1Oid(obj, oidStr, name, uuid)
        
        if (!oidIsAvailable(oid)) {
            throw Asn1OidAccessError.OidUuidNotAllowedErr
        }
        performRegistration(oid: oid)
        
        return oid
    }
    static func register(parent: Asn1Oid, obj: [UInt], _ name: String, _ uuid: UInt) throws -> Asn1Oid {
        return try register(parent: parent, str: obj2str(obj), name, uuid)
    }
    
    // Registry accessors (will init builtins if they aren't)
    static func get(obj: [UInt]) -> Asn1Oid? {
        return get(str: obj2str(obj))
    }
    
    static func get(str: String) -> Asn1Oid? {
        _ = _bootstrapIfNotDone
        
        return implObjRegistry[str]
    }
    
    static func get(name: String) -> Asn1Oid? {
        _ = _bootstrapIfNotDone
        
        return implNameRegistry[name]
    }
    
    static func get(uuid: UInt) -> Asn1Oid? {
        _ = _bootstrapIfNotDone
        
        return implUuidRegistry[uuid]
    }

    // File private version of registration can
    // use reserved uuids and overwrite OIDs
    fileprivate static func _register(str: String, _ name: String, _ uuid: UInt) throws -> Asn1Oid {
        let obj = try str2obj(str)
        let oid = Asn1Oid(obj, str, name, uuid)
        
        performRegistration(oid: oid)
        
        return oid
    }
    fileprivate static func _register(obj: [UInt], _ name: String, _ uuid: UInt) throws -> Asn1Oid {
        return try _register(str: obj2str(obj), name, uuid)
    }
    
    // Methods for registering relative OIDs
    fileprivate static func _register(parent: Asn1Oid, str: String, _ name: String, _ uuid: UInt) throws -> Asn1Oid {
        let childStr = parent.str + "." + str
        let obj = try str2obj(childStr)
        
        return try _register(obj: obj, name, uuid)
    }
    fileprivate static func _register(parent: Asn1Oid, obj: [UInt], _ name: String, _ uuid: UInt) throws -> Asn1Oid {
        let oidStr = parent.str + "." + obj2str(obj)
        return try _register(str: oidStr, name, uuid)
    }
    
    // Performs the persist on OIDs being registered
    private static func performRegistration(oid: Asn1Oid) {
        implObjRegistry[oid.str] = oid
        implNameRegistry[oid.name] = oid
        implUuidRegistry[oid.uuid] = oid
    }
    
    // Registry Helpers
    static private func oidIsAvailable(_ oid: Asn1Oid) -> Bool {
        var available = true

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
    
    static private func obj2str(_ obj: [UInt]) -> String {
        return obj.map { num in
            return String(num)
        }.joined(separator: ".")
    }
    
    static private func str2obj(_ str: String) throws -> [UInt] {
        return try str.split(separator: ".").map { str in
            guard let num = UInt(str) else {
                throw OidConversionError.InvalidStringRepresentationGivenErr
            }
            
            return num
        }
    }
    
    // Due to lazy loading, we need to bootstrap our Built Ins at
    // first access. This variable allows us to "one-shot" load everything
    // the first time it is used. Just add this in the getters and it loads
    // the registry on first get.
    static private let  _bootstrapIfNotDone: Bool = _bootstrapRegistry()
    static private func _bootstrapRegistry() -> Bool {
        
        // Get a reference to the built ins file
        guard let registryFile = Bundle.module.url(
            forResource: Asn1Constants.OID_REGISTRY_FILE,
            withExtension: Asn1Constants.OID_REGISTRY_FILE_EXT
        ) else {
            fatalError("Invalid registry bootstrap file name!")
        }
        
        var lines: [String.SubSequence]
        do {
            lines = try String(
                contentsOf: registryFile,
                encoding: .utf8
            ).split(separator: "\n")
        } catch {
            fatalError("Couldn't open registry bootstrap file!")
        }
        
        for line in lines {
            if (line.starts(with: "//") || line.starts(with: "\n")) {
                continue
            }
            
            addItemToRegistryFromFileLine(String(line))
        }
        
        return true
    }
    
    private static func addItemToRegistryFromFileLine(_ str: String) {
        // Key value pairs of name to OID UInts
        var kvPairs = str.split(separator: "=")
        if (kvPairs.count != 2) {
            fatalError("Invalid contents of registry bootstrap file!")
        }
        
        // The raw OID numbers (ie. "1.2.5.4.6")
        // There is a change that the first item will be a parents name
        var rawOidNumsAsStr = kvPairs[1].split(separator: ",")
        if(rawOidNumsAsStr.count < 1) {
            fatalError("Invalid contents of registry bootstrap file!")
        }
                  
        // Check if this item has a parent
        let outOidName = String(kvPairs.removeFirst())
        let outOidUuid = Asn1OidBuiltIn.fromString(outOidName)!.rawValue

        let possibleParentName = String(rawOidNumsAsStr[0])
        let outOidParent: Asn1Oid? = implNameRegistry[possibleParentName]
                    
        if (outOidParent != nil) {
            rawOidNumsAsStr.removeFirst()
        }
        
        var outOidObj: [UInt] = []

        // Process the OID numbers and append to the array
        for idx in 0 ..< rawOidNumsAsStr.count {
            let byteAsStr = String(rawOidNumsAsStr[idx])
            
            guard let itemUint = UInt(byteAsStr) else {
                fatalError("Invalid contents of registry bootstrap file!")
            }
            
            outOidObj.append(itemUint)
        }
        
        do {
            if (outOidParent != nil) {
                _ = try _register(parent: outOidParent!, obj: outOidObj, outOidName, outOidUuid)
            } else {
                _ = try _register(obj: outOidObj, outOidName, outOidUuid)
            }
        } catch {
            fatalError("Could not register built in OID")
        }
    }
}
