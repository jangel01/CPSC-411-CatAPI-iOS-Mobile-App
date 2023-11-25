//
//  CatSaveViewController.swift
//  CatAPIFinalProject
//
//  Created by Jason Angel on 11/23/23.
//

import Foundation
import UIKit

class CatSaveViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    
    var imageString: String!
    
    var catRepo: CatRepo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.catRepo = CatRepo {
            (initResult) in
            self.currentCatToViews()
        }
    }
    
    private func catToViews(cat: Cat?) {
        if let cat = cat {
            self.imageString = cat.imgPath
            
            let imageData = CatPersistence.loadFileFromUserFolder(fileName: self.imageString)
            if let data = imageData {
                self.nameLabel.text = cat.name
                self.amountLabel.text = cat.amount?.stringValue

                self.imageView.image = UIImage(data: data)
            }
            
        } else {
            self.nameLabel.text = ""
            self.amountLabel.text = ""
            self.imageString = ""
            self.imageView.image = nil
        }
    }
    
    private func currentCatToViews() {
        self.catToViews(cat: self.catRepo.currentCat())
    }
    
    @IBAction func prevButtonTapped(_ btn: UIButton) {
        self.catRepo.previousCat()
        self.currentCatToViews()
    }
    
    @IBAction func nextButtonTapped(_ btn: UIButton) {
        self.catRepo.nextCat()
        self.currentCatToViews()
    }
    
    @IBAction func refreshButtonTapped(_ btn: UIButton) {
        self.catRepo.loadAllCats {
            (result) in
            
            switch result {
            case .success(_):
                self.currentCatToViews()
            case let .failure(error):
                print("couldn't reload cats: \(error)")
            }
        }
    }
    
}
