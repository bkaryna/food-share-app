//
//  OtherCollectionViewCell.swift
//  food-share
//
//  Created by Karen on 13/01/2022.
//

import UIKit
import FirebaseStorage

class OtherCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var validUntilLabel: UILabel!
    
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
        validUntilLabel.text = item.getValidUntilDate()
        Styling.makeImageCornersRound(self.imageView)
    }
}
