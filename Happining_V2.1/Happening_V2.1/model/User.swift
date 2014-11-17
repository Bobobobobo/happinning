//
//  User.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/5/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

let kUserLoggedKey:String = "kUserLoggedKey"

class User: NSObject {
    class var currentUser : User {
        var userDefault = NSUserDefaults.standardUserDefaults()
        struct Singleton {
            static let instance:User = User()
        }
        
        if User.isLogin() {
            Singleton.instance.storeUser(userDefault.objectForKey(kUserLoggedKey) as NSDictionary)
        }
        
        return Singleton.instance
    }
    
    var userID:String? = ""
    var userImage:String? = ""
    var userName:String? = ""
    
    private var savedUser:User?
    
    func storeUser(dict: NSDictionary) {
        self.userID = dict["_id"] as? String
        self.userImage = dict["userImage"] as? String
        self.userName = dict["username"] as? String
    }
    
    class func isLogin() -> Bool {
        var userDefault = NSUserDefaults.standardUserDefaults()
        return (userDefault.objectForKey(kUserLoggedKey) != nil)
    }
    
    func logout() {
        var currentUser = User.currentUser
        currentUser.userName = nil
        currentUser.userID = nil
        currentUser.userImage = nil

        var userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.removeObjectForKey(kUserLoggedKey)
        userDefault.synchronize()
    }
    
}
