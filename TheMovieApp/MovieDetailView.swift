//
//  MovieDetailView.swift
//  TheMovieApp
//
//  Created by Khader Syed on 7/19/25.
//

import SwiftUI

struct MovieDetailView: View {
    let movie: Movie // The initial movie object from the search results
    
    @State private var detailedMovie: Movie? // To hold the full details after fetching
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    private let tmdbService = TMDBService() // Instance of our service

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Backdrop Image (New!)
                if let backdropURL = detailedMovie?.backdropURL {
                    AsyncImage(url: backdropURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 200)
                                .background(Color.gray.opacity(0.1))
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit) // Use .fit to ensure full image is visible
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(maxWidth: .infinity, minHeight: 200)
                                .cornerRadius(10)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 80))
                                        .foregroundColor(.white.opacity(0.7))
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.bottom, 10)
                } else {
                    // Fallback to poster if no backdrop or while loading
                    // Movie Poster (from initial 'movie' object)
                    AsyncImage(url: movie.posterURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                            .overlay(
                                Image(systemName: "film")
                                    .font(.system(size: 80))
                                    .foregroundColor(.white.opacity(0.7))
                            )
                    }
                    .padding(.bottom, 10)
                }

                // Movie Title
                Text(detailedMovie?.title ?? movie.title) // Use detailedMovie title if available
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 5)

                // Tagline (New!)
                if let tagline = detailedMovie?.tagline, !tagline.isEmpty {
                    Text(tagline)
                        .font(.headline)
                        .italic()
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 5)
                }
                
                // Loading / Error State
                if isLoading {
                    ProgressView("Loading details...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else if detailedMovie == nil {
                    // Fallback message if details somehow fail to load and no error
                    Text("Details not available.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }

                // Release Date
                if let releaseDate = detailedMovie?.releaseDate ?? movie.releaseDate, !releaseDate.isEmpty {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Release Date: \(formatDate(releaseDate))")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                
                // Genres (New!)
                if let genres = detailedMovie?.formattedGenres, !genres.isEmpty && genres != "N/A" {
                    HStack {
                        Image(systemName: "tag.fill")
                        Text("Genres: \(genres)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                
                // Runtime (New!)
                if let runtime = detailedMovie?.formattedRuntime, !runtime.isEmpty && runtime != "N/A" {
                    HStack {
                        Image(systemName: "hourglass")
                        Text("Runtime: \(runtime)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                
                // Vote Average (New!)
                if let voteAverage = detailedMovie?.formattedVoteAverage, !voteAverage.isEmpty && voteAverage != "N/A" {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Rating: \(voteAverage)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }

                // Overview
                Text("Overview")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 10)

                Text(detailedMovie?.overview ?? movie.overview) // Use detailedMovie overview if available
                    .font(.body)
                    .lineLimit(nil) // Allow unlimited lines for overview
            }
            .padding() // Add padding around the whole VStack content
        }
        .navigationTitle(detailedMovie?.title ?? movie.title)
        .navigationBarTitleDisplayMode(.inline) // Keep title compact
        .onAppear {
            // Fetch detailed movie information when the view appears
            Task {
                await fetchMovieDetails()
            }
        }
    }

    // Function to fetch movie details
    func fetchMovieDetails() async {
        isLoading = true
        errorMessage = nil // Clear any previous errors

        do {
            let fetchedMovie = try await tmdbService.getMovieDetails(movieId: movie.id)
            await MainActor.run {
                self.detailedMovie = fetchedMovie
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            print("Error fetching movie details for ID \(movie.id): \(error)")
        }
    }

    // Helper to format the release date (can be shared or duplicated for simplicity)
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Input format

        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM d, yyyy" // Output format
            return dateFormatter.string(from: date)
        }
        return dateString // Return original if parsing fails
    }
}

// MARK: - Preview Provider
struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a sample movie for the preview canvas
        NavigationView {
            MovieDetailView(movie: Movie(
                id: 550,
                title: "Fight Club",
                overview: "A depressed man suffering from insomnia...",
                posterPath: "/aCKiNYG1B4Fqj73HlXyG763Xw9F.jpg", // Example path
                releaseDate: "1999-10-15",
                backdropPath: "/o0F8L.jpg", // Example backdrop path
                genres: [Genre(id: 1, name: "Drama"), Genre(id: 2, name: "Thriller")],
                voteAverage: 8.4,
                runtime: 139,
                tagline: "Mischief. Mayhem. Soap."
            ))
        }
    }
}
