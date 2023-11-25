//
//  ViewController.swift
//  CatAPIFinalProject
//
//  Created by Jason Angel on 11/20/23.
//

import UIKit

class CatSearchViewController: UIViewController {

    @IBOutlet var searchImageView: UIImageView!
    @IBOutlet var downvoteButton: UIButton!
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var nameInput: UITextField!
    @IBOutlet var amountInput: UITextField!
    
    var catAPIService: CatAPIService!
    var catRepo: CatRepo!
    var currentImageUrl: URL?
    var currentImageData: Data?
    
    var catSearchImages: [SearchImagesData]? = nil
    var currentImageIndex = 0
    
    static let NAME_INPUT_KEY = "text-input-state"
    static let AMOUNT_INPUT_KEY = "text-imput-state"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadAllPreferences()
        self.catAPIService = CatAPIService()
        self.catRepo = CatRepo {
            (initResult) in
        }
        self.nameInput.placeholder = "Ex. John"
        self.amountInput.placeholder = "$10.00"
        self.fetchCatImages()
    }
    
    @IBAction func saveAllPreferences(_ sender: UITextField) {
        
        let defaults = UserDefaults.standard
        
        defaults.set(
            self.nameInput.text, forKey: CatSearchViewController.NAME_INPUT_KEY
            )
        
        defaults.set(
            self.amountInput.text, forKey: CatSearchViewController.AMOUNT_INPUT_KEY
            )
    }
    
    func loadAllPreferences() {
        
        let defaults = UserDefaults.standard
        
        if (defaults.object(forKey: CatSearchViewController.NAME_INPUT_KEY) != nil)
        {
            self.nameInput.text = defaults.string(forKey: CatSearchViewController.NAME_INPUT_KEY)
        }
        
        if (defaults.object(forKey: CatSearchViewController.AMOUNT_INPUT_KEY) != nil)
        {
            self.amountInput.text = defaults.string(forKey: CatSearchViewController.AMOUNT_INPUT_KEY)
        }
        
    }
    
    func updateSearchImageView(for image: SearchImagesData) {
        self.currentImageUrl = image.url
        self.catAPIService.downloadSearchImage(for: image) {
            (imageResult) in
        
            switch imageResult {
            case let .success(image):
                print("Successfully downloaded search image: \(image)")
                self.searchImageView.image = image
                
                // try converting to jpg first
                if let imageData = image.jpegData(compressionQuality: 1.0) {
                    self.currentImageData = imageData
                }
                // try converting to png
                else if let imageData = image.pngData() {
                    self.currentImageData = imageData
                } else {
                    print("Error grabbing current image data")
                }
            case let .failure(error):
                print("Error downloading image: \(error)")
            }
        }
    }
    
    func fetchCatImages() {
        self.catAPIService.getSearchImages {
            (getSearchResult) in
            
            switch getSearchResult {
            case let .success(images):
                print("Successfully found \(images.count) cat images!")
                self.catSearchImages = images
                self.currentImageIndex = 0
                
                if !images.isEmpty {
                    self.updateSearchImageView(for: images[self.currentImageIndex])
                    self.toggleVoteButtons(true)
                } else {
                    print("there are no search images to view")
                    self.hideViews()
                }
            case let .failure(error):
                print("Error fetching random cat images: \(error)")
            }
        }
    }
    
    @IBAction func prevButtonTapped(_ btn: UIButton) {
        if let catSearchImages = self.catSearchImages {
            if !catSearchImages.isEmpty {
                if currentImageIndex > 0 {
                    self.currentImageIndex -= 1
                } else {
                    currentImageIndex = catSearchImages.count - 1
                }
                            
                updateSearchImageView(for: catSearchImages[self.currentImageIndex])
                self.toggleVoteButtons(true)
            } else {
                print("error: there are no search image to traverse")
            }
        } else {
            print("error: the search image array seems to be nil")
        }
    }
    
    @IBAction func nextButtonTapped(_ btn: UIButton) {
        if let catSearchImages = self.catSearchImages {
            if !catSearchImages.isEmpty {
                if self.currentImageIndex < catSearchImages.count - 1 {
                    self.currentImageIndex += 1
                } else {
                    self.currentImageIndex = 0
                }

                updateSearchImageView(for: catSearchImages[self.currentImageIndex])
                self.toggleVoteButtons(true)
            } else {
                print("erro: there are no search image to traverse")
            }
            
        } else {
            print("error: the search image array seems to be nil")
        }
    }
    
    @IBAction func rerollButtonTapped(_ btn: UIButton) {
        fetchCatImages()
    }
    
    @IBAction func upvoteButtonTapped(_ btn: UIButton) {
        if let catSearchImages = self.catSearchImages {
            if !catSearchImages.isEmpty {
                self.catAPIService.voteOnImage(imageId: catSearchImages[currentImageIndex].id, value: 1) {
                    (voteResult) in
                    
                    switch voteResult {
                    case let .success(result):
                        print("upvoted cat image! \(result.imageId), status: \(result.message)")
                        self.toggleVoteButtons(false)
                        
                        let alert = UIAlertController(title: "Vote recorded!", message: "You have upvoted the image", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    case let .failure(error):
                        print("Failed to upvote image: \(error)")
                    }
                }
            } else {
                print("error: there is no search image to upvote")
            }
        } else {
            print("error: search image array seems to be nil")
        }
    }
    
    @IBAction func downvoteButtonTapped(_ btn: UIButton) {
        if let catSearchImages = self.catSearchImages {
            if !catSearchImages.isEmpty {
                self.catAPIService.voteOnImage(imageId: catSearchImages[currentImageIndex].id, value: -1) {
                    (voteResult) in
                    
                    switch voteResult {
                    case let .success(result):
                        print("downvoted cat image! \(result.imageId), status: \(result.message)")
                        self.toggleVoteButtons(false)
                        
                        let alert = UIAlertController(title: "Vote recorded!", message: "You have downvoted the image", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    case let .failure(error):
                        print("Failed to downvote image: \(error)")
                    }
                }
            } else {
                print("error: there is no search image to downvote")
            }
        } else {
            print("error: the search image aaray seems to be nil")
        }
    }
    
    func toggleVoteButtons(_ btnState: Bool) {
        self.upvoteButton.isEnabled = btnState
        self.downvoteButton.isEnabled = btnState
    }
    
    private func viewToCat(cat: Cat) -> Bool {
        
        if let name = self.nameInput.text, let amount = self.amountInput.text, !name.isEmpty, !amount.isEmpty {
            if let urlAsString = currentImageUrl?.absoluteString, let data = self.currentImageData {
                cat.name = name
                cat.amount = NSDecimalNumber(string: amount)

                let url = URL(string: urlAsString)
                if let urlSafe = url {
                    let filename = urlSafe.lastPathComponent
                    cat.imgPath = urlAsString
                    CatPersistence.saveFileToUserFolder(fileName: filename, data: data)
                    
                    let alert = UIAlertController(title: "Cat saved!", message: "You have saved the cat image and information", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    print("error: couldn't save to user folder -- url is innvalid")
                }
            }
            return true
        } else {
            print("Unable to parse Cat from views; one or more was blank or invalid, or there is an issue with the image url")
        }
        return false
    }
    
    @IBAction func saveButtonTapped(_ btn: UIButton) {
        let cat = self.catRepo.makeCat()
        if (self.viewToCat(cat: cat)) {
            self.catRepo.saveCat(cat: cat) {
                (saveResult) in
            }
        }
    }
    
    func hideViews() {
        self.searchImageView = nil
    }
}

