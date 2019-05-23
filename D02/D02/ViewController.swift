//
//  ViewController.swift
//  D02
//
//  Created by Artem KUPRIIANETS on 1/17/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//


import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var pages: [Page] = [
        Page(name:"Vladimir Vladimirovich", desc: "Former KGB cunt\ntsar of Russia", deathDate: Date(timeIntervalSinceNow: 3600))!,
        Page(name:"Addie Hitler", desc: "Also placed him here\nIn case he's not dead", deathDate: Date(timeIntervalSinceNow: 3600))!,
        Page(name:"2PAC", desc: "Pretty sure this guy's dead\n so no harm done", deathDate: Date(timeIntervalSinceNow: 3600))!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DeathBookTableView.rowHeight = UITableViewAutomaticDimension
        DeathBookTableView.estimatedRowHeight = 140
    }

    @IBOutlet weak var DeathBookTableView: UITableView! {
        didSet {
            DeathBookTableView.delegate = self
            DeathBookTableView.dataSource = self
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Death Book"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"
        let convertedDate: String = dateFormatter.string(from: self.pages[indexPath.row].deathDate)
        
        let cellIdentifier = "PageTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PageTableViewCell  else {
            fatalError("The cell is not an instance of PageTableViewCell.")
        }
        cell.title?.text = self.pages[indexPath.row].name
        cell.deathDate?.text = convertedDate
        cell.detail?.text = self.pages[indexPath.row].desc
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete {
            pages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! NewPageViewController
        if segue.identifier == "newPage"{
            vc.navigationItem.title = "Add a person"
        } else if segue.identifier == "editPage" {
            if let selectedCell = sender as? PageTableViewCell {
                let indexPath = DeathBookTableView.indexPath(for: selectedCell)!
                let selectedItem = pages[indexPath.row]
                vc.navigationItem.title = "editPage"
                vc.page = selectedItem
            }
        }
    }
    
    @IBAction func unwindToSegue (segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? NewPageViewController, let page = sourceViewController.page {
            if let selectedIndexPath = DeathBookTableView.indexPathForSelectedRow {
                pages[selectedIndexPath.row] = page
                DeathBookTableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            } else {
                let newIndexPath = IndexPath(row: pages.count, section: 0)
                pages.append(page)
                DeathBookTableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
}
