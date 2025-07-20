//
//  ContentView.swift
//  TheMovieApp
//
//  Created by Khader Syed on 7/19/25.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var movies: [Movie] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var searchTask: Task<Void, Never>? = nil // To hold the debounced search task

    private let tmdbService = TMDBService()

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search for movies...", text: $searchText)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .textInputAutocapitalization(.never) // Prevent auto-capitalization
                    .autocorrectionDisabled() // Disable autocorrection
                    .onChange(of: searchText) {
                        // Cancel any existing search task
                        searchTask?.cancel()

                        // Only trigger search if query is not empty after trimming
                        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                            movies = [] // Clear results if search box is emptied
                            isLoading = false
                            errorMessage = nil
                            return
                        }

                        // Start a new debounced search task
                        searchTask = Task {
                            do {
                                // Add a small delay (e.g., 0.75 seconds)
                                try await Task.sleep(nanoseconds: 750_000_000) // 0.75 seconds

                                // If the task was cancelled during sleep, this will throw
                                try Task.checkCancellation()

                                await searchMovies() // Perform the actual search
                            } catch is CancellationError {
                                print("Search task was cancelled.")
                            } catch {
                                // Handle other potential errors, though searchMovies handles its own
                                print("Error in debounced task: \(error.localizedDescription)")
                            }
                        }
                    }

                // Loading Indicator
                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    // Error Message
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                } else if movies.isEmpty && !searchText.isEmpty {
                    Text("No movies found for \(searchText).")
                        .foregroundColor(.gray)
                        .padding()
                } else if movies.isEmpty && searchText.isEmpty {
                    // Message when search bar is empty and no results yet
                    Text("Start typing to search for movies.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    // Movie List
                    List(movies) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            MovieRow(movie: movie)
                        }
                    }
                    .listStyle(.plain) // Use plain list style for cleaner look
                }
            }
            .navigationTitle("Movie Search")
            // Removed the ToolbarItem for the "Search" button
        }
    }

    // Function to perform the movie search
    func searchMovies() async {
        isLoading = true
        errorMessage = nil // Clear any previous errors

        do {
            let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            // No need for isEmpty check here as `onChange` handles it
            
            let fetchedMovies = try await tmdbService.searchMovies(query: trimmedQuery)
            await MainActor.run {
                self.movies = fetchedMovies
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                if Task.isCancelled { // Don't show error if task was cancelled deliberately
                    print("Search cancelled, suppressing error.")
                } else {
                    self.errorMessage = error.localizedDescription
                }
                self.movies = []
                self.isLoading = false
            }
            print("Error searching movies: \(error)")
        }
    }
}

// MARK: - MovieRow View (No changes needed)
struct MovieRow: View {
    let movie: Movie

    var body: some View {
        HStack {
            AsyncImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 75)
                    .cornerRadius(5)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 75)
                    .cornerRadius(5)
                    .overlay(
                        Image(systemName: "film")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
            .shadow(radius: 3)

            VStack(alignment: .leading) {
                Text(movie.title)
                    .font(.headline)
                if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                    Text("Release: \(formatDate(releaseDate))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Preview Provider (No changes needed)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
