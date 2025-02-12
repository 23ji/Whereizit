//
//  ListTableViewCell.swift
//  SmokingAreaOdi
//
//  Created by 이상지 on 2/12/25.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    @IBOutlet weak var SmokinAreaImage: UIImageView!
    @IBOutlet weak var SmokingAreaName: UILabel!
    @IBOutlet weak var SmokingAreaDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
