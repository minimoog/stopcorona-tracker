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

class ViewController: UIViewController, CBCentralManagerDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var peripherals: [ScannedPeripheral] = [ScannedPeripheral]() //model
    var cbManager: CBCentralManager?
    let cbuuid = CBUUID(string: "00000000-0000-2a34-6561-35396137667e"); //stopcorona UUID
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cbManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("BLE powered off")
        case .poweredOn:
            print("BLE powered on")
            
            self.cbManager?.scanForPeripherals(withServices: [self.cbuuid], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            
            /*
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                self.cbManager?.stopScan()
                self.cbManager?.scanForPeripherals(withServices: [self.cbuuid], options: nil)
            }
            */
            
        case .resetting:
            print("BLE resetting")
        case .unauthorized:
            print("BLE unauthorized")
        case .unsupported:
            print("BLE unsupported")
        default:
            return;
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            let scanned = ScannedPeripheral(name: localName, rssi: RSSI.intValue)
            
            if let index = peripherals.firstIndex(where: { $0.name == scanned.name} ) {
                peripherals[index].rssi = scanned.rssi
                
                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                return;
            }
            
            peripherals.append(scanned) //add filtering due to continuios scanning
            tableView.reloadData()
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

