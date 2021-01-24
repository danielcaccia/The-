//
//  WeatherModel.swift
//  The Weather Panel
//
//  Created by Daniel Caccia on 24/01/21.
//

import Foundation

struct WeatherModel {
    
    let conditionId: Int
    let cityName: String
    let temperature: Double
    
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    
    var conditionName: String {
        switch conditionId {
        case 200...202:
            return K.tsRain
        case 203...221:
            return K.ts
        case 222...232:
            return K.tsRain
        case 233...322:
            return K.drizzle
        case 500, 522:
            return K.lightRain
        case 523...531:
            return K.heavyRain
        case 600, 620:
            return K.lightSnow
        case 601, 602, 621, 622:
            return K.snow
        case 611...616:
            return K.sleet
        case 701...741:
            return K.fog
        case 800:
            return K.clear
        case 801...804:
            return K.cloud
        default:
            return K.clear
        }
    }

}
