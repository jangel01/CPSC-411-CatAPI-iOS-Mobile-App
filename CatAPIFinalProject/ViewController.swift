//
//  ViewController.swift
//  CatAPIFinalProject
//
//  Created by Jason Angel on 11/20/23.
//

import UIKit

class ViewController: UIViewController {

    var catAPIService: CatAPIService!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.catAPIService = CatAPIService()
        
        // grab some cat images
        self.catAPIService.getSearchImages {
            (getSearchResult) in
            
            switch getSearchResult {
            case let .success(images):
                print("Successfully found \(images.count) cat images!")
                if let firstImage = images.first {
                    print("First image is: \(firstImage.id)")
                }
            case let .failure(error):
                print("Error fetching random cat images: \(error)")
            }
        }
    }


}

