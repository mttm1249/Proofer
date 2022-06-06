//
//  CardCell.swift
//  Proofer
//
//  Created by Денис on 29.05.2022.
//

import UIKit

class CardCell: UICollectionViewCell {
    
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setup(_ data: Card) {
        nameLabel.text = data.name
        locationLabel.text = data.locationInfo
        dateLabel.text = data.dateInfo
        cardImage.image = UIImage(data: data.image!)
    }
}
