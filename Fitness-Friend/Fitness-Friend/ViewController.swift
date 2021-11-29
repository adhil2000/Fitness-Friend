//
//  ViewController.swift
//  Fitness-Friend
//
//  Created by Adhil Akbar on 10/20/21.
//

import UIKit
import Charts
import Foundation
import CoreBluetooth

struct CBUUIDs{

    static let kBLEService_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    // Characteristic for Transfering Data
    static let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    // Characteristic for Recieving Data
    static let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

}

// Bluetooth Support
import CoreBluetooth

class ViewController: UIViewController {
    @IBOutlet weak var lineBox: LineChartView!
    @IBOutlet weak var barBox: BarChartView!
    @IBOutlet weak var pieBox: PieChartView!
    @IBOutlet weak var checkList: UIView!
    @IBOutlet weak var bpm: UITextField!
    @IBOutlet weak var heartStack: UIStackView!
    @IBOutlet weak var stepStack: UIStackView!
    @IBOutlet weak var daysOfWeek: UITextField!
    @IBOutlet weak var sleepStack: UIStackView!
    @IBOutlet weak var checkListStack: UIStackView!
    @IBOutlet weak var calStack: UIStackView!
    @IBOutlet weak var calButon: UIButton!
    @IBOutlet weak var One: UITextField!
    @IBOutlet weak var Two: UITextField!
    @IBOutlet weak var Three: UITextField!
    @IBOutlet weak var Four: UITextField!
    @IBOutlet weak var Five: UITextField!
        
    // Bluetooth Support
    var centralManager: CBCentralManager!
    private var bluefruitPeripheral: CBPeripheral!
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    var Data = [0]
    var pieData = [0]
    // End
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // BPM
        bpm.text = "    " + String(Int.random(in: 50..<65)) + " BPM";
        
        // Hides Keyboard upon Return
        One.delegate = self
        Two.delegate = self
        Three.delegate = self
        Four.delegate = self
        Five.delegate = self
        One.tag = 1
        Two.tag = 2
        Three.tag = 2
        Four.tag = 2
        Five.tag = 2
        
        // Bluetooth Support
        centralManager = CBCentralManager(delegate: self, queue: nil)
        // End
        
        checkListStack.layer.cornerRadius=40;
        checkListStack.layer.borderWidth = 5.0
        checkListStack.layer.borderColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1).cgColor
        
        //textField.backgroundColor = UIColor.clear
        
        stepStack.layer.cornerRadius=40
        stepStack.layer.borderWidth = 5.0
        stepStack.layer.borderColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1).cgColor
        stepStack.backgroundColor = UIColor(red: (0/255.0), green: (223/255.0), blue: (89/255.0), alpha: 1.0)
        daysOfWeek.layer.cornerRadius = 40
        daysOfWeek.backgroundColor = UIColor.clear
        
        sleepStack.layer.cornerRadius = 40;
        sleepStack.layer.borderWidth = 5.0
        sleepStack.layer.borderColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1).cgColor
        sleepStack.backgroundColor = UIColor(red: (187/255.0), green: (0/255.0), blue: (255/255.0), alpha: 1.0)
        
        heartStack.layer.cornerRadius = 25;
        heartStack.layer.borderWidth = 5.0
        heartStack.layer.borderColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1).cgColor
        
        bpm.backgroundColor = UIColor.clear
        
        calStack.layer.cornerRadius = 40;
        calStack.layer.borderWidth = 5.0
        calStack.layer.borderColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 1).cgColor
        calStack.backgroundColor = UIColor(red: (255/255.0), green: (202/255.0), blue: (0/255.0), alpha: 1.0)
        calButon.backgroundColor = UIColor.clear
        
        //let Data = [1, 2, 4, 8, 16, 8, 2]
        graphLineChart(dataArray: Data)
        //let pieData = [30, 40, 30]
        graphPieChart(dataArray: pieData)
        graphBarChart(dataArray: Data)
    }
    
    // Function that Reads Data
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

          var characteristicASCIIValue = NSString()

          guard characteristic == rxCharacteristic,

          let characteristicValue = characteristic.value,
          let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else { return }

          characteristicASCIIValue = ASCIIstring
        
        // 35:00
        let myInt = (characteristicASCIIValue as NSString).integerValue
        Data.append(myInt)
        pieData.append(myInt)
        graphLineChart(dataArray: Data)
        graphPieChart(dataArray: pieData)
        graphBarChart(dataArray: Data)
        print("Value Recieved: \((characteristicASCIIValue as String))")
    }
    
    // Write Data to Arduino over Bluetooth
    func writeOutgoingValue(data: String){
          
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        
        if let bluefruitPeripheral = bluefruitPeripheral {
              
          if let txCharacteristic = txCharacteristic {
                  
            bluefruitPeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
              }
          }
      }
    
    func graphLineChart(dataArray: [Int]) {
            // Make lineBox size have width and height both equal to width of screen
            lineBox.frame = CGRect(x: 0, y:0,
                                    width: self.view.frame.size.width,
                                    height: self.view.frame.size.width / 2)
        
            //Make lineBox center to be horizontally centered, but
            // offset towards the top of the screen
            lineBox.center.x = self.view.center.x
            // Subtracting will move up an Object
            lineBox.center.y = self.view.center.y - 240
            
            //Settings when chart has no data
            lineBox.noDataText = "No data avaiable"
            lineBox.noDataTextColor = UIColor.black
        
            // Simplicity Settings
            lineBox.xAxis.drawGridLinesEnabled = false
            lineBox.leftAxis.drawLabelsEnabled = false
            lineBox.rightAxis.drawLabelsEnabled = false
            lineBox.legend.enabled = false
            lineBox.leftAxis.drawTopYLabelEntryEnabled = false
            
            //Initialize Array that will eventually be displayed on the graph
            var entries = [ChartDataEntry]()

            //For every element in given dataset
            //Set the X and Y coordinates in a data chart entry and add to the entire list
            for i in 0..<dataArray.count {
                let value = ChartDataEntry(x: Double(i), y: Double(dataArray[i]))
                    entries.append(value)
            }
            
            //Use the entries object and a label string to make a LineChartDataSet object
            let dataSet = LineChartDataSet(entries: entries, label: "Line Chart")
            dataSet.mode = .cubicBezier
            lineBox.layer.cornerRadius=40;
            
            //Customize graph settings to your liking
            dataSet.colors = [UIColor.white]
            lineBox.backgroundColor = UIColor(red: (187/255.0), green: (0/255.0), blue: (255/255.0), alpha: 1.0)
            
            //Make object that will be added to the chart and set it to the variable in the Storyboard
            let data = LineChartData(dataSet: dataSet)
            lineBox.data = data
            //lineBox.borderLineWidth = 20.0
            //Add settings for the chartBox
            lineBox.chartDescription?.text = "Sleep Data"
            
            //Animations
            lineBox.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .linear)
        }
    
    func graphPieChart(dataArray: [Int]) {
            // Make lineBox size have width and height both equal to width of screen
            pieBox.frame = CGRect(x: 0, y:0,
                                        width: self.view.frame.size.width,
                                        height: self.view.frame.size.width / 2)
            
            //Make lineBox center to be horizontally centered, but
            // offset towards the top of the screen
            pieBox.center.x = self.view.center.x
            // Subtracting will move up an Object
            pieBox.center.y = self.view.center.y
        
            
            //Settings when chart has no data
            pieBox.noDataText = "No data avaiable"
            pieBox.noDataTextColor = UIColor.black
            
            //Initialize Array that will eventually be displayed on the graph
            var entries = [ChartDataEntry]()

            //For every element in given dataset
            //Set the X and Y coordinates in a data chart entry and add to the entire list
            for i in 0..<dataArray.count {
                let value = ChartDataEntry(x: Double(i), y: Double(dataArray[i]))
                    entries.append(value)
            }
            
            //Use the entries object and a label string to make a LineChartDataSet object
            let dataSet = PieChartDataSet(entries: entries, label: "Breakfast, Lunch, Dinner")
            
            //Customize graph settings to your liking
            dataSet.colors = ChartColorTemplates.joyful()
            
            //Make object that will be added to the chart and set it to the variable in the Storyboard
            let data = PieChartData(dataSet: dataSet)
            pieBox.data = data
            pieBox.holeRadiusPercent = 0.0
            pieBox.transparentCircleRadiusPercent = 0.6
            pieBox.legend.drawInside = true
            pieBox.legend.horizontalAlignment = .center
            pieBox.sizeToFit()
            
            //Animations
            pieBox.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .linear)
        }
    
    func graphBarChart(dataArray: [Int]) {
        // Make lineChartBox size have width anf height both equal to width of screen
        barBox.frame = CGRect (x:0, y: 0, width: self.view.frame.width, height: self.view.frame.size.width / 2)
        
        // Make lineChartBox center to be horizontally centered, offset towards the yop of the screen
        barBox.center.x = self.view.center.x
        barBox.center.y = self.view.center.y + 240
        
        //Settings when chart has no data
        barBox.noDataText = "No data available"
        barBox.noDataTextColor = UIColor.black
        
        // Simplicity Settings
        barBox.xAxis.drawGridLinesEnabled = false
        barBox.leftAxis.drawLabelsEnabled = false
        barBox.rightAxis.drawLabelsEnabled = false
        barBox.legend.enabled = false
        barBox.leftAxis.drawTopYLabelEntryEnabled = false
        
        // Intialize Array that will evetually be displayed on the graph
        var entries = [BarChartDataEntry]()
        
        // For every element in given dataset, setj the X and Y coordinates in a data chart entry and add to the entries list
        for i in 0..<dataArray.count{
            let value = BarChartDataEntry(x: Double(i+1), y: Double(dataArray[i]))
            entries.append(value)
        }
        let dataSet = BarChartDataSet(entries: entries, label: "Total Steps")
        
        barBox.layer.cornerRadius=40
        
        // Color Change
        dataSet.colors = [UIColor.white]
        barBox.backgroundColor = UIColor(red: (0/255.0), green: (223/255.0), blue: (89/255.0), alpha: 1.0)
        
        //Make object that will be added tot he chart and set it to the variable in the Storyboard
        let data = BarChartData(dataSet: dataSet)
        barBox.data = data
        
        //Animation
        barBox.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .linear)
    }
    
    func startScanning() -> Void {
      // Start Scanning
      centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {

        bluefruitPeripheral = peripheral
        bluefruitPeripheral.delegate = self

        print("Peripheral Discovered: \(peripheral)")
          print("Peripheral name: \(peripheral.name)")
        print ("Advertisement Data : \(advertisementData)")
        
        centralManager?.connect(bluefruitPeripheral!, options: nil)

       }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
       bluefruitPeripheral.discoverServices([CBUUIDs.BLEService_UUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            print("*******************************************************")

            if ((error) != nil) {
                print("Error discovering services: \(error!.localizedDescription)")
                return
            }
            guard let services = peripheral.services else {
                return
            }
            //We need to discover the all characteristic
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            print("Discovered Services: \(services)")
        }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
           
               guard let characteristics = service.characteristics else {
              return
          }

          print("Found \(characteristics.count) characteristics.")

          for characteristic in characteristics {

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx)  {

              rxCharacteristic = characteristic

              peripheral.setNotifyValue(true, for: rxCharacteristic!)
              peripheral.readValue(for: characteristic)

              print("RX Characteristic: \(rxCharacteristic.uuid)")
            }

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){
              
              txCharacteristic = characteristic
              
              print("TX Characteristic: \(txCharacteristic.uuid)")
            }
          }
    }
    
    func disconnectFromDevice () {
        if bluefruitPeripheral != nil {
        centralManager?.cancelPeripheralConnection(bluefruitPeripheral!)
        }
     }

}

extension ViewController: CBCentralManagerDelegate {

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    
     switch central.state {
          case .poweredOff:
              print("Is Powered Off.")
          case .poweredOn:
              print("Is Powered On.")
              startScanning()
          case .unsupported:
              print("Is Unsupported.")
          case .unauthorized:
          print("Is Unauthorized.")
          case .unknown:
              print("Unknown")
          case .resetting:
              print("Resetting")
          @unknown default:
            print("Error")
          }
  }

}

extension ViewController: CBPeripheralDelegate {
}

extension ViewController: CBPeripheralManagerDelegate {

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .poweredOn:
        print("Peripheral Is Powered On.")
    case .unsupported:
        print("Peripheral Is Unsupported.")
    case .unauthorized:
    print("Peripheral Is Unauthorized.")
    case .unknown:
        print("Peripheral Unknown")
    case .resetting:
        print("Peripheral Resetting")
    case .poweredOff:
      print("Peripheral Is Powered Off.")
    @unknown default:
      print("Error")
    }
  }
}

// Hides Keyboard upon Return
extension ViewController: UITextFieldDelegate {
 func textFieldShouldReturn(_ textField: UITextField) -> Bool {
 //Check if there is any other text-field in the view whose tag is +1 greater than the current text-field on which the return key was pressed. If yes → then move the cursor to that next text-field. If No → Dismiss the keyboard
 if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
 nextField.becomeFirstResponder()
 } else {
 textField.resignFirstResponder()
 }
 return false
 }
 }
