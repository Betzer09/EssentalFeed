//
//  FeedViewController.swift
//  Prototype
//
//  Created by Austin Betzer on 6/11/22.
//

import Foundation
import UIKit

final class FeedViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "FeedImageCells", for: indexPath)
    }
}
