//
//  RepositoryCellViewModel.swift
//  GitHub Client Tests
//
//  Created by Adrian Ilie on 21/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import XCTest

@testable import GitHub_Client

class TestRepositoryCellViewModel: XCTestCase {
    func testBind() {
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
        let viewModel = RepositoryCellViewModel(repository)

        XCTAssertEqual(viewModel.repository, repository)
        XCTAssertEqual(viewModel.name, repository.fullName)
        XCTAssertEqual(viewModel.stars, "\(repository.starsCount)")
    }
}
