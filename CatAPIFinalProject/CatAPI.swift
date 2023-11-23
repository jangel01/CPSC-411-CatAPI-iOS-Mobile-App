//
//  CatAPI.swift
//  CatAPIFinalProject
//
//  Created by Jason Angel on 11/20/23.
//

import Foundation

enum EndPoint: String {
    case search = "images/search"
    case vote = "votes"
}

class CatAPI {
    public static let baseURLString = "https://api.thecatapi.com/v1/"
    public static let apiKey = "live_ZQ3B38vSAAFigt7lF03OkIBGFR4qIs5z9AzDN9KhkCtbgshWURlRP3i8DMRVLblO"
    
    static var searchURL: URL {
        return CatURL(endPoint: .search, parameters: ["size":"small", "has_breeds":"false", "include_breeds":"0", "include_categories":"0", "limit":"10", "mime_types":"jpg,png"])
    }
    
    static var imageVoteURL: URL {
        return CatURL(endPoint: .vote, parameters: nil)
    }
    
    static var votesURL: URL {
        return CatURL(endPoint: .vote, parameters: ["order": "DESC", "limit": "10"])
    }
    
    private static func CatURL(endPoint: EndPoint, parameters: [String:String]?) -> URL {
        let endpoint = self.baseURLString + endPoint.rawValue
        
        var components = URLComponents(string: endpoint)!
        var queryItems = [URLQueryItem]()
        
        let baseQueryParamters = [
            "dummy": "value"
        ]
        
        for (key, value) in baseQueryParamters {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParamters = parameters {
            for (key, value) in additionalParamters {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        
        components.queryItems = queryItems
        
        return components.url!
    }
    
    static func encodeHttpPostBody(paramters: [String:Any]) -> Data {
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: paramters, options: [])
            return jsonData
        } catch {
            print("Error encoding JSON for http body: \(error)")
            return Data()
        }
    }
    
    static func searchImages(fromJSON data: Data) -> Result<[SearchImagesData], Error>  {
        do {
            let decoder = JSONDecoder()

            let getSearchImagesResponse = try decoder.decode([SearchImagesData].self, from: data)

            let catSearchImages = getSearchImagesResponse.filter {
                $0.url != nil
            }
            
            return .success(catSearchImages)
        } catch {
            return .failure(error)
        }
    }
    
    static func votes(fromJSON data: Data) -> Result<[VotesData], Error>  {
        do {
            let decoder = JSONDecoder()

            let getVotesResponse = try decoder.decode([VotesData].self, from: data)

            let voteImages = getVotesResponse.filter {
                $0.image.url != nil
            }
            
            return .success(voteImages)
        } catch {
            return .failure(error)
        }
    }
    
    static func imageVote(fromJSON data: Data) -> Result<ImageVoteData, Error> {
        do {
            let decoder = JSONDecoder()
            
            let imageVoteResponse = try decoder.decode(ImageVoteData.self, from: data)
            
            return .success(imageVoteResponse)
        } catch {
            return .failure(error)
        }
    }
    
}

struct SearchImagesData: Codable {
    let id: String
    let url: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
    }
}

struct ImageVoteData: Codable {
    let message: String
    let id: Int
    let imageId: String
    let value: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case id
        case imageId = "image_id"
        case value
    }
}

struct VotesData: Codable {
    let value: Int
    let image: VoteImageData
    
    enum CodingKeys: String, CodingKey {
        case value
        case image
    }
}

struct VoteImageData: Codable {
    let id: String
    let url: URL?
    
    enum CodingKeys: String, CodingKey {
        case id
        case url
    }
}
