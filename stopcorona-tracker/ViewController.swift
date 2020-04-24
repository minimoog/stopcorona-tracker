//
//  ViewController.swift
//  stopcorona-tracker
//
//  Created by Antonie Jovanoski on 4/13/20.
//  Copyright © 2020 Antonie Jovanoski. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

struct ScannedPeripheral {
    var name: String
    var rssi: Int
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

class ViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var peripherals: [ScannedPeripheral] = [ScannedPeripheral]() //model
    let tracker: Tracker = Tracker()
    let locationManager: CLLocationManager = CLLocationManager()
    var location: CLLocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        tracker.startTracking { coronaid, rssi in
            let scanned = ScannedPeripheral(name: coronaid, rssi: rssi)
            if let index = self.peripherals.firstIndex(where: { $0.name == scanned.name} ) {
                self.peripherals[index].rssi = scanned.rssi
                
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                return
            }
            
            self.peripherals.append(scanned) //add filtering due to continuios scanning
            self.tableView.reloadData()
        }
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    // Mark: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! Cell
        
        cell.coronaid.text = peripherals[indexPath.row].name
        cell.rssi.text = "\(peripherals[indexPath.row].rssi)"
        
        return cell
    }
    
    // Mark: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            print(lastLocation)
            
            location = lastLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
           // Location updates are not authorized.
           manager.stopUpdatingLocation()
           return
        }
        
        print("OOOO CLLocation error")
    }
}

