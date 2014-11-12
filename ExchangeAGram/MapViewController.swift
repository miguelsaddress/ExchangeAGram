//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Miguel Angel Moreno Armenteros on 12/11/14.
//  Copyright (c) 2014 Miguel Angel Moreno Armenteros. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let request: NSFetchRequest = NSFetchRequest(entityName: "FeedItem")
        let context:NSManagedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
        var error:NSError?
        let itemsArray = context.executeFetchRequest(request, error: &error)
        if( error == nil ){
            //do nothing...
            println(error)
        }
        
        for item in itemsArray! {
            let i = item as FeedItem
            self.addAnnotation(latitude: Double(i.latitude), longitude: Double(i.longitude) , title: i.caption)
        }
        
        
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAnnotation(#latitude: Double, longitude: Double, title: String = "", subtitle:String = "") {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        let span = MKCoordinateSpanMake(0.05, 0.05)
        let span = MKCoordinateSpanMake(50, 50)
        let region = MKCoordinateRegionMake(location, span)
        
        self.mapView.setRegion(region, animated: true)
        
        var annotation = MKPointAnnotation()
        annotation.setCoordinate(location)
        annotation.title = title
        annotation.subtitle = subtitle
        
        self.mapView.addAnnotation(annotation)
    }

}
