//
//  HomeReminderTableViewCell.swift
//  Geofencing
//
//  Created by Patrick Leonardus on 20/09/19.
//  Copyright © 2019 Patrick Leonardus. All rights reserved.
//

import UIKit
import CloudKit

class HomeReminderTableViewCell: UITableViewCell {
    
    var arrayData : Array<CKRecord> = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.delegate = self
        collectionView.dataSource = self
        loadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
            }
        }

    }

}

extension HomeReminderTableViewCell : UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reminderCollectionView", for: indexPath) as! InsideReminderCollectionViewCell

        if !(arrayData.isEmpty){
            let rec : CKRecord = arrayData[indexPath.row]

            cell.inputName.text = (rec.value(forKey: "Activity") as! String)
            cell.inputTime.text = (rec.value(forKey: "Date") as! String)
        }

        else {
            cell.inputName.text = "Make reminder first"
            cell.inputTime.text = "No Data Found"
        }
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = false
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        cell.layer.shadowRadius = 2.5
        cell.layer.shadowOpacity = 0.8
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath

        return cell
    }


}
