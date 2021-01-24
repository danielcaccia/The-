//
//  WeatherManager.swift
//  The Weather Panel
//
//  Created by Daniel Caccia on 24/01/21.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    let baseURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(K.apiKey)"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(with units: String, for cityName: String) {
        let useUnits = (units != "˚C") ? K.fahrenheit : K.celsius
        let useCityName = cityName.replacingOccurrences(of: " ", with: "%20")
        
        let urlString = "\(baseURL)&units=\(useUnits)&q=\(useCityName)"
        
        performRequest(using: urlString)
    }
    
    func performRequest(using urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    
                    return
                }

                if let safeData = data {
                    if let weather = self.parseJSON(with: safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(with weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            return WeatherModel(conditionId: id, cityName: name, temperature: temp)
        } catch {
            self.delegate?.didFailWithError(error: error)
            
            return nil
        }
    }
    
}
