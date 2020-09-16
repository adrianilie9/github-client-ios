//
//  RepositoryTableViewCell.swift
//  GitHub Client
//
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {

    // MARK: - UI

    @IBOutlet var fullNameLabel: UILabel!
    @IBOutlet var starsCountLabel: UILabel!

    // MARK: - Content

    /// Bind view model with view.
    /// - parameter viewModel: configured view model
    func bind(_ viewModel: RepositoryCellViewModel) {
        fullNameLabel.text = viewModel.name
        starsCountLabel.text = "Stars: \(viewModel.stars)"
    }
}
