//
//  ViewController.swift
//  stopcorona-tracker
//
//  Created by Antonie Jovanoski on 4/13/20.
//  Copyright © 2020 Antonie Jovanoski. All rights reserved.
//

import UIKit
import CoreBluetooth

struct ScannedPeripheral {
    var name: String
    var rssi: Int
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var peripherals: [ScannedPeripheral] = [ScannedPeripheral]() //model
    var cbManager: CBCentralManager?
    var tracker: Tracker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tracker = Tracker()
        
        tracker?.startTracking { coronaid, rssi in
            let scanned = ScannedPeripheral(name: coronaid, rssi: rssi)
            if let index = self.peripherals.firstIndex(where: { $0.name == scanned.name} ) {
                self.peripherals[index].rssi = scanned.rssi
                
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                return
            }
            
            self.peripherals.append(scanned) //add filtering due to continuios scanning
            self.tableView.reloadData()
        }
    }
    
    // Mark: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = peripherals[indexPath.row].name
        cell.detailTextLabel?.text = "\(peripherals[indexPath.row].rssi)"
        
        return cell
    }
}

