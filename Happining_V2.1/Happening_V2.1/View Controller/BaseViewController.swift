//
//  BaseViewController.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/2/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var titleView = UIView(frame: CGRectMake(0, 0, 120, 30))
        self.navigationItem.titleView = titleView
        
        var iconView = UIImageView(frame: CGRectMake(0, 7, 16, 16))
        iconView.contentMode = UIViewContentMode.ScaleAspectFit
        iconView.image = UIImage(named: "icon_happining_actionbar")
        titleView.addSubview(iconView)
        
        var titleLabel = UILabel(frame: CGRectMake(20, 0, 100, 30))
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(16)
        titleLabel.text = "Happinning"
        titleView.addSubview(titleLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
