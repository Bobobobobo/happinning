//
//  KeychainService.swift
//  Happining_V2.1
//
//  Created by Tanthawat Khemavast on 11/10/14.
//  Copyright (c) 2014 Kan Boonprakub. All rights reserved.
//

import UIKit
import Security

// Identifiers
let emailIdentifier = "Email"
let passwordIdentifier = "Password"
let usernameIdentifier = "Username"
let userAccount = "authenticatedUser"
let accessGroup = "MyService"

// Arguments for the keychain queries
let kSecClassValue = kSecClass as NSString
let kSecAttrAccountValue = kSecAttrAccount as NSString
let kSecValueDataValue = kSecValueData as NSString
let kSecClassGenericPasswordValue = kSecClassGenericPassword as NSString
let kSecAttrServiceValue = kSecAttrService as NSString
let kSecMatchLimitValue = kSecMatchLimit as NSString
let kSecReturnDataValue = kSecReturnData as NSString
let kSecMatchLimitOneValue = kSecMatchLimitOne as NSString

public class KeychainService: NSObject {
    
    /**
    * Exposed methods to perform queries.
    * Note: feel free to play around with the arguments
    * for these if you want to be able to customise the
    * service identifier, user accounts, access groups, etc.
    */
    public class func saveEmail(token: NSString) {
        self.save(emailIdentifier, data: token)
    }
    
    public class func loadEmail() -> NSString? {
        var token = self.load(emailIdentifier)
        return token
    }
    
    public class func savePassword(token: NSString) {
        self.save(passwordIdentifier, data: token)
    }
    
    public class func loadPassword() -> NSString? {
        var token = self.load(passwordIdentifier)
        return token
    }
    
    public class func saveUsername(token: NSString) {
        self.save(usernameIdentifier, data: token)
    }
    
    public class func loadUsername() -> NSString? {
        var token = self.load(usernameIdentifier)
        return token
    }
    
    /**
    * Internal methods for querying the keychain.
    */
    private class func save(service: NSString, data: NSString) {
        var dataFromString: NSData = data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        // Instantiate a new default keychain query
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, dataFromString], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
        
        // Delete any existing items
        SecItemDelete(keychainQuery as CFDictionaryRef)
        
        // Add the new keychain item
        var status: OSStatus = SecItemAdd(keychainQuery as CFDictionaryRef, nil)
    }
    
    private class func load(service: NSString) -> NSString? {
        // Instantiate a new default keychain query
        // Tell the query to return a result
        // Limit our results to one item
        var keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, userAccount, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var dataTypeRef :Unmanaged<AnyObject>?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        
        let opaque = dataTypeRef?.toOpaque()
        
        var contentsOfKeychain: NSString?
        
        if let op = opaque? {
            let retrievedData = Unmanaged<NSData>.fromOpaque(op).takeUnretainedValue()
            
            // Convert the data retrieved from the keychain into a string
            contentsOfKeychain = NSString(data: retrievedData, encoding: NSUTF8StringEncoding)
        } else {
            println("Nothing was retrieved from the keychain. Status code \(status)")
        }
        
        return contentsOfKeychain
    }
}