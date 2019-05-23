//
//  ThemesViewController.swift
//  Rush00
//
//  Created by Artem KUPRIIANETS on 4/6/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit

class ThemesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var apiController: APIController?
    let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        ai.color = .red
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    @IBAction func addTopic(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addTopic", sender: nil)
    }
    @IBOutlet weak var tableview: UITableView!

    var topics: [TopicObtainer]?
    var chosenTopic: TopicObtainer?
    
    let deleteAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete your topic ?.", preferredStyle: UIAlertControllerStyle.alert)
    let editAlert = UIAlertController(title: "Edit", message: "Are you sure you want to edit your topic ?", preferredStyle: UIAlertControllerStyle.alert)
    let accessDenied = UIAlertController(title: "ACCESS DENIED", message: "You don't have the rights", preferredStyle: UIAlertControllerStyle.alert)
    
    func makeAlerts() {
        accessDenied.addAction(UIAlertAction(title: "OK", style: .default, handler:{ (action) in }))
        deleteAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            guard let topic = self.chosenTopic else {
                return
            }
            self.apiController?.deleteTopic(topic: topic){ _ in
                self.updateTopics()
            }
        }))
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in }))
        editAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in }))
        editAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in }))
    }

    @objc func handleRefresh(_ updateContr: UIRefreshControl) {
        updateTopics()
        updateContr.endRefreshing()
    }
    
    lazy var updateContr: UIRefreshControl = {
        let updateContr = UIRefreshControl()
        updateContr.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        updateContr.tintColor = UIColor.red

        return updateContr
    }()

    @IBAction func logout(_ sender: UIButton) {
        performSegue(withIdentifier: "unwind_to_login_segue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "messages_segue") {
            if let vc = segue.destination as? MessagesTableViewController {
                let indexPath = self.tableview.indexPathForSelectedRow!
                vc.title = topics![indexPath.row].name;
                vc.topic = topics![indexPath.row]
                vc.apiController = self.apiController
            }
        }
        else if (segue.identifier == "addTopic") {
            if let addTopicVC = segue.destination as? AddTopicViewController {
                addTopicVC.apiController = self.apiController
            }
        }
        else if (segue.identifier == "updateTopic") {
            if let updateTopicVC = segue.destination as? AddTopicViewController {
                let topic = sender as? TopicObtainer
                updateTopicVC.apiController = self.apiController
                updateTopicVC.topic = topic
            }
        }
    }


    func updateTopics() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true;
            self.activityIndicator.hidesWhenStopped = true;
            self.activityIndicator.startAnimating();
        }
        apiController?.topics(sort: "-updated_at") { data in
            let topics: [TopicObtainer]? = Utils.decodeData(data: data)
            self.topics = topics
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                self.activityIndicator.stopAnimating();
                self.tableview.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(activityIndicator)
     
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.tableview.estimatedRowHeight = 300
        self.tableview.rowHeight = UITableViewAutomaticDimension
        makeAlerts()
        self.tableview.addSubview(self.updateContr)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated:true);
        if apiController?.login != nil {
            updateTopics()
        } else {
            apiController?.me() { _ in
                self.updateTopics()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            guard var topics = topics else { return }
            topics.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)

        }
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let topic = topics![indexPath.row]
        chosenTopic = topic

        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action, indexPath) in
            if self.apiController?.login! != topic.author.login{
                self.present(self.accessDenied, animated: true, completion:  nil)
            }
            else {
                self.performSegue(withIdentifier: "updateTopic", sender: topic)
            }
        })
        editAction.backgroundColor = UIColor.blue

        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            if self.apiController?.login! != topic.author.login {
                self.present(self.accessDenied, animated: true, completion:  nil)
            }
            else {
                self.present(self.deleteAlert, animated: true, completion: nil)
            }
        })
        deleteAction.backgroundColor = UIColor.red
        return [editAction, deleteAction]
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let topic = topics else { return 0 }
        return topic.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "topics_cell") as! ThemesTableViewCell
        cell.tag = indexPath.row
        cell.author.text = topics![indexPath.row].author.login
        cell.date.text = topics![indexPath.row].created_at.forumTimeFormat
        cell.title.text = topics![indexPath.row].name

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tableCell = tableview?.cellForRow(at: indexPath) as! ThemesTableViewCell
        if (tableCell.author != nil) {
            performSegue(withIdentifier: "messages_segue", sender: indexPath.row);
        }
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
