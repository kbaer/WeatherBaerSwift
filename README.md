# WeatherBaerSwift

I created this app as part of a job interview.  I was presented with following challenge, and knocked out this quick app in
response.

Pick the informative API (think news feed or weather alerts) of your choice and build an app that 

1. Displays the 10 most recent entries for that API
2. Allows a user to tap on an entry to receive more detailed information about that entry
3. Schedules an alert for 10 minutes after a user closes the app that reminds the user to check this feed
4. Bonus points for having the API be location-based

The app is called WeatherBaer.  It is a weather forecast app that uses the Forecast.io API and displays a list of the forecast summary for the upcoming 8 (yes, I know it asked for 10, but the API just does an 8 day forecast) day forecast of the user's current location city.  And yes, I did step 4.  I also used reverse geo-coding to display the city and state names of that location.  I'm rather proud of that one.  Tapping on a row with push to a detail view that shows the low and high temperatures, the full summary, and sunrise and sunset times on that day.  It also implements step 3 and uses EventKit to save a reminder that you can view with the Reminders app.  This will be triggered when you press the home button to close the app.
