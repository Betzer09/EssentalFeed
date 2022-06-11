//
//  FeedViewController.swift
//  Prototype
//
//  Created by Austin Betzer on 6/11/22.
//

import Foundation
import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

final class FeedViewController: UITableViewController {
    
    private var feed = [FeedImageViewModel]()
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            refresh()
            tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: false)
        }

        @IBAction func refresh() {
            refreshControl?.beginRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if self.feed.isEmpty {
                    self.feed = FeedImageViewModel.prototypeFeed
                    self.tableView.reloadData()
                }
                self.refreshControl?.endRefreshing()
            }
        }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCells", for: indexPath) as! FeedImageCell
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}

extension FeedImageCell {
    func configure(with model: FeedImageViewModel) {
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil
        
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
        
        fadeIn(UIImage(named: model.imageName)) 
    }
    
    override func awakeFromNib() {
            super.awakeFromNib()

            feedImageView.alpha = 0
        }

        override func prepareForReuse() {
            super.prepareForReuse()

            feedImageView.alpha = 0
        }

        func fadeIn(_ image: UIImage?) {
            feedImageView.image = image

            UIView.animate(
                withDuration: 0.3,
                delay: 0.3,
                options: [],
                animations: {
                    self.feedImageView.alpha = 1
                })
        }
}
