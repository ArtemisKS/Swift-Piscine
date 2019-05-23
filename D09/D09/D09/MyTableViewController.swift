//
//  ViewController.swift
//  day09
//
//  Created by Artem KUPRIIANETS on 1/26/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit
import LocalAuthentication
import akupriia2019

final class MyCell:UITableViewCell {
    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var myImageView:UIImageView!
    @IBOutlet var contentLabel:UILabel!
    @IBOutlet var creationLabel:UILabel!
    @IBOutlet var modificationLabel:UILabel!
}

final class MyTableViewController: UITableViewController {
    
    lazy var articles:[Article] = {
        let lang = Locale.current.languageCode
        if let l = lang {
            return ArticleManager.shared.getArticles(withLang: l)
        }
        return ArticleManager.shared.getAllArticles()
    }()
    
    var signedIn = false {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    lazy var formatter:DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .medium
        f.dateStyle = .medium
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Diary", comment: "")
        
        signIn()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func signIn() {
        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: NSLocalizedString("We won't let you in otherwise ;)", comment: "")) { (success, error) in
            if (error != nil) || !success {
                self.signIn()
            }
            else {
                self.signedIn = true
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if signedIn {
            return articles.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! MyCell
        let a = articles[indexPath.row]
        cell.titleLabel.text = a.title
        cell.contentLabel.text = a.content
        cell.creationLabel.text = formatter.string(from: a.creationDate! as Date)
        if (a.creationDate != a.modificationDate) {
            cell.modificationLabel.text = "Modified: \(formatter.string(from: a.modificationDate! as Date))"
        }
        else {
            cell.modificationLabel.text = nil
        }
        if let d = a.image {
            cell.myImageView.image = UIImage(data: d as Data)
        }
        else {
            cell.myImageView.image = nil
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
        viewC.article = articles[indexPath.row]
        viewC.tableC = self
        navigationController?.pushViewController(viewC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            articles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    @IBAction func add(_ sender: UIBarButtonItem) {
        let viewC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArticleViewController") as! ArticleViewController
        viewC.tableC = self
        navigationController?.pushViewController(viewC, animated: true)
    }
    
}

