//
//  Pin.swift
//  Happining_V2
//
//  Created by Kan Boonprakub on 7/11/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

class Pin {
    
    var pinId: String
    var title: String
    var owner: String
    var content: String
    var timestamp: String
    var pinLat: Double
    var pinLong: Double
    var imgGalleryURL: String
    var videoGalleryURL: String
    
    init(pinId: String, title: String, owner: String, content: String, timestamp: String, pinLat: Double, pinLong: Double, imgGalleryURL: String, videoGalleryURL: String) {
        
        self.pinId = pinId
        self.title = title
        self.owner = owner
        self.content = content
        self.timestamp = timestamp
        self.pinLat = pinLat
        self.pinLong = pinLong
        self.imgGalleryURL = imgGalleryURL
        self.videoGalleryURL = videoGalleryURL

    }
   
}
