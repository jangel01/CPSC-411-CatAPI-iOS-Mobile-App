//
//  CatVotesViewController.swift
//  CatAPIFinalProject
//
//  Created by Jason Angel on 11/22/23.
//

import UIKit

class CatVotesViewController: UIViewController {
    
    @IBOutlet var voteImageView: UIImageView!
    @IBOutlet var voteStatusLabel: UILabel!
    // progammatic view
    var voteStatusAsset: UIImageView!
    var assetLeadingConstraintPortrait: NSLayoutConstraint!
    var assetLeadingConstraintLandscape: NSLayoutConstraint!
    
    var catAPIService: CatAPIService!
    
    var upvoteImages: [VotesData]? = nil
    var downvoteImages: [VotesData]? = nil
    var currentUpvoteIndex = 0
    var currentDownvoteIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.catAPIService = CatAPIService()
        
        self.fetchVoteImages()
    }
    
    override func loadView() {
        super.loadView()
        
        self.voteStatusAsset = UIImageView()
        self.voteStatusAsset.contentMode = .scaleAspectFit
        self.voteStatusAsset.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.voteStatusAsset)
        
        let assetTopConstraint = self.voteStatusAsset.topAnchor.constraint(equalTo: self.voteStatusLabel.bottomAnchor, constant: 30)
        self.assetLeadingConstraintPortrait = self.voteStatusAsset.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        self.assetLeadingConstraintLandscape = self.voteStatusAsset.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor, constant: 10)
        let assetTrailingConstraint = self.voteStatusAsset.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 10)
        
        assetTopConstraint.isActive = true
        assetTrailingConstraint.isActive = true
    }
    
    func fetchVoteImages() {
        self.catAPIService.getVotes {
            (getVotesResult) in
            
            switch getVotesResult {
            case let .success(votes):
                print("Successfully found \(votes.count) images that have votes!")
                self.upvoteImages = votes.filter {$0.value == 1}
                self.downvoteImages = votes.filter {$0.value == -1}
                self.currentUpvoteIndex = 0
                self.currentDownvoteIndex = 0
                
                let size = UIScreen.main.bounds.size
                
                if size.width < size.height {
                    // portrait
                    
                    self.toggleVoteAssetLeadingConstraint("portrait")

                    if let images = self.upvoteImages {
                        if !images.isEmpty {
                            self.updateVoteImageView(for: images.first!, true)
                            self.voteStatusAsset.image = UIImage(named: "thumbs-up.png")
                            self.voteStatusLabel.text = "You upvoted this image!"
                        } else {
                            print("there are no upvoted images to view")
                            self.hideViews()
                        }
                        
                    } else {
                        print("the upvote image array seems to be nil")
                    }
                } else {
                    // landscape
                    
                    self.toggleVoteAssetLeadingConstraint("landscape")
                    
                    if let images = self.downvoteImages {
                        if !images.isEmpty {
                            self.updateVoteImageView(for: images.first!, true)
                            self.voteStatusAsset.image = UIImage(named: "thumbs-down.png")
                            self.voteStatusLabel.text = "You downvoted this image!"
                        } else {
                            print("there are no downvoted images to view")
                            self.hideViews()
                        }
                    } else {
                        print("the downvote image array seems to be nil")
                    }
                }
            case let .failure(error):
                print("Error fetching images that have votes on them: \(error)")
            }
        }
    }
    
    func updateVoteImageView(for image: VotesData, _ first: Bool) {
        
        if first == true {
            if let urlAsString = image.image.url?.absoluteString {
                if CatPersistence.isFileInCache(urlAsString) == false {
                    CatPersistence.loadFileToCache(image: image) {
                        (fileData) in
                        
                        self.voteImageView.image = UIImage(data: fileData)
                    }
                } else {
                    if let data = CatPersistence.loadFileFromCache(urlAsString) {
                        self.voteImageView.image = UIImage(data: data)
                    } else {
                        print("Failed to load from cache: \(urlAsString)")
                    }
                }
            } else {
                print("Unable to load URL; specified string is invalid")
            }
        } else {
            self.catAPIService.downloadVoteImage(for: image) {
                (imageResult) in
            
                switch imageResult {
                case let .success(image):
                    print("Successfully downloaded vote image: \(image)")
                    self.voteImageView.image = image
                case let .failure(error):
                    print("Error downloading image: \(error)")
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if self.traitCollection.verticalSizeClass == .compact {
            // landscape orientation
            
            self.toggleVoteAssetLeadingConstraint("landscape")
            
            if let images = self.downvoteImages {
                if !images.isEmpty {
                    let isFirst = self.isIndexFirst(self.currentDownvoteIndex, "downvotes")
                    self.updateVoteImageView(for: images[self.currentDownvoteIndex], isFirst)
                    self.voteStatusAsset.image = UIImage(named: "thumbs-down.png")
                    self.voteStatusLabel.text = "You downvoted this image!"
                } else {
                    print("there are no downvoted images to view")
                    self.hideViews()
                }
            } else {
                print("the downvoted image array seems to be nil")
            }
        } else {
            // portrait orientation
            
            self.toggleVoteAssetLeadingConstraint("portrait")

            if let images = self.upvoteImages {
                if !images.isEmpty {
                    let isFirst = self.isIndexFirst(self.currentUpvoteIndex, "upvotes")
                    self.updateVoteImageView(for: images[self.currentUpvoteIndex], isFirst)
                    self.voteStatusAsset.image = UIImage(named: "thumbs-up.png")
                    self.voteStatusLabel.text = "You upvoted this image!"
                } else {
                    print("there are no upvoted images to view")
                    self.hideViews()
                }
            } else {
                print("the upvoted image array seems to be nil")
            }
        }
    }
    
    func toggleVoteAssetLeadingConstraint(_ s: String) {
        if s == "portrait" {
            self.assetLeadingConstraintPortrait.isActive = true
            self.assetLeadingConstraintLandscape.isActive = false
        } else if s == "landscape" {
            self.assetLeadingConstraintPortrait.isActive = false
            self.assetLeadingConstraintLandscape.isActive = true
        }
    }
    
    @IBAction func prevButtonTapped(_ btn: UIButton) {
        let size = UIScreen.main.bounds.size
        
        if size.width < size.height {
            // portrait
            if let images = self.upvoteImages {
                if !images.isEmpty {
                    if self.currentUpvoteIndex > 0 {
                        self.currentUpvoteIndex -= 1
                    } else {
                        self.currentUpvoteIndex = images.count - 1
                    }
                    
                    let isFirst = self.isIndexFirst(self.currentUpvoteIndex, "upvotes")
                    self.updateVoteImageView(for: images[self.currentUpvoteIndex], isFirst)
                } else {
                    print("error: there are no upvoted images to traverse")
                }
            } else {
                print("error: the upvote image array seems to be nil")
            }
        } else {
            // landscape
            
            if let images = self.downvoteImages {
                if !images.isEmpty {
                    if self.currentDownvoteIndex > 0 {
                        self.currentDownvoteIndex -= 1
                    } else {
                        self.currentDownvoteIndex = images.count - 1
                    }
                    
                    let isFirst = self.isIndexFirst(self.currentDownvoteIndex, "downvotes")
                    self.updateVoteImageView(for: images[self.currentDownvoteIndex], isFirst)

                } else {
                    print("error: there are no downvoted images to traverse")
                }
            } else {
                print("error: the downvote image array seems to be nil")
            }
        }
    }
    
    @IBAction func nextButtonTapped(_ btn: UIButton) {
        let size = UIScreen.main.bounds.size
        
        if size.width < size.height {
            // portrait
            
            if let images = self.upvoteImages {
                if !images.isEmpty {
                    if self.currentUpvoteIndex < images.count - 1 {
                        self.currentUpvoteIndex += 1
                    } else {
                        self.currentUpvoteIndex = 0
                    }
                    
                    let isFirst = self.isIndexFirst(self.currentUpvoteIndex, "upvotes")
                    self.updateVoteImageView(for: images[self.currentUpvoteIndex], isFirst)
                } else {
                    print("error: there are no upvoted images to traverse")
                }
                
            } else {
                print("error: the upvote image array seems to be nil")
            }
        } else {
            // landscape
            
            if let images = self.downvoteImages {
                if !images.isEmpty {
                    if self.currentDownvoteIndex < images.count - 1 {
                        self.currentDownvoteIndex += 1
                    } else {
                        self.currentDownvoteIndex = 0
                    }
                    
                    let isFirst = self.isIndexFirst(self.currentDownvoteIndex, "downvotes")
                    self.updateVoteImageView(for: images[self.currentDownvoteIndex], isFirst)
                } else {
                    print("error: there are no downvoted images to traverse")
                }
                
            } else {
                print("error: the downvote image array seems to be nil")
            }
        }
    }
    
    func isIndexFirst(_ index: Int, _ array: String) -> Bool {
        if array == "upvotes" {
            if self.currentUpvoteIndex == 0 {
                return true
            } else {
                return false
            }
        } else if array == "downvotes" {
            if self.currentDownvoteIndex == 0 {
                return true
            } else {
                return false
            }
        }
        
        return false
    }
    
    func hideViews() {
        self.voteStatusAsset.image = nil
        self.voteImageView.image = nil
        self.voteStatusLabel.text = ""
    }
    
    @IBAction func refreshButtonTapped(_ btn: UIButton) {
        self.fetchVoteImages()
    }
    
}
