//
//GithubService
//EricHuangPeek
//
//Created by Huang, Eric on 2/19/22
//Copyright © 2022 Merrill Corporation. All rights reserved.


import Foundation
import RxSwift

protocol RepoService {
    func getRepo(query: String, afterCursor: String?, first: Int) -> Single<SearchResultItemConnection>
}

// This class is a layer between the Network architecture and View Model of the apps
// This class should remained unchanged if the Network stuff undergoes some sort of refactor
// We can also test aganist this layer with our View Models
class GithubService: RepoService {
    
    func getRepo(query: String, afterCursor: String?, first: Int) -> Single<SearchResultItemConnection> {
        
        // What is cool about this here is we are putting the result of the network call into the world of observables
        // This makes it easier to manage in a multithread situtation 
        return Single.create { single -> Disposable in
            API.githubApi.makeRepoRequest(query: query, first: first, afterCursor: afterCursor) { (result) in
                    
                switch result {
                case .success(let response as SearchResultItemConnection):
                    single(.success(response))
                case .failure(let error):
                    single(.failure(error))
                default:
                    break
                }
            }
            return Disposables.create {}
        }
    }
}
