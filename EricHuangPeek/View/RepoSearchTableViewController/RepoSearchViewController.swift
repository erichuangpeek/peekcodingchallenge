//
//RepoSearchTableViewController
//EricHuangPeek
//
//Created by Huang, Eric on 2/18/22
//Copyright © 2022 Merrill Corporation. All rights reserved.


import Foundation
import UIKit
import RxCocoa
import RxSwift

class RepoSearchViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    // Views
    lazy var tv: UITableView = {
       let tv = UITableView()
       tv.register(RepoSearchTableViewCell.self, forCellReuseIdentifier: "cell")
       return tv
    }()
    
    lazy var mainStackView: UIStackView = {
        var sv = UIStackView.init(arrangedSubviews: [tv])
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        return sv
    }()
    
    var viewModel: RepoSearchViewModel!
    
    init(viewModel: RepoSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainStackView.frame = .zero
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            mainStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 32),
            mainStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -32),
            mainStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -32),
        ])
        
        bindings() 
    }
    
    // Helper function to set up the bindings for inputs and outputs
    func bindings() {
        
        // View Model Inputs
        
        tv.rx.didScroll
            .asObservable()
            .map { [unowned self]  in
                // Determine when the tableview hit the bottom
                let height = self.tv.frame.size.height
                let contentYoffset = self.tv.contentOffset.y
                let distanceFromBottom = self.tv.contentSize.height - contentYoffset
                return distanceFromBottom < height
            }
            // Feeds this back into the view model
            .bind(to: viewModel.tableViewDidScrollToBottom)
            .disposed(by: disposeBag)
        
        // View Model Outputs
        
        // Get the signal of repos from the viewmodel and configure the ui
        let reposFromVM = viewModel.repos.share()

        reposFromVM
            .observe(on: MainScheduler.instance)
            .catch { error in return Observable.just([]) }
            .bind(to: tv.rx.items(cellIdentifier: "cell", cellType: RepoSearchTableViewCell.self)) { row, element, cell in

                cell.configure(with: .init(ownerAvatarURL: element.owner.avatarUrl, stargazerCount: element.stargazerCount, ownerName: element.owner.name, repoName: element.name))
            }
            .disposed(by: disposeBag)
        
        reposFromVM
            .observe(on: MainScheduler.instance)
            .subscribe(
                onError: { error in
                    let alert = UIAlertController(title: "Alert", message: "Error Happened from the Network", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                }
            ).disposed(by: disposeBag)
        
        viewModel.didGetCursor
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}
