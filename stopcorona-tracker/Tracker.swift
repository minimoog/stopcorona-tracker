//
//  Tracker.swift
//  stopcorona-tracker
//
//  Created by Antonie Jovanoski on 4/22/20.
//  Copyright © 2020 Antonie Jovanoski. All rights reserved.
//

import Foundation
import CoreBluetooth

class Tracker: NSObject, CBCentralManagerDelegate {
    var cbManager: CBCentralManager?
    var trackedClosure: ((String, Int) -> ())?
    
    override init() {
        super.init()
        
        cbManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startTracking(closure: @escaping (String, Int) -> ()) {
        trackedClosure = closure
    }
    
    func stopTracking() {
        trackedClosure = nil
        
        cbManager?.stopScan()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOff:
            print("BLE powered off")
        case .poweredOn:
            print("BLE powered on")
            
            cbManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            
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
                        
                        if let invoke = trackedClosure {
                            invoke(coronaid, RSSI.intValue)
                        }
                    }
                    
                } else {
                    //android
                    
                    if let dataServices = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data],
                        let data = dataServices[dataServiceUUID] {
                        
                        var coronaid = String(decoding: data, as: UTF8.self)
                        
                        if coronaid.first == "~" {
                            coronaid.remove(at: coronaid.startIndex)
                            
                            print("android coronaid: \(coronaid)")
                            
                            if let invoke = trackedClosure {
                                invoke(coronaid, RSSI.intValue)
                            }
                        }
                    }
                }
            }
        }
    }
}
