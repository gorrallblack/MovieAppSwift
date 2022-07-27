//
//  MovieTableViewCell.swift
//  Poc
//
//  Created by  
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func customizedMovieTableCell(movieDataItem : MovieDataItem) {
        self.movieTitle.text = movieDataItem.originalTitle ?? ""
        let imageURLString = MovieImagesURL.ImageURL + (movieDataItem.posterPath ?? "")
        self.thumbnail.setImage(with: imageURLString)
    }
}
