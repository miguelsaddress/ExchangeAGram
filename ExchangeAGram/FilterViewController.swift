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
        let image = self.feedItem.image
        
        cell.imageView.image = UIImage(named: "Placeholder")
        
        let filterQueue:dispatch_queue_t = dispatch_queue_create("Filter Queue", nil)
        dispatch_async(filterQueue, { () -> Void in
            let filterImage = self.filteredImageFromImage(image, filter: filter)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.imageView.image = filterImage
            })
        }) 
        
        return cell
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


}
