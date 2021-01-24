//
//  WeatherData.swift
//  The Weather Panel
//
//  Created by Daniel Caccia on 24/01/21.
//

import Foundation

struct WeatherData: Codable {
    
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let id: Int
}
