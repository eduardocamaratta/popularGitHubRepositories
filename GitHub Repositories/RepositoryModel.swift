//
//  RepositoryModel.swift
//  GitHub Repositories
//
//  Copyright © 2019 Eduardo Camaratta. All rights reserved.
//

import SwiftyJSON

class RepositoryModel {
    let name: String
    let stars: Int
    let description: String?
    let language: String?
    
    init(name: String, stars: Int, description: String?, language: String?) {
        self.name = name
        self.stars = stars
        self.description = description
        self.language = language
    }

    static func parse(json: JSON) -> RepositoryModel? {
        if let name = json["name"].string,
            let stars = json["stargazers_count"].int {
            return RepositoryModel(name: name, stars: stars, description: json["description"].string, language: json["language"].string)
        } else {
            return nil
        }
    }
}
