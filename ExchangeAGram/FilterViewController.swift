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
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell:FilterCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("filterCell", forIndexPath: indexPath) as FilterCell
        cell.imageView.image = UIImage(named:"Placeholder")
        
        return cell
    }

}
