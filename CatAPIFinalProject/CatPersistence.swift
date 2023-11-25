//
//  CatPersistence.swift
//  CatAPIFinalProject
//
//  Created by Jason Angel on 11/23/23.
//

import CryptoKit
import Foundation

class CatPersistence {

    private static var catApiService = CatAPIService()
    
    public static func stringToHashString(_ s: String) -> String {
            var hashString: String = ""
            
            if let data = s.data(using: String.Encoding.utf8) {
                let hash = SHA512.hash(data: data)
                print("SHA512 hash of \(s) is \(hash)")
                
                hashString = hash.map {
                    String(format: "%03hhx", $0)
                }.joined()
            } else {
                print("Unable to decode string to data for hash")
            }
            
            return hashString
        }
        
        public static func makeFileCacheURL(_ fileKey: String) -> URL {
            return CatPersistence.makeUserDomainFileURL(fileKey, searchPath: FileManager.SearchPathDirectory.cachesDirectory, convertToHash: true)
        }
        
        public static func makeUserDomainFileURL(_ fileKey: String, searchPath: FileManager.SearchPathDirectory, convertToHash: Bool) -> URL {
            let dirs = FileManager.default.urls(for: searchPath, in: FileManager.SearchPathDomainMask.userDomainMask)
            
            let dir = dirs.first!
            
            var fileURL: URL
            if(convertToHash == true) {
                let fileNameHash = CatPersistence.stringToHashString(fileKey)
                fileURL = dir.appendingPathComponent(fileNameHash)
            } else {
                let keyURL = URL(string: fileKey)
                if let keyURLSafe = keyURL {
                    fileURL = dir.appendingPathComponent(keyURLSafe.lastPathComponent)
                } else {
                    fileURL = URL(string: "invalid")!
                }
            }
            print("File URL for \(fileKey) is \(fileURL)")
            
            return fileURL
        }
        
        public static func isFileInCache(_ fileKey: String) -> Bool {
            let cacheURL = CatPersistence.makeFileCacheURL(fileKey)
            
            let exists = FileManager.default.fileExists(atPath: cacheURL.path)
            
            return exists
        }
        
        public static func saveFileToCache(_ fileKey: String, fileData: Data?) {
            if let fileDataSafe = fileData {
                let cacheURL = CatPersistence.makeFileCacheURL(fileKey)
                
                do {
                    try fileDataSafe.write(to: cacheURL, options: NSData.WritingOptions.atomic)
                    
                    print("Successfully save file \(fileKey) to cache")
                }
                catch {
                    print("Failed to save file \(fileKey) to cache \(error)")
                }
            } else {
                print("Unable to save file to cache: File data was nil")
            }
        }
        
        public static func loadFileFromCache(_ fileKey: String) -> Data? {
            let cacheURL = CatPersistence.makeFileCacheURL(fileKey)
            do {
                let fileData = try Data(contentsOf: cacheURL)
                print("Successfully loaded filekey from cache: \(fileKey)")
                return fileData
            } catch {
                print("Failed to load fileKey from cache: \(fileKey)")
                return nil
            }
        }
        
    public static func loadFileToCache(image: VotesData, completion: @escaping (Data) -> ()) {
        if let urlString = image.image.url?.absoluteString {
                catApiService.downloadVoteImage(for: image) {
                    (imageResult) in
                    
                    switch imageResult {
                    case let .success(image):
                        print("Successfully downloaded vote image: \(image)")
                        
                        // try converting to jpg first
                        if let imageData = image.jpegData(compressionQuality: 1.0) {
                            
                            self.saveFileToCache(urlString, fileData: imageData)
                                                        
                            OperationQueue.main.addOperation {
                                completion(imageData)
                            }
                        }
                        // try converting to png
                        else if let imageData = image.pngData() {
                            self.saveFileToCache(urlString, fileData: imageData)
                                                        
                            OperationQueue.main.addOperation {
                                completion(imageData)
                            }
                        } else {
                            print("Error converting image to JPEG or PNG data")
                        }
                                        
                    case let .failure(error):
                        print("Error downloading image: \(error)")
                        print("Error loading file to cache")
                    }
                }
            } 
        }
        
        public static func makeFileDocumentsURL(_ filekey: String) -> URL {
            return CatPersistence.makeUserDomainFileURL(filekey, searchPath: FileManager.SearchPathDirectory.documentDirectory, convertToHash: false)
        }
        
        public static func saveFileToUserFolder(fileName: String, data: Data?) {
            if let fileData = data {
                let fileURL = CatPersistence.makeFileDocumentsURL(fileName)
                do {
                    try fileData.write(to: fileURL, options:NSData.WritingOptions.atomic)
                    print("Successfully saved file \"\(fileName)\" to locale dir: \(fileURL)")
                } catch {
                    print("Failed to save file \"\(fileName)\": \(error)")
                }
            } else {
                print("Refusing to save nil file data to user folder")
            }
        }
    
    public static func loadFileFromUserFolder(fileName: String) -> Data? {
        let fileURL = CatPersistence.makeFileDocumentsURL(fileName)
        do {
            let fileData = try Data(contentsOf: fileURL)
            print("Successfully loaded image file \"\(fileName)\" from the user directory: \(fileURL)")
            return fileData
        } catch {
            print("Failed to load image file \"\(fileName)\": \(error)")
            return nil
        }
    }
}
