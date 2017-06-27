//
//  MenuBar.swift
//  Pluto
//
//  Created by Faisal M. Lalani on 6/27/17.
//  Copyright © 2017 Faisal M. Lalani. All rights reserved.
//

import UIKit

class MenuBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UI Components
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        let colView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colView.backgroundColor = UIColor.white
        colView.translatesAutoresizingMaskIntoConstraints = false
        colView.dataSource = self
        colView.delegate = self
        return colView
    }()
    
    let horizontalUnderlineBarView: UIView = {
        
        let horizontalBarView = UIView()
        horizontalBarView.backgroundColor = UIColor.black
        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        
        return horizontalBarView
    }()
    
    // MARK: - Global Variables
    
    let cellId = "menuBarCell"
    let cellIconImageNames = ["ic_room", "ic_forum", "ic_account_circle", "ic_dehaze"]
    
    // MARK: - View Configuration
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Change the background color of the bar.
        backgroundColor = UIColor.white
        
        // Add the UI components to the view.
        addSubview(collectionView)
        addSubview(horizontalUnderlineBarView)
        
        // Set up the constraints for the UI components.
        setUpCollectionView()
        setUpHorizontalUnderlineBarView()
        
        // Register the custom MenuCell class for the collection view cells.
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpCollectionView() {
        
        // Add X, Y, width, and height constraints to the collectionView.
        collectionView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        collectionView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    // This needs to be declared here so we can change them with when the user selects another tab in the menuBar.
    var horizontalUnderlineBarViewLeftAnchor: NSLayoutConstraint?
    
    func setUpHorizontalUnderlineBarView() {
        
        // Add X, Y, width, and height constraints to the horizontalUnderlineBarView.
        horizontalUnderlineBarViewLeftAnchor = horizontalUnderlineBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalUnderlineBarViewLeftAnchor?.isActive = true
        horizontalUnderlineBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        horizontalUnderlineBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/4).isActive = true
        horizontalUnderlineBarView.heightAnchor.constraint(equalToConstant: 4).isActive = true
    }
    
    // MARK: - Collection View Functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: frame.width/4, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        // Spacing between each cell needs to be reduced to zero.
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        
        // Set the icon image of the cell to the corresponding image name.
        cell.iconImageView.image = UIImage(named: "\(cellIconImageNames[indexPath.row])")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let xValue = CGFloat(indexPath.item) * frame.width/4
        
        // Move the horizontalUnderlineBarView to other cells.
        horizontalUnderlineBarViewLeftAnchor?.constant = xValue
        
        // Add an animation to the horizontalUnderlineBarView so it slides over when moved.
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.layoutIfNeeded()
            
        }, completion: nil)
    }
}
