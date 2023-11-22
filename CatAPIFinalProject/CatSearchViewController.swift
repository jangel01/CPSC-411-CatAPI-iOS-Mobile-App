//
//  ViewController.swift
//  CatAPIFinalProject
//
//  Created by Jason Angel on 11/20/23.
//

import UIKit

class CatSearchViewController: UIViewController {

    @IBOutlet var searchImageView: UIImageView!
    
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
                    self.updateSearchImageView(for: firstImage)
                } else {
                    print("first image doesn't exist")
                }
            case let .failure(error):
                print("Error fetching random cat images: \(error)")
            }
        }
    }
    
    func updateSearchImageView(for image: SearchImagesData) {
        self.catAPIService.downloadSearchImage(for: image) {
            (imageResult) in
            
            switch imageResult {
            case let .success(image):
                print("Successfully downloaded search image: \(image)")
                self.searchImageView.image = image
            case let .failure(error):
                print("Error downloading image: \(error)")
            }
        }
    }


}

