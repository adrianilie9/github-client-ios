//
//  AIHTTP.swift
//  GitHub Client
//
//  Created by Adrian Ilie on 20/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import Foundation

public class AIHTTP {
    
    public enum EncodingError: Error {
        case invalidParameterName
        case invalidParameterValue
        case invalidEncoding
    }
    
    /// Encode HTTP request parameters for transport.
    ///
    /// - parameter params: HTTP request parameters payload
    /// - returns: parameters joined and escaped
    public static func encodeRequestParameters(_ params: [String:String]) throws -> String? {
        var encodedParameters: [String] = []
        
        for (name, value) in params {
            guard let encodedName = name.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
                throw EncodingError.invalidParameterName
            }
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
            
            encodedParameters.append(String(format: "%@=%@", encodedName, encodedValue))
        }
        
        return encodedParameters.joined(separator: "&")
    }
    
    /// Decode HTTP request parameters.
    ///
    /// - parameter params: encoded HTTP request parameters
    /// - returns: HTTP request parameters decoded
    public static func decodeRequestParameters(_ params: String) throws -> [String:String]? {
        var decodedParameters: [String:String] = [:]
        
        for nameAndValue in params.split(separator: "&") {
            if !nameAndValue.contains("=") {
                throw EncodingError.invalidEncoding
            }
            
            let parts = nameAndValue.split(separator: "=")
            guard let name = parts[0].removingPercentEncoding else {
                throw EncodingError.invalidParameterName
            }
            guard let value = parts[1].removingPercentEncoding else {
                throw EncodingError.invalidParameterValue
            }
            
            decodedParameters[name] = value
        }
        
        return decodedParameters
    }
}
