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
    *   MARK: New post
    *
    ***********************************/
    
    func prepareSamplePin() {
        self.sampleProfileImage.sd_setImageWithURL(NSURL(string: User.currentUser.userImage!))
        self.sampleUserName.text = User.currentUser.userName
    }
    
    func showNewPost(show:Bool) {
        var alpha:CGFloat = 0.0
        if show {
            self.prepareSamplePin()
            self.mediaPlayer.view.removeFromSuperview()
            alpha = 1.0
            self.pinTypeChooserView.selectItemAtIndexPath(NSIndexPath(forItem: kDefaultPostType, inSection: 0), animated: false, scrollPosition: .None)

            //if UserLocation.manager.subLocality.count > 0 {
                //self.localityManager.locality = UserLocation.manager.subLocality
                //self.tagCollectionView.reloadData()
            //}
        } else {
            alpha = 0.0
            self.postTextView.resignFirstResponder()
            self.placeTagField.resignFirstResponder()
            
            self.postImageButton.selected = false
            self.removePreviewImage()
            updateIconFor(self.postImageButton)
            
            self.mediaPlayer.stop()
            self.postVideoButton.selected = false
            updateIconFor(self.postVideoButton)

            self.postPinButton.selected = false
            updateIconFor(self.postPinButton)
        }
        
        self.view.userInteractionEnabled = false
        self.pinsTableView.scrollEnabled = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.postScrollView.alpha = alpha
        }, completion: {(conplete) -> Void in
            self.view.userInteractionEnabled = true
            self.pinsTableView.scrollEnabled = true
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
            postPinRequest.pinType = "\((self.pinTypeChooserView.indexPathsForSelectedItems()?.first as NSIndexPath).item + 1)"
            
            if self.previewImageView.image != nil {
                postPinRequest.pinImage = self.previewImageView.image
            }
            
            if self.postVideoButton.selected {
                println("post video \(self.mediaPlayer.contentURL)")
                postPinRequest.pinVideo = NSData(contentsOfURL:self.mediaPlayer.contentURL)
            }
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            self.postButton.enabled = false
            
            postPinRequest.upload({ (result) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.postButton.enabled = true

                var response:PinResponse = result as PinResponse
                if response.pins.count > 0 {
                    self.removeAllVideo()
                    
                    self.showNewPost(false)
                    self.postTextView.text = ""
                    self.tableManager.pins = response.pins + self.tableManager.pins
                    self.pinsTableView.reloadData()
                    
                    self.localityManager.locality = UserLocation.manager.subLocality
                    self.tagCollectionView.reloadData()
                }
            })
        }
    }
    
    func updateIconFor(button:UIButton) {
        (self.buttonIcons[button.tag%100-1]).highlighted = button.selected
        
        if button == self.postImageButton || button == self.postImageButton {
            self.previewImageView.hidden = !button.selected
        } else if button == self.postPinButton {
            self.pinTypeChooser.hidden = !button.selected
        }
        
        self.postTextView.resignFirstResponder()
        self.placeTagField.resignFirstResponder()
    }
    
    @IBAction func addNewImage(sender: AnyObject) {
        self.postImageButton.selected = !self.postImageButton.selected
        updateIconFor(self.postImageButton)
        
        self.postVideoButton.selected = false
        updateIconFor(self.postVideoButton)

        if self.postImageButton.selected {
            showImagePickerFor(.Image)
        } else {
            self.removePreviewImage()
        }
    }
    
    @IBAction func addNewVideo(sender: AnyObject) {
        self.postVideoButton.selected = !self.postVideoButton.selected
        updateIconFor(self.postVideoButton)

        self.postImageButton.selected = false
        updateIconFor(self.postImageButton)

        if self.postVideoButton.selected {
            showImagePickerFor(.Video)
        } else {
            self.removePreviewImage()
            self.mediaPlayer.stop()
            self.mediaPlayer.view.removeFromSuperview()
        }
    }
    
    func playPreviewVideo(sender: AnyObject) {
        var tapGesture = sender as UITapGestureRecognizer
        if self.postVideoButton.selected && tapGesture.state == .Ended {
            self.mediaPlayer.play()
        }
    }
    
    @IBAction func addPinType(sender: AnyObject) {
        self.postPinButton.selected = !self.postPinButton.selected
        updateIconFor(self.postPinButton)
    }
    
    /**********************************
    *
    *   MARK: Table View
    *
    ***********************************/
    
    func pinListShouldHideComposerView() {
        if self.tableManager.shouldHidePost {
            showNewPost(false)
            self.tableManager.shouldHidePost = false
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
            UserLocation.manager.startUpdatingLocation()
            UserLocation.manager.delegate = self
        } else {
            println("Login Error")
        }
    }
    
    /**********************************
    *
    *   MARK: Text field
    *
    ***********************************/
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        self.samplePinitle.text = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)

        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        self.samplePinLocation.text = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)

        if self.samplePinLocation.text != nil {
            self.locationDataSource.searchWith(self.samplePinLocation.text!)
        } else {
            self.locationDataSource.tableData = self.locationDataSource.locations
        }
        
        self.locationTableView.reloadData()
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if strlen(textField.text) > 0 {
            self.localityManager.locality = [textField.text]
            self.tagCollectionView.reloadData()
            self.samplePinLocation.text = textField.text
            textField.text = ""
        }
        
        self.locationTableView.hidden = true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.locationTableView.hidden = false
        return true
    }
    
    /**********************************
    *
    *   MARK: Image Picker
    *
    ***********************************/
    
    func showImagePickerFor(mediaType:PostMedia) {
        var picker = UIImagePickerController()
        picker.delegate = self
        
        if mediaType == .Image {
            picker.mediaTypes = [kUTTypeImage]
        } else {
            picker.mediaTypes = [kUTTypeMovie]
            picker.videoMaximumDuration = 15.0
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            picker.sourceType = .Camera
        }
        
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        var mediaType = info[UIImagePickerControllerMediaType] as String
        var image:UIImage?
        
        if mediaType == kUTTypeMovie {
            var contentURL = info[UIImagePickerControllerMediaURL] as NSURL
            println("contentURL \(contentURL)")
            
            var asset = AVAsset.assetWithURL(contentURL) as AVAsset
            var imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            var time = CMTimeMake(1, 1)
            var imageRef = imageGenerator.copyCGImageAtTime(time, actualTime: nil, error: nil)
            
            image = UIImage(CGImage: imageRef, scale:1.0, orientation:.Up)

            self.view.userInteractionEnabled = false
            self.convertVideoToMp4(contentURL, handler: { (success, input, output) -> Void in
                self.view.userInteractionEnabled = true
                if Bool(success) {
//                    self.mediaPlayer.stop()
//                    self.mediaPlayer.contentURL = output
//                    self.mediaPlayer.play()
                    
                    self.mediaPlayer.contentURL = output
                    self.mediaPlayer.view.frame = self.previewImageView.bounds
                    self.mediaPlayer.view.userInteractionEnabled = false
                    self.previewImageView.addSubview(self.mediaPlayer.view)
                    self.addMediaPlayerConstraint()
                    self.mediaPlayer.prepareToPlay()
                    self.mediaPlayer.play()
                } else {
                    if self.postVideoButton.selected {
                        self.addNewVideo(self.postVideoButton)
                    }
                }
            })
        } else {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
            
        self.postPinButton.selected = false
        updateIconFor(self.postPinButton)
        
        self.samplePinImageConstraint.constant = 200;
        self.previewImageView.superview?.layoutIfNeeded()
        self.previewImageView.hidden = false
        self.previewImageView.image = image

    }
    
    func convertVideoToMp4(videoURL:NSURL, handler: ((success:Bool, input:NSURL?, output:NSURL?) -> Void)!) {
        println("videoURL \(videoURL)")
        
        removeAllVideo()
        
        var paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        var originPath = (paths[0] as NSString).stringByAppendingPathComponent("video.mov")
        NSData(contentsOfURL: videoURL)?.writeToFile(originPath, atomically: false)

        println("originPath \(originPath)")

        var avAsset = AVURLAsset(URL: NSURL(fileURLWithPath: originPath), options: nil)
        
        var exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)        
        var videoPath = (paths[0] as NSString).stringByAppendingPathComponent("video.mp4")
        println("videoPath \(videoPath)")

        exportSession.outputURL = NSURL(fileURLWithPath: videoPath)
        exportSession.outputFileType = AVFileTypeMPEG4
        exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
            if exportSession.status == .Failed {
                println("exportSession error \(exportSession.error)")
               
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if handler != nil {
                        handler(success: false, input:videoURL, output: nil)
                    }
                })
                self.removeAllVideo()
            } else if exportSession.status == .Completed {
                println("exportSession success")
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if handler != nil {
                        handler(success: true, input:videoURL, output: exportSession.outputURL)
                    }
                })
                
            }
        }
    }
    
    func addMediaPlayerConstraint() {
        if isAddConstraint {
            return
        }
        
        self.mediaPlayer.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        isAddConstraint = true
    }
    
    func removeAllVideo() {
        var fileManager = NSFileManager.defaultManager()
        var paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        var originPath = (paths[0] as NSString).stringByAppendingPathComponent("video.mov")
        var videoPath = (paths[0] as NSString).stringByAppendingPathComponent("video.mp4")

        fileManager.removeItemAtPath(originPath, error: nil)
        fileManager.removeItemAtPath(videoPath, error: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.removePreviewImage()
        
        self.postImageButton.selected = false
        updateIconFor(self.postImageButton)
        
        self.postVideoButton.selected = false
        updateIconFor(self.postVideoButton)

    }
    
    func removePreviewImage() {
        self.samplePinImageConstraint.constant = 0;
        self.previewImageView.superview?.layoutIfNeeded()
        self.previewImageView.image = nil
    }
    
    /**********************************
    *
    *   MARK: Post type
    *
    ***********************************/
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PinManager.manager.pinList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("iconCell", forIndexPath: indexPath) as PinIconCell
        
        var imageName = PinManager.manager.pinList[indexPath.item]
        cell.iconImage.image = UIImage(named: "\(imageName).png")
        
        var iconName = imageName.stringByReplacingOccurrencesOfString("icon_", withString: "")
        iconName = iconName.stringByReplacingOccurrencesOfString("_", withString: " ")
        
        if iconName.hasPrefix("department") {
            iconName = iconName.stringByReplacingOccurrencesOfString("department ", withString: "")
        }
        
        cell.textLabel.text = iconName.capitalizedString
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var imageName = PinManager.manager.pinList[indexPath.item]
        self.samplePinType.image = UIImage(named: "\(imageName).png")
    }
}

