//
//  RepositoryDetailsViewController.swift
//  GitHub Repositories
//
//  Copyright © 2019 Eduardo Camaratta. All rights reserved.
//

import UIKit

class RepositoryDetailsViewController: UIViewController {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var labelStars: UILabel!
    @IBOutlet weak var labelLanguage: UILabel!
    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var data:RepositoryModel?
    private var index:Int = 0

    func initiate(data: RepositoryModel?, index: Int) {
        self.data = data
        self.index = index
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateLabels()
    }

    private func updateLabels() {
        if let data = self.data {
            self.viewLoading.isHidden = true
            self.labelName.text = data.name
            self.labelDescription.text = data.description ?? "No Description"
            self.labelStars.text = String(data.stars)
            self.labelLanguage.text = data.language ?? "Not Informed"
        } else {
            self.viewLoading.isHidden = false
        }
    }

    func dataUpdated(data: RepositoryModel?) {
        self.activityIndicator.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (_) in
            self.activityIndicator.isHidden = true
        }
        self.data = data
        self.updateLabels()
    }

    func getIndex() -> Int {
        return self.index
    }
}
