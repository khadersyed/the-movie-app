//
//  TMDBservice.swift
//  TheMovieApp
//
//  Created by Khader Syed on 7/19/25.
//

import Foundation

enum TMDBServiceError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case apiError(String) // For handling specific API errors like invalid key

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL for the request was invalid."
        case .noData:
            return "No data was returned from the server."
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .apiError(let message):
            return "TMDB API Error: \(message)"
        }
    }
}

class TMDBService {

    // Function to search for movies based on a query string
    func searchMovies(query: String) async throws -> [Movie] {
        guard !query.isEmpty else { return [] } // Don't search for empty queries

        // Construct the URL for the search endpoint
        // https://api.themoviedb.org/3/search/movie?api_key=YOUR_KEY&query=QUERY
        var components = URLComponents(string: Constants.tmdbBaseURL + "/search/movie")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: Constants.tmdbAPIKey),
            URLQueryItem(name: "query", value: query)
        ]

        guard let url = components?.url else {
            throw TMDBServiceError.invalidURL
        }

        print("Fetching URL: \(url.absoluteString)") // For debugging

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw TMDBServiceError.networkError(NSError(domain: "InvalidResponse", code: 0, userInfo: nil))
            }

            // Check for API-specific errors (e.g., invalid API key)
            if httpResponse.statusCode == 401 {
                let errorData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let statusMessage = errorData?["status_message"] as? String ?? "Unknown API Error"
                throw TMDBServiceError.apiError(statusMessage)
            }

            guard httpResponse.statusCode == 200 else {
                throw TMDBServiceError.networkError(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil))
            }

            let decoder = JSONDecoder()
            let movieResponse = try decoder.decode(MovieResponse.self, from: data)
            return movieResponse.results
        } catch let decodingError as DecodingError {
            throw TMDBServiceError.decodingError(decodingError)
        } catch {
            throw TMDBServiceError.networkError(error)
        }
    }
}
