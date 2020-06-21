//
//  RepositoryPropertyViewModel.swift
//  GitHub Client
//
//  Created by Adrian Ilie on 21/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import Foundation

class RepositoryPropertyViewModel {
    let starsCount: String
    let watchersCount: String
    let forksCount: String
    
    let ownerName: String
    let ownerUrl: URL
    
    init(_ repository: Repository) {
        starsCount = "\(repository.starsCount)"
        watchersCount = "\(repository.watcherCount)"
        forksCount = "\(repository.forkCount)"
        
        ownerName = repository.owner.login
        ownerUrl = repository.owner.url
    }
}
