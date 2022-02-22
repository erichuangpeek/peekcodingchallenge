//
//RepoSearchTableViewCell
//EricHuangPeek
//
//Created by Huang, Eric on 2/21/22
//Copyright © 2022 Merrill Corporation. All rights reserved.


import Foundation
import UIKit

class RepoSearchTableViewCell: UITableViewCell {
    
    struct ViewState {
        let ownerAvatarURL: URL
        let stargazerCount: Int
        let ownerName: String
        let repoName: String
    }
    
    private lazy var ownerAvatarImageView: UIImageView = {
        let imgView = UIImageView.init()
        return imgView
    }()
    
    private lazy var stargazerCount: UILabel = {
        let label = UILabel.init()
        return label
    }()
    
    private lazy var ownerNameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var repoNameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        var sv = UIStackView.init(arrangedSubviews: [ownerAvatarImageView, repoNameLabel, ownerNameLabel, stargazerCount])
        sv.axis = .vertical
        sv.distribution = .equalSpacing
        return sv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func setupViews() {
        
        mainStackView.frame = .zero
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])
        
        
    }
    
    func configure(with item: ViewState) {
        let url = item.ownerAvatarURL
        let data = try? Data(contentsOf: url)
        
        if let imageData = data {
            ownerAvatarImageView.image = UIImage(data: imageData)
        }
        
        repoNameLabel.text = "Repo Name: \(item.repoName)"
        ownerNameLabel.text = "Owner: \(item.ownerName)"
        stargazerCount.text = "Stars: \(String(item.stargazerCount))"
    }
}
