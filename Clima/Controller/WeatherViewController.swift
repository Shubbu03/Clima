//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController{

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()  // to get access to the user's current location
        locationManager.requestLocation() // to get the location of user's for only one time.
        
        
        weatherManager.delegate = self
        searchTextField.delegate = self
        
    }

    @IBAction func locationPressed(_ sender: UIButton) {
        
        locationManager.requestLocation()
    }
    
}
    
//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate{
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true) // this is used to automatically dismiss the onscreen keyboard after typing
        print(searchTextField.text!)
        
    }
    
    // this below func is used so that we can use the onscreen keyboard for interacting with the app
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(searchTextField.text!)
        searchTextField.endEditing(true)
        return true
    }
    
    // here our viewController gets to decide what happens when user tries to deselct textfield
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        }
        else{
            textField.placeholder = "Type something"
            return false
        }
    }
    
    // this below func is used so that once user has ended writing text in the search box should disappear automatically
    func textFieldDidEndEditing(_ textField: UITextField) {
        // use searchTextField.text to get the weather for that city
        if let city = searchTextField.text{
            weatherManager.fetchWeather(cityName: city)
        }
        
        searchTextField.text = ""
    }
}

extension WeatherViewController:WeatherManagerDelegate{
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        // dispatchqueue is used so if the user's network is slow the data we recieve should be in background so there is something to display
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperature
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }

}
//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager , didUpdateLocations locations: [CLLocation]){
        if let location = locations.last{
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
