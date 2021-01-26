//
//  ViewController.swift
//  The Weather Panel
//
//  Created by Daniel Caccia on 23/01/21.
//

import UIKit
import AVFoundation
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var videoLayer: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var tempTypeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    var weatherManager = WeatherManager()
    var backgroundManager = BackgroundManager()
    var playerLayer = AVPlayerLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self
        weatherManager.delegate = self
        backgroundManager.delegate = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        setLayout()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let cityName = cityLabel.text {
            backgroundManager.fetchBackground(for: cityName)
        }
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        locationManager.requestLocation()
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
    
    func setLayout() {
        infoView.layer.cornerRadius = 5
        infoView.clipsToBounds = true
        
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter the City Name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
    }
    
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
  
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            textField.placeholder = "Enter the City Name"
            
            return true
        } else {
            textField.placeholder = "Type some city..."
            
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let cityName = searchTextField.text, let units = tempTypeLabel.text {
            weatherManager.fetchWeather(with: units, for: cityName)
        }
        
        searchTextField.text = ""
    }
    
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.temperatureLabel.text = weather.temperatureString
            self.cityLabel.text = weather.cityName
            
            self.backgroundManager.fetchBackground(for: weather.cityName)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
}

//MARK: - BackgroundManagerDelegate

extension WeatherViewController: BackgroundManagerDelegate {
    
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
    
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last, let units = tempTypeLabel.text {
            locationManager.stopUpdatingLocation()
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude

            weatherManager.fetchWeather(with: units, latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
