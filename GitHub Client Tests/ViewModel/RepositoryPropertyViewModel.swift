//
//  RepositoryPropertyViewModel.swift
//  GitHub Client Tests
//
//  Created by Adrian Ilie on 21/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import XCTest

@testable import GitHub_Client

class TestRepositoryPropertyViewModel: XCTestCase {
    func testBind() {
        let owner = RepositoryUser(id: 1, login: "githubUser", url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!)
        let repository = Repository(
            id: 1, name: "repoName", fullName: "repoOwner/repoName",
            url: URL(string: "https://example.com/path?q=query&secondParameter=example#anchor")!,
            starsCount: 1, watcherCount: 2, forkCount: 3,
            owner: owner
        )
        let viewModel = RepositoryPropertyViewModel(repository)
        
        XCTAssertEqual(viewModel.starsCount, "\(viewModel.starsCount)")
        XCTAssertEqual(viewModel.watchersCount, "\(viewModel.watchersCount)")
        XCTAssertEqual(viewModel.forksCount, "\(viewModel.forksCount)")
        XCTAssertEqual(viewModel.ownerName, repository.owner.login)
        XCTAssertEqual(viewModel.ownerUrl, repository.owner.url)
    }
}
