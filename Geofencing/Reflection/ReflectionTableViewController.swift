//
//  ReflectionTableViewController.swift
//  Geofencing
//
//  Created by Patrick Leonardus on 18/09/19.
//  Copyright © 2019 Patrick Leonardus. All rights reserved.
//

import UIKit
import CloudKit

class ReflectionTableViewController: UITableViewController {
    
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputDesc: UITextView!
    
    var size = CGSize()
    var newSize = CGSize()
    
    var btnOK = UIBarButtonItem()
    
    var titleText = ["What did you learn today?",
                    "Share your day here",
                    "Do you learn something new?",
                    "How was your day?"]

    override func viewDidLoad() {
        super.viewDidLoad()

        btnOK = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(ok))
        let btnCancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = btnOK
        navigationItem.leftBarButtonItem = btnCancel
        btnOK.isEnabled = false
        
        tableView.tableFooterView = UIView()
        tableView = UITableView.init(frame: CGRect.zero, style: .grouped)
        
        inputDesc.delegate = self
        inputDesc.text = "Activity"
        inputDesc.textColor = #colorLiteral(red: 0.7805331349, green: 0.7801250815, blue: 0.8018200994, alpha: 1)
        
        inputName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = titleText.randomElement()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if !(inputName.text!.isEmpty) && inputDesc!.text != "Activity" {
            btnOK.isEnabled = true
        }
        else if inputName.text!.isEmpty {
            btnOK.isEnabled = false
        }
            
        else if inputDesc.text! == "Activity" {
            btnOK.isEnabled = false
        }
        else if inputDesc.text!.isEmpty {
            btnOK.isEnabled = false
        }
    }
    
    @objc func closeKeyboard(){
        view.endEditing(true)
    }
    
    @objc func ok(){
        saveData(title: inputName.text! as CKRecordValue, description: inputDesc.text! as CKRecordValue, dateTime: DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none) as CKRecordValue)
        self.dismiss(animated: true, completion: nil)
        view.endEditing(true)
    }
    
    @objc func cancel(){
        self.dismiss(animated: true, completion: nil)
        view.endEditing(true)
    }
    
    func saveData(title : CKRecordValue, description : CKRecordValue, dateTime : CKRecordValue){
        let record = CKRecord(recordType: "Reflection")
        record["title"] = title
        record["description"] = description
        record["date"] = dateTime
        
        
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
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none)
        }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var height : CGFloat = 0
        
        if indexPath.row == 0 {
            height = UITableView.automaticDimension
        }
        else if indexPath.row == 1 {
            height = 450
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension ReflectionTableViewController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if inputDesc.text == "Activity" {
            inputDesc.text = nil
            inputDesc.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if inputDesc.text.isEmpty {
            inputDesc.text = "Activity"
            inputDesc.textColor = #colorLiteral(red: 0.7805331349, green: 0.7801250815, blue: 0.8018200994, alpha: 1)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if !(inputName.text!.isEmpty) && !(inputDesc.text!.isEmpty) && inputDesc!.text != "Activity" {
            btnOK.isEnabled = true
        }
        else if inputName.text!.isEmpty {
            btnOK.isEnabled = false
        }
        
        else if inputDesc.text! == "Activity" {
            btnOK.isEnabled = false
        }
        else if inputDesc.text!.isEmpty {
            btnOK.isEnabled = false
        }
        else {
            btnOK.isEnabled = false
        }
    }
}
