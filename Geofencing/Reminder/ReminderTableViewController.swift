//
//  ReminderTableViewController.swift
//  Geofencing
//
//  Created by Patrick Leonardus on 19/09/19.
//  Copyright © 2019 Patrick Leonardus. All rights reserved.
//

import UIKit
import CloudKit

class ReminderTableViewController: UITableViewController {
    
    var inputName = UITextField()
    var inputDesc = UITextField()
    var inputDate = UITextField()
    var addAction = UIAlertAction()
    var addActionUpdate = UIAlertAction()
    var datePicker = UIDatePicker()
    var refresh = UIRefreshControl()
    var dateFormatter = DateFormatter()
    
    var titleText = ["Let me remind you",
                    "Put your task here"]
    var arrayData : Array<CKRecord> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let btnAdd = UIBarButtonItem(title: "Add Task", style: .done, target: self, action: #selector(add))
        let btnCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.leftBarButtonItem = btnCancel
        navigationItem.rightBarButtonItem = btnAdd
        
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: #selector(refreshing), for: UIControl.Event.valueChanged)
        tableView.addSubview(refresh)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = titleText.randomElement()
        
        arrayData.removeAll()
        loadData()
        tableView.reloadData()
    }
    
    @objc func refreshing(){
        arrayData.removeAll()
        loadData()
        tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
    func saveData(activity : CKRecordValue, describe : CKRecordValue, date : CKRecordValue){
        let record = CKRecord(recordType: "MyProfile")
        record["Activity"] = activity
        record["Describe"] = describe
        record["Date"] = date
        
        
        let database = CKContainer.default().publicCloudDatabase
        database.save(record) { (record, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                print("save data works")
            }
        }
    }
    
    func loadData(){
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        
        let query = CKQuery(recordType: "MyProfile", predicate: predicate)
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
    
    @objc func dateChanged(datePicker : UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy - hh:mm"
        inputDate.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func add(){
        
        let alert = UIAlertController(title: "Add Reminder", message: "What do you want me to remind you?", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            self.inputDate = textField
            self.inputDate.placeholder = "Decide what we will remind it to you"
            self.inputDate.addTarget(self, action: #selector(self.validation), for: UIControl.Event.allEvents)
            self.datePicker.datePickerMode = .dateAndTime
            self.datePicker.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)
            self.inputDate.inputView = self.datePicker
        }
        alert.addTextField { (textField) in
            self.inputName = textField
            self.inputName.placeholder = "Reminder activity"
            self.inputName.addTarget(self, action: #selector(self.validation), for: UIControl.Event.allEvents)
        }
        alert.addTextField { (textField) in
            self.inputDesc = textField
            self.inputDesc.placeholder = "Describe your activity"
            self.inputDesc.addTarget(self, action: #selector(self.validation), for: UIControl.Event.allEvents)
        }
        
        addAction = (UIAlertAction(title: "Add", style: .default, handler: { (action : UIAlertAction!) in
            self.saveData(activity: self.inputName.text! as CKRecordValue, describe: self.inputDesc.text! as CKRecordValue, date: self.inputDate.text! as CKRecordValue)
            
            self.dismiss(animated: true, completion: nil)
            self.view.endEditing(true)
        }))
        
        addAction.isEnabled = false
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        
        
    }
    
    @objc func cancel(){
        self.dismiss(animated: true, completion: nil)
        view.endEditing(true)
    }
    
    @objc func validation(){
        
        if !(inputName.text!.isEmpty) && !(inputDesc.text!.isEmpty) && !(inputDate.text!.isEmpty) {
            addAction.isEnabled = true
            addActionUpdate.isEnabled = true
        }
        
        else if inputName.text!.isEmpty {
            addAction.isEnabled = false
            addActionUpdate.isEnabled = false
        }
        else if inputDesc.text!.isEmpty {
            addAction.isEnabled = false
            addActionUpdate.isEnabled = false
        }
        else if inputDate.text!.isEmpty {
            addAction.isEnabled = false
            addActionUpdate.isEnabled = false
        }
       
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayData.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cells") as! ReminderTableViewCell
        let rec : CKRecord = arrayData[indexPath.row]
        cell.lblTitle.text = (rec.value(forKey: "Activity") as! String)
        cell.lblSubtitle.text = (rec.value(forKey: "Describe") as! String)
        cell.lblClock.text = (rec.value(forKey: "Date") as! String)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
       let alert = UIAlertController(title: "Update your schedule", message: "This will update your previous reminder with the new one", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            self.inputDate = textField
            self.inputDate.placeholder = "Decide what we will remind it to you"
            self.inputDate.addTarget(self, action: #selector(self.validation), for: UIControl.Event.allEvents)
            self.datePicker.datePickerMode = .dateAndTime
            self.datePicker.addTarget(self, action: #selector(self.dateChanged(datePicker:)), for: .valueChanged)
            self.inputDate.inputView = self.datePicker
        }
        alert.addTextField { (textField) in
            self.inputName = textField
            self.inputName.placeholder = "Reminder activity"
            self.inputName.addTarget(self, action: #selector(self.validation), for: UIControl.Event.allEvents)
        }
        alert.addTextField { (textField) in
            self.inputDesc = textField
            self.inputDesc.placeholder = "Describe your activity"
            self.inputDesc.addTarget(self, action: #selector(self.validation), for: UIControl.Event.allEvents)
        }
        
        addActionUpdate = UIAlertAction(title: "Update", style: .default, handler: { (action : UIAlertAction) in
            
            let container = CKContainer.default()
            let publicDatabase = container.publicCloudDatabase
            
            let rec = self.arrayData[indexPath.row]
            
            publicDatabase.fetch(withRecordID: rec.recordID) { (record, error) in
                if (error != nil) {
                    print("error when fecthing database from cloud kit")
                }
                else {
                    DispatchQueue.main.async {
                        rec.setValue(self.inputName.text, forKey: "Activity")
                        rec.setValue(self.inputDesc.text, forKey: "Describe")
                        rec.setValue(self.inputDate.text, forKey: "Date")
                    }
                    let database = CKContainer.default().publicCloudDatabase
                    database.save(rec) { (rec, error) in
                        if error != nil {
                            print(error!.localizedDescription + "Error when saving data")
                        }
                        else {
                            print("succesfully save updated data")
                        }
                    }
                    
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.arrayData.removeAll()
                self.loadData()
                self.tableView.reloadData()
            })
            
             tableView.deselectRow(at: indexPath, animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
             tableView.deselectRow(at: indexPath, animated: true)
        }))
        
        alert.addAction(addActionUpdate)
        addActionUpdate.isEnabled = false
        self.present(alert, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let container = CKContainer.default()
        let publicDatabase = container.publicCloudDatabase
        
        
        if editingStyle == .delete {
            let rec = arrayData[indexPath.row]
            
            publicDatabase.delete(withRecordID: rec.recordID) { (returnRecord, error) in
                if error != nil {
                    print("Error when delete the data")
                }
                else {
                    DispatchQueue.global(qos: .background).async {
                        self.arrayData.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                }
            }
        }
    }
}
