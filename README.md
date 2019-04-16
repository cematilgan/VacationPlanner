# VacationPlanner

Vacation planner is an iOS app that allows users to search and pin points of interest on a map and save them with customized notes and tags to create personal vacation itineraries. The app integrates with Google Maps and consumes Google Places and Foursquare REST APIs for POI reviews and details. The codebase follows MVC pattern and network requests are handled using Alamofire and SwiftyJSON for convenience. The UI is built using storyboards and autolayout. Persistance is handled by serializing the model using the Codable protocol.

## Getting Started

### Install dependencies

Download the repository and run the .xcworkspace file to launch the project. If you encounter any issues, please make sure you have the latest version of [Cocoapods](https://github.com/CocoaPods/CocoaPods) installed in your system already.

To install Cocoapods, open the terminal and run the following command

```
sudo gem install cocoapods
```

Once you have Cocoapods installed, go to the project directory install the added dependencies by running the following command.

```
pod install
```

Now you can run the .xcworkspace file to launch the app.

### Setup API keys

This app uses data from Google Maps API, Google Places API and Foursquare Places API, so you must have valid API keys in order to use their service.

Edit the `Utilities/Keys.swift` and replace your API keys with `<YOUR-API-KEY>`.

```swift
enum Keys {
    static let googleKey = "<YOUR-API-KEY>"
    static let foursquareClienId = "<YOUR-API-KEY>"
    static let foursquareClientSecret = "<YOUR-API-KEY>"
}

```

### Backlog
- Geofencing for added places
- Displaying photos of the places

### Requirements
- Runs on iOS 12.0 or above 
- Optimized for screen sizes of iPhone 6 or newer 

