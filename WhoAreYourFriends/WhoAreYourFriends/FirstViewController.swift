//
//  FirstViewController.swift
//  WhoAreYourFriends
//
//  Created by Edgar Wang on 2016-08-20.
//  Copyright © 2016 Edgar Wang. All rights reserved.
//
import UIKit
import Charts

class FirstViewController: UIViewController {
    var userPassword = "test"
    var userName = "edgarwang"
    var userEmail = "edgarwang95@gmail.com"
    
    @IBOutlet weak var output: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = "http://localhost:3000/getPoliticalSentiment"
        var input = "I have a constitutional right to bear arms!"
        var addressNoSpaces = input.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        
        //create NSURL object
        //let myUrl = NSURL(string: url)
        
        let urlWithParams = NSURL(string: (url + "?data=" + addressNoSpaces!))
        
        //create URl Request
        let request = NSMutableURLRequest(URL: urlWithParams!)
        
        //set method to GET method
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            //print out response string
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            //convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                {
                    print(convertedJsonIntoDict)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        task.resume();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

