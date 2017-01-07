//
//  DetailViewController.swift
//  WeatherBaerSwift
//
//  Created by Ken Baer on 1/28/16.
//  Copyright © 2016 BaerCode. All rights reserved.
//

import UIKit
import ForecastIOClient


public class DetailViewController: UIViewController {

    public var dayForecast: DataPoint?
    var dateFormatter: NSDateFormatter = NSDateFormatter()
    var timeFormatter: NSDateFormatter = NSDateFormatter()
    
    @IBOutlet var highTempLabel: UILabel?
    @IBOutlet var lowTempLabel: UILabel?
    @IBOutlet var forecastTextView: UILabel?
    @IBOutlet var sunriseLabel: UILabel?
    @IBOutlet var sunsetLabel: UILabel?

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.formatterBehavior = NSDateFormatterBehavior.Behavior10_4
        dateFormatter.dateFormat = "EEEE MMM d"
     
        timeFormatter.formatterBehavior = NSDateFormatterBehavior.Behavior10_4
        timeFormatter.dateFormat = "h:mma"

    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var time : NSTimeInterval = NSTimeInterval(dayForecast!.time)
        var date : NSDate = NSDate(timeIntervalSince1970:time)
        self.navigationItem.title = dateFormatter.stringFromDate(date) + " Forecast"
        
        if let highTemp: Double = dayForecast?.temperatureMax {
            highTempLabel!.text = String(Int(round(highTemp))) + "°"
        }
        if let lowTemp: Double = dayForecast?.temperatureMin {
            lowTempLabel!.text = String(Int(round(lowTemp))) + "°"
        }
        if let weatherSummary: String = dayForecast?.summary {
            forecastTextView!.text = weatherSummary
        }
        if let sunriseTime: Int = dayForecast?.sunriseTime {
            time = NSTimeInterval(sunriseTime)
            date = NSDate(timeIntervalSince1970:time)
            sunriseLabel!.text = timeFormatter.stringFromDate(date)
        }
        if let sunsetTime: Int = dayForecast?.sunsetTime {
            time = NSTimeInterval(sunsetTime)
            date = NSDate(timeIntervalSince1970:time)
            sunsetLabel!.text = timeFormatter.stringFromDate(date)
        }

    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
}
