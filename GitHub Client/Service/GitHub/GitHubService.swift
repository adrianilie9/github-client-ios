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
            
            do {
                // extract repository list from response
                let decodedResponse = try JSON(data: data)
                guard let repositoriesJson = decodedResponse["items"].array else {
                    OperationQueue.main.addOperation { completionHandler(.failure(.responseError)) }
                    return
                }
                
                // map fetched repositories to model
                OperationQueue.main.addOperation {
                    completionHandler(.success(
                        repositoriesJson.compactMap({ (repositoryJson) -> Repository? in
                            return self.map(repositoryJson: repositoryJson)
                        })
                    ))
                }
            } catch {
                OperationQueue.main.addOperation { completionHandler(.failure(.responseError)) }
                return
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
            
            do {
                // extract file contents from response
                let decodedResponse = try JSON(data: data)
                guard let contentEncoded = decodedResponse["content"].string else {
                    OperationQueue.main.addOperation { completionHandler(.failure(.notFound)) }
                    return
                }
                
                // decode file contents
                guard let contentData = Data(base64Encoded: contentEncoded, options: .ignoreUnknownCharacters) else {
                    OperationQueue.main.addOperation { completionHandler(.failure(.responseError)) }
                    return
                }
                guard let content = String(data: contentData, encoding: .utf8) else {
                    OperationQueue.main.addOperation { completionHandler(.failure(.responseError)) }
                    return
                }
                
                OperationQueue.main.addOperation { completionHandler(.success(content)) }
            } catch {
                OperationQueue.main.addOperation { completionHandler(.failure(.responseError)) }
                return
            }
        }
        task.resume()
    }
    
    // MARK: - Model mapping
    
    /**
     * Map GitHub repository fetched from REST API to model.
     *
     * - parameter repositoryJson: repository as fetched from REST API
     * - returns: Repository model or nil if an error occurs
     */
    private func map(repositoryJson: JSON) -> Repository? {
        guard let id = repositoryJson["id"].int64 else { return nil }
        guard let name = repositoryJson["name"].string else { return nil }
        guard let fullName = repositoryJson["full_name"].string else { return nil }
        
        guard let urlHtml = repositoryJson["html_url"].string else { return nil }
        guard let url = URL(string: urlHtml) else { return nil }
        
        guard let starsCount = repositoryJson["stargazers_count"].int64 else { return nil }
        guard let watcherCount = repositoryJson["watchers_count"].int64 else { return nil }
        guard let forkCount = repositoryJson["forks_count"].int64 else { return nil }
        
        guard let ownerDict = repositoryJson["owner"].dictionary else { return nil }
        guard let owner = map(repositoryUserDictionary: ownerDict) else { return nil }
        
        return Repository(
            id: id, name: name, fullName: fullName,
            url: url,
            starsCount: starsCount, watcherCount: watcherCount, forkCount: forkCount,
            owner: owner
        )
    }
    
    /**
     * Map GitHub repository user fetched from REST API to model.
     *
     * - parameter repositoryUserJson: repository user as fetched from REST API
     * - returns: RepositoryUser model or nil if an error occurs
     */
    private func map(repositoryUserDictionary: [String : JSON]) -> RepositoryUser? {
        guard let id = repositoryUserDictionary["id"]?.int64 else { return nil }
        guard let login = repositoryUserDictionary["login"]?.string else { return nil }
        guard let urlHtml = repositoryUserDictionary["html_url"]?.string else { return nil }
        guard let url = URL(string: urlHtml) else { return nil }
        
        return RepositoryUser(id: id, login: login, url: url)
    }
}
