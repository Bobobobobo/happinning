//
//  PinListViewController.swift
//  Happening_V2.1
//
//  Created by Kan Boonprakub on 8/12/2557 BE.
//  Copyright (c) 2557 Kan Boonprakub. All rights reserved.
//

import CoreLocation
import UIKit
import AVFoundation
import MediaPlayer
import MobileCoreServices

class PinListViewController: BaseViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate , UITextViewDelegate, UITextFieldDelegate, LoginViewDelegate, LocationDelegate, PinListDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var pinsTableView : UITableView!
    @IBOutlet var sidebarButton : UIBarButtonItem!
    @IBOutlet weak var postScrollView: UIScrollView!
    
    // New pin
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var locationTableView: UITableView!
    @IBOutlet weak var placeTagField: UITextField!
    @IBOutlet weak var postImageButton: UIButton!
    @IBOutlet weak var postVideoButton: UIButton!
    @IBOutlet weak var postPinButton: UIButton!
    @IBOutlet var buttonIcons: [UIImageView]!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var pinTypeChooser: UIView!
    @IBOutlet weak var pinTypeChooserView: UICollectionView!
    
    // Sample pin
    @IBOutlet weak var sampleProfileImage: UIImageView!
    @IBOutlet weak var sampleUserName: UILabel!
    @IBOutlet weak var samplePinitle: UILabel!
    @IBOutlet weak var samplePinType: UIImageView!
    @IBOutlet weak var samplePinImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var samplePinLocation: UILabel!
    
    @IBOutlet weak var noPinView: UIView!
    
    var refreshControl:UIRefreshControl!
    var request:PinRequest?
    
    let kDefaultPostType = 10
    
    var api : APIController!
    
    var imageCache = [String : UIImage]()
    
    var isShowPost = false
    var isLogin = false
    
    var selectedImage:UIImage?
    var selectedVideo:NSData?
    
    let tableManager = PinTableViewDataSource()
    let locationDataSource = PinLocationTableDataSource()
    let localityManager = PinLocalityComposerDataSource()
    
    let mediaPlayer = MPMoviePlayerController()
    var isAddConstraint = false
    
    var lastSelected = -1
    
    enum PostMedia : Int {
        case None = 0
        case Image, Video
    }
    
    /**********************************
    *
    *   MARK: View cycle
    *
    ***********************************/

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //sidebarButton.target = self.revealViewController()
        //sidebarButton.action = Selector("revealToggle:")

        //self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        self.api = APIController()
        
        self.refreshControl = UIRefreshControl(frame: CGRectMake(0, 0, self.pinsTableView.frame.size.width, 60))
        self.refreshControl.tintColor = UIColor.hRedColor()
        self.refreshControl.addTarget(self, action: "reloadPins:", forControlEvents: UIControlEvents.ValueChanged)
        self.pinsTableView.addSubview(self.refreshControl)
        self.postScrollView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 0.0, 0.0)
        
        // Logged in
        isLogin = User.isLogin()
        
        if isLogin == true {
            self.loginViewDidFinishWithUser(User.currentUser)
        }
        
        self.postScrollView.alpha = 0.0
        
        self.postTextView.scrollsToTop = false
        self.pinTypeChooserView.scrollsToTop = false
        self.tagCollectionView.scrollsToTop = false
        self.pinsTableView.scrollsToTop = true
        
        self.adjustBorderForView(self.postTextView, withColor: UIColor.hRedColor())
        self.adjustBorderForView(self.postButton, withColor: UIColor.hgreyColor())
        self.adjustBorderForView(self.tagCollectionView.superview!, withColor: UIColor.hgreyColor())
        
        self.pinsTableView.delegate = self.tableManager
        self.pinsTableView.dataSource = self.tableManager
        self.tableManager.tableView = self.pinsTableView
        self.tableManager.delegate = self
        
        self.locationTableView.dataSource = self.locationDataSource
        self.locationTableView.delegate = self.locationDataSource

        self.tagCollectionView.delegate = self.localityManager
        self.tagCollectionView.dataSource = self.localityManager
        self.localityManager.collectionView = self.tagCollectionView
        
        self.setUpPlayer()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("reloadPins:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func setUpPlayer() {
        self.mediaPlayer.shouldAutoplay = false
        self.mediaPlayer.controlStyle = .None
        self.mediaPlayer.movieSourceType = .File
        
        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("playPreviewVideo:"))
        self.previewImageView.userInteractionEnabled = true
        self.previewImageView.addGestureRecognizer(tapGesture)
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
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "onContentSizeChange:",
                name: UIContentSizeCategoryDidChangeNotification,
                object: nil)

            //testing
            //var latitude: Double = 13.7324541
            //var longitude: Double = 100.5309073
            //self.loadPinsAt(latitude, longitude: longitude)
            
            if lastSelected >= 0 {
                var indexPath = NSIndexPath(forRow: lastSelected, inSection: 0)!
                self.pinsTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                lastSelected = -1
            }
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
                } else {
                    self.tableManager.pins += response.pins
                }
                
                //println("pins \(self.pins.count)")
                
                self.tableManager.hasMore = !(response.pins.count < 20)
            }
            
            self.noPinView.hidden = (self.tableManager.pins.count > 0)
        }
        
        if !self.tableManager.isScrolling {
            self.pinsTableView.reloadData()
        }
        
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
        } else if (segue.destinationViewController.isKindOfClass(PinDetailViewController.self)) {
            var detailView = segue.destinationViewController as PinDetailViewController
            var row = self.pinsTableView.indexPathForSelectedRow()?.row
            lastSelected = row!
            detailView.pin = self.tableManager.pins[row!]
        }
    }
    
    /**********************************
    *
    *   MARK: Location
    *
    ***********************************/
    
    func userLocationDidUpdateLocations(locations: [AnyObject]!) {
        UserLocation.manager.locationManager.stopUpdatingLocation()
        
        var loc:CLLocation = locations[locations.count-1] as CLLocation
        var locValue: CLLocationCoordinate2D = loc.coordinate
        println("location = \(locValue.latitude) \(locValue.longitude)")
        
        var latitude: Double = locValue.latitude
        var longitude: Double = locValue.longitude
        var userId = User.currentUser.userID
        //self.api.getPins(latitude, longitude: longitude,distance: 100000, userId: userId, loadPins)
        self.loadPinsAt(latitude, longitude: longitude, page:1)
        
        var request = LocationRequest()
        request.latitude = latitude
        request.longitude = longitude
        request.request(handleLocationResponse)
    }
    
    func userLocationDidUpdateGeoCoding(locality: [AnyObject]!) {
        //        if !self.placeTagField.isFirstResponder() && self.localityManager.locality.count == 0 {
        //            self.localityManager.locality = locality
        //            self.tagCollectionView.reloadData()
        //        }
    }
    
    func handleLocationResponse(result:BaseResponse) {
        var response = result as LocationResponse
        self.locationDataSource.locations = response.locations
        self.locationTableView.reloadData()
    }
    
    func userDidSelectLocation(location:Location!) {
        self.placeTagField.text = location.subLocality
        self.placeTagField.resignFirstResponder()
    }
}

