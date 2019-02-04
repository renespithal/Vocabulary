//
//  Cell.swift
//  Vocabulary
//
//  Created by Alex on 02/06/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

import UIKit
import SwipeCellKit

class Cell: SwipeTableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
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
        self.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        self.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        self.detailTextLabel?.textColor = UIColor.lightGray
        self.accessoryType = .disclosureIndicator
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
        textLabel?.textColor = style.textLabelLabelColor
        detailTextLabel?.textColor = style.detailTextLabelColor
        tintColor = style.cellTintColor
    }

}
