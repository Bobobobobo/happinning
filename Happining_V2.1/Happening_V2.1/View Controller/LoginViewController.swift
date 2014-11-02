//
//  LoginViewController.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/2/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

protocol LoginViewDelegate : NSObjectProtocol {
    func loginViewDidFinishWithEmail(email:String, Password password:NSString, Username username:String)
}

class LoginViewController: BaseViewController, LoginCollectionViewCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {

    var delegate: LoginViewDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pagingView: UIView!

    var pageControl:StyledPageControl!
    var textHolder = ["Email", "Password", "Username"]
    
    var email:String = ""
    var password:String = ""
    var username:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var pageControl:StyledPageControl = StyledPageControl(frame: self.pagingView.bounds)
        pageControl.pageControlStyle = PageControlStyleStrokedCircle
        pageControl.numberOfPages = 3
        pageControl.coreSelectedColor = UIColor.whiteColor()
        pageControl.strokeNormalColor = UIColor.whiteColor()
        pageControl.strokeSelectedColor = UIColor.whiteColor()
        pageControl.diameter = 10;
        self.pageControl = pageControl
        self.pagingView.addSubview(pageControl)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextPage(sender: AnyObject) {
        self.collectionView.scrollEnabled = true
        var page:Int = Int(self.pageControl.currentPage)
        
        if (page < 2) {
            var width = CGRectGetWidth(self.collectionView.frame)
            var indexPath = NSIndexPath(forItem: page+1, inSection: 0)
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
            self.pageControl.currentPage = page+1
            
            if (page == 1) {
                self.nextButton.setTitle("Done", forState: .Normal)
                self.nextLabel.text = "Done"
            }
        } else {
            // finish login
            // TODO: Go to next page
            self.dismissViewControllerAnimated(true, completion: nil)
            
            if self.delegate != nil {
                var delegate = self.delegate!
                if delegate.respondsToSelector(Selector("loginViewDidFinishWithEmail:Password:Username:")) {
                    delegate.loginViewDidFinishWithEmail(self.email, Password: self.password, Username: self.username)
                }
            }
        }
        self.collectionView.scrollEnabled = false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:LoginCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as LoginCollectionViewCell
        cell.delegate = self
        cell.textField.placeholder = self.textHolder[indexPath.item]
        if(indexPath.item == 2) {
            // Done
            cell.textField.returnKeyType = .Done
        } else {
            cell.textField.returnKeyType = .Next
        }
        return cell
    }
    
    
    // Login cell
    
    func loginCellDidResignTextField(cell: LoginCollectionViewCell) {
        var indexPath = self.collectionView.indexPathForCell(cell)!
        var text = cell.textField.text
        
        switch (indexPath.item) {
            case 0:
                self.email = text
                break
            
            case 1:
                self.password = text
                break
            
            case 2:
                self.username = text
                break
            
            default:
                break
        }
        
        self.nextPage(cell)
    }
}
