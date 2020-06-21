//
//  RepositoryPropertyView.swift
//  GitHub Client
//
//  Created by Adrian Ilie on 21/06/2020.
//  Copyright © 2020 Adrian Ilie. All rights reserved.
//

import UIKit

class RepositoryPropertyView: UIView {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        Bundle.main.loadNibNamed("RepositoryPropertyView", owner: self, options: nil)
        addSubview(contentView)
        
        ownerLoginLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOwner(sender:))))
    }
    
    // MARK: - UI
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var watcherLabel: UILabel!
    @IBOutlet weak var forkLabel: UILabel!
    
    @IBOutlet weak var ownerLoginLabel: UILabel!
    
    // MARK: - Content
    
    private var ownerUrl: URL?
    
    /**
     * Bind view model with view.
     *
     * - paramter viewModel: configured view model
    */
    func bind(_ viewModel: RepositoryPropertyViewModel) {
        starLabel.text = viewModel.starsCount
        watcherLabel.text = viewModel.watchersCount
        forkLabel.text = viewModel.forksCount
        
        ownerLoginLabel.text = viewModel.ownerName
        ownerUrl = viewModel.ownerUrl
    }
    
    // MARK: - Navigation
    
    @objc func tapOwner(sender: AnyObject?) {
        guard let url = ownerUrl else { return }
        UIApplication.shared.open(url)
    }
}
