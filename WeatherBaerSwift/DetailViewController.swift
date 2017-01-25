//
//  DetailViewController.swift
//  WeatherBaerSwift
//
//  Created by Ken Baer on 1/28/16.
//  Copyright © 2016 BaerCode. All rights reserved.
//

import UIKit
import ForecastIOClient


open class DetailViewController: UIViewController {

    open var dayForecast: DataPoint?
    var dateFormatter: DateFormatter = DateFormatter()
    var timeFormatter: DateFormatter = DateFormatter()
    
    @IBOutlet var highTempLabel: UILabel?
    @IBOutlet var lowTempLabel: UILabel?
    @IBOutlet var forecastTextView: UILabel?
    @IBOutlet var sunriseLabel: UILabel?
    @IBOutlet var sunsetLabel: UILabel?

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4
        dateFormatter.dateFormat = "EEEE MMM d"
     
        timeFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4
        timeFormatter.dateFormat = "h:mma"

    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var time : TimeInterval = TimeInterval(dayForecast!.time)
        var date : Date = Date(timeIntervalSince1970:time)
        self.navigationItem.title = dateFormatter.string(from: date) + " Forecast"
        
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
            time = TimeInterval(sunriseTime)
            date = Date(timeIntervalSince1970:time)
            sunriseLabel!.text = timeFormatter.string(from: date)
        }
        if let sunsetTime: Int = dayForecast?.sunsetTime {
            time = TimeInterval(sunsetTime)
            date = Date(timeIntervalSince1970:time)
            sunsetLabel!.text = timeFormatter.string(from: date)
        }

    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
}
