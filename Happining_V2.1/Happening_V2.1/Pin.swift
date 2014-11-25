//
//  Pin.swift
//  Happining_V2
//
//  Created by Kan Boonprakub on 7/11/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import Foundation

class PinManager {
    var pinList:[String] = []
    
    class var manager : PinManager {
        struct Singleton {
            static let instance:PinManager = PinManager()
        }
        
        var path = NSBundle.mainBundle().pathForResource("post_icon_list", ofType: "plist")
        var list:NSArray = NSArray(contentsOfFile: path!)!
        
        for icon in list {
            Singleton.instance.pinList.append(icon as String)
        }
        
        return Singleton.instance
    }
}

class Pin {
    
    var pinId: String!
    var pinType: String?
    var text: String
    var uploadDate: NSDate
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
    var pinName: String?
    var distance:Float = 0 // in kilometers
    
    init(pinDict: NSDictionary) {
        if let tempPinId = pinDict["_id"] as? String {
            self.pinId = tempPinId
        }
        
        self.pinType = pinDict["pinType"] as? String
        self.text = pinDict["text"] as String
        var tempUploadDate: Double = pinDict["uploadDate"] as Double
        self.uploadDate = NSDate(timeIntervalSince1970: NSTimeInterval(tempUploadDate*0.001))
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

        if self.pinType != nil {
            self.pinName = PinManager.manager.pinList[self.pinType!.toInt()!-1]
            //println("\(self.pinName).png")
        }
    }
   
}
