//
//  GitHubResponse.swift
//  GitHub Client
//
//  Created by Adrian on 16/09/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import Foundation

public struct GitHubResponseItems<T: Decodable>: Decodable {
    public enum GitHubResponseItemsError: Error {
        case decode(String)
    }
    
    let totalCount: Int64
    let incompleteResults: Bool
    let items: [T]
    
    // MARK: - Decodable
    
    private enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.totalCount = try container.decode(Int64.self, forKey: .totalCount)
        self.incompleteResults = try container.decode(Bool.self, forKey: .incompleteResults)
        self.items = try container.decode([T].self, forKey: .items)
    }
}

public struct GitHubResponseContent: Decodable {
    public enum GitHubResponseContentError: Error {
        case decode(String)
    }
    
    let name: String
    let sha: String
    let size: Int64
    let content: String
    
    // MARK: - Decodable
    
    private enum CodingKeys: String, CodingKey {
        case name
        case sha
        case size
        case content
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.sha = try container.decode(String.self, forKey: .sha)
        self.size = try container.decode(Int64.self, forKey: .size)
        
        let contentEncoded = try container.decode(String.self, forKey: .content)
        guard let contentData = Data(base64Encoded: contentEncoded, options: .ignoreUnknownCharacters) else {
            throw GitHubResponseContentError.decode("Cannot base64 decode content")
        }
        guard let content = String(data: contentData, encoding: .utf8) else {
            throw GitHubResponseContentError.decode("Cannot decode content")
        }
        self.content = content
    }
}
