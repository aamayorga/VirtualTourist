//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Ansuke on 4/6/18.
//  Copyright © 2018 AM. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func initWithPhoto(_ photo: Photo) {
        
        if photo.photo != nil {
            DispatchQueue.main.async {
                
                self.imageView.image = UIImage(data: photo.photo! as Data)
                
            }
        } else {
            print("Isn't Nil \n\n")
        }
    }
    
    
}
