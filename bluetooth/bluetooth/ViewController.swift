//
//  ViewController.swift
//  bluetooth
//
//  Created by mitlab on 2022/1/25.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController ,CBCentralManagerDelegate,CBPeripheralDelegate{
    
    
    
    @IBAction func b1(_ sender: UIButton) {
        let alertController = UIAlertController(title: "提示", message: "一個簡單提示，請按確認繼續", preferredStyle: .alert)

        // 建立[確認]按鈕
        let okAction = UIAlertAction(title: "確認", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            print("按下確認後，閉包裡的動作")
        })
        alertController.addAction(okAction)
        
        // 顯示提示框
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func b2(_ sender: UIButton) {
        let alertController = UIAlertController(title: "送出", message: "確認要送出了嗎？", preferredStyle: .alert)
        
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // 建立[送出]按鈕
        let okAction = UIAlertAction(title: "送出", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // 顯示提示框
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func b3(_ sender: UIButton) {
        // 建立一個提示框
        let alertController = UIAlertController(title: "刪除", message: "刪除字樣會變紅色的", preferredStyle: .alert)
        
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // 建立[刪除]按鈕
        let okAction = UIAlertAction(title: "刪除", style: .destructive, handler: nil)
        alertController.addAction(okAction)

        // 顯示提示框
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func b4(_ sender: UIButton) {
        let alertController = UIAlertController(title: "登入", message: "請輸入帳號與密碼", preferredStyle: .alert)
        
        // 建立兩個輸入框
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "帳號"
        }
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "密碼"
            
            // 如果要輸入密碼 這個屬性要設定為 true
            textField.isSecureTextEntry = true
        }

        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // 建立[登入]按鈕
        let okAction = UIAlertAction(title: "登入", style: .default) {
            (action: UIAlertAction!) -> Void in
            let acc = (alertController.textFields?.first)! as UITextField
            let password = (alertController.textFields?.last)! as UITextField
            
            print("輸入的帳號為：\(acc.text!)")
            print("輸入的密碼為：\(password.text!)")
        }
        alertController.addAction(okAction)
        
        // 顯示提示框
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func b5(_ sender: UIButton) {
        // 建立一個提示框
        let alertController = UIAlertController(title: "底部提示", message: "這個提示會從底部彈出", preferredStyle: .actionSheet)
        
        // 建立[取消]按鈕
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // 建立[確認]按鈕
        let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // 顯示提示框
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func next(_ sender: UIButton) {
        performSegue(withIdentifier: "GoTo2", sender: nil)

    }
    
    
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    // 自訂一個錯誤型態
    enum SendDataError: Error {
        case CharacteristicNotFound
    }
    
    // GATT
    let C001_CHARACTERISTIC = "C001"
    var centralManager: CBCentralManager!
    // 儲存連上的 peripheral，此變數一定要宣告為全域
    var connectPeripheral: CBPeripheral!
    // 記錄所有的 characteristic
    var charDictionary = [String: CBCharacteristic]()
    
    func isPaired() -> Bool {
        let user = UserDefaults.standard
        if let uuidString = user.string(forKey: "KEY_PERIPHERAL_UUID") {
            let uuid = UUID(uuidString: uuidString)
            let list = centralManager.retrievePeripherals(withIdentifiers: [uuid!])
            if list.count > 0 {
                connectPeripheral = list.first!
                connectPeripheral.delegate = self
                return true
            }
        }
        return false
    }


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let queue = DispatchQueue.global()
        // 將觸發1號method
        centralManager = CBCentralManager(delegate: self, queue: queue)
        // Do any additional setup after loading the view.
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // 先判斷藍牙是否開啟，如果不是藍牙4.x ，也會傳回電源未開啟
        guard central.state == .poweredOn else {
            // iOS 會出現對話框提醒使用者
            return
        }
        
        if isPaired() {
            // 將觸發 3號method
            centralManager.connect(connectPeripheral, options: nil)
        } else {
            // 將觸發 2號method
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    /* 2號method */
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        guard let deviceName = peripheral.name else {
            return
        }
        print("找到藍牙裝置: \(deviceName)")
        
        guard deviceName.range(of: "我的ABC裝置") != nil ||
            deviceName.range(of: "MacBook") != nil
        else {
            return
        }
        
        central.stopScan()
        
        // 斷線處理
        // 儲存周邊端的UUID，重新連線時需要這個值
        let user = UserDefaults.standard
        user.set(peripheral.identifier.uuidString, forKey: "KEY_PERIPHERAL_UUID")
        user.synchronize()
        
        connectPeripheral = peripheral
        connectPeripheral.delegate = self
        
        // 將觸發 3號method
        centralManager.connect(connectPeripheral, options: nil)
    }
    
    
    /* 3號method */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 清除上一次儲存的 characteristic 資料
        charDictionary = [:]
        // 將觸發 4號method
        peripheral.discoverServices(nil)
    }
    
    /* 4號method */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("ERROR: \((#file, #function))")
            print(error!.localizedDescription)
            return
        }
        
        for service in peripheral.services! {
            // 將觸發 5號method
            connectPeripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    
    /* 5號method */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("ERROR: \((#file, #function))")
            print(error!.localizedDescription)
            return
        }
        
        for characteristic in service.characteristics! {
            let uuidString = characteristic.uuid.uuidString
            charDictionary[uuidString] = characteristic
            print("找到: \(uuidString)")
        }
    }
    
    /* 將資料傳送到 peripheral */
    func sendData(_ data: Data, uuidString: String, writeType: CBCharacteristicWriteType) throws {
        guard let characteristic = charDictionary[uuidString] else {
            throw SendDataError.CharacteristicNotFound
        }
        
        connectPeripheral.writeValue(
            data,
            for: characteristic,
            type: writeType
        )
    }

    /* 將資料傳送到 peripheral 時如果遇到錯誤會呼叫 */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("寫入資料錯誤: \(error!)")
        }
    }
    
    /* 取得 peripheral 送過來的資料 */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("ERROR: \((#file, #function))")
            print(error!)
            return
        }
        
        if characteristic.uuid.uuidString == C001_CHARACTERISTIC {
            let data = characteristic.value! as NSData
            let string = "> " + String(data: data as Data, encoding: .utf8)!
            print(string)

            DispatchQueue.main.async {
                if self.textView.text.isEmpty {
                    self.textView.text = string
                } else {
                    self.textView.text = self.textView.text + "\n" + string
                }
            }
        }
    }
    
    /* 訂閱與取消訂閱開關 */
    @IBAction func subscribeValue(_ sender: UISwitch) {
        connectPeripheral.setNotifyValue(sender.isOn, for: charDictionary[C001_CHARACTERISTIC]!)
    }
    
    /* 按下送出按鈕 */
    @IBAction func sendClick(_ sender: Any) {
        let string = textField.text ?? ""
        if textView.text.isEmpty {
            textView.text = string
        } else {
            textView.text = textView.text + "\n" + string
        }
        
        do {
            let data = string.data(using: .utf8)
            // 注意這裡必須根據 characteristic 的屬性設定
            // 來決定使用 withoutResponse 或是 withResponse
            try sendData(data!, uuidString: C001_CHARACTERISTIC, writeType: .withResponse)
        } catch {
            print(error)
        }
    }
    
    /* 向 periphral 送出讀資料請求 */
    @IBAction func readDataClick(_ sender: Any) {
        let characteristic = charDictionary[C001_CHARACTERISTIC]!
        connectPeripheral.readValue(for: characteristic)
    }
    
    /* 關閉鍵盤 */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.3) {
            self.view.endEditing(true)
        }
    }
    
    /* 斷線處理 */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("連線中斷")
        if isPaired() {
            // 將觸發 3號method
            centralManager.connect(connectPeripheral, options: nil)
        }
    }
    
    /* 解配對 */
    func unpair() {
        let user = UserDefaults.standard
        user.removeObject(forKey: "KEY_PERIPHERAL_UUID")
        user.synchronize()
        centralManager.cancelPeripheralConnection(connectPeripheral)
        // 在 iOS 中要提醒使用者必須從系統設定中「忘記裝置」，否則無法再配對
    }

    @IBAction func unpairClick(_ sender: Any) {
        unpair()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    




}

