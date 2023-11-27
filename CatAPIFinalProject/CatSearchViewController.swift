//
//  ViewController.swift
//  CatAPIFinalProject
//
//  Created by Jason Angel on 11/20/23.
//

import UIKit
import AVFoundation
import FacebookCore
import FacebookLogin

class CatSearchViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var searchImageView: UIImageView!
    @IBOutlet var downvoteButton: UIButton!
    @IBOutlet var upvoteButton: UIButton!
    @IBOutlet var nameInput: UITextField!
    @IBOutlet var amountInput: UITextField!
    @IBOutlet var saveButton: UIButton!
    
    var catAPIService: CatAPIService!
    var catRepo: CatRepo!
    var currentImageUrl: URL?
    var currentImageData: Data?
    
    var catSearchImages: [SearchImagesData]? = nil
    var currentImageIndex = 0
    var audio: AVAudioPlayer?
    
    static let NAME_INPUT_KEY = "text-input-state"
    static let AMOUNT_INPUT_KEY = "text-imput-state"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadAllPreferences()
        self.catAPIService = CatAPIService()
        self.catRepo = CatRepo {
            (initResult) in
        }
        self.nameInput.placeholder = NSLocalizedString("placeholder_name", comment: "")
        self.amountInput.placeholder = NSLocalizedString("placeholder_amount", comment: "")

        self.fetchCatImages()
        
        nameInput.delegate = self
        amountInput.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountInput{
            let currentLocale = Locale.current
            let decimalSeparator = currentLocale.decimalSeparator ?? "."
            
            let existingTextHasDecimal = textField.text?.range(of: decimalSeparator)
            let replacementTextHasDecimal = string.range(of: decimalSeparator)
            
            if existingTextHasDecimal != nil,
               replacementTextHasDecimal != nil {
                return false
            } else {
                return true
            }
        }
        else if textField == nameInput{
            let letters = CharacterSet.letters
            if string.rangeOfCharacter(from: letters.inverted) != nil{
                return false
            }
            return true
        }
        return false
    }
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.nameInput.resignFirstResponder()
        self.amountInput.resignFirstResponder()
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
                    self.saveButton.isEnabled = true
                    self.resetInputs()
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
                self.resetInputs()
                self.saveButton.isEnabled = true
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
                self.resetInputs()
                self.saveButton.isEnabled = true
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
                        
                        self.triggerSound(str: "hungry")
                        
                        let alertTitle = NSLocalizedString("alert_title_vote_recorded", comment: "")
                        let alertMessage = NSLocalizedString("alert_message_upvote", comment: "")
                        let alertOkActionTitle = NSLocalizedString("alert_action_ok", comment: "")

                        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: alertOkActionTitle, style: .default, handler: nil))

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
                        
                        self.triggerSound(str: "angry")
                        
                        let alertTitle = NSLocalizedString("alert_title_vote_recorded", comment: "")
                        let alertMessage = NSLocalizedString("alert_message_downvote", comment: "")
                        let alertOkActionTitle = NSLocalizedString("alert_action_ok", comment: "")

                        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: alertOkActionTitle, style: .default, handler: nil))

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
                    
                    self.triggerSound(str: "purr")
                    
                    let alertTitle = NSLocalizedString("alert_title_cat_saved", comment: "")
                    let alertMessage = NSLocalizedString("alert_message_cat_saved", comment: "")
                    let alertOkActionTitle = NSLocalizedString("alert_action_ok", comment: "")

                    let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: alertOkActionTitle, style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    self.saveButton.isEnabled = false
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
    
    
/*      //old code for oAuth
        @IBAction func facebookButtonTapped(_ sender: Any) {
        // 登录facebook
        let login = LoginManager.init()
        login.logIn(permissions: ["public_profile"], from: self) { (result, error) in
            print(result?.token?.appID)
            print(result?.token?.userID)
          
            /// id,name,email,age_range,first_name,last_name,link,gender,locale,picture,timezone,updated_time,verified
            let request = GraphRequest.init(graphPath: result!.token!.userID, parameters: ["fields": "name"], httpMethod: HTTPMethod.get)
            request.start { result,one,two  in
                print(result)
                print(one)
                let alertController = UIAlertController(title: "Message", message: "\(one)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }*/
    
    //new code for oAuth
    @IBAction func facebookButtonTapped(_ sender: Any) {
        // Initialize Facebook Login Manager
        let login = LoginManager()

        // Perform Facebook login
        login.logIn(permissions: ["public_profile"], from: self) { [weak self] (result, error) in
            // Check for any errors
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                return
            }

            // Safely unwrap the token
            guard let token = result?.token else {
                print("Error: Unable to retrieve token")
                return
            }

            // Extract userID from the token
            let userID = token.userID
            print("App ID: \(token.appID)")
            print("User ID: \(userID)")

            // Setup the Graph Request
            let request = GraphRequest(graphPath: userID, parameters: ["fields": "name"], tokenString: token.tokenString, version: nil, httpMethod: .get)
            
            // Start the Graph Request
            request.start { _, result, error in
                // Check for any errors
                if let error = error {
                    print("Graph request error: \(error.localizedDescription)")
                    return
                }

                // Handle the result
                if let result = result {
                    print("Graph Request Result: \(result)")
                } else {
                    print("Graph Request returned no result")
                }

                // Show an alert with the result
                guard let strongSelf = self else { return }
                let message = result != nil ? "\(result!)" : "No data"
                let alertController = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alertController.addAction(okAction)
                strongSelf.present(alertController, animated: true, completion: nil)
            }
        }
    }

    
    func hideViews() {
        self.searchImageView = nil
    }
    
    func resetInputs() {
        self.amountInput.text = ""
        self.nameInput.text = ""
        // just pass either input field -- doesn't matter
        self.saveAllPreferences(self.nameInput)
    }
    
    func triggerSound(str: String?) {
        var effect: String?
        switch str {
        case "angry": effect = Bundle.main.path(forResource: "meow/mixkit-angry-cartoon-kitty-meow-94", ofType: "wav")
        case "purr": effect = Bundle.main.path(forResource: "meow/mixkit-big-wild-cat-long-purr-96", ofType: "wav")
        case "hungry": effect = Bundle.main.path(forResource: "meow/mixkit-domestic-cat-hungry-meow-45", ofType: "wav")
        default: print("error")
        }
        
        let soundURL = URL(fileURLWithPath: effect ?? "")
        do {
        audio = try AVAudioPlayer(contentsOf: soundURL)
        audio?.play()
        } catch {
            print("error")
        }
    }
}

