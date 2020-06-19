//
//  GitHubService.swift
//  GitHub Client
//
//  Created by Adrian Ilie on 19/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import Foundation

import SwiftyJSON

public enum GitHubServiceError: ServiceError {
    case networkError
    
    public var message: String {
        switch self {
        case .networkError:
            return "Network error"
        }
    }
}

public protocol GitHubServiceInterface {
    
}

public class GitHubService: GitHubServiceInterface {
    init() {
        
    }
}
