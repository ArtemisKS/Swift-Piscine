//
//  SecondViewController.swift
//  D05
//
//  Created by Artem KUPRIIANETS on 1/22/19.
//  Copyright © 2019 Artem KUPRIIANETS. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var locationItems: [Location] = []

    var delegate : LocationProtocol?
    
    @IBOutlet weak var locationTableView: UITableView! {
        didSet {
            locationTableView.delegate = self
            locationTableView.dataSource = self
        }
    }

    fileprivate func initLocationItems() {
        // load the list of places from the location.plist file
        // (it's cleaner than loading the list in hard code)
        print("loading the list of places from the location.plist file")
        var locations = [Location]()
        let inputFile = Bundle.main.path(forResource: "location", ofType: "plist")
        
        let inputDataArray = NSArray(contentsOfFile: inputFile!)
        
        for inputItem in inputDataArray as! [Dictionary<String, String>] {
            let locationItem = Location(dataDictionary: inputItem)
            locations.append(locationItem)
            print(locationItem)
        }
        
        locationItems = locations
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initLocationItems() // load the data
        delegate?.setPins(locations: locationItems)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // we only have one section
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell")
         cell?.textLabel?.text = self.locationItems[indexPath.row].name
         cell?.detailTextLabel?.text = self.locationItems[indexPath.row].desc
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        print("SecondViewController.delegate = \(String(describing: self.delegate))")

        delegate?.updateLocation(newLocation: locationItems[row])
        delegate?.isUpdatingLoc = false
        self.tabBarController!.selectedViewController = self.tabBarController!.viewControllers?.first
    }

 }

protocol LocationProtocol {
    var isUpdatingLoc: Bool { get set }
    func updateLocation(newLocation : Location)
    func setPins(locations : [Location])
}
