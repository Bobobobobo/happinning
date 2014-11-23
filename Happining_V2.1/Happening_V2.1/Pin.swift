//
//  Pin.swift
//  Happining_V2
//
//  Created by Kan Boonprakub on 7/11/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import Foundation

class Pin {
    
    var pinId: String!
    var pinType: Int?
    var text: String
    var uploadDate: String
    var thumbURL: String
    var imageURL: String?
    var videoURL: String?
    var ratio: Double
    var userId: String
    var userName: String
    var userImageURL: String
    var isLike: Bool
    var likesNum: Int
    var commentsNum: Int
    var location: Location
    
    init(pinId: String!, pinType: Int, text: String, uploadDate: String, thumbURL: String, imageURL: String, videoURL: String, ratio: Double, userId: String, userName: String, userImageURL: String, isLike: Bool, likesNum: Int, commentsNum: Int, location: Location) {
        self.pinId = pinId
        self.pinType = pinType
        self.text = text
        self.uploadDate = uploadDate
        self.thumbURL = thumbURL
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.ratio = ratio
        self.userId = userId
        self.userName = userName
        self.userImageURL = userImageURL
        self.isLike = isLike;
        self.likesNum = likesNum
        self.commentsNum = commentsNum
        self.location = location
    }
    
    init(pinDict: NSDictionary) {
        if let tempPinId = pinDict["_id"] as? String {
            self.pinId = tempPinId
        }
                
        self.pinType = pinDict["pinType"] as? Int
        self.text = pinDict["text"] as String
        var tempUploadDate: Int = pinDict["uploadDate"] as Int
        self.uploadDate =  "\(tempUploadDate)"
        self.thumbURL = pinDict["thumb"] as String
        self.imageURL = pinDict["image"] as? String
        self.videoURL = pinDict["video"] as? String
        self.ratio = pinDict["ratio"] as Double
        self.userId = pinDict["userId"] as String
        self.userName = pinDict["username"] as String
        self.userImageURL = pinDict["userImage"] as String
        self.isLike = pinDict["isLike"] as Bool
        if let tempLikesNum = pinDict["likesNum"] as? Int {
            self.likesNum = tempLikesNum
        }
        else {
            self.likesNum = 0
        }
        if let tempCommentsNum = pinDict["commentsNum"] as? Int {
            self.commentsNum = tempCommentsNum
        }
        else {
            self.commentsNum = 0
        }
        var tempLocationDict = pinDict["location"] as NSDictionary
        self.location = Location(locationDict: tempLocationDict)
    }
   
}
