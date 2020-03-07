//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by 11ien on 7/25/17.
//  Copyright © 2017 11ien. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
   
    let cellId = "cellId"
    
    let homePostCellId = "homePostCellId"
    
    var userId: String?
    
    var isGridView = true
    
    func didChangeToGridView() {
        isGridView = true
        collectionView?.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        setupLogOutButton()
        
        fetchUser()
        
     //   fetchOrderedPosts()
    }
    
    var isFinishedPaging = false
    var posts = [Post]()
    
    fileprivate func paginatePosts(){
        print("Start paging for more posts")
        
        guard let uid = self.user?.uid else {return}
        let ref = FIRDatabase.database().reference().child("posts").child(uid)
        
  //      var query = ref.queryOrderedByKey()
        
        var query = ref.queryOrdered(byChild: "creationData")
        
        if posts.count > 0 {
 //         let value = posts.last?.id
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard var allObjects = snapshot.children.allObjects as? [FIRDataSnapshot] else {return}
            
            allObjects.reverse()
            
            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }
            
            if self.posts.count > 0 && allObjects.count > 0 {
                 allObjects.removeFirst()
            }
           
            
            guard let user = self.user else {return }
            
            allObjects.forEach({ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                var post = Post(user: user, dictionary: dictionary)
                
                post.id = snapshot.key
                
                self.posts.append(post)
            })
            
            self.posts.forEach({ (post) in
                
            })
            
            self.collectionView?.reloadData()
        }) { (err) in
            print("Failed to paginate for posts:", err)
        }
        
    }
    
    fileprivate func fetchOrderedPosts(){
        guard let uid = self.user?.uid else {return}
         let ref = FIRDatabase.database().reference().child("posts").child(uid)
    
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
          
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            
            guard let user = self.user else {return}
            
            let post = Post(user: user, dictionary: dictionary)
        
            self.posts.insert(post, at: 0)
       //     self.posts.append(post)
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to fetch ordered posts: ",err)
        }
    }
    

    
    fileprivate func setupLogOutButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogout))
    }
    
    @objc func handleLogout(){
        
        let alertController = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
           
            do {
            
                try FIRAuth.auth()?.signOut()
                //present login controller 
                
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
                
            }catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
            
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //how to fire off the paginate cell
        if indexPath.item == self.posts.count - 1 && !isFinishedPaging {
            print("Paginating for posts")
            self.paginatePosts()
        }
        
        
        if isGridView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.post = posts[indexPath.item]
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if isGridView{
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        }else{
            var height: CGFloat = 40 + 8 + 8  //username userprofileimageview
            height += view.frame.width
            height += 50                //caption
            height += 60
            
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
        header.user = self.user
        header.delegate = self
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }

    
    var user: User?
    fileprivate func fetchUser(){
        
        let uid = userId ?? FIRAuth.auth()?.currentUser?.uid ?? ""
        
     // guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        
        FIRDatabase.fetchUserWithUID(uid: uid) { (user) in
            
            self.user = user
            
            self.navigationItem.title = self.user?.username
            
            self.collectionView?.reloadData()
            
            self.paginatePosts()
        }
  
    }
}

