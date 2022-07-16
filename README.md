# SwiftyScep

Swifty Scep is a SCEP client written in Swift.

[![Swift Version][swift-image]][swift-url] [![License][license-image]][license-url]

I was looking for a nice SCEP client that easily interfaces with Apple CommonCrypto and Keychain. 
I couldn't find anything that really got the job done so I've decided to take a crack at it myself.

The intention of this library is that it will not depend on any other libraries and will be fully self contained. 
Therefore - it will be more than just a SCEP client. It will also be a fully loaded PKI library that is able to create most PKI structures.

A lot of inspiration was taken from the [Simple ASN.1 Reader and Writer by nextincrement](https://github.com/nextincrement/simple-asn1-reader-writer)

## Features
### PKI Features
#### ASN.1 Reader
- [ ] Reading ASN.1 BER/DER/CER format
- [ ] Conversion of ASN.1 data to Swift types
- [ ] Ease of use functionality for ASN.1 traversal (probably with dictionaries)

#### ASN.1 Writer
- [ ] Encoding bytes using the ASN.1 BER encoding format
- [ ] Easy insertion of new bytes to already written structure
- [ ] Composition of structured and nested types
- [ ] Wrapping of existing structures

#### General PKI

- [x] RSA and ECC key generation (Apple SecKey/Secure Enclave)
    - [x] Biometric usage
    - [x] Saving to KeyChain
    - [ ] Encryption with keys
    - [ ] Signing with keys
    - [ ] ASN.1 representation
- [ ] Distinguished Name
  - [ ] Swift
  - [ ] ASN.1
- [ ] X509 Certificate
  - [ ] Swift
  - [ ] ASN.1
  - [ ] Saved as Apple SecCertificate
  - [ ] Store the the Key Chain
- [ ] Certificate Revocation List
  - [ ] Swift
  - [ ] ASN.1
- [ ] PKCS#10 Certificate Signing Request
  - [ ] Swift
  - [ ] ASN.1
- [ ] PKCS#7
  - [ ] Swift
  - [ ] ASN.1

### SCEP Features
  - [ ] SCEP pkcsPKIEnvelope construction (Enveloped PKCS#7) 
    - [ ] PKCSReq
    - [ ] RenewalReq
    - [ ] CertPoll
    - [ ] GetCert
    - [ ] GetCRL
  - [ ] SCEP client
    - [ ] Server capabilities fetching
    - [ ] Certificate chain
    - [ ] Certificate revocation lists
    - [ ] Certificate issuance request
    - [ ] Certificate issuance polling
    - [ ] Certificate reissuance


[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]:https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE

## Usage

`There isn't really anything to use at the moment but keep checking back!`

## Resources

- [Laymans ASN.1 BER and DER](http://luca.ntop.org/Teaching/Appunti/asn1.html)

- [RSA Public Key Cryptography Syntax (PKCS) RFC](https://datatracker.ietf.org/doc/html/rfc8017)

- [X.509 & Certificate Revocation List (CRL) RFC](https://datatracker.ietf.org/doc/html/rfc5280)

- [PKCS#10 Certificate Signing Request (CSR) RFC](https://datatracker.ietf.org/doc/html/rfc2986)

- [PKCS#7 Cryptographic Message Syntax (CMS) RFC](https://datatracker.ietf.org/doc/html/rfc2315)

- [Simple Certificate Enrollment Protocol (SCEP) RFC](https://datatracker.ietf.org/doc/html/rfc8894)