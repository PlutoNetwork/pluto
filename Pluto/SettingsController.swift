//
//  SettingsController.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 7/10/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import Firebase

class SettingsController: FormViewController {
    
    // MARK: - UI Components
    
    lazy var saveButtonItem: UIBarButtonItem = {
        
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleUpdateUserData))
        
        return button
    }()
    
    func handleUpdateUserData() {
        
        // Check if the user has filled out all the required fields.
        if form.validate().isEmpty {
            
            let imageRow: ImageRow! = form.rowBy(tag: "profileImage")
            
            if imageSelected {
            
                // Upload the new profile pic and save the new data.
                uploadProfilePicToFirebase(image: imageRow.value!)
                
            } else if valueChanged {
                
                // Update the event.
                DataService.ds.REF_CURRENT_USER.updateChildValues(self.userValuesDictionary)
            }
            
            // Dismiss the view controller.
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Global Variables
    
    var userProfileImage: UIImage?
    var userValuesDictionary = [String: AnyObject]()
    var imageSelected = false
    var valueChanged = false
    
    // MARK: - View Configuration
    
    fileprivate func navigationBarCustomization() {
        
        // Set the navigationItem's title.
        navigationItem.title = "Settings"
        
        // Set the color of the navigationItem to white.
        let colorAttribute = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = colorAttribute
        
        navigationItem.rightBarButtonItems = [saveButtonItem]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarCustomization()
        
        // Customize the view.
        tableView.backgroundColor = HIGHLIGHT_COLOR
        tableView.separatorColor = LIGHT_BLUE_COLOR
        
        grabUserData()
    }
    
    func grabUserData() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        UserService.sharedInstance.fetchUserData(withKey: uid) { (user) in
            
            self.userValuesDictionary = ["profileImageUrl": user.profileImageUrl as AnyObject,
                                         "name": user.name as AnyObject]
            
            self.setUpForm()
        }
    }
  
    func setUpForm() {
        
        form
            +++ Section()
            <<< ImageRow() {
                $0.title = "Profile picture"
                $0.tag = "profileImage"
                $0.cell.backgroundColor = DARK_BLUE_COLOR
                $0.value = userProfileImage
                $0.sourceTypes = .PhotoLibrary
                $0.clearAction = .no
            }
            .cellUpdate { cell, row in
            
                cell.height = ({return 80})
                cell.textLabel?.textColor = WHITE_COLOR
                cell.accessoryView?.layer.cornerRadius = 35
                cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
            }.onChange({ _ in
                
                self.imageSelected = true
            })
        
            +++ Section()
            <<< NameRow() {
                $0.title = "Name"
                $0.cell.backgroundColor = DARK_BLUE_COLOR
                $0.value = (userValuesDictionary["name"] as? String)
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.cellUpdate { (cell, row) in
                    
                    cell.titleLabel?.textColor = WHITE_COLOR
                    cell.textField.textColor = WHITE_COLOR
                    cell.tintColor = WHITE_COLOR
                    
                    if !row.isValid {
                        
                        // The row is empty, notify the user by highlighting the label.
                        cell.titleLabel?.textColor = UIColor.red
                    }
                }
                $0.onChange({ row in
                    
                    self.valueChanged = true
                    
                    // Save the value to the userValuesDictionary.
                    self.userValuesDictionary["name"] = row.value as AnyObject
                })
            }
    }

    func uploadProfilePicToFirebase(image: UIImage) {
        
        // Upload the selected profile pic to Firebase.
        if let uploadData = UIImagePNGRepresentation(image) {
            
            DataService.ds.REF_PROFILE_PICS.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    
                    print("ERROR: could not upload profile pic to Firebase. Details: \(error.debugDescription)")
                    
                    SCLAlertView().showError("Whoops!", subTitle: "Pluto couldn't upload your profile picture. Try again later.")
                    
                    return
                }
                
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    
                    // Update the user values dictionary.
                    self.userValuesDictionary["profileImageUrl"] = profileImageUrl as AnyObject
                    
                    // Update the event.
                    DataService.ds.REF_CURRENT_USER.updateChildValues(self.userValuesDictionary)
                }
            })
        }
    }
}
