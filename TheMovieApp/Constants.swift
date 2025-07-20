//
//  Constants.swift
//  TheMovieApp
//
//  Created by Khader Syed on 7/19/25.
//

import Foundation

struct Constants {
    // Read the API key from Info.plist
    static let tmdbAPIKey: String = {
        guard let apiKey = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String,
              !apiKey.isEmpty else {
            fatalError("TMDB_API_KEY not found in Info.plist. Please set it in build settings.")
        }
        return apiKey
    }()

    static let tmdbBaseURL = "https://api.themoviedb.org/3"
    static let tmdbImageBaseURL = "https://image.tmdb.org/t/p/w500" // For movie posters
}
