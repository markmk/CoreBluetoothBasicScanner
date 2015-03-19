//
//  ViewController.swift
//  CoreBluetoothBasicScanner
//
//  Created by GrownYoda on 3/6/15.
//  Copyright (c) 2015 yuryg. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    
    
    let myCentralManager = CBCentralManager()
    var peripheralArray = [CBPeripheral]()
    
    
    // create now empty array.
    var  deviceArray = [String]()
    
    // create empty dictionary
    var counter = 0  //dictionary Coutner
    
    
    
    
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        myCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())

    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    
    
    }


// Mark   CBCentralManager Methods
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        printToMyTextView("centralManagerDidUpdateState")
       
        /*
        typedef enum {
            CBCentralManagerStateUnknown  = 0,
            CBCentralManagerStateResetting ,
            CBCentralManagerStateUnsupported ,
            CBCentralManagerStateUnauthorized ,
            CBCentralManagerStatePoweredOff ,
            CBCentralManagerStatePoweredOn ,
        } CBCentralManagerState;
     */
        switch central.state{
        case .PoweredOn:
            println("poweredOn")
            
            
        case .PoweredOff:
            printToMyTextView("Central State PoweredOFF")

        case .Resetting:
            printToMyTextView("Central State Resetting")

        case .Unauthorized:
            printToMyTextView("Central State Unauthorized")
        
        case .Unknown:
            printToMyTextView("Central State Unknown")
            
        case .Unsupported:
            printToMyTextView("Central State Unsupported")
            
        default:
            printToMyTextView("Central State None Of The Above")
            
        }
        
    }
    
    
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {

          printToMyTextView(" -- didDiscoverPeripheral -- ")
        
        printToMyTextView("Name: \(peripheral.name)")
        printToMyTextView("RSSI: \(peripheral.RSSI)")
  //      printToMyTextView("Services: \(peripheral.services)")
   //     printToMyTextView("Description: \(peripheral.identifier.UUIDString)")
        printToMyTextView("\r")
      
        
        if peripheral?.name == "RedDotBean"{  // Look for your device by Name
              myCentralManager.stopScan()  // stop scanning to save power
            peripheralArray.append(peripheral) // add found device to device array to keep a strong reverence to it.
            
            myCentralManager.connectPeripheral(peripheralArray[0], options: nil)  // connect to this found device
            printToMyTextView("Attempting to Connect to \(peripheral.name)")
         
        }
        
        
    }
    
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        printToMyTextView("\r\r Did Connect to \(peripheral.name) \r\r")
        peripheral.delegate = self
        peripheral.discoverServices(nil)  // discover services
        printToMyTextView("Scanning For Services")
        
        
        
    }
    
    
    
// Mark   CBPeriperhalManager

    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        printToMyTextView("\r\r Discovered Servies for \(peripheral.name) \r\r")
        
        
        
        for service in peripheral.services as [CBService]{
            println("Service: \(service)  Service.UUID \(service.UUID)  Service.UUID.UUIDString \(service.UUID.UUIDString) \r\r"  )
            
            printToMyTextView("\r Services: \(service.UUID.UUIDString) ")
            
            if service.UUID.UUIDString == "180F"{

                printToMyTextView("------ FOUND BATT with service.UUID.UUIDString \r\r")


                peripheral.discoverCharacteristics(nil, forService: service)
    
                
            }

    

            
        }
        
    }
    
  
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        //
          println("didDiscoverCharacteristicsForService")
        
        printToMyTextView("DidDiscoverCharacteristicsForService:  Service.UUID \(service.UUID)  Service.UUID.UUIDString \(service.UUID.UUIDString) \r\r"  )

        
        
        for characteristic in service.characteristics as [CBCharacteristic]{
            println("Reading Characteristic: \(characteristic)\r")
            
            printToMyTextView("Reading Characteristic Value: \(characteristic.value)\r")
       
            peripheral.readValueForCharacteristic(characteristic)
            peripheral.readRSSI()
        }

        

    }
  
    func peripheral(peripheral: CBPeripheral!, didReadRSSI RSSI: NSNumber!, error: NSError!) {
        //code
        printToMyTextView("\r didReadRSSI: \(RSSI)\r")
    
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        //
        
        
        let convertedReading = "\u{2B}"
        println("converted reading:\(convertedReading)")
        
        
        println("2  Reading Characteristic: \(characteristic)\r")

        printToMyTextView("2  Reading Characteristic Value: \(characteristic.value)\r")
        println("2  Reading Characteristic Property: \(characteristic.properties)\r")

        
        var myData = NSData()

        myData = characteristic.value

        println("MyData: \(myData)\r")

        var buffer = [UInt8](count: myData.length, repeatedValue: 0x00)
        myData.getBytes(&buffer, length: buffer.count)

        var reading:UInt16?
        if (buffer.count >= myData.length){
            if (buffer[0] & 0x01 == 0){
                reading = UInt16(buffer[1]);
            
            }
        } else {
        
        if let actualReading = reading{
            println("Actual Reading \(actualReading)")
        } else  {
            println("reading \(reading)")
        }
        
           
        }
    }
    
    
//  Mark UI Stuff
    
    @IBOutlet weak var myTextView: UITextView!
    
    @IBAction func scanSwitch(sender: UISwitch) {
        if sender.on{

        myCentralManager.scanForPeripheralsWithServices(nil, options: nil )
        printToMyTextView("scanning for Peripherals")

          
        }else{
        myCentralManager.stopScan()
        printToMyTextView("stop scanning")
        
            
        }
    }
    
    func printToMyTextView(passedString: String){
        myTextView.text = passedString + "\r" + myTextView.text
    }
    
}

