//
//  String.swift
//  
//
//  Created by Kevin Miller on 7/16/22.
//

import Foundation

enum StringError: Error {
    case Base64EncodingErr // Does this even happen? Is this possible?
    case Base64DecodingErr
    
    case UnexpectedStringErr(_ message: String, _ code: Int)
}

extension String {
    
    func inserting(str s: String, every n: Int) -> String {
        var result = ""
        for i in 0..<self.count {
            if (i != 0) && (i % n == 0) {
                result += s
            }
            result.append(self[self.index(self.startIndex, offsetBy: i)])
            
        }
        
        return result
    }
    
}
