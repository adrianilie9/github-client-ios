//
//  GitHubService.swift
//  GitHub Client
//
//  Created by Adrian Ilie on 19/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import Foundation

public enum GitHubServiceError: ServiceError {
    case requestError
    case responseError
    case networkError
    case apiLimitReached
    case notFound
    
    public var message: String {
        switch self {
        case .requestError:
            return "Cannot perform request to GitHub REST API."
            
        case .responseError:
            return "Cannot understand response from GitHub REST API."
            
        case .networkError:
            return "Cannot connect to GitHub server, make sure you are connected to the internet."
        
        case .apiLimitReached:
            return "Exceeded maximum request allowed for GitHub REST API. Please try again later."
            
        case .notFound:
            return "Resource not found."
        }
    }
}

public protocol GitHubServiceInterface {
    func list(page: Int64, completionHandler: @escaping ServiceResultClosure<GitHubServiceError, [Repository]>)
    func getReadme(repository: Repository, completionHandler: @escaping ServiceResultClosure<GitHubServiceError, String>)
}

public class GitHubService: GitHubServiceInterface {
    init() {
        
    }
    
    // MARK: - Sync
    
    lazy private var syncQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    lazy private var syncSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.isDiscretionary = false
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 15.0
        
        return URLSession(configuration: config, delegate: nil, delegateQueue: self.syncQueue)
    }()
    
    /**
     * Fetch GitHub iOS repositories using REST API.
     *
     * - parameter page: page number
     * - parameter completionHandler: closure to execute after fetch process completes successfully or a failure occurs
     */
    public func list(page: Int64, completionHandler: @escaping ServiceResultClosure<GitHubServiceError, [Repository]>) {
        // encode request parameters
        var requestParameters: String?
        do {
            requestParameters = try AIHTTP.encodeRequestParameters([
                "q": "iOS",
                "sort": "stars",
                "order": "desc",
                "page": "\(page)"
            ])
        } catch {
            OperationQueue.main.addOperation { completionHandler(.failure(.requestError)) }
            return
        }
        guard let requestParametersEncoded = requestParameters else {
            OperationQueue.main.addOperation { completionHandler(.failure(.requestError)) }
            return
        }
        
        // create request URL including query parameters
        guard let requestUrl = URL(string: "https://api.github.com/search/repositories?\(requestParametersEncoded)") else {
            OperationQueue.main.addOperation { completionHandler(.failure(.requestError)) }
            return
        }
        
        // performing HTTP request
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        let task = syncSession.dataTask(with: request) { (data, response, error) in
            // validate response
            if error != nil {
                OperationQueue.main.addOperation { completionHandler(.failure(.networkError)) }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                OperationQueue.main.addOperation { completionHandler(.failure(.responseError)) }
                return
            }
            if httpResponse.statusCode != 200 {
                var error: GitHubServiceError = .responseError
                switch httpResponse.statusCode {
                case 403:
                    error = .apiLimitReached
                default:
                    error = .responseError
                }
                OperationQueue.main.addOperation { completionHandler(.failure(error)) }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(GitHubResponseItems<Repository>.self, from: data)
                OperationQueue.main.addOperation { completionHandler(.success(response.items)) }
            } catch {
                OperationQueue.main.addOperation { completionHandler(.failure(.responseError)) }
            }
        }
        task.resume()
    }
    
    /**
     * Fetch GitHub repository README file contents.
     *
     * - parameter repository: repository model
     * - parameter completionHandler: closure to execute after fetch process completes successfully or a failure occurs
     */
    public func getReadme(repository: Repository, completionHandler: @escaping ServiceResultClosure<GitHubServiceError, String>) {
        // create request URL
        guard let requestUrl = URL(string: "https://api.github.com/repos/\(repository.owner.login)/\(repository.name)/contents/README.md") else {
            OperationQueue.main.addOperation { completionHandler(.failure(.requestError)) }
            return
        }
        
        // performing HTTP request
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        let task = syncSession.dataTask(with: request) { (data, response, error) in
            // validate response
            if error != nil {
                OperationQueue.main.addOperation { completionHandler(.failure(.networkError)) }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                OperationQueue.main.addOperation { completionHandler(.failure(.responseError)) }
                return
            }
            if httpResponse.statusCode != 200 {
                var error: GitHubServiceError = .responseError
                switch httpResponse.statusCode {
                case 403:
                    error = .apiLimitReached
                case 404:
                    error = .notFound
                default:
                    error = .responseError
                }
                OperationQueue.main.addOperation { completionHandler(.failure(error)) }
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(GitHubResponseContent.self, from: data)
                OperationQueue.main.addOperation { completionHandler(.success(response.content)) }
            } catch {
                OperationQueue.main.addOperation { completionHandler(.failure(.responseError)) }
            }
        }
        task.resume()
    }
}
