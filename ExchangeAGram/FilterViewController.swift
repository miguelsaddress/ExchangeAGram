//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Miguel Angel Moreno Armenteros on 06/11/14.
//  Copyright (c) 2014 Miguel Angel Moreno Armenteros. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var feedItem: FeedItem!
    var collectionView: UICollectionView!
    var context:CIContext = CIContext(options: nil)
    var filters: [CIFilter] {
        let blur = CIFilter(name: "CIGaussianBlur")
        
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let sepia = CIFilter(name:"CISepiaTone")
        sepia.setValue(self.kIntensity, forKey:kCIInputIntensityKey)
        
        let colorControls = CIFilter(name:"CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)
        
        return [blur, instant, noir, transfer, unsharpen, monochrome, sepia, colorControls, colorClamp, composite, vignette]

    }
    
    let kIntensity = 0.7
    let placeholderImage = UIImage(named: "Placeholder")
    let tmp = NSTemporaryDirectory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Adding the collection view in code
        
        //The resposible for determinng the ways the elements are organised inside the collection
        let layout = UICollectionViewFlowLayout()
        //the margins
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //size of the cells
        layout.itemSize = CGSize(width: 150.0, height: 150.0)
        
        //init the collectionview
        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        //register the cell
        self.collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "filterCell")
        
        //add the colelction view to the VC's view
        self.view.addSubview(self.collectionView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:FilterCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("filterCell", forIndexPath: indexPath) as FilterCell
        let filter = self.filters[indexPath.row]
        let image = self.feedItem.thumbNail
        
        cell.imageView.image = self.placeholderImage
           
        let filterQueue:dispatch_queue_t = dispatch_queue_create("Filter Queue", nil)
        dispatch_async(filterQueue, { () -> Void in
            let filterImage = self.getCachedImage(indexPath.row)
               
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filterImage
            })
        })
        
        return cell
    }
    
    //UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.createUIAlertController(indexPath)
        
    }
    
    func saveFilterToCoreData(indexPath: NSIndexPath){
        //apply the filter to our real image, not the low quality thumbnail
        let filteredImage = self.filteredImageFromImage(self.feedItem.image, filter: self.filters[indexPath.row])
        let imageData = UIImageJPEGRepresentation(filteredImage, 1.0)
        self.feedItem.image = imageData
        self.feedItem.thumbNail = UIImageJPEGRepresentation(filteredImage, 0.1)
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    
    //Helpers
    
    func filteredImageFromImage(imageData: NSData, filter: CIFilter) -> UIImage {
        
        //creting the image from NSData
        let initialImage = CIImage(data: imageData)
        
        //We set the image to the filter
        filter.setValue(initialImage, forKey: kCIInputImageKey)
        
        //get the resulting image after apply it
        let filteredImage: CIImage = filter.outputImage
        
        //we get the rectangle of the image
        let imageRect: CGRect = filteredImage.extent()
        //create the image from the filter output and the rectangle
        let cgImage: CGImage = self.context.createCGImage(filteredImage, fromRect: imageRect)
        
        //build a UIImage to return, with the filter applied
        let finalImage = UIImage(CGImage: cgImage)
        
        return finalImage!

    }
    
    //UIAlertController Helper Functions
    
    func createUIAlertController(indexPath: NSIndexPath) {
        var alertController = UIAlertController(title: "Photo Options", message: "Please select an option", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            //configuration and behaviour of the textfield
            textField.placeholder = "Add a caption!"
            textField.secureTextEntry = false
        }
        
        var text: String
        let textField = alertController.textFields![0] as UITextField
        
        if textField.text != nil {
            text = textField.text
        }
        
        let photoAction = UIAlertAction(title: "Post Photo to Facebook with caption", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            self.saveFilterToCoreData(indexPath)
            self.shareToFacebook(indexPath)
        }
        alertController.addAction(photoAction)
        
        let saveFilterAction = UIAlertAction(title: "Save Filter without posting to Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.saveFilterToCoreData(indexPath)
        }
        
        alertController.addAction(saveFilterAction)
        
        let cancelAction = UIAlertAction(title: "Select another Action", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
            //nothing here yet
        }
        
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func shareToFacebook(indexPath: NSIndexPath) {
        let filteredImage = self.filteredImageFromImage(self.feedItem.image, filter: self.filters[indexPath.row])
        let photos: NSArray = [filteredImage]
        var params = FBPhotoParams()
        params.photos = photos
    
        FBDialogs.presentShareDialogWithPhotoParams(params, clientState: nil) { (call, result, error) -> Void in
            //code
            println(call)
            if (result != nil) {
                println(result)
            } else {
                println(error)
            }
        }
    }
    
    //Caching functions
    
    func cacheImage(imageNumber: Int) {
        let fileName = "\(imageNumber)-\(self.feedItem.objectID.hash)"
        let uniquePath = self.tmp.stringByAppendingPathComponent(fileName)
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            let data = self.feedItem.thumbNail
            let filter = self.filters[imageNumber]
            let image = self.filteredImageFromImage(data, filter: filter)
            UIImageJPEGRepresentation(image, 1.0).writeToFile(uniquePath, atomically: true)
        }
    }
    
    func getCachedImage(imageNumber: Int) -> UIImage {
        let fileName = "\(imageNumber)-\(self.feedItem.objectID.hash)"
        let uniquePath = self.tmp.stringByAppendingPathComponent(fileName)
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            self.cacheImage(imageNumber)
        }
        let image = UIImage(contentsOfFile: uniquePath)!
        return image
    }
    

}
