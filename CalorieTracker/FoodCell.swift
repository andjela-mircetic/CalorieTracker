//
//  FoodCell.swift
//  CalorieTracker
//
//  Created by Andjela Mircetic on 21.5.24..
//

import UIKit

class FoodCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var caloriesLabel: UILabel!
    
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
  
    }

    func configure(with food: Food) {
        foodImage.image = UIImage(named: "p2")
        foodImage.clipsToBounds = true
        foodImage.contentMode = .scaleAspectFill
        foodImage.layer.cornerRadius = 10
        nameLabel.text = food.name
        caloriesLabel.text = "\(food.calories) kcal"
        contentView.backgroundColor = .systemGray
        unitLabel.text = food.unit
        
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
       // contentView.layer.borderWidth = 1.0
       // contentView.layer.borderColor = UIColor.lightGray.cgColor
    }
}

