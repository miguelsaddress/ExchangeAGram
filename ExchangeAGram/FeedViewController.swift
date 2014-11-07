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

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    var feedArray = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let request = NSFetchRequest(entityName: "FeedItem")
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        feedArray = context.executeFetchRequest(request, error: nil)!

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        cell.imageView.image = UIImage(data: feedItem.image)
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
        
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let thumbNailData = UIImageJPEGRepresentation(image, 0.1)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!)
        
        var feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        
        feedItem.image = imageData
        feedItem.thumbNail = thumbNailData
        feedItem.caption = "Feed item caption"
        appDelegate.saveContext()
        
        feedArray.append(feedItem)
        self.dismissViewControllerAnimated(true, completion: nil)

        self.collectionView.reloadData()

    }
    

}
