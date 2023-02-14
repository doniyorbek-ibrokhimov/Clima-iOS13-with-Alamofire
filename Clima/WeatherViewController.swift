//
//  ViewController.swift
//  Clima
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

//MARK: - WeatherDataModel
// Step 5
class WeatherDataModel {
    var temperature: Int = 0
    var condition: Int = 0
    var city : String = ""
    var weatherIconName : String = ""
    
    func updateWeatherIcon(condition: Int) -> String {
        
    switch (condition) {
    
        case 0...300 :
            return "tropicalstorm"
        
        case 301...500 :
            return "cloud.rain"
        
        case 501...600 :
            return "cloud.heavyrain.fill"
        
        case 601...700 :
            return "snowflake"
        
        case 701...771 :
            return "cloud.fog"
        
        case 772...799 :
            return "tropicalstorm.circle.fill"
        
        case 800 :
            return "sun.min"
        
        case 801...804 :
            return "cloud"
        
        case 900...903, 905...1000  :
            return "tropicalstorm.circle"
        
        case 903 :
            return "cloud.snow"
        
        case 904 :
            return "sun.max"
        
        default :
            return "dunno"
        }

    }
}

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var changeCityTextField: UITextField!
    
    // MARK: - Credentions
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "4fe76d6d3ca3d145536320183e9e51a0"
    
    //MARK: - Instances
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Step 1
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // add two key values in info.plist
        // add code for fix for app transport security override
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    

    
    //MARK: - JSON Parsing
    // Step 6
    func updateWeatherData(json: JSON) {
        
        // main.temp
        if let tempResult = json["main"]["temp"].double {
            
            // from kelvin to celcius
            weatherDataModel.temperature = Int(tempResult - 273.15)
            
            // name
            weatherDataModel.city = json["name"].stringValue
            
            // weather[0].id
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
    }
    
    //MARK: - NETWORKING
    // Step 4
    func getWeatherData(url: String, parameters: [String : String]) {
 
        AF.request(url, method: .get, parameters: parameters).responseJSON { response in
            
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON : JSON = JSON(response.value!)
//                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
                
            } else {
                print("ERROR \(response.error)")
                self.cityLabel.text = "Connection issues"
            }
            
        }
    }
    
    // MARK: - Location Manager
    
    // Step 2
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // show telegram location as an example
        let location = locations[locations.count-1]
        
//        print("Horizontal Accuracy: \(location.horizontalAccuracy)")
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            //            print("long = \(location.coordinate.longitude) lat = \(location.coordinate.latitude)")
            locationManager.delegate = nil
            

            
            let latitude = String(location.coordinate.latitude)
            let longtitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longtitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    // Step 3
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location unavailable"
    }
    
    //MARK: - UI Updates
    // Step 7
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(systemName: weatherDataModel.weatherIconName)
    }
    
    // Step 8
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        let cityName = changeCityTextField.text!
        let params : [String : String] = ["q" : cityName, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
}

