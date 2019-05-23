//
//  AlterTextViewController.swift
//  Rush00
//
//  Created by Artem KUPRIIANETS on 4/6/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit

class EditMessageViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var inputField: UITextView!
    
    var message : MessageObtainer?
    var topic: TopicObtainer?
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    let shOpacity: Float = 0.3
    let shRadius: CGFloat = 3.0
    let bordWidth: CGFloat = 1.5
    let cornerRadius: CGFloat = 2.0
    let bordColor: CGColor = UIColor.red.cgColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        inputField.text = message?.content
        navigationItem.rightBarButtonItem = doneButton
        doneButton!.isEnabled = false
        estTextFields()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButton(_ sender: Any) {
        message?.content = inputField.text
        guard let author_id = apiController?.author_id else {
            return
        }
        guard let topic_id = topic?.id else {
            return
        }
        guard let message_id = message?.id else {
            return
        }
        let updatedMessage = Message(
            author_id: String(author_id),
            content: (self.message?.content)!,
            messageable_id: String(topic_id),
            messageable_type: "Topic")
        let messageCreationHandler = MessageCreationHandler(id: String(message_id), message: updatedMessage)
        apiController?.updateMessage(message: messageCreationHandler) {
            d in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    var apiController: APIController?
    
    func estTextFields() {
        inputField.textInputView.clipsToBounds = true
        Utils.setViewProps(for: inputField, bordWidth: bordWidth, shColor: UIColor.purple.cgColor, borderColor: bordColor, shOpacity: shOpacity, shRadius: shRadius, cornerRadius: cornerRadius, shOffset: CGSize(width: 1, height: 1))
        self.inputField.delegate = self
    }
    
    @objc func textViewDidChange(_ textView: UITextView) {
        if !inputField.text.isEmpty {
            doneButton!.isEnabled = true
        } else {
            doneButton!.isEnabled = false
        }
    }
    
    @objc func didTapView(gesture: UITapGestureRecognizer){
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
