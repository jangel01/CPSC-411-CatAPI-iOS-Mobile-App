//
//  CatAPIService.swift
//  CatAPIFinalProject
//
//  Created by Jason Angel on 11/20/23.
//

import Foundation
import UIKit

class CatAPIService {
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func getSearchImages() {
        let url = CatAPI.searchURL
        
        var request = URLRequest(url: url)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(CatAPI.apiKey, forHTTPHeaderField: "x-api-key")
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            if let jsonData = data {
                if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                    print(jsonString)
                } else if let requestError = error {
                    print("Error fetching cat images: \(requestError)")
                } else {
                    print("Unexpected error with the request")
                }
            }
        }
        task.resume()
    }
}
