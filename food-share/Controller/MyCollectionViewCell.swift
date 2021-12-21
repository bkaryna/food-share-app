//
//  MyCollectionViewCell.swift
//  food-share
//
//  Created by Karyna Babenko on 09/12/2021.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
//    @IBOutlet var imageView: UIImageView!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var validUntilLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var validUntilLabel: UILabel!
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    public func configure(with image: UIImage, with name: String, with validUntil: String) {
//        imageView.image = image
//        nameLabel.text = name
//        validUntilLabel.text = validUntil
//    }
//
//    //register a cell
//    static func nib() -> UINib {
//        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    
    public func setup(with item: UserItem) {
        imageView.image = UIImage(named: "user-avatar")!
        nameLabel.text = item.getname()
        validUntilLabel.text = item.getValidUntilDate()
    }
}
