//
//  GitHubService.swift
//  GitHub Repositories
//
//  Copyright © 2019 Eduardo Camaratta. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol GitHubServiceDelegate {
    func dataUpdated(data:[RepositoryModel?], startIndex:Int, count:Int, total:Int?)
}

class GitHubService {
    // https://developer.github.com/v3/search/
    private let baseURL = "https://api.github.com/search/repositories?q=stars:>=10000&sort=stars&order=desc"
    private let minimumInterval:TimeInterval = 10.0
    private let resultsPerPage:Int = 30
    private let maxResults:Int = 1000

    private var delegate:GitHubServiceDelegate? = nil
    private var pagesList:[Int] = []

    // Gets the first page of results and starts the timer
    func initiate(delegate:GitHubServiceDelegate) {
        self.delegate = delegate
        self.getPopularRepositories()
        Timer.scheduledTimer(withTimeInterval: self.minimumInterval, repeats: true, block: ({ (_) in
            self.getPopularRepositories()
        }))
    }

    // Add the page that contains the repository index to the list of pages
    func scheduleUpdate(repositoryIndex: Int) {
        let pageIndex = repositoryIndex / self.resultsPerPage
        if let currentIndex = self.pagesList.firstIndex(of: pageIndex) {
            guard currentIndex != 0 else { return }
            self.pagesList.remove(at: currentIndex)
        }
        self.pagesList.insert(pageIndex, at: 0)
    }

    // Returns the URL to get a specific page of results
    private func getUrl(pageIndex: Int) -> URL {
        let pageParam = pageIndex > 0 ? "&page=\(pageIndex + 1)" : ""
        return URL(string: "\(self.baseURL)\(pageParam)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
    }

    // Adds the indexes of the missing result pages to the list of pages
    private func pagesListInit(total: Int) {
        guard self.pagesList.count == 0 && total > self.resultsPerPage else { return }

        let lastPageIndex = Int(ceil(Double(total) / Double(self.resultsPerPage)) - 1)
        for index in 1...lastPageIndex {
            self.pagesList.append(index)
        }
    }

    // Executes the HTTP GET to retrieve a page of results
    private func getPopularRepositories() {
        var pageIndex = 0
        if self.pagesList.count > 0 {
            pageIndex = self.pagesList.removeFirst()
            if self.pagesList.count == 0 {
                self.pagesList.append(pageIndex)
            }
        }
        Alamofire.request(self.getUrl(pageIndex: pageIndex), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON {response in
                switch response.result {
                case .success:
                    if let result = response.result.value {
                        if let total = self.parseResult(result: result, pageIndex: pageIndex) {
                            self.pagesListInit(total: total)
                        }
                    } else {
                        print("Malformed response")
                    }
                case .failure:
                    self.pagesList.insert(pageIndex, at: 0)
                    print("Request Error")
                }
        }
    }

    // Parses repositories details and updates the delegate with the new data
    private func parseResult(result: Any, pageIndex: Int) -> Int? {
        var total:Int? = pageIndex == 0 ? JSON(result)["total_count"].int : nil
        if total != nil && total! > self.maxResults {
            total = self.maxResults
        }

        let jsonRepositories = JSON(result)["items"].array
        guard jsonRepositories != nil else {
            print("Unexpected JSON format")
            return nil
        }

        let repositories = jsonRepositories!.enumerated().map({ (index, json) -> RepositoryModel? in
            return RepositoryModel.parse(json: json)
        })

        self.delegate?.dataUpdated(data: repositories, startIndex: pageIndex * self.resultsPerPage, count: repositories.count, total: total)

        return total
    }
}
