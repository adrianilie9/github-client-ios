//
//  RepositoryListViewController.swift
//  GitHub Client
//
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import UIKit

class RepositoryListViewController: UIViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupContent()
        fetchContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        repositoryTableView.indexPathsForSelectedRows?.forEach({ [weak self] (selectedRowIndexPath) in
            self?.repositoryTableView.deselectRow(at: selectedRowIndexPath, animated: true)
        })
    }

    // MARK: - UI

    @IBOutlet weak var repositoryTableView: UITableView!

    // MARK: - Content

    let githubService = ServiceManager.shared.github

    let repositories = Observable<[RepositoryCellViewModel]>([])
    var selectedRepository: Repository?

    private func setupContent() {
        navigationItem.title = "iOS Repositories"

        repositoryTableView.dataSource = self
        repositoryTableView.delegate = self

        repositories.observer = { [weak self] (repositories) in
            self?.repositoryTableView.reloadData()
            self?.repositoryTableView.flashScrollIndicators()
        }
    }

    // MARK: - Fetch

    private var fetchPage: Int64 = 1
    private var fetchInProgress = false

    private func fetchContent() {
        if fetchInProgress { return }

        fetchInProgress = true
        githubService.list(page: fetchPage) { [weak self] (listResult) in
            self?.fetchInProgress = false

            switch listResult {
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.message, preferredStyle: .alert)
                alert.addAction(
                    UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                )
                alert.addAction(
                    UIAlertAction(title: "Retry", style: .default) { [weak self] (_) in
                        self?.fetchContent()
                    }
                )
                self?.present(alert, animated: true, completion: nil)

            case .success(let repositories):
                self?.fetchPage += 1

                self?.repositories.value.append(contentsOf:
                    repositories.map({ (repository) -> RepositoryCellViewModel in
                        return RepositoryCellViewModel(repository)
                    }
                ))
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "repository" {
            if let viewController = segue.destination as? RepositoryViewController {
                viewController.repository = selectedRepository
            }
        }
    }
}

extension RepositoryListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = repositories.value[indexPath.row]

        if let cell = tableView.dequeueReusableCell(
            withIdentifier: viewModel.cellIdentifier
        ) as? RepositoryTableViewCell {
            cell.bind(viewModel)
            return cell
        }

        return UITableViewCell()
    }
}

extension RepositoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return repositories.value[indexPath.row].cellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 5 >= repositories.value.count {
            fetchContent()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRepository = repositories.value[indexPath.row].repository
        performSegue(withIdentifier: "repository", sender: nil)
    }
}
