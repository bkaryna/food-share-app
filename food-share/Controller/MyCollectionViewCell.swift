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
    @IBOutlet weak var validUntilLabel: UILabel!
    
    public func setup(with item: UserItem) {
        let storage = Storage.storage().reference()
        
        DispatchQueue.global().async {
            let ref = storage.child("\(item.getOwner())/images/items/\(item.getID()).png")
            
            ref.downloadURL { url, error in
                if (error != nil) {
                    try? self.imageView.image = UIImage(data: Data(contentsOf: URL(string: "https://www.wfp.org/sites/default/files/styles/impact_image/public/2017-01/SOM_20150614_WFP-Laila_Ali_5556.jpg?itok=Ef1CTnPL")!))
                    
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
