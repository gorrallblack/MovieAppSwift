//
//  MovieTrailer.swift
//  MovieApp
//
//  Created by  
//

import Foundation

// MARK: - Welcome
struct MovieTrailer: Codable {
    let id: Int?
    let results: [Result]?
}

// MARK: - Result
struct Result: Codable {
    let id: String?
    let iso639_1: ISO639_1?
    let iso3166_1: ISO3166_1?
    let key, name: String?
    let site: Site?
    let size: Int?
    let type: TypeEnum?

    enum CodingKeys: String, CodingKey {
        case id
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case key, name, site, size, type
    }
}

enum ISO3166_1: String, Codable {
    case us = "US"
}

enum ISO639_1: String, Codable {
    case en = "en"
}

enum Site: String, Codable {
    case youTube = "YouTube"
}

enum TypeEnum: String, Codable {
    case clip = "Clip"
    case featurette = "Featurette"
    case teaser = "Teaser"
    case trailer = "Trailer"
}
