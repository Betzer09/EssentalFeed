//
//  FeedViewController.swift
//  EssentalFeediOS
//
//  Created by Austin Betzer on 6/11/22.
//

import Foundation
import UIKit
import EssentalFeed

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL)
}

final public class FeedViewController: UITableViewController {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    private var tableModel = [FeedImage]()
    
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [weak self] result in
            
            if let feed = try? result.get() {
                self?.tableModel = (try? result.get()) ?? []
                self?.tableView.reloadData()
            }
            
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModal = tableModel[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModal.location == nil)
        cell.locationLabel.text = cellModal.location
        cell.descriptionLabel.text = cellModal.description
        imageLoader?.loadImageData(from: cellModal.url)
        return cell
    }
}
