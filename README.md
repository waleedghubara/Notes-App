# Notes App

[![Ask DeepWiki](https://devin.ai/assets/askdeepwiki.png)](https://deepwiki.com/waleedghubara/Notes-App)

[![Notes App Preview](assets/images/notes_image.png)](https://github.com/waleedghubara/Notes-App)

A dynamic and feature-rich notes application built with Flutter. The application features a smooth, animated user interface and connects to a PHP backend for full user authentication and note management.

## Features

-   **User Authentication**: Secure sign-up and login functionality.
-   **Profile Management**: Users can create a profile with a personal image, name, email, phone, and age.
-   **View Profile**: A dedicated, animated page to view user profile details.
-   **CRUD for Notes**:
    -   **Create**: Add new notes with a title, detailed content, and an associated image.
    -   **Read**: View all your notes in an animated list, each displaying its image, title, and content.
    -   **Update**: Easily edit the title and content of existing notes.
    -   **Delete**: Remove notes with a single tap.
-   **Image Handling**: Upload images for user profiles and individual notes using the device gallery.
-   **Secure Session Management**: User sessions are securely managed using `flutter_secure_storage` to store authentication tokens.
-   **Engaging UI/UX**: The app is filled with custom animations, background effects, and smooth page transitions for an enhanced user experience.

## Technical Stack

-   **Framework**: Flutter
-   **Language**: Dart
-   **Networking**: `dio` for handling API requests.
-   **Image Loading**: `cached_network_image` for efficient loading and caching of network images.
-   **Image Picking**: `image_picker` to select images from the gallery.
-   **Secure Storage**: `flutter_secure_storage` for securely storing user tokens and ID.
-g   **UI & Styling**:
    -   `google_fonts` for typography.
    -   Custom animated widgets and painters for a unique look and feel.

## Getting Started

To run this project locally, you will need a local server environment (like XAMPP, WAMP, or MAMP) with PHP to host the backend API.

### Prerequisites

-   Flutter SDK
-   A configured IDE (like VS Code or Android Studio)
-   A local web server with PHP

### Installation

1.  **Backend Setup**:
    This project requires a PHP backend. The API endpoints are configured in the app but the backend source code is not included in this repository. You will need to set up your own PHP scripts for handling authentication and notes CRUD operations.

2.  **Frontend Setup**:
    -   Clone the repository:
        ```sh
        git clone https://github.com/waleedghubara/Notes-App.git
        ```
    -   Navigate to the project directory:
        ```sh
        cd Notes-App
        ```
    -   Update the API base URL. Open `lib/core/api/end_point.dart` and change `baseUrl` and `baseUrlImage` to match the address of your local PHP server.
        ```dart
        class EndPoint {
          // Update this to your local IP address
          static const String baseUrl = 'http://YOUR_LOCAL_IP/phpapi/'; 
          static const String baseUrlImage = 'http://YOUR_LOCAL_IP/phpapi/upload/';
          // ...
        }
        ```
    -   Install dependencies:
        ```sh
        flutter pub get
        ```
    -   Run the application:
        ```sh
        flutter run
