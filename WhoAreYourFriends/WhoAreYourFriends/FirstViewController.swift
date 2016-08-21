//
//  FirstViewController.swift
//  WhoAreYourFriends
//
//  Created by Edgar Wang on 2016-08-20.
//  Copyright © 2016 Edgar Wang. All rights reserved.
//
import UIKit
import Charts

class FirstViewController: UIViewController, FBSDKLoginButtonDelegate {
    var userPassword = "test"
    var userName = "edgarwang"
    var userEmail = "edgarwang95@gmail.com"
    
    @IBAction func getUserFeed(sender: AnyObject) {
        getFBPosts(nil, failureHandler: {(error) in print(error)})
    }
    @IBOutlet weak var btnFacebook: FBSDKLoginButton!
    //@IBOutlet weak var output: UITextField!
    
    @IBOutlet var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFacebook()
        
    }
    
    func getAnalysis(postData :String) {
        let url = "http://localhost:3000/getPoliticalSentiment"
        
        
        //var input = "I have a constitutional right to bear arms!"
        let input = String(UTF8String: postData.cStringUsingEncoding(NSUTF8StringEncoding)!)
        
        var addressNoSpaces = input!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        
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
                    
                    let politicalview: [String] = convertedJsonIntoDict.allKeys as! [String]
                    let values: [Double] = convertedJsonIntoDict.allValues as! [Double]
                    
                    self.setChart(politicalview, values: values)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        
        task.resume();

    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Units Sold")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        var colors: [UIColor] = []
        
        for i in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        
        
//        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
//        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
//        lineChartView.data = lineChartData
        
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
            
            let strFirstName: String = (result.objectForKey("first_name") as? String)!
            let strLastName: String = (result.objectForKey("last_name") as? String)!
            let strPictureURL: String = (result.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as? String)!
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!)
    {
        print("test logout")
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
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
                var combinedFeed = ""
                
                for i in 0..<data.count {
                    let valueDict : NSDictionary = data[i] as! NSDictionary
                    let postMessage = valueDict.objectForKey("message") as? String
                    postMessage?.stringByReplacingOccurrencesOfString("\n", withString: " ")
                    if (postMessage != nil) {
                        combinedFeed = combinedFeed + " " + postMessage!
                    }
                    
                }
                
                self.getAnalysis(combinedFeed)
            }
        }
        //print("output man")
        //print(combinedFeed)
        //return combinedFeed
        
    }

}

