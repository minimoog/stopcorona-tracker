//
//  ViewController.swift
//  stopcorona-tracker
//
//  Created by Antonie Jovanoski on 4/13/20.
//  Copyright © 2020 Antonie Jovanoski. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var cbManager: CBCentralManager?
    
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
            cbManager?.scanForPeripherals(withServices: nil, options: nil) // UUID?????
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
        
    }
}

