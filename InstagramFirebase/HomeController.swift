//
//  HomeController.swift
//  InstagramFirebase
//
//  Created by 11ien on 8/3/17.
//  Copyright © 2017 11ien. All rights reserved.
//

import UIKit
import Firebase


class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate{
    
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        
        collectionView?.backgroundColor = .white
        
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        setupNavigationItems()
        
        fetchAllPosts()
        
    }
    
    @objc func handleUpdateFeed(){
        handleRefresh()
    }
    
    @objc func handleRefresh(){
        
        posts.removeAll()
        fetchAllPosts()
    }
    
    fileprivate func fetchAllPosts(){
        fetchPosts()
        fetchFollowingUserIds()
        
    }
    
    fileprivate func fetchFollowingUserIds(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        FIRDatabase.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userIdsDictionary = snapshot.value as? [String: Any] else {return}
            
            userIdsDictionary.forEach({ (key,value) in
                FIRDatabase.fetchUserWithUID(uid: key, completion: { (user) in
                    self.fetchPostWithUser(user: user)
                })
            })
            
        }) { (err) in
            print("Failed to fetch following users: ",err)
        }
    
    }
    
    //iOS 9 
    //let refreshCOntrol = UIRefreshCOntrol()
    
    var posts = [Post]()
    
    fileprivate func fetchPosts(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        
        FIRDatabase.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostWithUser(user: user)
        }
        
    }
    
    fileprivate func fetchPostWithUser(user: User){
        
        let ref = FIRDatabase.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.collectionView?.refreshControl?.endRefreshing()
            
            guard let dictionaries =  snapshot.value as? [String: Any] else {return}
            
            dictionaries.forEach({ (key,value) in
              
                guard let dictionary = value as? [String: Any] else {return}
                
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                
                guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
                FIRDatabase.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let value = snapshot.value as? Int, value == 1 {
                        post.hasLike = true
                    }else {
                        post.hasLike = false
                    }
                    
                    self.posts.append(post)
                    self.posts.sort(by: { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    })
                    
                        self.collectionView?.reloadData()
                    
                }, withCancel: { (err) in
                    print("Failed to fetch like info for post", err)
                })
                
                
            })
            
        }) { (err) in
            print("failed to fetch posts", err)
        }
    }

    func setupNavigationItems(){
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "logo2"))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }
    
    @objc func handleCamera(){
      //  print("Showing camera")
        
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8  //username userprofileimageview
        height += view.frame.width
        height += 50
        height += 60
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        cell.post = posts[indexPath.item]
        
        cell.delegate = self
        
        return cell
    }
    
    func didTapComment(post: Post) {
    //    print("message coming from h controller")
    //    print(post.caption)
        
        let commentsController = CommentsController(collectionViewLayout: UICollectionViewFlowLayout())
        commentsController.post = post
        navigationController?.pushViewController(commentsController, animated: true)
        
    }
    
    func didLike(for cell: HomePostCell) {
    //    print("Handling like inside")
        
        guard let indexPath = collectionView?.indexPath(for: cell) else {return}
        var post = self.posts[indexPath.item]
    //    print(post.caption)
        
        guard let postId = post.id else {return}
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        
        let values = [uid: post.hasLike == true ? 0 : 1]
        
        FIRDatabase.database().reference().child("likes").child(postId).updateChildValues(values) { (err, _) in
            
            if let err = err {
                print("Failed to like post",err)
                return
            }
            
          //  print("Sucessfully liked post")
            
            post.hasLike = !post.hasLike
            
            self.posts[indexPath.item] = post
            
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
    
   
}
