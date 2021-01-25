//
//  ViewController.swift
//  The Weather Panel
//
//  Created by Daniel Caccia on 23/01/21.
//

import UIKit
import AVKit
import AVFoundation

class WeatherViewController: UIViewController, UITextFieldDelegate, WeatherManagerDelegate, BackgroundManagerDelegate {
    
    @IBOutlet weak var videoLayer: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var tempTypeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    var weatherManager = WeatherManager()
    var backgroundManager = BackgroundManager()
    var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self
        weatherManager.delegate = self
        backgroundManager.delegate = self
        
        infoView.layer.cornerRadius = 5
        infoView.clipsToBounds = true

    }

    @IBAction func locationButtonPressed(_ sender: UIButton) {
    
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //return button function
        searchTextField.endEditing(true)
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type some city..."
            
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let cityName = searchTextField.text, let units = tempTypeLabel.text {
            backgroundManager.fetchBackground(for: cityName)
            weatherManager.fetchWeather(with: units, for: cityName)
        }
        
        searchTextField.text = ""
    }
    
    func didUpdateBackground(_ backgroundManager: BackgroundManager, videoId: Int) {
        DispatchQueue.main.async {
            backgroundManager.getVideoLink(for: videoId)
        }
    }
    
    func didUpdateVideo(_ backgroundManager: BackgroundManager, videoStringURL: String) {
        DispatchQueue.main.async {
            if let videoURL = URL(string: videoStringURL) {
                self.playVideo(with: videoURL)
            }
        }
    }
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.temperatureLabel.text = weather.temperatureString
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func playVideo(with videoURL: URL) {
        let player = AVPlayer(url: videoURL)
        player.isMuted = true
        player.actionAtItemEnd = .none
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        playerLayer.videoGravity = .resizeAspectFill
        
        self.videoLayer.layer.addSublayer(playerLayer)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem
        )
        
        player.play()
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        playerLayer.player?.seek(to: CMTime.zero)
    }
    
}
