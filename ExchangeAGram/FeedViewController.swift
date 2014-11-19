//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Miguel Angel Moreno Armenteros on 05/11/14.
//  Copyright (c) 2014 Miguel Angel Moreno Armenteros. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import MapKit

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    var feedArray = [AnyObject]()
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 100.0
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        feedArray = context.executeFetchRequest(request, error: nil)!

        self.collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func profileTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("profileSegue", sender: nil)
    }
    
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {
        //A controller for the image picker, whatever source
        var imagePickerController = UIImagePickerController()
        
        //this is just to present this controller or the alert
        var presentableController: UIViewController = imagePickerController
        
        //lets set the delegate of the image picker
        imagePickerController.delegate = self
        
        //And lets allow only media type for images, not videos
        //also no editing posibilities
        let mediaTypes:[AnyObject] = [kUTTypeImage]
        imagePickerController.mediaTypes = mediaTypes
        imagePickerController.allowsEditing = false
        
        //If the camera is available, take picture. Otherwise, if the photo library is available,
        //chose a picture from there. finally, if none is available, inform the user that we cannot
        //do anything, via alert
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        } else {
            var alertController = UIAlertController(
                title: "Alert",
                message: "Your device does not support the camera or Photo Library",
                preferredStyle: UIAlertControllerStyle.Alert
            )
            var action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(action)
            presentableController = alertController
        }
        self.presentViewController(presentableController, animated: true, completion: nil)

    }
    
    //UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView:UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feedArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("feedCell", forIndexPath: indexPath) as FeedCell
        
        //set data into the feed cell
        let feedItem = self.feedArray[indexPath.row] as FeedItem
        let itemImage = UIImage(data: feedItem.image)!
        if feedItem.filtered as Bool {
            cell.imageView.image = UIImage(CGImage: itemImage.CGImage, scale: 1.0, orientation: UIImageOrientation.Up)!
        } else {
            cell.imageView.image = itemImage
        }

        cell.captionLabel.text = feedItem.caption
        return cell
    }
    
    //UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = feedArray[indexPath.row] as FeedItem
        var filterVC = FilterViewController()
        filterVC.feedItem = selectedItem
        
        self.navigationController?.pushViewController(filterVC, animated: false)
    }
    
    //UIImagePickerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        
        //  info = [
        //        UIImagePickerControllerOriginalImage: <UIImage: 0x7f94ea65fe20> size {554, 426} orientation 0 scale 1.000000,
        //        UIImagePickerControllerMediaType: public.image,
        //        UIImagePickerControllerReferenceURL: assets-library://asset/asset.JPG?id=3F44831C-DA90-40B2-B03D-2D3080E8FD8B&ext=JPG
        //  ]

        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let thumbNailData = UIImageJPEGRepresentation(image, 0.1)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!)
        
        var feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        
        feedItem.uniqueID = NSUUID().UUIDString
        feedItem.filtered = false
        feedItem.image = imageData
        feedItem.thumbNail = thumbNailData
        feedItem.caption = "Feed item caption"
        feedItem.latitude = self.locationManager.location.coordinate.latitude
        feedItem.longitude = self.locationManager.location.coordinate.longitude
        appDelegate.saveContext()
        
        feedArray.append(feedItem)
        self.dismissViewControllerAnimated(true, completion: nil)

        self.collectionView.reloadData()

    }
    
    //CCLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("locations = [\(locations)]")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        // The location "unknown" error simply means the manager is currently unable to get the location.
        // We can ignore this error for the scenario of getting a single location fix, because we already have a
        // timeout that will stop the location manager to save power.
        if error.code != CLError.LocationUnknown.rawValue {
            self.locationManager.stopUpdatingLocation()
        }

    }

}
