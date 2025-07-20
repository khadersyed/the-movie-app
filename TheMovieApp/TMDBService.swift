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
    case movieNotFound // Specific error for 404 on movie details

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
        case .movieNotFound:
            return "Movie details not found for the given ID."
        }
    }
}

class TMDBService {

    // Function to search for movies based on a query string (no changes here)
    func searchMovies(query: String) async throws -> [Movie] {
        guard !query.isEmpty else { return [] }

        var components = URLComponents(string: Constants.tmdbBaseURL + "/search/movie")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: Constants.tmdbAPIKey),
            URLQueryItem(name: "query", value: query)
        ]

        guard let url = components?.url else {
            throw TMDBServiceError.invalidURL
        }

        print("Fetching URL: \(url.absoluteString)")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw TMDBServiceError.networkError(NSError(domain: "InvalidResponse", code: 0, userInfo: nil))
            }

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

    // MARK: - New Function: Get Movie Details by ID
    func getMovieDetails(movieId: Int) async throws -> Movie {
        // Construct the URL for the movie details endpoint
        // https://api.themoviedb.org/3/movie/{movie_id}?api_key=YOUR_KEY
        var components = URLComponents(string: Constants.tmdbBaseURL + "/movie/\(movieId)")
        components?.queryItems = [
            URLQueryItem(name: "api_key", value: Constants.tmdbAPIKey)
        ]

        guard let url = components?.url else {
            throw TMDBServiceError.invalidURL
        }

        print("Fetching Movie Details URL: \(url.absoluteString)")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw TMDBServiceError.networkError(NSError(domain: "InvalidResponse", code: 0, userInfo: nil))
            }

            // Check for specific HTTP status codes
            if httpResponse.statusCode == 401 {
                let errorData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let statusMessage = errorData?["status_message"] as? String ?? "Unknown API Error"
                throw TMDBServiceError.apiError(statusMessage)
            } else if httpResponse.statusCode == 404 {
                throw TMDBServiceError.movieNotFound // Movie not found error
            }

            guard httpResponse.statusCode == 200 else {
                throw TMDBServiceError.networkError(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil))
            }

            let decoder = JSONDecoder()
            // Decode directly into a Movie object, as this endpoint returns a single movie's details
            let movie = try decoder.decode(Movie.self, from: data)
            return movie
        } catch let decodingError as DecodingError {
            print("Decoding Error for Movie ID \(movieId): \(decodingError)")
            throw TMDBServiceError.decodingError(decodingError)
        } catch {
            print("Network Error for Movie ID \(movieId): \(error.localizedDescription)")
            throw TMDBServiceError.networkError(error)
        }
    }
}
