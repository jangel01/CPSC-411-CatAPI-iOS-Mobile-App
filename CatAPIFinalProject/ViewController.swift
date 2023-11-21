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
        self.catAPIService.getSearchImages()
    }


}

