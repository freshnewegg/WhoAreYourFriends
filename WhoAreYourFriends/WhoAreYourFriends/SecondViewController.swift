//
//  SecondViewController.swift
//  WhoAreYourFriends
//
//  Created by Edgar Wang on 2016-08-20.
//  Copyright © 2016 Edgar Wang. All rights reserved.
//

import UIKit
import Charts

class SecondViewController: UIViewController {

    @IBOutlet var pieChartView: PieChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getAnalysis(combinedFeed)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.pieChartView.reloadInputViews()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        pieChartView.descriptionText = ""
        pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
        pieChartView.data = pieChartData
        
        var colors: [UIColor] = []
        
        for i in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            var color = UIColor();
            if dataPoints[i] == "Liberal" {
                color = UIColor(red: CGFloat(1.0), green: CGFloat(0), blue: CGFloat(0), alpha: 1)
            } else if dataPoints[i] == "Green" {
                color = UIColor(red: CGFloat(0), green: CGFloat(1.0), blue: CGFloat(0.0), alpha: 1)
            } else if dataPoints[i] == "Libertarian" {
                color = UIColor(red: CGFloat(22/255), green: CGFloat(45/255), blue: CGFloat(0), alpha: 1)
            } else {
                color = UIColor(red: CGFloat(0), green: CGFloat(0), blue: CGFloat(1.0), alpha: 1)
            }
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
        
        
        //        let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
        //        let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
        //        lineChartView.data = lineChartData
        
    }



}

