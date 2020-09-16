//
//  RepositoryViewController.swift
//  GitHub Client
//
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import UIKit

class RepositoryViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContent()
    }
    
    // MARK: - UI
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var propertiesView: RepositoryPropertyView!
    @IBOutlet weak var readmeTextView: UITextView!
    @IBOutlet weak var constraintReadmeTextViewHeight: NSLayoutConstraint!
    
    // MARK: - Content
    
    let githubService = ServiceManager.shared.github
    
    var repository: Repository?
    let repositoryReadme = Observable<String>("")
    
    private func setupContent() {
        guard let repo = repository else { return }
        
        navigationItem.title = repo.name
        
        propertiesView.bind(RepositoryPropertyViewModel(repo))
        
        repositoryReadme.observer = { [weak self] readmeContent in
            guard let readmeTextView = self?.readmeTextView else { return }
            
            readmeTextView.text = readmeContent
            let requiredSize = readmeTextView.sizeThatFits(
                CGSize(width: readmeTextView.bounds.width, height: CGFloat.greatestFiniteMagnitude)
            )
            self?.constraintReadmeTextViewHeight.constant = requiredSize.height
        }
        fetchReadme()
    }
    
    // MARK: - Fetch
    
    private var fetchInProgress = false
    
    private func fetchReadme() {
        if fetchInProgress == true { return }
        guard let repo = repository else { return }
        
        fetchInProgress = true
        githubService.getReadme(repository: repo) { [weak self] (fetchResult) in
            self?.fetchInProgress = false
            
            switch fetchResult {
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.message, preferredStyle: .alert)
                if error == .notFound {
                    alert.addAction(
                        UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                    )
                } else {
                    alert.addAction(
                        UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    )
                    alert.addAction(
                        UIAlertAction(title: "Retry", style: .default) { [weak self] (action) in
                            self?.fetchReadme()
                        }
                    )
                }
                self?.present(alert, animated: true, completion: nil)
                break
                
            case .success(let readmeContent):
                self?.repositoryReadme.value  = readmeContent
                break
            }
        }
    }
}
