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
        let user = RepositoryUser(
            identifier: 1, login: "githubUser",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!
        )

        XCTAssertEqual(user, RepositoryUser(
            identifier: 1, login: "githubUser",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!
        ))
        XCTAssertNotEqual(user, RepositoryUser(
            identifier: 2, login: "githubUser",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!
        ))
        XCTAssertNotEqual(user, RepositoryUser(
            identifier: 1, login: "githubOtherUser",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!
        ))
        XCTAssertNotEqual(user, RepositoryUser(
            identifier: 1, login: "githubUser",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#otherAnchor")!
        ))
    }
}

class TestRepository: XCTestCase {
    // swiftlint:disable function_body_length
    func testEquatable() {
        let owner = RepositoryUser(
            identifier: 1, login: "githubUser",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!
        )
        let repository = Repository(
            identifier: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        )

        XCTAssertEqual(repository, Repository(
            identifier: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            identifier: 2, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            identifier: 1, name: "repoOtherName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            identifier: 1, name: "repoName", fullName: "repoOwner/repoOtherName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            identifier: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#otherAnchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            identifier: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 2, watcherCount: 2, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            identifier: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 3, forkCount: 3,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            identifier: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 4,
            owner: owner
        ))
        XCTAssertNotEqual(repository, Repository(
            identifier: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: RepositoryUser(
                identifier: 2, login: "githubUser",
                url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!
            )
        ))
    }
}
