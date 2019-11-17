//
//  RepositoriesListViewController.swift
//  GitHub Repositories
//
//  Copyright © 2019 Eduardo Camaratta. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RepositoriesListViewController: UIViewController {

    @IBOutlet weak var tableRepositories: UITableView!
    @IBOutlet weak var viewLoading: UIView!

    private var data:[RepositoryModel?] = []
    private var selectedCell:RepositoryDetailsViewController? = nil
    private var githubService:GitHubService = GitHubService()

    override func viewDidLoad() {
        super.viewDidLoad()
        githubService.initiate(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedCell = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RepositoryDetailsSegue" {
            let repositoryDetailsVC:RepositoryDetailsViewController = segue.destination as! RepositoryDetailsViewController
            let cell:TableViewCellRepository = sender as! TableViewCellRepository
            self.githubService.scheduleUpdate(repositoryIndex: cell.index)
            self.selectedCell = repositoryDetailsVC
            repositoryDetailsVC.initiate(data: cell.data, index: cell.index)
            self.githubService.scheduleUpdate(repositoryIndex: cell.index)
        }
    }
}

// MARK: - Table View Data Source
extension RepositoriesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:TableViewCellRepository? = tableView.dequeueReusableCell(withIdentifier: "CellRepository") as? TableViewCellRepository
        if cell == nil {
            cell = TableViewCellRepository()
        }
        let data = self.data[indexPath.row]
        cell!.initiate(data: data, index: indexPath.row, delegate: self)
        self.githubService.scheduleUpdate(repositoryIndex: indexPath.row)
        return cell!
    }
}

// MARK: - GitHub Service Delegate
extension RepositoriesListViewController: GitHubServiceDelegate {
    func dataUpdated(data: [RepositoryModel?], startIndex: Int, count: Int, total: Int?) {
        self.viewLoading.isHidden = true
        
        if let total = total {
            if self.data.count == 0 {
                self.data = Array(repeating: nil, count: total)
            }
            
            for index in startIndex..<(startIndex + count) {
                self.data[index] = data[index - startIndex]
            }
            
            tableRepositories.reloadData()
        } else {
            var indexes:[IndexPath] = []
            for index in startIndex..<min(startIndex + count, self.data.count) {
                self.data[index] = data[index - startIndex]
                indexes.append(IndexPath(row: index, section: 0))
            }
            tableRepositories.reloadRows(at: indexes, with: .fade)
        }
        
        if let selectedCell = self.selectedCell {
            selectedCell.dataUpdated(data: self.data[selectedCell.getIndex()])
        }
    }
}

// MARK: - Cell Delegate
extension RepositoriesListViewController: TableViewCellRepositoryDelegate {
    func cellTapped(cell: TableViewCellRepository) {
        self.performSegue(withIdentifier: "RepositoryDetailsSegue", sender: cell)
    }
}
