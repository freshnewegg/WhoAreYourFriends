//
//  FourthViewController.swift
//  WhoAreYourFriends
//
//  Created by Edgar Wang on 2016-08-21.
//  Copyright © 2016 Edgar Wang. All rights reserved.
//

import Foundation
import UIKit
import Charts

class FourthViewController: UIViewController {
    
    @IBOutlet var radarChartView: RadarChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getAnalysis(combinedFeed)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAnalysis(postData :String) {
        let url = "http://localhost:3000/getEmotion"
        
        
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
        
        
        let chartDataSet = RadarChartDataSet(yVals: dataEntries, label: "Personalities")
        chartDataSet.colors = ChartColorTemplates.colorful()
        let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        radarChartView.data = chartData
    }

}