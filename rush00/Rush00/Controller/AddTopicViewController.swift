//
//  InsertTopicViewController.swift
//  Rush00
//
//  Created by Artem KUPRIIANETS on 4/6/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit

class AddTopicViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var topicName: UITextField!
    var doneButton: UIBarButtonItem?
    
    var apiController: APIController?
    var topic: TopicObtainer?
    
    
    let shOpacity: Float = 0.3
    let shRadius: CGFloat = 3.0
    let bordWidth: CGFloat = 1.5
    let cornerRadius: CGFloat = 2.0
    let bordColor: CGColor = UIColor.red.cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneAction))
        navigationItem.rightBarButtonItem = doneButton
        doneButton!.isEnabled = false
        estTextFields()
        if let existingTopic = topic {
            topicName.text = existingTopic.name
            doneButton!.isEnabled = true
        }
    }
    
    func estTextFields() {
        textView.clipsToBounds = true
        topicName.clipsToBounds = true
        Utils.setViewProps(for: textView, bordWidth: bordWidth, shColor: UIColor.purple.cgColor, borderColor: bordColor, shOpacity: shOpacity, shRadius: shRadius, cornerRadius: cornerRadius, shOffset: CGSize(width: 1, height: 1))
        textView.isScrollEnabled = true
        
        
        topicName.placeholder = "Name"
        Utils.setViewProps(for: topicName, bordWidth: bordWidth, shColor: UIColor.purple.cgColor, borderColor: bordColor, shOpacity: shOpacity, shRadius: shRadius, cornerRadius: cornerRadius, shOffset: CGSize(width: 0, height: 0))
        
        
        textView.delegate = self
        topicName.addTarget(self, action: #selector(editingHasStarted), for: .editingChanged)
    }
    
    @objc func textViewDidChange(_ textView: UITextView) {
        editingHasStarted()
    }
    
    @objc func didTapView(gesture: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func editingHasStarted(){
        if let tvText = textView.text, let tnText = topicName.text, !tvText.isEmpty, !tnText.isEmpty {
            doneButton!.isEnabled = true
        } else if (topic == nil) {
            doneButton!.isEnabled = false
        }
    }

    @objc func doneAction() {
        if var topicToUpdate = self.topic {
            topicToUpdate.name = topicName.text!
            updateTopic(topic: topicToUpdate)
        } else {
            createTopic()
        }
    }
    
    func createTopic() {
        guard let apiController = self.apiController, let author_id = apiController.author_id else {
            self.navigationController?.popViewController(animated: true)
            return
        }

        let message = Message(author_id: String(author_id), content: textView.text, messageable_id: "1", messageable_type: "Topic")
        let TopicStr = TopicStruct(author_id: String(author_id), cursus_ids: ["1"], kind: "normal", language_id: "1", messages_attributes: [message], name: topicName.text!, tag_ids: ["5"])
        let TopicStrHandler = TopicStructHandler(topic: TopicStr)
        
        doneButton?.isEnabled = false
        apiController.createTopic(topicCreate: TopicStrHandler) { data in
            if let _: TopicObtainer = Utils.decodeData(data: data) {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                DispatchQueue.main.async {
					Utils.alert(title: "Oops!", message: "Topic could not be created", prefStyle: .alert, vc: self, handler: nil) {
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
							self.navigationController?.popViewController(animated: true)
						})
					}
                }
            }
        }
    }
    
    func updateTopic(topic: TopicObtainer) {
        doneButton?.isEnabled = false
        apiController?.updateTopic(topic: topic) { data in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
