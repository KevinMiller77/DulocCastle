//
//  Asn1ObjectIdentifier+BuiltIn.swift
//  
//
//  Created by Kevin Miller on 7/23/22.
//

import Foundation



// Currently just contains the RSA basic OIDs
// TODO: (Anyone) Fill this with more IDs
enum Asn1OidBuiltIn: UInt, CaseIterable {
    case algorithm = 0
    case rsadsi = 1
    case pkcs = 2
    case md2 = 3
    case md5 = 4
    case rc4 = 5
    case rsaEncryption = 6
    case md2WithRSAEncryption = 7
    case md5WithRSAEncryption = 8
    case pbeWithMD2AndDES_CBC = 9
    case pbeWithMD5AndDES_CBC = 10
    case X500 = 11
    case X509 = 12
    case commonName = 13
    case countryName = 14
    case localityName = 15
    case stateOrProvinceName = 16
    case organizationName = 17
    case organizationalUnitName = 18
    case rsa = 19
    case pkcs7 = 20
    case pkcs7_data = 21
    case pkcs7_signed = 22
    case pkcs7_enveloped = 23
    case pkcs7_signedAndEnveloped = 24
    case pkcs7_digest = 25
    case pkcs7_encrypted = 26
    case pkcs3 = 27
    case dhKeyAgreement = 28
    case des_ecb = 29
    case des_cfb64 = 30
    case des_cbc = 31
    case des_ede = 32
    case rc2_cbc = 33
    case sha = 34
    case shaWithRSAEncryption = 35
    case des_ede3_cbc = 36
    case des_ofb64 = 37
    case pkcs9 = 38
    case pkcs9_emailAddress = 39
    case pkcs9_unstructuredName = 40
    case pkcs9_contentType = 41
    case pkcs9_messageDigest = 42
    case pkcs9_signingTime = 43
    case pkcs9_countersignature = 44
    case pkcs9_challengePassword = 45
    case pkcs9_unstructuredAddress = 46
    case pkcs9_extCertAttributes = 47
    case netscape = 48
    case netscape_cert_extension = 49
    case netscape_data_type = 50
    case sha1 = 51
    case sha1WithRSAEncryption = 52
    case dsaWithSHA = 53
    case dsa_2 = 54
    case pbeWithSHA1AndRC2_CBC = 55
    case pbeWithSHA1AndRC4 = 56
    case dsaWithSHA1_2 = 57
    case netscape_cert_type = 58
    case netscape_base_url = 59
    case netscape_revocation_url = 60
    case netscape_ca_revocation_url = 61
    case netscape_renewal_url = 62
    case netscape_ca_policy_url = 63
    case netscape_ssl_server_name = 64
    case netscape_comment = 65
    case netscape_cert_sequence = 66
    case ld_ce = 67
    case subject_key_identifier = 68
    case key_usage = 69
    case private_key_usage_period = 70
    case subject_alt_name = 71
    case issuer_alt_name = 72
    case basic_constraints = 73
    case crl_number = 74
    case certificate_policies = 75
    case authority_key_identifier = 76
    case mdc2 = 77
    case mdc2WithRSA = 78
    case givenName = 79
    case surname = 80
    case initials = 81
    case uniqueIdentifier = 82
    case crl_distribution_points = 83
    case md5WithRSA = 84
    case serialNumber = 85
    case title = 86
    case description = 87
    case cast5_cbc = 88
    case pbeWithMD5AndCast5_CBC = 89
    case dsaWithSHA1 = 90
    case sha1WithRSA = 91
    case dsa = 92
    case ripemd160 = 93
    case ripemd160WithRSA = 94
    case rc5_cbc = 95
    
    func getOid() -> Asn1Oid {
        // All of these OIDs will always exist
        return Asn1OidRegistry.get(uuid: self.rawValue)!
    }
    
    // Get enum from the string of the same name
    static func fromString(_ str: String) -> Asn1OidBuiltIn? {
        var found: Asn1OidBuiltIn? = nil
        
        self.allCases.forEach { it in
            if (str == "\(it)") {
                found = it
                return
            }
        }
        
        return found
    }
}
