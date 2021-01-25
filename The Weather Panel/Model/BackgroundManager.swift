//
//  ImageManager.swift
//  The Weather Panel
//
//  Created by Daniel Caccia on 24/01/21.
//

import Foundation

protocol BackgroundManagerDelegate {
    func didUpdateBackground(_ backgroundManager: BackgroundManager, videoId: Int)
    func didUpdateVideo(_ backgroundManager: BackgroundManager, videoStringURL: String)
    func didFailWithError(error: Error)
}

struct BackgroundManager {
    
    var delegate: BackgroundManagerDelegate?
    
    func fetchBackground(for cityName: String) {
        let searchURL = "https://api.pexels.com/videos/search?orientation=landscape&size=small&per_page=5"
        
        let useCityName = cityName.replacingOccurrences(of: " ", with: "%20")
        let urlString = "\(searchURL)&query=\(useCityName)"
        
        performSearchRequest(using: urlString)
    }
    
    func getVideoLink(for id: Int) {
        let urlString = "https://api.pexels.com/videos/videos/\(id)"
        
        performVideoRequest(using: urlString)
    }
    
    func performSearchRequest(using urlString: String) {
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(K.backgroundAPIKey, forHTTPHeaderField: "Authorization")
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    
                    return
                }
                
                if let safeData = data {
                    if let videoId = self.parseSearchJSON(with: safeData) {
                        self.delegate?.didUpdateBackground(self, videoId: videoId)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func performVideoRequest(using urlString: String) {
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(K.backgroundAPIKey, forHTTPHeaderField: "Authorization")
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    
                    return
                }
                
                if let safeData = data {
                    if let videoStringURL = self.parseVideoJSON(with: safeData) {
                        self.delegate?.didUpdateVideo(self, videoStringURL: videoStringURL)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseSearchJSON(with backgroundData: Data) -> Int? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(BackgroundData.self, from: backgroundData)
           
            if !decodedData.videos.isEmpty {
                let index = Int.random(in: 0..<decodedData.videos.count)
                let id = decodedData.videos[index].id
                
                return id
            } else {
                return K.defaultBackground
            }
        } catch {
            self.delegate?.didFailWithError(error: error)
            
            return nil
        }
    }
    
    func parseVideoJSON(with backgroundData: Data) -> String? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(VideoAddress.self, from: backgroundData)
            let videoURL = decodedData.video_files[0].link
            
            return videoURL
        } catch {
            self.delegate?.didFailWithError(error: error)
            
            return nil
        }
    }
    
}
