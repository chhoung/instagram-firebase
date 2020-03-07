//
//  LikeController.swift
//  InstagramFirebase
//
//  Created by 11ien on 8/31/17.
//  Copyright © 2017 11ien. All rights reserved.
//

import UIKit

class LikeController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
   
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.register(LikeCell.self, forCellWithReuseIdentifier: cellId)
        navigationItem.title = "Notification"
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! LikeCell
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
}
