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
            
            self.cbManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            
            /*
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                self.cbManager?.stopScan()
             
                self.cbManager?.scanForPeripherals(withServices: [self.cbuuid], options: nil)ѐѐѐѐ
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
        
        let ff01 = CBUUID(string: "FF01")
        let dataServiceUUID = CBUUID(string: "FFAA")
        
        if let services = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            if services.contains(ff01) {
                if services.contains(where: { cbuuid in
                    let uuidString = cbuuid.uuidString
                    
                    // 00000000-0000-2A34-6561-35396137667E
                    if uuidString.contains("00000000-0000-2A") {
                        return true
                    }
                    
                    return false
                }) {
                    //ios
                    
                    if let coronaid = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
                        print("ios coronaid: \(coronaid)")
                        
                        //make a function:
                        let scanned = ScannedPeripheral(name: coronaid, rssi: RSSI.intValue)
                        if let index = peripherals.firstIndex(where: { $0.name == scanned.name} ) {
                            peripherals[index].rssi = scanned.rssi
                            
                            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                            return;
                        }
                        
                        peripherals.append(scanned) //add filtering due to continuios scanning
                        tableView.reloadData()
                        ///
                    }
                    
                } else {
                    //android
                    
                    if let dataServices = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data],
                        let data = dataServices[dataServiceUUID] {
                        
                        var coronaid = String(decoding: data, as: UTF8.self)
                        
                        if coronaid.first == "~" {
                            coronaid.remove(at: coronaid.startIndex)
                            
                            print("android coronaid: \(coronaid)")
                            
                            //make a function:
                            let scanned = ScannedPeripheral(name: coronaid, rssi: RSSI.intValue)
                            if let index = peripherals.firstIndex(where: { $0.name == scanned.name} ) {
                                peripherals[index].rssi = scanned.rssi
                                
                                tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                                return;
                            }
                            
                            peripherals.append(scanned) //add filtering due to continuios scanning
                            tableView.reloadData()
                            ///
                        }
                    }
                }
            }
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

