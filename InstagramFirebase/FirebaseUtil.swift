//
//  FirebaseUtil.swift
//  InstagramFirebase
//
//  Created by 11ien on 8/6/17.
//  Copyright © 2017 11ien. All rights reserved.
//

import Foundation
import Firebase

extension FIRDatabase {
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> () ){
        print("Fetching user", uid)
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else {return}
            
            let user = User(uid: uid, dictionary: userDictionary)
            
            print(user.username)
            // self.fetchPostWithUser(user: user)
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user for posts: ", err)
        }
        
    }
    
}
