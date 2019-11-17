//
//  TableViewCellRepository.swift
//  GitHub Repositories
//
//  Copyright © 2019 Eduardo Camaratta. All rights reserved.
//

import UIKit

class TableViewCellRepository: UITableViewCell {

    @IBOutlet weak var labelOrder: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var delegate:TableViewCellRepositoryDelegate?
    var data:RepositoryModel?
    var index:Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped(sender:)))
        self.addGestureRecognizer(tap)
    }

    func initiate(data: RepositoryModel?, index: Int, delegate: TableViewCellRepositoryDelegate) {
        self.data = data
        self.index = index

        self.labelOrder.text = String(index + 1)
        if let data = data {
            self.labelName.text = data.name
            self.labelName.isHidden = false
            self.activityIndicator.stopAnimating()
        } else {
            self.labelName.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        self.delegate = delegate
    }

    @objc func cellTapped(sender:UITapGestureRecognizer) {
        delegate?.cellTapped(cell: self)
    }
}

protocol TableViewCellRepositoryDelegate {
    func cellTapped(cell:TableViewCellRepository)
}
