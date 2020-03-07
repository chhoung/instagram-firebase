//
//  User.swift
//  InstagramFirebase
//
//  Created by 11ien on 8/5/17.
//  Copyright © 2017 11ien. All rights reserved.
//

import Foundation

struct User{
    
    let uid: String
    let username: String
    let profileImageUrl: String
    
    init(uid: String, dictionary: [String: Any]){
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.uid = uid
    }
}
