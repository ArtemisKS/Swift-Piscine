//
//  TextTableViewController.swift
//  Rush00
//
//  Created by Artem KUPRIIANETS on 4/6/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit

class MessagesTableViewController: UITableViewController, UITextFieldDelegate {


    var apiController: APIController?
    var topic: TopicObtainer?

    @IBOutlet weak var messageField: UITextField!
    var selectedMessage: MessageObtainer?
    var messages: [MessageObtainer]?
    var changedMessages : [MessageObtainer] = []
    
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        ai.color = .red
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    @IBOutlet weak var indicatorView: UIView!

    func alter_messages(messages: [MessageObtainer]) -> [MessageObtainer] {
        changedMessages = messages
        var array : [MessageObtainer] = []
        for (count, message) in changedMessages.enumerated() {
            array.append(message)
            array[count].replies.insert(message, at:0)
        }
        return array
    }
    
    func reloadMessages() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true;
            self.activityIndicator.hidesWhenStopped = true;
            self.activityIndicator.startAnimating();
        }
		guard let topic =  self.topic else { Utils.alert(title: "Oops!", message: "Topic is not found", prefStyle: .alert, vc: self, handler: nil); return }
        apiController?.topicMessages(topic: topic) { data in
            let messagesArray: [MessageObtainer]? = Utils.decodeDataArray(data: data)
            guard let messages = messagesArray else {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                    self.activityIndicator.stopAnimating();
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                return
            }
            self.messages = messages
            self.changedMessages = self.alter_messages(messages: messages)
            DispatchQueue.main.async {
                self.messageField.isHidden = false
                UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                self.activityIndicator.stopAnimating();
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "editMessageSegue") {
            if let editMessageVC = segue.destination as? EditMessageViewController {
                if let messageCell = sender as? MessageTableViewCell, let messages = messages {
					for message in messages {
						if let text = messageCell.message.text, message.content == text {
							selectedMessage = message
							break
						}
					}
				}
                editMessageVC.apiController = self.apiController
                editMessageVC.message = selectedMessage
                editMessageVC.topic = topic
            }
        }
    }
    
    private func makeMessageRequest(author_id: Int, topic_id: Int, content: String) {
        let message = Message(
            author_id: String(author_id),
            content: content,
            messageable_id: String(topic_id),
            messageable_type: "Topic")
        let messageHandler = MessageCreationHandler(id: String(topic_id), message: message)
        
        apiController?.createMessage(messageCreate: messageHandler) {
            d in
            print(String(data: d, encoding: .utf8)!)
            self.reloadMessages()
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let author_id = apiController?.author_id, let topic_id = topic?.id, let text = messageField.text else {
            return true
        }
        
        makeMessageRequest(author_id: author_id, topic_id: topic_id, content: text)
        
        messageField.text = ""
        return true
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        reloadMessages()
        refreshControl.endRefreshing()
    }
    
    private func setupActInd(activityIndicator: UIActivityIndicatorView, toView view: UIView) {
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.hidesWhenStopped = true;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl?.tintColor = UIColor.red
        UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        view.addSubview(activityIndicator)
        setupActInd(activityIndicator: activityIndicator, toView: view)
        activityIndicator.startAnimating();
        
        messageField.isHidden = true
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
        
        messageField.delegate = self
        tableView.keyboardDismissMode = .onDrag
//        tableView.keyboardDismissMode = .interactive
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if apiController?.login != nil {
            reloadMessages()
        } else {
            apiController?.me() { _ in
                self.reloadMessages()
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return changedMessages.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return changedMessages[section].replies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messagecell", for: indexPath) as! MessageTableViewCell
        cell.author.text = changedMessages[indexPath.section].replies[indexPath.row]!.author.login
        cell.date.text = changedMessages[indexPath.section].replies[indexPath.row]!.created_at.forumTimeFormat
        if (indexPath.row != 0){
            cell.author.text = "-> " + cell.author.text!
        }
        cell.message.text = changedMessages[indexPath.section].replies[indexPath.row]!.content
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        view.frame = CGRect(x: 0, y: 0, width: 400, height: 100)
        let auth_label = UILabel()
        auth_label.text = messages![section].author.login
        auth_label.textColor = UIColor.orange
        auth_label.adjustsFontSizeToFitWidth = true
        auth_label.frame = CGRect(x: 10, y: 1, width: 300, height: 30)
        view.addSubview(auth_label)
        return view
    }
}
