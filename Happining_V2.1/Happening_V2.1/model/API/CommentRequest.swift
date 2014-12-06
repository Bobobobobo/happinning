//
//  CommentRequest.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 12/5/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import Foundation

class CommentRequest: BaseRequest {
    var pinID:String = ""
    
    override func urlRequest() -> NSURLRequest? {
        var params = NSDictionary(objectsAndKeys:
            self.pinID, PARAM_PIN_ID,
            self.page, PARAM_PAGE
        )
        
        println("Param \(params)")
        
        return API.requestWith(BASE_URL, path:API_GET_COMMENTS, parameters: params)
    }
    
    override func responseClass() -> AnyClass {
        return CommentResponse.self
    }
}

class CommentResponse: BaseResponse {
    var comments:[Comment] = []
    var commentsNum:Int?
    
    override func createModelsWithJSON(JSON: AnyObject) {
        println("CommentResponse JSON \(JSON)")
        
        var commentfromResult:NSArray? = JSON["comments"] as? NSArray
        //println(pinfromResult)
        var commentList: [Comment] = [];
        
        if commentfromResult != nil {
            for commentDict in commentfromResult! {
                //println(_stdlib_getTypeName(pinDict))
                var comment:Comment?
                if commentDict is NSDictionary {
                    comment = Comment(commentDic: commentDict as? NSDictionary)
                    commentList.append(comment!)
                }
            }
        }
        
        self.commentsNum = JSON["commentsNum"] as? Int
        self.comments = commentList
    }
}