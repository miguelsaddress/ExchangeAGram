//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by Miguel Angel Moreno Armenteros on 07/11/14.
//  Copyright (c) 2014 Miguel Angel Moreno Armenteros. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "publish_actions"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        //when a user succesfully logs in
        self.nameLabel.hidden = false
        self.profileImageView.hidden = false
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        //when a user succesfully logs out
        self.nameLabel.hidden = true
        self.profileImageView.hidden = true
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        //
    }
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        
    }

}
