# TheMovieApp

A simple iOS application built with SwiftUI that allows users to search for movies using The Movie Database (TMDB) API and view detailed information about them.

## Table of Contents

*   [Features](#features)
*   [Screenshots](#screenshots)
*   [Technologies Used](#technologies-used)
*   [Setup and Installation](#setup-and-installation)
    *   [Prerequisites](#prerequisites)
    *   [Getting Started](#getting-started)
    *   [TMDB API Key Setup (Crucial!)](#tmdb-api-key-setup-crucial)
*   [Usage](#usage)
*   [Future Enhancements](#future-enhancements)
*   [Contributing](#contributing)
*   [License](#license)
*   [Acknowledgements](#acknowledgements)

## Features

*   **Movie Search:** Search for movies by title using a debounced text input for a smooth "live search" experience.
*   **Search Results List:** Displays a list of movies matching the search query with their titles, poster, and release dates.
*   **Movie Details:** Tap on a movie to view a dedicated detail screen showing:
    *   Larger Poster and Backdrop images
    *   Full Overview/Synopsis
    *   Release Date
    *   Genres
    *   Runtime
    *   TMDB Vote Average
    *   Tagline
*   **Asynchronous Image Loading:** Efficiently loads movie posters and backdrops using `AsyncImage`.
*   **Secure API Key Handling:** Demonstrates how to keep your TMDB API key out of your public Git repository.

## Screenshots

*(Once you have your app running, capture some screenshots and replace this text. For example:)*

| Search Screen | Detail Screen |
| :-----------: | :-----------: |
| ![Search Screen](https://via.placeholder.com/300x600?text=Search+Screen) | ![Detail Screen](https://via.placeholder.com/300x600?text=Detail+Screen) |

## Technologies Used

*   **SwiftUI:** Apple's declarative UI framework for building modern iOS interfaces.
*   **Swift Concurrency (`async/await`):** For handling asynchronous network requests and UI updates efficiently.
*   **URLSession:** For making HTTP requests to the TMDB API.
*   **Codable:** For easily parsing JSON responses from the API into Swift structs.
*   **The Movie Database (TMDB) API:** The primary data source for movie information.

## Setup and Installation

Follow these steps to get the project up and running on your local machine.

### Prerequisites

*   macOS (with Xcode installed)
*   Xcode 13.0 or later (required for Swift Concurrency and latest SwiftUI features)
*   A free [TMDB API Key](https://www.themoviedb.org/documentation/api)

### Getting Started

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/khadersyed/TheMovieApp.git
    cd TheMovieApp
    ```

2.  **Open the project in Xcode:**
    Double-click `TheMovieApp.xcodeproj` to open it.

### TMDB API Key Setup (Crucial!)

For security reasons, the TMDB API key is **not committed to the repository**. You need to add it yourself as a **User-Defined Build Setting** in Xcode.

1.  **Obtain your API Key:** If you don't have one, sign up for a free API key on [The Movie Database (TMDB) website](https://www.themoviedb.org/documentation/api).
2.  **Add to Project Build Settings:**
    *   In Xcode, select the **Project** (the top-level item) in the Project Navigator.
    *   Go to the **"Build Settings"** tab.
    *   Click the **`+`** button at the bottom and choose **"Add User-Defined Setting"**.
    *   Name the setting: `TMDB_API_KEY`
    *   For the value of `TMDB_API_KEY` under both "Debug" and "Release" (or just "Debug" for initial testing), **paste your actual TMDB API key**.

3.  **Add to Target Info.plist Build Settings:**
    *   In Xcode, select your **Target** (e.g., `TheMovieApp`) in the Project Navigator.
    *   Go to the **"Build Settings"** tab.
    *   Search for "Info.plist Additions" (or locate the "Packaging" section).
    *   Right-click in this section and choose **"Add User-Defined Setting"**.
    *   Name the setting: `TMDB_API_KEY`
    *   For the value of this `TMDB_API_KEY` under both "Debug" and "Release", enter: `$(TMDB_API_KEY)` (this tells Xcode to use the value from the project-level setting).

4.  **Build and Run:**
    *   Once the API key is set up, build and run the project on a simulator or physical device (`Cmd + R`).

## Usage

1.  **Search:** Start typing a movie title into the search bar. Results will appear as you type with a small delay (debounced search).
2.  **View Details:** Tap on any movie in the list to navigate to its detail screen, which provides more information.

## Future Enhancements

*   **Pagination:** Implement loading more results as the user scrolls down the search list.
*   **Error Handling UI:** More sophisticated error messages and recovery options.
*   **Offline Support:** Caching movie data for offline viewing.
*   **Sorting/Filtering:** Add options to sort search results or filter by genre.
*   **User Favorites:** Allow users to mark movies as favorites.
*   **Watchlist:** Implement a feature to add movies to a watchlist.
*   **Similar Movies/Recommendations:** Utilize other TMDB API endpoints.
*   **Better UI/UX:** Refine the user interface, add animations, etc.

## Contributing

Feel free to fork this repository, open issues, and submit pull requests if you have suggestions or improvements!

## License

This project is open-source and available under the [MIT License](LICENSE).

## Acknowledgements

*   Powered by [The Movie Database (TMDB) API](https://www.themoviedb.org/).
