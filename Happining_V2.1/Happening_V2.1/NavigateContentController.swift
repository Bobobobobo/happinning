//
//  NavigateContentController.swift
//  Happining_V2.1
//
//  Created by Kan Boonprakub on 8/12/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

protocol NavigateContentProtocol {
    func getPageIndex() -> Int
}

class NavigateContentController: NSObject {
    
    var delegate: NavigateContentProtocol?
    
    init(delegate: NavigateContentProtocol?) {
        self.delegate = delegate
    }
    
    func getIndex() {
        self.delegate?.getPageIndex()
    }
    
}
