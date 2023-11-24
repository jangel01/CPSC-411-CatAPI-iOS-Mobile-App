//
//  CatRepo.swift
//  CatAPIFinalProject
//
//  Created by Jason Angel on 11/23/23.
//

import Foundation
import CoreData

class CatRepo {
    let persistentContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "MyDatabaseModel")
        
        container.loadPersistentStores{
            (description, error) in
            
            if let error = error {
                print("CatRepo caught error loading persistent data store (Core Data)")
            } else {
                print("CatRepo successfully loaded persistent data store")
            }
        }
        
        return container
    }()
    
    var context: NSManagedObjectContext!
    var cats: [Cat] = []
    var catIndex = 0
    
    init(completion: @escaping(Result<[Cat], Error>) -> Void) {
        self.context = self.persistentContainer.viewContext
        
        self.context = self.persistentContainer.viewContext
        self.loadAllCats(completion: completion)
    }
    
    private func keepCatIndexInBounds() {
        if (self.catIndex < 0) {
            self.catIndex = self.cats.count - 1
        } else if (self.catIndex >= self.cats.count) {
            self.catIndex = 0
        }
    }
    
    func previousCat() {
        self.catIndex -= 1
        self.keepCatIndexInBounds()
    }
    
    func nextCat() {
        self.catIndex += 1
        self.keepCatIndexInBounds()
    }
    
    func currentCat() -> Cat? {
        if (self.cats.isEmpty) {
            return nil
        }
        
        self.keepCatIndexInBounds()
        
        return self.cats[self.catIndex]
    }
    
    func makeCat() -> Cat {
        return Cat(context: self.context)
    }
    
    func fetchAllCats(completion: @escaping(Result<[Cat], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Cat> = Cat.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Cat.name), ascending: false)]
        
        self.context.perform {
            do {
                let allCats = try self.context.fetch(fetchRequest)
                completion(.success(allCats))
            } catch {
                print("CatRepo::fetchAllCats caught an exception: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func loadAllCats(completion: @escaping(Result<[Cat], Error>) -> Void) {
        self.fetchAllCats {
            (fetchResult) in
            
            switch fetchResult {
            case let .success(fetchedCats):
                self.cats = fetchedCats
                print("CatRepo::loadAllCats got \(self.cats.count) cats")
                self.keepCatIndexInBounds()
                self.catIndex = 0
                completion(.success(fetchedCats))
            case let .failure(error):
                print("CatRepo::loadALlCats failed with error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func saveCat(cat: Cat, completion: @escaping(Result<[Cat], Error>) -> Void) {
        self.context.perform {
            do {
                try self.context.save()
                self.loadAllCats {
                    (loadResult) in
                    
                    switch (loadResult) {
                    case let .success(cats):
                        completion(.success(cats))
                        
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
            } catch {
                print("CatRepo::saveCat caught exception while trying to save cat: \(error)")
                completion(.failure(error))
            }
        }
    }
}
