//
//SearchResultItemConnection
//EricHuangPeek
//
//Created by Huang, Eric on 2/20/22
//Copyright © 2022 Merrill Corporation. All rights reserved.


import Foundation

struct RepoNode: Codable {
    let node: Repo
}

struct PageInfo: Codable {
    let endCursor: String?
}

struct SearchResultItemConnection: Codable {
    let pageInfo: PageInfo
    let edges: [RepoNode]
}


