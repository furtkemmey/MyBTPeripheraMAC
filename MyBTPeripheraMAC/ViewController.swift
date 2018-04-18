//
//  ViewController.swift
//  MyBTPeripheraMAC
//
//  Created by KaiChieh on 2018/4/13.
//  Copyright © 2018 KaiChieh. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController {
    let strService = "8B3A14A0-BD8D-4891-98C6-C3CE6B28081B" // get form uuidgen command
    let strCharacteristic1 = "51D39CEA-041D-47D2-979F-B65E0FAC3743"  // for send message
    let strCharacteristic2 = "157012B5-5F47-4D48-8B09-E9EDD519E948"  // for written

    var peripheralMangger: CBPeripheralManager!
    var arrCharacteristics = [CBMutableCharacteristic]()


    @IBOutlet weak var lblInfo: NSTextField!
    @IBOutlet weak var lblSend: NSTextField!
    @IBOutlet weak var lblPower: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peripheralMangger = CBPeripheralManager(delegate: self, queue: nil)

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension ViewController: CBPeripheralManagerDelegate {
    // didUpdateState
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheralMangger.state {
        case .poweredOn:
            lblInfo.stringValue = "powerOn"
        case .poweredOff:
            lblInfo.stringValue = "powerOff"
        default:
            lblInfo.stringValue = "unknow"
            return
        }
        let serivce = CBMutableService(type: CBUUID(string: strService), primary: true)
        // notify from strCharacteristic1
        var characteristic = CBMutableCharacteristic(type: CBUUID(string: strCharacteristic1), properties: .notify, value: nil, permissions: .readable)
        arrCharacteristics.append(characteristic)
        //write from strCharacteristic2
        characteristic = CBMutableCharacteristic(type: CBUUID(string: strCharacteristic2), properties: .write, value: nil, permissions: .writeable)
        arrCharacteristics.append(characteristic)

        serivce.characteristics = arrCharacteristics
        peripheralMangger.add(serivce)
    }
    //  didAdd service
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil {
            lblInfo.stringValue  = lblInfo.stringValue  + "\n \(error!.localizedDescription)"
            return
        } else {
            lblInfo.stringValue  = lblInfo.stringValue + "\n did add serivce"
        }
        lblInfo.stringValue  = lblInfo.stringValue  + "\n added device"
        let deviceNmae = "MY MAC device"
        peripheralMangger.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[service.uuid], CBAdvertisementDataLocalNameKey:deviceNmae])

        //持續傳送累加數字
        let globalQueue = DispatchQueue.global(qos: .default)
        globalQueue.async {
            var i = 0
            while true {
                i += 1
                let strData = "\(i)".data(using: .utf8)!
                self.peripheralMangger.updateValue(strData, for: self.arrCharacteristics[0], onSubscribedCentrals: nil)
                DispatchQueue.main.async {
                    self.lblSend.stringValue = "\(i)"
                }
                Thread.sleep(forTimeInterval: 1)
            }
        }
    }
    // didReceiveWrite
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        let aRequest = requests.first
        let strReceived = String(data: aRequest!.value!, encoding: .utf8)
        if strReceived == "ON" {
            lblPower.stringValue = "ON"
        } else if strReceived == "OFF" {
            lblPower.stringValue = "OFF"
        }
        peripheralMangger.respond(to: aRequest!, withResult: .success)
    }
    


}

