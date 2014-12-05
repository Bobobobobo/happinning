//
//  Comment.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 12/5/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import Foundation

class Comment {
    var commentID:String?
    var text:String?
    var userID:String?
    var userImage:String?
    var userName:String?
    var date:NSDate?

    var height:CGFloat = 0
    
    init() {
        
    }
    
    init(commentDic: NSDictionary?) {
        if commentDic != nil {
            var dict = commentDic!
            
            self.commentID = dict["_id"] as? String
            self.text = dict["comment"] as? String
            self.userID = dict["userId"] as? String
            self.userImage = dict["userImage"] as? String
            self.userName = dict["username"] as? String
            
            var commentDate: Double = dict["commentDate"] as Double
            self.date = NSDate(timeIntervalSince1970: NSTimeInterval(commentDate*0.001))

        }
        
    }
}