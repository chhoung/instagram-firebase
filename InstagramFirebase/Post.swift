//
//  Post.swift
//  InstagramFirebase
//
//  Created by 11ien on 8/2/17.
//  Copyright © 2017 11ien. All rights reserved.
//

import Foundation

struct Post{
    
    var id: String?
    
    let imageUrl: String
    let user: User
    let caption: String
    let creationDate: Date

    var hasLike = false
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        
        //it's creationDate but i somehow named it createData in Firebase DB
        
        let secondsFrom1970 = dictionary["creationData"] as? Double ?? 0
        self.creationDate = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
