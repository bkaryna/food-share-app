//
//  MyCollectionViewCell.swift
//  food-share
//
//  Created by Karyna Babenko on 09/12/2021.
//

import UIKit
import FirebaseStorage

class MyCollectionViewCell: UICollectionViewCell {    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var validFromLabel: UILabel!
    @IBOutlet weak var validUntilLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    public func setup(with item: UserItem) {
        let storage = Storage.storage().reference()
        
        DispatchQueue.global().async {
            let ref = storage.child("\(item.getOwner())/images/items/\(item.getID()).png")
            
            ref.downloadURL { url, error in
                if (error != nil) {
                    try? self.imageView.image = UIImage(systemName: "photo.fill")
                    print("image fetching - error")
                } else {
                    try? self.imageView.image = UIImage(data: Data(contentsOf:url!))
                }
            }
        }

        nameLabel.text = item.getname()
        validFromLabel.text = "Valid from: " + item.getValidFromDate()
        validUntilLabel.text = "Valid until: " + item.getValidUntilDate()
        
        if (item.getPrice() == "0.0" || item.getPrice() == "0"){
            priceLabel.text = "Free"
        } else {
            priceLabel.text = "Price: " + String(item.getPrice()) + " zl"
        }
        
        Styling.makeImageCornersRound(self.imageView)
    }
}
