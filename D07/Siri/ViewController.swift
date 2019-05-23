//
//  ViewController.swift
//  D07
//
//  Created by Artem KUPRIIANETS on 1/23/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit
import RecastAI
import ForecastIO

class ViewController: UIViewController {
    var bot : RecastAIClient?
    let RECASTAI_TOKEN = "2e4038371c9608cb6fe85505fc255cea"
    let FORECASTIO_TOKEN = "0a244f3c897fc6a2753617903a7bb4ca"
    @IBOutlet weak var itemActivityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var answer: UILabel!
    
    @IBOutlet weak var question: UITextField!

    @IBAction func goButton(_ sender: UIButton) {
        guard let myString = question.text, !myString.isEmpty else { return }
        itemActivityIndicator.startAnimating()
        makeRequest(request : question.text!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        itemActivityIndicator.hidesWhenStopped = true
        self.bot = RecastAIClient(token : RECASTAI_TOKEN, language: "en")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     Make text request to Recast.AI API
     */
    func makeRequest(request: String)
    {
        //Call makeRequest with string parameter to make a text request
        self.bot?.textRequest(request, successHandler: recastRequestDone, failureHandle: processError)
    }
    /**
     Method called when the request was successful
     
     - parameter response: the response returned from the Recast API
     
     - returns: void
     */
    func recastRequestDone(_ response : Response)
    {
        if let location = response.get(entity: "location") {
            answer.text = "Location found : \(location["raw"]!), processing..."
            callForecast(location: location["raw"] as! String, lat: location["lat"] as! Double, lng: location["lng"] as! Double)
        }
        else {
            DispatchQueue.main.async {
                if let fuckoff = response.source?.uppercased(), fuckoff.range(of: "fuck off".uppercased()) != nil {
                    self.answer.text = "You fuck off, cocksucker"
                } else if let fuckoffbitch = response.source?.uppercased(), fuckoffbitch.range(of: "bitch".uppercased()) != nil {
                     self.answer.text = "No, you bitch!"
                } else {
                    self.answer.text = "Sorry, didn't get '\(response.source ?? "it")'. Come again"
                }
                self.itemActivityIndicator.stopAnimating()
            }
        }
    }
    
    func processError(_ err: Error) {
        DispatchQueue.main.async {
            self.answer.text = "Error"
        }
    }
    
    func callForecast(location: String, lat: Double, lng: Double){
        let client = DarkSkyClient(apiKey: FORECASTIO_TOKEN)
        client.units = .si
        
        /*
        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .userInitiated).async {
            // Do long running task here
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                self.friendLabel.text = "You are following \(friendCount) accounts"
            }
        }
        */
        
        
        client.getForecast(latitude: lat, longitude: lng) { result in
            DispatchQueue.main.async {
            switch result {
            case .success(let currentForecast, _):
                //  We got the current forecast!
                self.answer.text = location + " : " + (currentForecast.currently?.summary)! + "\nCurrent temperature : " + String(describing: (currentForecast.currently?.temperature)!) + " °C"
            case .failure(let error):
                Utils.alert(title: "Oops!", message: error.localizedDescription, prefStyle: .alert, handler: nil, vc: self)
                self.answer.text = "Error"
            }
            self.itemActivityIndicator.stopAnimating()
            }
        }
    }
    
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        /*
        if let channel = sender as? Channel {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.senderDisplayName = senderDisplayName
            chatVc.channel = channel
            chatVc.channelRef = channelRef.child(channel.id)
        }
 */
    }
    
    
}

