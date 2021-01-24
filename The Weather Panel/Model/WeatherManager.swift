//
//  WeatherManager.swift
//  The Weather Panel
//
//  Created by Daniel Caccia on 24/01/21.
//

import Foundation

struct WeatherManager {
    
    let baseURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(K.apiKey)"
    
    func fetchWeather(with units: String, for cityName: String) {
        let useUnits = (units == "˚C") ? K.celsius : K.fahrenheit
        
        let urlString = "\(baseURL)&units=\(useUnits)&q=\(cityName)"
        performRequest(using: urlString)
    }
    
    func performRequest(using urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler: handle(data:response:error:))
            
            task.resume()
        }
    }
    
    func handle(data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            print(error!)
            return
        }

        if let safeData = data {
            print(String(data: safeData, encoding: .utf8)!)
        }
    }
}
