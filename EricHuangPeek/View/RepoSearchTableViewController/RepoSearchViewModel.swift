//
//RepoSearchViewModel
//EricHuangPeek
//
//Created by Huang, Eric on 2/20/22
//Copyright © 2022 Merrill Corporation. All rights reserved.


import Foundation
import RxSwift

protocol RepoSearchVM {
    // Inputs
    var tableViewDidScrollToBottom: PublishSubject<Bool> { get }
    
    // Outputs
    var repos: Observable<[Repo]> { get }
    var didGetCursor: Observable<PageInfo> { get }
}

class RepoSearchViewModel: RepoSearchVM {
    
    // Inputs
    var tableViewDidScrollToBottom = PublishSubject<Bool>.init()
    
    // Outputs
    var repos: Observable<[Repo]>
    var didGetCursor: Observable<PageInfo>
    
    init(repoService: GithubService) {
        
        // Behavior subject to keep track of the latest cursor
        // The initial value is nil
        let latestCursor = BehaviorSubject<PageInfo>.init(value: PageInfo.init(endCursor: nil))
        
        typealias RepoServiceArgs = (String, String?, Int)
        
        // Merges the signals for initial load and events for tableViewDidScrollToBottom
        let networkCall = Observable.merge([
                Observable.just(()),
                tableViewDidScrollToBottom
                    .filter { $0 == true } // Ignore events until true
                    .debounce(RxTimeInterval.seconds(2), scheduler: MainScheduler.asyncInstance) // Debounce this event due to avoiding spamming the server. Looks like this fire many events
                    .map { _ in () }
            ])
            .observe(on: MainScheduler.asyncInstance)
            .withLatestFrom(latestCursor) // grabs the latest cursor for pagination
            .flatMap { latestCursor in
                return repoService.getRepo(query: "graphQL", afterCursor: latestCursor.endCursor, first: 20)
            }
            .share() // shares the signal for the view model
        
        //
        repos = Observable.just(())
            .flatMapLatest {
                return networkCall.map { $0.edges.map { $0.node }}
            }
            .scan([], accumulator: { acc, ele in acc + ele }) // accumulates all the [Repo] for all subsequent network calls
            
        didGetCursor = networkCall.map { $0.pageInfo }
            .do(onNext: { latestCursor.onNext($0) } ) // push the latest cursor on the the behaviorsubject
    }
}
