//
//  AIHTTP.swift
//  GitHub Client Tests
//
//  Created by Adrian Ilie on 20/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import XCTest

@testable import GitHub_Client

class TestAIHTTP: XCTestCase {
    func testRequestParametersEncodingAndDecoding() {
        let singleParameterPayload: [String:String] = [
            "Parameter": "Value"
        ]
        let multipleParameterPayload: [String:String] = [
            "Integer": "1",
            "String": "The quick brown fox jumps over the lazy dog",
            "SpecialCharacters? ": "$&+,/:;=?@ \"<>#%{}|\\^~[]`"
        ]
        
        for testPayload in [singleParameterPayload, multipleParameterPayload] {
            do {
                guard let encodedPayload = try AIHTTP.encodeRequestParameters(testPayload) else {
                    XCTAssertTrue(false, "Encoding request payload yelds no result.")
                    return
                }
                
                XCTAssertNil(encodedPayload.rangeOfCharacter(from: CharacterSet(charactersIn: "$+,/:;?@ \"<>#{}|\\^~[]`")))
                
                guard let decodedPayload = try AIHTTP.decodeRequestParameters(encodedPayload) else {
                    XCTAssertTrue(false, "Decoding request payload yelds no result.")
                    return
                }
                
                for (name, value) in testPayload {
                    XCTAssertNotNil(decodedPayload[name])
                    XCTAssertEqual(value, decodedPayload[name])
                }
            } catch AIHTTP.EncodingError.invalidParameterName {
                XCTAssertTrue(false, "Encoding failure; Invalid parameter name.")
            } catch AIHTTP.EncodingError.invalidParameterValue {
                XCTAssertTrue(false, "Encoding failure; Invalid parameter value.")
            } catch AIHTTP.EncodingError.invalidEncoding {
                XCTAssertTrue(false, "Encoding failure.")
            } catch {
                XCTAssertTrue(false, "Failure.")
            }
        }
    }
}
