//
//  BackgroundData.swift
//  The Weather Panel
//
//  Created by Daniel Caccia on 25/01/21.
//

import Foundation

struct BackgroundData: Codable {
    
    let videos: [Videos]
    
}

struct VideoAddress: Codable {

    let video_files: [VideoFiles]
    
}

struct Videos: Codable {
    
    let id: Int

}

struct VideoFiles: Codable {
    
    let link: String
    
}
