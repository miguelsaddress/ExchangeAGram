//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Miguel Angel Moreno Armenteros on 12/11/14.
//  Copyright (c) 2014 Miguel Angel Moreno Armenteros. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addAnnotation(latitude: 48.868639224587, longitud: 2.37119161036255, title: "Canal Saint-Martin", subtitle: "Paris")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAnnotation(#latitude: Double, longitud: Double, title: String = "", subtitle:String = "") {
        let location = CLLocationCoordinate2D(latitude: 48.868639224587, longitude: 2.37119161036255)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(location, span)
        
        self.mapView.setRegion(region, animated: true)
        
        var annotation = MKPointAnnotation()
        annotation.setCoordinate(location)
        annotation.title = title
        annotation.subtitle = subtitle
        
        self.mapView.addAnnotation(annotation)
    }

}
