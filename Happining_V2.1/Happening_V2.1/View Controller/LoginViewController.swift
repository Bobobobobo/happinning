//
//  LoginViewController.swift
//  Happining_V2.1
//
//  Created by Sopana Thitipariwat on 11/2/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import UIKit

protocol LoginViewDelegate : NSObjectProtocol {
    func loginViewDidFinishWithUser(user:User?)
}

class LoginViewController: BaseViewController, LoginCollectionViewCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {

    var delegate: LoginViewDelegate?
    
    enum LoginStep : Int {
        case email, password, username
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var pagingView: UIView!

    private var pageControl:StyledPageControl!
    private var textHolder = ["Email", "Password", "Username"]
    
    private var email:String = ""
    private var password:String = ""
    private var username:String = ""

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
        pageControl.userInteractionEnabled = false
        self.pageControl = pageControl
        self.pagingView.addSubview(pageControl)
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            self.email = "nim2@email.com"
            self.password = "11111111"
            self.username = "nnnn"
        #endif
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.pageControl.frame = self.pagingView.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Button Action
    
    @IBAction func previousPage(sender: AnyObject) {
        self.collectionView.scrollEnabled = true
        var page:Int = Int(self.pageControl.currentPage)

        var width = CGRectGetWidth(self.collectionView.frame)
        var indexPath = NSIndexPath(forItem: page-1, inSection: 0)
        self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        self.pageControl.currentPage = Int32(page-1)
        
        self.collectionView.scrollEnabled = false
        self.backButton.hidden = (self.pageControl.currentPage == 0)
        
        self.nextButton.setImage(UIImage(named: "button_next_login_inact.png"), forState: .Normal)
        self.nextLabel.text = "Next"
    }
    
    @IBAction func nextPage(sender: AnyObject) {
        var page:Int = Int(self.pageControl.currentPage)
        var indexPath = NSIndexPath(forItem: page, inSection: 0)
        var cell:LoginCollectionViewCell = self.collectionView.cellForItemAtIndexPath(indexPath) as LoginCollectionViewCell
        self.validateTextInCell(cell)
    }
    
    // MARK: Collection view

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
        
        cell.textField.secureTextEntry = (indexPath.item == 1)
        cell.textField.keyboardType = ((indexPath.item == 0) ? UIKeyboardType.EmailAddress : UIKeyboardType.Default)
        
        switch (LoginStep(rawValue:indexPath.item)!) {
            case .email:
                cell.textField.text = self.email
                break
                
            case .password:
                cell.textField.text = self.password
                break
                
            case .username:
                cell.textField.text = self.username
                break
                
            default:
                break
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(CGRectGetWidth(collectionView.frame), 270)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var cell:LoginCollectionViewCell = self.collectionView.cellForItemAtIndexPath(indexPath) as LoginCollectionViewCell
        cell.textField.resignFirstResponder()
    }
    
    /**********************************
    *
    // MARK:   Login Cell
    *
    ***********************************/
    
    func loginCellDidResignTextField(cell: LoginCollectionViewCell) {
        //self.validateTextInCell(cell);
    }
    
    // MARK: Validate data
    
    func validateTextInCell(cell:LoginCollectionViewCell) {
        var indexPath = self.collectionView.indexPathForCell(cell)!
        var text:String = cell.textField.text
        
        if strlen(text) > 0 {
            switch (LoginStep(rawValue:indexPath.item)!) {
                case .email:
                    if self.validateEmail(text) {
                        self.email = text.lowercaseString
                    } else {
                        self.showAlert("Invalid email")
                        return
                    }
                    break
                    
                case .password:
                    if self.validatePassword(text) {
                        self.password = text
                    } else {
                        self.showAlert("Password should be 8-20 characters")
                        return
                    }
                    break
                    
                case .username:
                    if self.validateUserName(text) {
                        self.username = text
                    } else {
                        self.showAlert("Username should be 4-20 characters")
                        return
                    }
                    break
                    
                default:
                    break
            }
            
            self.gotoNextStep()
        } else {
            self.showAlert("Please enter text")
        }
    }
    
    func showAlert(message:String) {
        var alert = UIAlertView(title: "Warning", message:message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func gotoNextStep() {
        self.collectionView.scrollEnabled = true
        var page:Int = Int(self.pageControl.currentPage)
        
        if (page < 2) {
            var width = CGRectGetWidth(self.collectionView.frame)
            var indexPath = NSIndexPath(forItem: page+1, inSection: 0)
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
            self.pageControl.currentPage = page+1
            
            if (page == 1) {
                self.nextButton.setImage(UIImage(named: "button_done_login_inact.png"), forState: .Normal)
                self.nextLabel.text = "Done"
            }
        } else {
            var request:LoginRequest = LoginRequest()
            request.email = email
            request.password = password
            request.userName = username
            request.request { (result) -> Void in
                var response = result as LoginResponse
                
                if response.user != nil {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    if self.delegate != nil {
                        var delegate = self.delegate!
                        if delegate.respondsToSelector(Selector("loginViewDidFinishWithUser:Password:Username:")) {
                            delegate.loginViewDidFinishWithUser(response.user!)
                        }
                    }
                } else {
                    println("Login Error \(response.error)")
                    
                    if response.error != nil {
                        var message = response.error!.localizedDescription
                        var alertView = UIAlertView(title: "Login failed", message:message, delegate: nil, cancelButtonTitle: "OK")
                        alertView.show()
                    }
                }
            }
        }
        self.collectionView.scrollEnabled = false
        self.backButton.hidden = (self.pageControl.currentPage == 0)
    }
    
    func validateEmail(email:String) -> Bool {
        var emailRegex = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        var predicate = NSPredicate(format:	"SELF MATCHES %@", emailRegex)!
        return predicate.evaluateWithObject(email.lowercaseString)
    }
    
    func validatePassword(password:String) -> Bool {
        return strlen(password) >= 8 && strlen(password) <= 20
    }
    
    func validateUserName(username:String) -> Bool {
        return strlen(username) >= 4 && strlen(username) <= 20
    }
}
