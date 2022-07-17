//
//  DistinguishedName.swift
//  
//
//  Created by Kevin Miller on 7/16/22.
//

import Foundation

enum DistinguishedNameError: Error {
    case MissingRequiredFieldErr
    case InvalidFieldErr
}

struct DistingiushedName {
    var nameString: String = ""
    var nameParams: [NameFields:String] = [:]
    
    enum NameFields: String {
        case CN = "CN"
        case O  = "O"
        case OU = "OU"
        case L  = "L"
        case S  = "S"
        case C  = "C"
        
    }
    
    init(name: String) throws {
        nameString = ""
        let fieldPairs = name.split(separator: ",")
        
        for pair in fieldPairs {
            let pairData = pair.split(separator: "=")
                
            if (pairData.count != 2) {
                print("[DN][Creation] ERROR: Invalid field \(pairData[0])")
                continue
            }
            
            guard let field = NameFields(rawValue: pairData[0].uppercased()) else {
                print("[DN][Creation] ERROR: Invalid field \(pairData[0])")
                continue
            }
            
            self.nameParams[field] = String(pairData[1])
            self.nameString += pair
            self.nameString += ","
        }
        
        if (self.nameParams[NameFields.CN] == nil) {
            throw DistinguishedNameError.MissingRequiredFieldErr
        }
        
        nameString.removeLast()
    }
    
    init(
        cn: String,
        o : String? = nil,
        ou: String? = nil,
        l : String? = nil,
        s : String? = nil,
        c : String? = nil
    ) {
        addFieldIfExists(NameFields.CN, cn)
        addFieldIfExists(NameFields.O , o)
        addFieldIfExists(NameFields.OU, ou)
        addFieldIfExists(NameFields.L , l)
        addFieldIfExists(NameFields.S , s)
        addFieldIfExists(NameFields.C , c)
        
        nameString.removeLast()
    }
    
    mutating func addFieldIfExists(_ field: NameFields, _ content: String?) {
        guard let c = content else {
            return
        }
        
        self.nameParams[field] = c
        self.nameString += field.rawValue + "=" + c
        self.nameString += ","
    }
}
