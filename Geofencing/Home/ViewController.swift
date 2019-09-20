//
//  ViewController.swift
//  Geofencing
//
//  Created by Patrick Leonardus on 17/09/19.
//  Copyright © 2019 Patrick Leonardus. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import SystemConfiguration.CaptiveNetwork
import LocalAuthentication
import CloudKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewValidation: UIView!
    @IBOutlet weak var validImage: UIImageView!
    @IBOutlet weak var validTitle: UILabel!
    @IBOutlet weak var validSub: UILabel!
    @IBOutlet weak var validButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblEvent: UILabel!
    

    let locationManager : CLLocationManager = CLLocationManager()
    let reachability = try! Reachability()
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var updateTimer: Timer?
    let calendar = Calendar.current
    let now = Date()
    
    var arrayData : Array<CKRecord> = []
    var timer = Timer()
    var timerForEvent = Timer()
    
    var flag = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLocation()
        setUpGeoFencing()
        reachabilityDetection()
        repeatNotification(titleText: "Session will be start soon", bodyText: "Your session will be start in 30 minutes", hourInput: 13, minuteInput: 30)
        repeatNotification(titleText: "Your session is over", bodyText: "Before you left, remember to clock-out", hourInput: 18, minuteInput: 00)
        
        faceIDAuth()
        secure()
        setBeforeFailed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setTime()
        setEvent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8, execute: {
            self.arrayData.removeAll()
            self.loadData()
            self.tableView.reloadData()
        })
    }
    
    func secure(){
        setBeforeFailed()
        viewValidation.alpha = 1
        self.navigationController?.navigationBar.layer.zPosition = -1
        
    }
    
    func unlockScreen(){
        DispatchQueue.main.async {
            self.navigationController?.navigationBar.layer.zPosition = 0
            self.viewValidation.removeFromSuperview()
        }
        
    }
    
    func setBeforeFailed(){
        validImage.alpha = 0
        validTitle.alpha = 0
        validSub.alpha = 0
        validButton.alpha = 0
    }
    
    func setFailedFaceID(){
        DispatchQueue.main.async {
            self.validImage.alpha = 1
            self.validTitle.alpha = 1
            self.validSub.alpha = 1
            self.validButton.alpha = 1
        }
    }
    
    func faceIDAuth(){
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "FaceID/TouchID used to open this app") { (success, error) in
                if success {
                    self.unlockScreen()
                }
                else if (error != nil) {
                    self.setFailedFaceID()
                    print("Authentication failed")
                }
            }
        }
        else {
            print("FaceID/TouchID is not configure")
        }
    }
    
    func setTime(){
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(clockTick), userInfo: nil, repeats: true)
        
    }
    
    func setEvent(){
        timerForEvent = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(setUpcomingEvent), userInfo: nil, repeats: true)
    }
    
    func reachabilityDetection(){
           NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: Notification.Name.reachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Couldn't start notifier")
        }
    }
    
    @objc func setUpLocation(){
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 100
    }
    
    func setUpGeoFencing(){
        let geofencing : CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: -6.302313, longitude: 106.652327), radius: 10, identifier: "GOP 9")
        locationManager.startMonitoring(for: geofencing)
    }
    
    func notification(titleText : String, bodyText : String, dateTime : Date){
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = titleText
        content.body = bodyText
        content.sound = UNNotificationSound(named: UNNotificationSoundName("ios_gmail_sound.caf"))
        
        let date = dateTime
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
        let id = UUID().uuidString
        let request =  UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            
        }
    }
    
    func repeatNotification(titleText : String, bodyText : String, hourInput : Int, minuteInput : Int){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = titleText
        content.body = bodyText
        content.sound = UNNotificationSound(named: UNNotificationSoundName("ios_gmail_sound.caf"))
        
        var dateComponent = DateComponents()
        dateComponent.hour = hourInput
        dateComponent.minute = minuteInput
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        
        let id = UUID().uuidString
        let request =  UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            
        }
    }
    
    @objc func internetChanged(note : Notification){
        let reachability = note.object as! Reachability
        if reachability.isReachable{
            if reachability.isReachableViaWiFi{
                if getWiFiSsid() == "iosda-training" {
                    if flag == 0 {
                        notification(titleText: "You're using academy wifi", bodyText: "Have you clock-in yet?", dateTime: Date().addingTimeInterval(1))
                        flag+=1
                    }
                }
            }
            else {
                print("non wifi")
            }
        }
        else {
            print("unreachable connection")
        }
    }
    
    @objc func clockTick(){
        lblTime.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        navigationItem.title = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
    }
    
    @objc func setUpcomingEvent(){
        
        let beforeClassSession = calendar.date(
            bySettingHour: 13,
            minute: 30,
            second: 0,
            of: now)!
        let startClassSession = calendar.date(
            bySettingHour: 14,
            minute: 00,
            second: 0,
            of: now)!
        
        let beforeEndSession = calendar.date(
            bySettingHour: 17,
            minute: 45,
            second: 0,
            of: now)!
        
        let endClassSession = calendar.date(
            bySettingHour: 8,
            minute: 0,
            second: 0,
            of: now)!
        
        if now >= beforeClassSession && now <= startClassSession {
            lblEvent.text = "Your class session will be start immediately, Let's clock-in"
        }
        
        else if now >= beforeEndSession && now <= endClassSession {
            lblEvent.text = "Academy session will be over soon, remember always clock out before left the academy"
        }
        
        
    }
    
    func loadData(){
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "Reflection", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        publicDatabase.perform(query, inZoneWith: nil) { (results, error) -> Void in
            if error != nil {
                print(error as Any)
            }
            else {
                
                for result in results! {
                    self.arrayData.append(result)
                }
                
                OperationQueue.main.addOperation({ () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
        
    }
    
    func getWiFiSsid() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }

    @IBAction func btnTry(_ sender: Any) {
        faceIDAuth()
    }
}

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        notification(titleText: "We detected that you are near the academy", bodyText: "Don't forget to clock-in before your session begin", dateTime: Date().addingTimeInterval(1.5))
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        notification(titleText: "We detected that you just left the academy", bodyText: "Always remember to clock out before you left the academy", dateTime: Date().addingTimeInterval(1.5))
    }
    
}


extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Scheduled Reminder"
        }
        else if section == 1 {
            return "Your last activities"
        }
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return "Every last activities you wrote will be seen here"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height : CGFloat = 0
        
        if indexPath.section == 0 {
            height = 120
        }
        
        else if indexPath.section == 1 {
            height = 220
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height : CGFloat = 0
        if section == 0 {
            height = 30
        }
        else {
            height = 20
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell") as! HomeReminderTableViewCell
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reflectionCell")  as! HomeReflectionTableViewCell
            
            if !(arrayData.isEmpty){
                let rec : CKRecord = arrayData[indexPath.row]
                
                cell.inputDate.text = (rec.value(forKey: "date") as! String)
                cell.inputTitle.text = (rec.value(forKey: "title") as! String)
                cell.inputDesc.text = (rec.value(forKey: "description") as! String)
               
            }
            else{
                cell.inputDate.text = "No Data Available"
                cell.inputTitle.text = "No Data Available"
                cell.inputDesc.text = "Go fill your activites to show your last activity"
            }
             return cell
        }
        return UITableViewCell()
    }
    
    
}
