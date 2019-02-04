//
//  WordCell.swift
//  Vocabulary
//
//  Created by Alex on 30.06.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import TinyConstraints
import SwipeCellKit

class WordCell: SwipeTableViewCell {
    var headerView = UIView()
    var nameLabel = UILabel()
    var translationLabel = UILabel()

    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        viewSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        viewSetup()
    }
    
    @objc public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func viewSetup() {
        self.accessoryType = .none
        self.selectionStyle = .none
        
        self.contentView.addSubview(headerView)
        headerView.backgroundColor = .clear
        headerView.origin(to: self.contentView)
        headerView.height(CGFloat.init(integerLiteral: 60))
        headerView.width(to: self.contentView)
        
        headerView.addSubview(nameLabel)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.numberOfLines = 2
        nameLabel.textColor = .black
        nameLabel.centerY(to: headerView)
        nameLabel.left(to: headerView, nil, offset: 10, relation: .equal, priority: .required, isActive: true)
        nameLabel.height(50)
        nameLabel.width(to: self.headerView, nil, multiplier: 0.5, offset: -15, relation: .equal, priority: .required, isActive: true)
        
        headerView.addSubview(translationLabel)
        translationLabel.font = UIFont.boldSystemFont(ofSize: 17)
        translationLabel.numberOfLines = 2
        translationLabel.lineBreakMode = .byWordWrapping
        translationLabel.textColor = .lightGray
        translationLabel.textAlignment = .right
        translationLabel.centerY(to: self.headerView)
        translationLabel.height(50)
        translationLabel.right(to: self.headerView, nil, offset: -10, relation: .equal, priority: .required, isActive: true)
        translationLabel.width(to: self.headerView, nil, multiplier: 0.5, offset: -15, relation: .equal, priority: .required, isActive: true)
        
    }
}
