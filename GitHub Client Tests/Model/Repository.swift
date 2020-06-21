//
//  Repository.swift
//  GitHub Client Tests
//
//  Created by Adrian Ilie on 19/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import XCTest

@testable import GitHub_Client

class TestRepositoryUser: XCTestCase {
    func testEquatable() {
        let user = RepositoryUser(id: 1, login: "githubUser", url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!)
        
        XCTAssertEqual(user, RepositoryUser(
            id: 1, login: "githubUser",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!
        ))
        XCTAssertNotEqual(user, RepositoryUser(
            id: 2, login: "githubUser",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!
        ))
        XCTAssertNotEqual(user, RepositoryUser(
            id: 1, login: "githubOtherUser",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!
        ))
        XCTAssertNotEqual(user, RepositoryUser(
            id: 1, login: "githubUser",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#otherAnchor")!
        ))
    }
}

class TestRepository: XCTestCase {
    func testEquatable() {
        let owner = RepositoryUser(id: 1, login: "githubUser", url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!)
        let repository = Repository(
            id: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        )
        
        XCTAssertEqual(repository, Repository(
            id: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            id: 2, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            id: 1, name: "repoOtherName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            id: 1, name: "repoName", fullName: "repoOwner/repoOtherName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            id: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#otherAnchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            id: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 2, watcherCount: 2, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            id: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 3, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            id: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 4,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            id: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: RepositoryUser(id: 2, login: "githubUser", url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!)
        ))
    }
}
