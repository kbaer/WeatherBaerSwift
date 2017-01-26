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

    fileprivate var locationManager: CLLocationManager = CLLocationManager()
    fileprivate var geoCoder: CLGeocoder = CLGeocoder()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        isFindingLocation = true
        locationManager.requestLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var  preferredStatusBarStyle : UIStatusBarStyle {
        
        return UIStatusBarStyle.lightContent
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFindingLocation || isLoadingForecast {
            return 0
        }
        else { // Note: The spec called for 10 rows of data, but the API returns 8 days in the forecast
            return 8
        }
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "DayForecast", for: indexPath)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        if let _ = forecast?.daily?.data![indexPath.row].time {
            // convert the daily date from seconds to NSDate, then display it in MM/DD format
            let time : TimeInterval = TimeInterval(forecast!.daily!.data![indexPath.row].time)
            let date : Date = Date(timeIntervalSince1970:time)
            
            cell.textLabel!.text = appDelegate.dateFormatter.string(from: date) + " " + (forecast?.daily?.data![indexPath.row].summary)!
        }
        
        return cell
    }

    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: false)
        
        selectedDayForecast = forecast?.daily?.data![indexPath.row]
        
        self.performSegue(withIdentifier: "DailyDetails", sender: self)

    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "DailyDetails" {
            let vc : DetailViewController! = segue.destination as! DetailViewController
            vc.dayForecast = selectedDayForecast
        }
    }

    // MARK: - Location
    
    // EXTRA CREDIT
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        isFindingLocation = false
        // Retrieve current forecast
        if locations.count > 0 {
            
            guard let first = locations.first else { return }
            self.setNameOfLocation(first)
            
            let latitude = locations.first!.coordinate.latitude
            let longitude = locations.first!.coordinate.longitude
            
            ForecastIOClient.sharedInstance.forecast(latitude, longitude: longitude, failure: { (error) in
                let alert: UIAlertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                let alertAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                }) { (forecast, forecastAPICalls) -> Void in
                    if let numberOfAPICalls: Int = forecastAPICalls {
                        print("\(numberOfAPICalls) forecastIO API calls made today!")
                    }
                    self.forecast = forecast
                    print(self.forecast as Any)
                    self.tableView.reloadData()
                    
            }
        }
        else {
            self.navigationItem.title = "Sorry, can't find you"
            self.tableView.reloadData()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.navigationItem.title = "Sorry, can't find you"
        isFindingLocation = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        print(error)
    }
    
    // EXTRA EXTRA CREDIT
    // Get the city and state name for the found location using reverse geocoding
    
    func setNameOfLocation( _ location : CLLocation) {
        
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
        

        return
    }

    // MARK - Actions
    
    @IBAction func reloadLocation() {
        isFindingLocation = true
        self.navigationItem.title = "Finding Location"

        locationManager.requestLocation()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        self.tableView.reloadData()
    }

}
