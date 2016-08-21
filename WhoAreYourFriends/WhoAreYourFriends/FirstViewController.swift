//
//  FirstViewController.swift
//  WhoAreYourFriends
//
//  Created by Edgar Wang on 2016-08-20.
//  Copyright © 2016 Edgar Wang. All rights reserved.
//
import UIKit
import Charts

var combinedFeed = ""

class FirstViewController: UIViewController, FBSDKLoginButtonDelegate {
    var userPassword = "test"
    var userName = "edgarwang"
    var userEmail = "edgarwang95@gmail.com"
    
    
    @IBOutlet var userNameWelcome: UILabel!
    @IBOutlet var userImage: UIImageView!
    @IBAction func getUserFeed(sender: AnyObject) {
        getFBPosts(nil, failureHandler: {(error) in print(error)})
        userPostsButton.tintColor = UIColor.greenColor()
    }
    @IBOutlet weak var btnFacebook: FBSDKLoginButton!
    //@IBOutlet weak var output: UITextField!
    
    @IBOutlet var userPostsButton: UIButton!
    @IBOutlet var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPostsButton.tintColor = UIColor.redColor()
        
        configureFacebook()
        
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, friends, posts, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
            if (result != nil) {
                let strFirstName: String = (result.objectForKey("first_name") as? String)!
                let strLastName: String = (result.objectForKey("last_name") as? String)!
                let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
            
                self.userNameWelcome.text = "Welcome, \(strFirstName) \(strLastName)"
                self.userImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: strPictureURL)!)!)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func configureFacebook()
    {
        btnFacebook.readPermissions = ["user_posts", "user_friends", "public_profile"];
        btnFacebook.delegate = self
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!)
    {
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields":"first_name, last_name, friends, posts, picture.type(large)"]).startWithCompletionHandler { (connection, result, error) -> Void in
            if (result != nil) {
            let strFirstName: String = (result.objectForKey("first_name") as? String)!
            let strLastName: String = (result.objectForKey("last_name") as? String)!
            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
            
            self.userNameWelcome.text = "Welcome, \(strFirstName) \(strLastName)"
            self.userImage.image = UIImage(data: NSData(contentsOfURL: NSURL(string: strPictureURL)!)!)
        }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        print("test logout")
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        self.userNameWelcome.text = "Please Sign in"
        self.userImage.image = nil
    }
    
    func getFBPosts(nextCursor : String?, failureHandler: (error: NSError) -> Void) {
        //var combinedFeed = "Starting String: "
        
        var parameters = Dictionary<String, String>() as? Dictionary
        parameters!["limit"] = "500"
        parameters!["version"] = "2.1"
        
        let request = FBSDKGraphRequest(graphPath: "me/posts", parameters: parameters)
        request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                let resultdict = result as! NSDictionary
                let data : NSArray = resultdict.objectForKey("data") as! NSArray
                //var combinedFeed = ""
                
                for i in 0..<data.count {
                    let valueDict : NSDictionary = data[i] as! NSDictionary
                    let postMessage = valueDict.objectForKey("message") as? String
                    postMessage?.stringByReplacingOccurrencesOfString("\n", withString: " ")
                    if (postMessage != nil) {
                        combinedFeed = combinedFeed + " " + postMessage!
                    }
                    
                }
                
                //self.getAnalysis(combinedFeed)
            }
        }
        //print("output man")
        //print(combinedFeed)
        //return combinedFeed
        
    }

}

