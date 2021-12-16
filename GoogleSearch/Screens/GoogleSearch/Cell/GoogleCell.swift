//
//  GoogleCell.swift
//  GoogleSearch
//
//  Created by Александр Басов on 12/16/21.
//

import UIKit

class GoogleCell: UITableViewCell {

    // - UI
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    // - Register Cell
    static let reuseID = "GoogleCell"
    static func nib() -> UINib {
        return UINib(nibName: "GoogleCell",
                     bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(item: Item) {
        titleLbl.text = item.title
        descriptionLbl.text = item.snippet
    }
    
}
