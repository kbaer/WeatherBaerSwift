//
//  AppDelegate.swift
//  WeatherBaerSwift
//
//  Created by Ken Baer on 1/28/16.
//  Copyright © 2016 BaerCode. All rights reserved.
//

import UIKit
import ForecastIOClient
import EventKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var eventStore: EKEventStore?
    var reminderCalendar: EKCalendar?
    
    var dateFormatter: DateFormatter = DateFormatter()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ForecastIOClient.apiKey = "ed0c3f8a1d3bcee7fcbf67c1eb599d3d"
        ForecastIOClient.units = Units.Us
        
        dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4
        dateFormatter.dateFormat = "M/d"
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        self.setReminder(self) // set a reminder for 10 minutes from now
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setReminder(_ sender: AnyObject) {
        
        if eventStore == nil {
            eventStore = EKEventStore()
            eventStore!.requestAccess(
                to: EKEntityType.reminder, completion: {(granted, error) in
                    if !granted {
                        print("Access to store not granted")
                    } else {
                        print("Access granted")
                    }
            })
        }
        
        if (eventStore != nil) {
            self.retrieveMyCalendar()
            self.createReminder()
        }
    }
    
    func retrieveMyCalendar() {
        let calendars = eventStore!.calendars(for: EKEntityType.reminder)
        
        if(reminderCalendar == nil) {
            for calendar in calendars {
                if calendar.title == "Reminders" {
                    reminderCalendar = (calendar as EKCalendar)
                    break
                }
            }
            
            if(reminderCalendar == nil) {
                reminderCalendar = EKCalendar(for: EKEntityType.reminder, eventStore: eventStore!)
                reminderCalendar!.title = "Reminders"
                reminderCalendar!.source = eventStore!.defaultCalendarForNewReminders().source
                
                do {
                    try eventStore!.saveCalendar(reminderCalendar!, commit: true)
                } catch _ {
                    print("reminder calendar not saved")
                }
            }
        }
    }

    func createReminder() {
        
        let reminder = EKReminder(eventStore: self.eventStore!)
        
        reminder.title = "Check the latest forecast on the WeatherBaer app"
        reminder.calendar = reminderCalendar!
        let dueDate: Date = Date(timeIntervalSinceNow: 10 * 60) // 10 minutes from now
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        let unitFlags = NSCalendar.Unit(rawValue: UInt.max)
        reminder.dueDateComponents = (gregorian as NSCalendar?)?.components(unitFlags, from: dueDate)
        reminder.priority = 4
        
        let alarm = EKAlarm(relativeOffset: 0)
        reminder.addAlarm(alarm)
        
        do {
            try eventStore!.save(reminder, commit: true)
        } catch _ {
            print("Reminder failed")
        }
    }

}

