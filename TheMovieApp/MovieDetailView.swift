//
//  MovieDetailView.swift
//  TheMovieApp
//
//  Created by Khader Syed on 7/19/25.
//


import SwiftUI

struct MovieDetailView: View {
    let movie: Movie // The movie object passed from ContentView

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Movie Poster
                if let posterURL = movie.posterURL {
                    AsyncImage(url: posterURL) { image in
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
                }

                // Movie Title
                Text(movie.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 5)

                // Release Date
                if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Release Date: \(formatDate(releaseDate))")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }

                // Overview
                Text("Overview")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 10)

                Text(movie.overview)
                    .font(.body)
                    .lineLimit(nil) // Allow unlimited lines for overview
            }
            .padding() // Add padding around the whole VStack content
        }
        .navigationTitle(movie.title)
        .navigationBarTitleDisplayMode(.inline) // Keep title compact
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
                releaseDate: "1999-10-15"
            ))
        }
    }
}
