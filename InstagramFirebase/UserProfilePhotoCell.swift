//
//  UserProfilePhotoCell.swift
//  InstagramFirebase
//
//  Created by 11ien on 8/2/17.
//  Copyright © 2017 11ien. All rights reserved.
//

import UIKit

class UserProfilePhotoCell: UICollectionViewCell{

    var post: Post? {
        didSet{
            guard let imageUrl = post?.imageUrl else {return}
            
            photoImageView.loadImage(urlString: imageUrl)
        }
    
    }
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleToFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
