//
//  Repository.swift
//  GitHub Client
//
//  Created by Adrian Ilie on 19/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import Foundation

// MARK: - Repository user

public struct RepositoryUser: Decodable {
    let id: Int64
    let login: String
    let url: URL
    
    // MARK: - Decodable
    
    public enum RepositoryUserError: Error {
        case decodeError(String)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case login
        case url
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int64.self, forKey: .id)
        self.login = try container.decode(String.self, forKey: .login)
        guard let url = try URL(string: container.decode(String.self, forKey: .url)) else {
            throw RepositoryUserError.decodeError("Cannot decode URL")
        }
        self.url = url
    }
}

extension RepositoryUser: Equatable {
    public static func ==(lhs: RepositoryUser, rhs: RepositoryUser) -> Bool {
        return (
            lhs.id == rhs.id &&
            lhs.login == rhs.login &&
            lhs.url == rhs.url
        )
    }
}

// MARK: - Repository

public struct Repository {
    let id: Int64
    let name: String
    let fullName: String
    
    let url: URL
    
    let starsCount: Int64
    let watcherCount: Int64
    let forkCount: Int64
    
    let owner: RepositoryUser
}

extension Repository: Equatable {
    public static func ==(lhs: Repository, rhs: Repository) -> Bool {
        return (
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.fullName == rhs.fullName &&
            lhs.url == rhs.url &&
            lhs.starsCount == rhs.starsCount &&
            lhs.watcherCount == rhs.watcherCount &&
            lhs.forkCount == rhs.forkCount &&
            lhs.owner == rhs.owner
        )
    }
}
