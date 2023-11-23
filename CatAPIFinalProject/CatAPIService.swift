//
//  CatAPIService.swift
//  CatAPIFinalProject
//
//  Created by Jason Angel on 11/20/23.
//

import Foundation
import UIKit

enum CatError: Error {
    case getSearchImangesError
    case getVotesError
    case missingImageURL
    case imageCreationError
}

class CatAPIService {
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func getSearchImages(completion: @escaping (Result<[SearchImagesData], Error>) -> Void) {
        let url = CatAPI.searchURL
        
        var request = URLRequest(url: url)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(CatAPI.apiKey, forHTTPHeaderField: "x-api-key")
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            let result = self.processGetSearchImagesResult(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    func getVotes(completion: @escaping (Result<[VotesData], Error>) -> Void) {
        let url = CatAPI.votesURL
        var request = URLRequest(url: url)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(CatAPI.apiKey, forHTTPHeaderField: "x-api-key")
        
        let task = self.session.dataTask(with: request) {
            (data, response, error) in
            
            let result = self.processGetVotesResult(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        
        task.resume()
    }
    
    func voteOnImage(imageId: String, value: Int, completion: @escaping(Result<ImageVoteData, Error>) -> Void) {
        let url = CatAPI.imageVoteURL
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(CatAPI.apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = CatAPI.encodeHttpPostBody(paramters: [
            "image_id": imageId,
            "value": value
        ])
                
        let task = self.session.dataTask(with: request) {
            (data, response, error) in
            
            let result = self.processImageVoteResult(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    private func processGetSearchImagesResult(data: Data?, error: Error?) -> Result<[SearchImagesData], Error> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return CatAPI.searchImages(fromJSON: jsonData)
    }
    
    private func processGetVotesResult(data: Data?, error: Error?) -> Result<[VotesData], Error> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return CatAPI.votes(fromJSON: jsonData)
    }
    
    private func processImageVoteResult(data: Data?, error: Error?) -> Result<ImageVoteData, Error> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return CatAPI.imageVote(fromJSON: jsonData)
    }
    
    func downloadSearchImage(for image: SearchImagesData, completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let imageURL = image.url {
            self.downloadImage(url: imageURL, completion: completion)
        } else {
            completion(.failure(CatError.missingImageURL))
        }
    }
    
    func downloadVoteImage(for image: VotesData, completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let imageURL = image.image.url {
            self.downloadImage(url: imageURL, completion: completion)
        } else {
            completion(.failure(CatError.missingImageURL))
        }
    }
    
    private func downloadImage(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            let result = self.processImageDownloadResult(data: data, error: error)
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        
        task.resume()
    }
    
    func processImageDownloadResult(data: Data?, error: Error?) -> Result<UIImage, Error> {
        guard let imageData = data, let image = UIImage(data: imageData) else {
            if data == nil {
                return .failure(error!)
            } else {
                return .failure(CatError.imageCreationError)
            }
        }
        
        return .success(image)
    }
}
