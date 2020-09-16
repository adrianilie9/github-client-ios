//
//  ServiceManager.swift
//  GitHub Client
//
//  Created by Adrian Ilie on 19/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import Foundation

public protocol ServiceError {
    var message: String { get }
}

public enum ServiceResult<Error: ServiceError, T> {
    case failure(Error)
    case success(T)
}

public typealias ServiceResultClosure<Error: ServiceError, T> = (ServiceResult<Error, T>) -> Void

public class ServiceManager {

    public static let shared = ServiceManager()
    private init() { }

    // MARK: - Services

    lazy var github: GitHubServiceInterface = {
        return GitHubService()
    }()
}
