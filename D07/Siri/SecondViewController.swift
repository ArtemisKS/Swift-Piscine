//
//  SecondViewController.swift
//  D07
//
//  Created by Artem KUPRIIANETS on 1/23/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit
import RecastAI
import ForecastIO
import JSQMessagesViewController

class SecondViewController: JSQMessagesViewController {
    
    var bot : RecastAIClient?
    let RECASTAI_TOKEN = "2e4038371c9608cb6fe85505fc255cea"
    let FORECASTIO_TOKEN = "0a244f3c897fc6a2753617903a7bb4ca"
    
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bot = RecastAIClient(token : RECASTAI_TOKEN, language: "en")
        // Do any additional setup after loading the view.
        self.senderId = "weatherApp"
        self.senderDisplayName = "You"
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_: Bool) {
        // messages from someone else
        addMessage(withId: "foo", name: "Mr.Bolt", text: "Good day, good sir, weather service at your service")
        addMessage(withId: "foo", name: "Mr.Bolt", text: "What can I do for you today?")
        // messages sent from local sender
        // animates the receiving of a new message on the view
        finishReceivingMessage()
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        addMessage(withId: senderId, name: senderDisplayName, text: text)
        finishReceivingMessage()
        makeRequest(request : text!)


    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
    }
  
    /**
     Make text request to Recast.AI API
     */
    func makeRequest(request: String) {
        //Call makeRequest with string parameter to make a text request
        self.bot?.textRequest(request, successHandler: recastRequestDone, failureHandle: processError)
    }
    
    /**
     Method called when the request was successful
     
     - parameter response: the response returned from the Recast API
     
     - returns: void
     */
    
    func recastRequestDone(_ response : Response) {
        if let location = response.get(entity: "location") {
            callForecast(location: location["raw"] as! String, lat: location["lat"] as! Double, lng: location["lng"] as! Double)
        }
        else {
            DispatchQueue.main.async {
                if let fuckoff = response.source?.uppercased(), fuckoff.range(of: "fuck off".uppercased()) != nil{
                     self.addMessage(withId: "foo", name: "Mr.Bolt", text: "You fuck off, cocksucker")
                } else if let fuckoffbitch = response.source?.uppercased(), fuckoffbitch.range(of: "bitch".uppercased()) != nil {
                    self.addMessage(withId: "foo", name: "Mr.Bolt", text: "No, you bitch!")
                } else {
                    self.addMessage(withId: "foo", name: "Mr.Bolt", text: "Sorry, didn't get '\(response.source ?? "it")'. Come again")
                }
                // messages sent from local sender
                // animates the receiving of a new message on the view
                self.finishReceivingMessage()
            }
        }
    }
    
    func processError(_ err: Error) {
        DispatchQueue.main.async {
            self.addMessage(withId: "foo", name: "Mr.Bolt", text: "Error")
            // messages sent from local sender
            // animates the receiving of a new message on the view
            self.finishReceivingMessage()        }
    }
    
    func callForecast(location: String, lat: Double, lng: Double) {
        let client = DarkSkyClient(apiKey: FORECASTIO_TOKEN)
        client.units = .si
        
        client.getForecast(latitude: lat, longitude: lng) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let currentForecast, _):
                    let text = location + " : " + (currentForecast.currently?.summary)! + "\nCurrent temperature : " + String(describing: (currentForecast.currently?.temperature)!) + " °C"
                    self.addMessage(withId: "foo", name: "Mr.Bolt", text: text)
                    // messages sent from local sender
                    // animates the receiving of a new message on the view
                    self.finishReceivingMessage()
                case .failure(let error):
                    Utils.alert(title: "Oops!", message: error.localizedDescription, prefStyle: .alert, handler: nil, vc: self)
                    self.addMessage(withId: "foo", name: "Mr.Bolt", text: "Error")
                    // messages sent from local sender
                    // animates the receiving of a new message on the view
                    self.finishReceivingMessage()
                }
            }
        }
    }
}
