//
//  CommentsController.swift
//  InstagramFirebase
//
//  Created by 11ien on 8/19/17.
//  Copyright © 2017 11ien. All rights reserved.
//

import UIKit
import Firebase

class CommentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var post: Post?
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Comments"
        
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .interactive
        
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        
        fetchComments()
        
    }
    var comments = [Comment]()
    fileprivate func fetchComments(){
        guard let postId = self.post?.id else {return}
        let ref = FIRDatabase.database().reference().child("comments").child(postId)
        ref.observe(.childAdded, with: { (snapshot) in
            

            guard let dictionary = snapshot.value as? [String: Any] else {return}
            
            guard let uid = dictionary["uid"] as? String else {return}
            
            FIRDatabase.fetchUserWithUID(uid: uid, completion: { (user) in
               
                let comment = Comment(user: user, dictionary: dictionary)
           
                self.comments.append(comment)
                self.comments.sort(by: { (c1, c2) -> Bool in
                    return c1.creationDate.compare(c2.creationDate) == .orderedAscending
                })
                
                self.collectionView?.reloadData()
            })
            
            
            
        }) { (err) in
            print("Failed to observe comments")
        }
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        
        cell.comment = self.comments[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummycell = CommentCell(frame: frame)
        dummycell.comment = comments[indexPath.item]
        dummycell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummycell.systemLayoutSizeFitting(targetSize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    lazy var contianerView: UIView = {
        let contianerView = UIView()
        contianerView.backgroundColor = .white
        contianerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        contianerView.addSubview(submitButton)
        submitButton.anchor(top: contianerView.topAnchor, left: nil, bottom: contianerView.bottomAnchor, right: contianerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        
       
        contianerView.addSubview(self.commentTextField)
        self.commentTextField.anchor(top: contianerView.topAnchor, left: contianerView.leftAnchor, bottom: contianerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let lineSeparatorView = UIView()
        lineSeparatorView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        contianerView.addSubview(lineSeparatorView)
        lineSeparatorView.anchor(top: contianerView.topAnchor, left: contianerView.leftAnchor, bottom: nil, right: contianerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return contianerView
    
    }()
    
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Comment"
        return textField
    }()
    
    @objc func handleSubmit(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        
        print("post id", self.post?.id ?? "")
        
        print("Handling submit..", commentTextField.text ?? "")
        
        let postId = self.post?.id ?? ""
        let values = ["text": commentTextField.text ?? "", "creationDate": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
        
        FIRDatabase.database().reference().child("comments").child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            
            if let err = err {
                print("Failed to insert comment:", err)
            }
            
            print("Sucessfully inserted comment.")
            self.commentTextField.text = ""
        }
        
    }
    
    override var inputAccessoryView: UIView?{
        get{
            
            return contianerView
     
        }
    }

    override var canBecomeFirstResponder: Bool{
        return true
    }
}
