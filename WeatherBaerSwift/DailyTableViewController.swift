//
//  DailyTableViewController.swift
//  WeatherBaerSwift
//
//  Created by Ken Baer on 1/28/16.
//  Copyright © 2016 BaerCode. All rights reserved.
//

import UIKit
import ForecastIOClient
import CoreLocation


class DailyTableViewController: UITableViewController, CLLocationManagerDelegate {

    private var locationManager: CLLocationManager = CLLocationManager()
    private var geoCoder: CLGeocoder = CLGeocoder()
    
    var forecast: Forecast?
    var isFindingLocation : Bool = true
    var isLoadingForecast : Bool = false
    var selectedDayForecast : DataPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Finding Location"
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        isFindingLocation = true
        locationManager.requestLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func  preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return UIStatusBarStyle.LightContent
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFindingLocation || isLoadingForecast {
            return 0
        }
        else { // Note: The spec called for 10 rows of data, but the API returns 8 days in the forecast
            return 8
        }
    }
        
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("DayForecast", forIndexPath: indexPath)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        if let _ = forecast?.daily?.data![indexPath.row].time {
            // convert the daily date from seconds to NSDate, then display it in MM/DD format
            let time : NSTimeInterval = NSTimeInterval(forecast!.daily!.data![indexPath.row].time)
            let date : NSDate = NSDate(timeIntervalSince1970:time)
            
            cell.textLabel!.text = appDelegate.dateFormatter.stringFromDate(date) + " " + (forecast?.daily?.data![indexPath.row].summary)!
        }
        
        return cell
    }

    // MARK: - Navigation

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        selectedDayForecast = forecast?.daily?.data![indexPath.row]
        
        self.performSegueWithIdentifier("DailyDetails", sender: self)

    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "DailyDetails" {
            let vc : DetailViewController! = segue.destinationViewController as! DetailViewController
            vc.dayForecast = selectedDayForecast
        }
    }

    // MARK: - Location
    
    // EXTRA CREDIT
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        isFindingLocation = false
        // Retrieve current forecast
        if locations.count > 0 {
            
            self.getNameOfLocation(locations.first!)
            
            let latitude = locations.first!.coordinate.latitude
            let longitude = locations.first!.coordinate.longitude
            
            ForecastIOClient.sharedInstance.forecast(latitude, longitude: longitude, failure: { (error) in
                let alert: UIAlertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let alertAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alert.addAction(alertAction)
                self.presentViewController(alert, animated: true, completion: nil)
                }) { (forecast, forecastAPICalls) -> Void in
                    if let numberOfAPICalls: Int = forecastAPICalls {
                        print("\(numberOfAPICalls) forecastIO API calls made today!")
                    }
                    self.forecast = forecast
                    print(self.forecast)
                    self.tableView.reloadData()
                    
            }
        }
        else {
            self.navigationItem.title = "Sorry, can't find you"
            self.tableView.reloadData()
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.navigationItem.title = "Sorry, can't find you"
        isFindingLocation = false
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

        print(error)
    }
    
    // EXTRA EXTRA CREDIT
    // Get the city and state name for the found location using reverse geocoding
    
    func getNameOfLocation( location : CLLocation) -> String {
        
        var locationName : String = ""
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemark, error) -> Void in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
                return
            }
            if placemark!.count > 0 {
                let pm = placemark![0] as CLPlacemark
                locationName = "\(pm.locality!), \(pm.administrativeArea!)"
                self.navigationItem.title = "Forecast for " + locationName
            } else {
                print("Error with data")
            }
        })
        

        return locationName
    }

    // MARK - Actions
    
    @IBAction func reloadLocation() {
        isFindingLocation = true
        self.navigationItem.title = "Finding Location"

        locationManager.requestLocation()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        self.tableView.reloadData()
    }

}
