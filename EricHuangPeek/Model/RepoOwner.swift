//
//RepoOwner
//EricHuangPeek
//
//Created by Huang, Eric on 2/19/22
//Copyright © 2022 Merrill Corporation. All rights reserved.


import Foundation

struct RepoOwner: Codable {
    let name: String
    let avatarUrl: URL
    
    enum CodingKeys: String, CodingKey {
        case name = "login"
        case avatarUrl
    }
}
