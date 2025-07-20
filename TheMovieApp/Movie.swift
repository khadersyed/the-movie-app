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

    // MARK: - New properties for Movie Details endpoint
    let backdropPath: String? // Path to the movie's backdrop image
    let genres: [Genre]?
    let voteAverage: Double?
    let runtime: Int? // in minutes
    let tagline: String?

    // Custom coding keys to map JSON snake_case to Swift camelCase
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case backdropPath = "backdrop_path" // New
        case genres // New
        case voteAverage = "vote_average" // New
        case runtime // New
        case tagline // New
    }
}

// MARK: - New struct for Genre
struct Genre: Identifiable, Codable {
    let id: Int
    let name: String
}

// Represents the structure of a movie search response from TMDB (no changes needed here)
struct MovieResponse: Codable {
    let results: [Movie]
    // You might add total_pages, page, etc., if you plan to implement pagination
}

// MARK: - Extend Movie Model for Image URLs (no changes needed here)
extension Movie {
    var posterURL: URL? {
        if let posterPath = posterPath {
            return URL(string: Constants.tmdbImageBaseURL + posterPath)
        }
        return nil
    }

    var backdropURL: URL? { // New computed property for backdrop image
        if let backdropPath = backdropPath {
            // TMDB often uses w1280 or original for backdrops for larger sizes
            // Constants.tmdbImageBaseURL uses w500, so we might need a dedicated constant for backdrops
            // For now, let's use a common size like 'w780' or 'original'
            return URL(string: "https://image.tmdb.org/t/p/w780" + backdropPath)
        }
        return nil
    }
    
    var formattedGenres: String { // Helper for displaying genres
        genres?.map { $0.name }.joined(separator: ", ") ?? "N/A"
    }
    
    var formattedVoteAverage: String { // Helper for displaying rating
        if let voteAverage = voteAverage {
            return String(format: "%.1f", voteAverage) + "/10"
        }
        return "N/A"
    }
    
    var formattedRuntime: String { // Helper for displaying runtime
        if let runtime = runtime {
            return "\(runtime) mins"
        }
        return "N/A"
    }
}

