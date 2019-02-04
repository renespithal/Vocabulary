//
//  Cell2.swift
//  Vocabulary
//
//  Created by Margaretha Lucha on 25.07.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//



import UIKit


class Cell2: UITableViewCell {
    
    var customTextLabel : UILabel!
    var customDetailedTextLabel: UILabel!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.customTextLabel = UILabel()
        self.customDetailedTextLabel = UILabel()
        self.contentView.addSubview(customTextLabel)
        self.contentView.addSubview(customDetailedTextLabel)
        configureView()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configureView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func configureView() {
        self.customTextLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        self.customDetailedTextLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        self.customDetailedTextLabel.textColor = UIColor.lightGray
        self.accessoryType = .none
    }
    
    struct Style {
        let backgroundColor: UIColor
        let textLabelLabelColor: UIColor
        let detailTextLabelColor: UIColor
        let cellTintColor: UIColor
        
        static let light = Style(
            backgroundColor: tableViewBackgroundColor,
            textLabelLabelColor: tableViewCellTextLabelColor,
            detailTextLabelColor: tableViewCellDescriptionLabelColor,
            cellTintColor: tableViewCellTintColor
        )
        
        static let dark = Style(
            backgroundColor: tableViewBackgroundColorDark,
            textLabelLabelColor: tableViewCellTextLabelColorDark,
            detailTextLabelColor: tableViewCellDescriptionLabelColorDark,
            cellTintColor: tableViewCellTintColorDark
        )
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func apply(style: Style) {
        backgroundColor = style.backgroundColor
        self.customTextLabel.textColor = style.textLabelLabelColor
        self.customDetailedTextLabel.textColor = style.detailTextLabelColor
        tintColor = style.cellTintColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
      
        self.customTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.customTextLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        self.customTextLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.customTextLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        self.customTextLabel.bottomAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 35).isActive = true
        
        self.customDetailedTextLabel.translatesAutoresizingMaskIntoConstraints = false
        self.customDetailedTextLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 23).isActive = true
        self.customDetailedTextLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        self.customDetailedTextLabel.topAnchor.constraint(equalTo: self.customTextLabel.bottomAnchor).isActive = true
        self.customDetailedTextLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
     
    }
    
    
   }
