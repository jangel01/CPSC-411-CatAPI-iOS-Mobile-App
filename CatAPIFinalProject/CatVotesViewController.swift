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
                    
                    if let image = self.upvoteImages {
                        self.updateVoteImageView(for: image.first!)
                        self.voteStatusAsset.image = UIImage(named: "thumbs-up.png")
                        self.toggleVoteAssetLeadingConstraint("portrait")
                    } else {
                        print("there are no images that are upvoted")
                    }
                } else {
                    // landscape
                    
                    if let image = self.downvoteImages {
                        self.updateVoteImageView(for: image.first!)
                        self.voteStatusAsset.image = UIImage(named: "thumbs-down.png")
                        self.toggleVoteAssetLeadingConstraint("landscape")
                    } else {
                        print("there are no images that are downvoted")
                    }
                }
            case let .failure(error):
                print("Error fetching images that have votes on them: \(error)")
            }
        }
    }
    
    func updateVoteImageView(for image: VotesData) {
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
    
    func toggleVoteAssetLeadingConstraint(_ s: String) {
        if s == "portrait" {
            self.assetLeadingConstraintPortrait.isActive = true
            self.assetLeadingConstraintLandscape.isActive = false
        } else if s == "landscape" {
            self.assetLeadingConstraintPortrait.isActive = false
            self.assetLeadingConstraintLandscape.isActive = true
        }
    }
    
}
