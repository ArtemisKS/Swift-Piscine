//
//  NewPageViewController.swift
//  D02
//
//  Created by Artem KUPRIIANETS on 1/17/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit

class NewPageViewController: UIViewController, UITextFieldDelegate {

    var page : Page?

    @IBOutlet weak var personName: UITextField!

    @IBOutlet weak var desc: UITextView!

    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var deathDate: UIDatePicker!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if sender as AnyObject? === doneButton {
            if let name = personName.text, let desc = desc.text, !name.isEmpty, !desc.isEmpty {
                page = Page(name: name, desc: desc, deathDate: deathDate.date)
            } else if self.page == nil {
                navigationController?.popViewController(animated: true)
            }
        } else {
            page = Page(name: personName.text!, desc: desc.text, deathDate: deathDate.date)
        }
    }

    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let page = page {
            personName.text = page.name
            desc.text = page.desc
//            nameLabel.text = String(item.name.split(separator: " ")[0])
        }
        personName.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deathDate.minimumDate = Date(timeIntervalSinceNow: 0)
        deathDate.date = Date(timeIntervalSinceNow: 3600)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.navigationItem.title = textField.text
    }
}
