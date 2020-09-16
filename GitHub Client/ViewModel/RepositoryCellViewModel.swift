//
//  RepositoryCellViewModel.swift
//  GitHub Client
//
//  Created by Adrian Ilie on 21/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import UIKit

class RepositoryCellViewModel {
    
    let cellIdentifier = "Repository"
    let cellHeight: CGFloat = 80.0
    
    let repository: Repository
    
    let name: String
    let stars: String
    
    init(_ repository: Repository) {
        self.repository = repository
        
        self.name = repository.fullName
        self.stars = "\(repository.starsCount)"
    }
}
