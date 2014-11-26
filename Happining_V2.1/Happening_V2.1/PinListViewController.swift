//
//  PinListViewController.swift
//  Happening_V2.1
//
//  Created by Kan Boonprakub on 8/12/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import CoreLocation
import UIKit
import MobileCoreServices

class PinListViewController: BaseViewController ,
                            // Image Picker
                            UIImagePickerControllerDelegate, UINavigationControllerDelegate ,
                            // Text Input
                            UITextViewDelegate, UITextFieldDelegate,
                            // Custom
                            LoginViewDelegate, LocationDelegate, PinListDelegate {
                            
    @IBOutlet var pinsTableView : UITableView!
    @IBOutlet var sidebarButton : UIBarButtonItem!
    @IBOutlet weak var postViewConstraint: NSLayoutConstraint!
    
    // New pin
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var placeTagField: UITextField!
    @IBOutlet weak var postImageButton: UIButton!
    @IBOutlet weak var postVideoButton: UIButton!
    @IBOutlet weak var postPinButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewImageConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var noPinView: UIView!
    
    var refreshControl:UIRefreshControl!
    var request:PinRequest?
    
    let kPostViewSize:CGFloat = 142
    
    var api : APIController!
    
    var imageCache = [String : UIImage]()
    
    var isShowPost = false
    var isLogin = false
    
    var selectedImage:UIImage?
    var selectedVideo:NSData?
    
    let tableManager = PinTableViewDataSource()
    let localityManager = PinLocalityComposerDataSource()
    
    enum PostMedia : Int {
        case PostMediaNone = 0
        case PostMediaImage, PostMediaVideo
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        sidebarButton.target = self.revealViewController()
        sidebarButton.action = Selector("revealToggle:")

        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.api = APIController()
        
        self.refreshControl = UIRefreshControl(frame: CGRectMake(0, 0, self.pinsTableView.frame.size.width, 60))
        self.refreshControl.tintColor = UIColor.hRedColor()
        self.refreshControl.addTarget(self, action: "reloadPins:", forControlEvents: UIControlEvents.ValueChanged)
        self.pinsTableView.addSubview(self.refreshControl)
        
        // Logged in
        isLogin = User.isLogin()
        self.postViewConstraint.constant = 0;
        
        self.postTextView.scrollsToTop = false
        self.tagCollectionView.scrollsToTop = false
        
        self.adjustBorderForView(self.postTextView, withColor: UIColor.hRedColor())
        self.adjustBorderForView(self.postButton, withColor: UIColor.hgreyColor())
        self.adjustBorderForView(self.tagCollectionView.superview!, withColor: UIColor.hgreyColor())
        
        self.pinsTableView.delegate = self.tableManager
        self.pinsTableView.dataSource = self.tableManager
        self.tableManager.delegate = self
        
        self.tagCollectionView.delegate = self.localityManager
        self.tagCollectionView.dataSource = self.localityManager
        self.localityManager.collectionView = self.tagCollectionView
    }
    
    func adjustBorderForView(view:UIView, withColor color:UIColor) {
        view.layer.borderWidth = 1.5
        view.layer.borderColor = color.CGColor
        view.layer.cornerRadius = 3.0
    }
    
    func onContentSizeChange(notification: NSNotification) {
        self.pinsTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isLogin {
            self.performSegueWithIdentifier("signin", sender: self)
            isLogin = true
        } else {
            UserLocation.manager.startUpdatingLocation()
            UserLocation.manager.delegate = self
            
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "onContentSizeChange:",
                name: UIContentSizeCategoryDidChangeNotification,
                object: nil)

            //testing
            //var latitude: Double = 13.7324541
            //var longitude: Double = 100.5309073
            //self.loadPinsAt(latitude, longitude: longitude)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func testTapped(sender: UIBarButtonItem!) {
        self.revealViewController().revealToggle(sender)
    }
    
    @IBAction func postNewPin(sender: AnyObject) {
        showNewPost(!isShowPost)
    }
    
    /**********************************
    *
    *   MARK: Location
    *
    ***********************************/
    
    func userLocationDidUpdateLocations(locations: [AnyObject]!) {
        var loc:CLLocation = locations[locations.count-1] as CLLocation
        var locValue: CLLocationCoordinate2D = loc.coordinate
        println("location = \(locValue.latitude) \(locValue.longitude)")
        
        var latitude: Double = locValue.latitude
        var longitude: Double = locValue.longitude
        var userId = User.currentUser.userID
        //self.api.getPins(latitude, longitude: longitude,distance: 100000, userId: userId, loadPins)
        self.loadPinsAt(latitude, longitude: longitude, page:1)
    }
    
    func userLocationDidUpdateGeoCoding(locality: [AnyObject]!) {
        if !self.placeTagField.isFirstResponder() && self.localityManager.locality.count == 0 {
            self.localityManager.locality = locality
            self.tagCollectionView.reloadData()
        }
    }
    
    /**********************************
    *
    *   MARK: New post
    *
    ***********************************/
    
    func showNewPost(show:Bool) {
        if show {
            self.postViewConstraint.constant = kPostViewSize
            
            if UserLocation.manager.subLocality.count > 0 {
                self.localityManager.locality = UserLocation.manager.subLocality
                self.tagCollectionView.reloadData()
            }
        } else {
            self.postViewConstraint.constant = 0
            self.postTextView.resignFirstResponder()
            
            self.postImageButton.selected = false
            self.previewImageView.image = nil
        }
        
        self.view.userInteractionEnabled = false
        self.pinsTableView.scrollEnabled = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }, completion: {(conplete) -> Void in
            self.view.userInteractionEnabled = true
            self.pinsTableView.scrollEnabled = true
            self.pinsTableView.contentOffset = CGPointMake(0, -self.pinsTableView.contentInset.top)
        })
        
        self.isShowPost = show
    }
    
    @IBAction func addNewPin(sender: AnyObject) {
        if strlen(self.postTextView.text) == 0 {
            self.postTextView.becomeFirstResponder()
            return
        }
        
        if self.localityManager.locality.count == 0 {
            self.placeTagField.becomeFirstResponder()
            return
        }
        
        if self.request != nil {
            var subLocal = self.localityManager.locality.firstObject as String
            var locality = (UserLocation.manager.locality as NSArray).componentsJoinedByString(",")
            
            var postPinRequest = PostPinRequest()
            postPinRequest.latitude = self.request!.latitude
            postPinRequest.longitude = self.request!.longitude
            postPinRequest.pinLocality = locality
            postPinRequest.pinSubLocality = subLocal
            postPinRequest.userID = User.currentUser.userID!
            postPinRequest.pinText = self.postTextView.text
            
            if self.previewImageView.image != nil {
                postPinRequest.pinImage = self.previewImageView.image
            }
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.postButton.enabled = false
            
            postPinRequest.upload({ (result) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.postButton.enabled = true

                var response:PinResponse = result as PinResponse
                if response.pins.count > 0 {
                    self.showNewPost(false)
                    self.postTextView.text = ""
                    self.tableManager.pins = response.pins + self.tableManager.pins
                    self.pinsTableView.reloadData()
                }
            })
        }
    }
    
    @IBAction func addNewImage(sender: AnyObject) {
        self.postImageButton.selected = !self.postImageButton.selected
        
        if self.postImageButton.selected {
            showImagePickerFor(PostMedia.PostMediaImage)
        } else {
            self.postViewConstraint.constant = kPostViewSize
            self.view.layoutIfNeeded()
            self.previewImageView.image = nil
        }
    }
    
    @IBAction func addNewVideo(sender: AnyObject) {
        showImagePickerFor(PostMedia.PostMediaVideo)
    }
    
    /**********************************
    *
    *   MARK: Table View
    *
    ***********************************/
    
    func pinListShouldHideComposerView() {
        if self.tableManager.shouldHidePost {
            self.postViewConstraint.constant = 0
            showNewPost(false)
            self.tableManager.shouldHidePost = false
        } else if !isShowPost {
            self.postViewConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func pinListShouldUpdateComposerView(constant: CGFloat) {
        if isShowPost {
            self.tableManager.shouldHidePost = true
            self.postViewConstraint.constant -= constant
            self.view.layoutIfNeeded()
            self.pinsTableView.contentOffset = CGPointZero
        }
    }
    
    func pinListShouldLoadMore() {
        if  self.request != nil {
            self.loadPinsAt(self.request!.latitude, longitude: self.request!.longitude, page: request!.page+1)
        }
    }
    
    /**********************************
    *
    *   MARK: Load Pin
    *
    ***********************************/

    func loadPinsAt(latitude:Double, longitude:Double, page:Int) {
        if self.request != nil {
            if self.request!.task!.state == .Running {
                return;
            }
        }

        var userId = User.currentUser.userID
        //self.api.getPins(latitude, longitude: longitude,distance: 100000, userId: userId, loadPins)
        var request = PinRequest()
        request.latitude = latitude
        request.longitude = longitude
        request.userID = userId!
        request.distance = 100000
        request.page = page
        self.request = request
        self.request!.request(handleResponse)
    }
    
    func reloadPins(sender:AnyObject?) {
//        if  self.request != nil {
//            self.request!.page = 1;
//            self.request!.request(handleResponse)
//        }
        UserLocation.manager.startUpdatingLocation()
    }
    
    func handleResponse(result:BaseResponse) {
        var response = result as PinResponse

        if self.request != nil {
            if response.pins.count > 0 {
                if self.request!.page == 1 {
                    self.tableManager.pins = response.pins
                    self.pinsTableView.contentOffset = CGPointMake(0, -self.pinsTableView.contentInset.top);
                } else {
                    self.tableManager.pins += response.pins
                }
                
                //println("pins \(self.pins.count)")
                
                self.tableManager.hasMore = !(response.pins.count < 20)
            }
            
            self.noPinView.hidden = (self.tableManager.pins.count > 0)
        }
        
        self.pinsTableView.reloadData()
        self.refreshControl.endRefreshing()
    }

    /**********************************
    *
    *   MARK: Navigation
    *
    ***********************************/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier != nil) {
            var segueID = segue.identifier!
            if (segueID == "signin") {
                var navigationController:UINavigationController = segue.destinationViewController as UINavigationController
                var loginController:LoginViewController = navigationController.viewControllers[0] as LoginViewController
                loginController.delegate = self
            }
        }
    }
    
    /**********************************
    *
    *   MARK: Login Delegate
    *
    ***********************************/

    func loginViewDidFinishWithUser(user: User?) {
        if user != nil {
            println("Finish login with \(user!.userName)")
        } else {
            println("Login Error")
        }
    }
    
    /**********************************
    *
    *   MARK: Location view collection
    *
    ***********************************/
    
    @IBAction func clearAllLocation(sender: AnyObject) {
        self.localityManager.locality = []
        self.tagCollectionView.reloadData()
    }
    
    /**********************************
    *
    *   MARK: Text field
    *
    ***********************************/
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if strlen(textField.text) > 0 {
            self.localityManager.locality = [textField.text]
            self.tagCollectionView.reloadData()
            textField.text = ""
        }
    }
    
    /**********************************
    *
    *   MARK: Image Picker
    *
    ***********************************/
    
    func showImagePickerFor(mediaType:PostMedia) {
        var picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeImage]
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            picker.sourceType = .Camera
        }
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.postViewConstraint.constant = kPostViewSize + CGRectGetWidth(self.view.frame)
        self.view.layoutIfNeeded()
        self.previewImageView.image = image
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

