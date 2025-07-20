//
//  Movie.swift
//  TheMovieApp
//
//  Created by Khader Syed on 7/19/25.
//

import Foundation

// Represents a single movie object from the TMDB API
struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String? // Path to the movie poster image
    let releaseDate: String?

    // Custom coding keys to map JSON snake_case to Swift camelCase
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
}

// Represents the structure of a movie search response from TMDB
struct MovieResponse: Codable {
    let results: [Movie]
    // You might add total_pages, page, etc., if you plan to implement pagination
}
