//
//  MovieDetailViewController.swift
//  MovieApp
//
//  Created by  
//

import UIKit
import PromiseKit
import SwifterSwift

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    
    @IBOutlet weak var watchLaterButton: UIButton!
    
    var movieDetailData : MovieDetailData?
    var movieTrailer : MovieTrailer?
    var selectedMovieID : String = ""

    //MARK:- Default Init Method
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationItem.title = "Movie's Detail"
        self.watchLaterButton.setTitle("Watch Trailer", for: .normal)
        
        self.titleLabel.text = ""
        self.genresLabel.text = ""
        self.dateLabel.text = ""
        self.overviewTextView.text = ""
        
        self.loadMovieDetailFromServer()
    }
    
    //MARK:- Button Action Method
    @IBAction func watchLaterButtonAction(_ sender : Any) {
        print("watchLaterButtonAction")
        self.loadMovieTrailerDetailFromServer()
    }
}

extension MovieDetailViewController {
    func loadMovieDetailFromServer() {
        if currentReachabilityStatus == .notReachable {
            self.showToastFromTop("No Internet")
        }
        else {
            firstly {
                NetRequest.fetchMovieDetail(nil, self.selectedMovieID)
            }
            .done({ [weak self](movieDetailData) in
                print("movieData is \(movieDetailData)")
                self?.movieDetailData = (movieDetailData)
                self?.populateMovieInfoItems()
            })
            .catch { error in
                print("error : \(error)")
            }
            .finally {
                print("finally")
            }
        }
    }
    
    func loadMovieTrailerDetailFromServer() {
        if currentReachabilityStatus == .notReachable {
            self.showToastFromTop("No Internet")
        }
        else {
            firstly {
                NetRequest.fetchMovieTrailerDetail(nil, self.selectedMovieID)
            }
            .done({ [weak self](movieTrailer) in
                print("movieTrailer is \(movieTrailer)")
                self?.movieTrailer = (movieTrailer)
                self?.parseYoutubeIdentifierFromData()
            })
            .catch { error in
                print("error : \(error)")
            }
            .finally {
                print("finally")
            }
        }
    }
    
    func populateMovieInfoItems() {
        let imageURLString = MovieImagesURL.ImageURL + (self.movieDetailData?.posterPath ?? "")
        self.posterImage.setImage(with: imageURLString)
        
        self.titleLabel.text = self.movieDetailData?.title ?? ""
        self.dateLabel.text = self.movieDetailData?.releaseDate ?? ""
        self.overviewTextView.text = self.movieDetailData?.overview ?? ""
        self.parseGenresFromData()
    }
    
    func parseGenresFromData() {
        if let genres = self.movieDetailData?.genres {
            var genresString : String = ""
            for i in 0..<genres.count{
                genresString += genres[i].name ?? ""
                //to avoid comma at the end of string
                if i == genres.count - 1 {
                    break
                }
                genresString += ", "
            }
            self.genresLabel.text = genresString
            self.genresLabel.isHidden = false
        }
    }
    
    func parseYoutubeIdentifierFromData() {
        if let results = self.movieTrailer?.results {
            for result in results{
                let type = result.type
                if type == "Trailer" {
                    let youtubeIdentifier = result.key!
                    self.navigateToPlayerView(videoIdentifier: youtubeIdentifier)
                    break;
                }
            }
        }
    }
    
    func navigateToPlayerView(videoIdentifier : String) {
        if let playerVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as? PlayerViewController {
                playerVC.youtubeIdentifier = videoIdentifier
            self.navigationController?.pushViewController(playerVC, animated: true)
        }
    }
}
