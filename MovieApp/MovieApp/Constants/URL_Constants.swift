//
//  URL_Constants.swift
//  
//
//  Created by  on 26/10/2020.
//

import Foundation
import UIKit

enum AppNetworkURL {
    //Define URL Path
    static func SERVER_URL() -> String {
        return "https://api.themoviedb.org/3/movie/"
    }
}

enum PopularMovies {
    static let POPULAR = "popular"
}

enum MovieImagesURL {
    static let ImageURL = "https://image.tmdb.org/t/p/w342"
}
