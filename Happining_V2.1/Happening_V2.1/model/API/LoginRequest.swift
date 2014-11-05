//
//  LoginRequest.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/5/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

extension String  {
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.destroy()
        
        return String(format: hash)
    }
}

class LoginRequest: BaseRequest {
    var userName:String = ""
    var password:String = ""
    var email:String = ""
    
    override func urlRequest() -> NSURLRequest? {
        var params = NSDictionary(objectsAndKeys:
            self.email, PARAM_EMAIL,
            self.md5(self.password), PARAM_PASSWORD,
            self.userName, PARAM_USERNAME
        )
            
        return API.requestPostWith(BASE_URL, path: API_LOGIN, parameters: params)
    }
    
    func md5(text:String) -> String {
        return text.md5
    }
    
    override func responseClass() -> AnyClass {
        return LoginResponse.self
    }
}

class LoginResponse: BaseResponse {
    var user:User?
    
    override func createModelsWithJSON(JSON: AnyObject) {
        println("LoginResponse JSON \(JSON)")
        
        if JSON["status"] as Int == 200 {
            self.user = User.currentUser
            self.user?.storeUser(JSON as NSDictionary)
            
            var userDefault = NSUserDefaults.standardUserDefaults()
            userDefault.setObject(JSON, forKey: kUserLoggedKey)
            userDefault.synchronize()
        }
    }
}
