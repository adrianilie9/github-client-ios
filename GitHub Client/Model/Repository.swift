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

    public enum RepositoryUserError: Error {
        case decode(String)
    }

    let identifier: Int64
    let login: String
    let url: URL

    init(identifier: Int64, login: String, url: URL) {
        self.identifier = identifier
        self.login = login
        self.url = url
    }

    // MARK: - Decodable

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case login
        case url
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.identifier = try container.decode(Int64.self, forKey: .identifier)
        self.login = try container.decode(String.self, forKey: .login)
        guard let url = try URL(string: container.decode(String.self, forKey: .url)) else {
            throw RepositoryUserError.decode("Cannot decode URL")
        }
        self.url = url
    }
}

extension RepositoryUser: Equatable {
    public static func == (lhs: RepositoryUser, rhs: RepositoryUser) -> Bool {
        return (
            lhs.identifier == rhs.identifier &&
            lhs.login == rhs.login &&
            lhs.url == rhs.url
        )
    }
}

// MARK: - Repository

public struct Repository: Decodable {

    public enum RepositoryError: Error {
        case decode(String)
    }

    let identifier: Int64
    let name: String
    let fullName: String

    let url: URL

    let starsCount: Int64
    let watcherCount: Int64
    let forkCount: Int64

    let owner: RepositoryUser

    init(
        identifier: Int64, name: String, fullName: String, url: URL,
        starsCount: Int64, watcherCount: Int64, forkCount: Int64,
        owner: RepositoryUser
    ) {
        self.identifier = identifier
        self.name = name
        self.fullName = fullName

        self.url = url

        self.starsCount = starsCount
        self.watcherCount = watcherCount
        self.forkCount = forkCount

        self.owner = owner
    }

    // MARK: - Decodable

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
        case fullName = "full_name"
        case url = "html_url"
        case starsCount = "stargazers_count"
        case watcherCount = "watchers_count"
        case forkCount = "forks_count"
        case owner
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.identifier = try container.decode(Int64.self, forKey: .identifier)
        self.name = try container.decode(String.self, forKey: .name)
        self.fullName = try container.decode(String.self, forKey: .fullName)

        guard let url = try URL(string: container.decode(String.self, forKey: .url)) else {
            throw RepositoryError.decode("Cannot decode URL")
        }
        self.url = url

        self.starsCount = try container.decode(Int64.self, forKey: .starsCount)
        self.watcherCount = try container.decode(Int64.self, forKey: .watcherCount)
        self.forkCount = try container.decode(Int64.self, forKey: .forkCount)

        self.owner = try container.decode(RepositoryUser.self, forKey: .owner)
    }
}

extension Repository: Equatable {
    public static func == (lhs: Repository, rhs: Repository) -> Bool {
        return (
            lhs.identifier == rhs.identifier &&
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
