//
//Repo
//EricHuangPeek
//
//Created by Huang, Eric on 2/19/22
//Copyright © 2022 Merrill Corporation. All rights reserved.


import Foundation

struct Repo: Codable {
    let name: String
    let stargazerCount: Int
    let owner: RepoOwner
}
