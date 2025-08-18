🎵 Flutter Music Player App

A sleek and simple Flutter-based music player that allows users to browse, select, and listen to popular songs with album art, ratings, and full playback controls. Built using just_audio, this app features animations, shuffle/repeat modes, and a responsive UI.

📱 Screenshots

(Add your screenshots here after running the app!)
Example:

🏠 Home Screen — Song list

🎶 Player Screen — Album art with controls

🚀 Features

🎧 Stream and play music from URLs

🖼️ Display album art from the internet

⭐ Rate and favorite songs

🔀 Shuffle & 🔁 Repeat modes

⏯️ Playback controls (Play, Pause, Next, Previous)

🎛️ Animated spinning album art while playing

⏱️ Audio progress slider with time labels

📂 Project Structure
lib/
├── main.dart               # Entry point
├── home_screen.dart        # Song list screen
├── song_detail_screen.dart # Song player screen
├── app_colors.dart         # Custom color definitions
└── assets/
    └── songs.json          # List of songs with metadata

📦 Dependencies
dependencies:
  flutter:
    sdk: flutter
  just_audio: ^0.9.36
  audio_session: ^0.1.13
  path_provider: ^2.1.1

🔧 Setup Instructions

Clone the repo

git clone https://github.com/your-username/flutter-music-player.git
cd flutter-music-player


Install dependencies

flutter pub get


Run the app

flutter run


(Optional) Update Android NDK in android/app/build.gradle.kts if needed:

android {
    ndkVersion = "27.0.12077973" // Recommended for audio plugins
}

🎶 Song Data

The app uses a list of 20 popular songs (title, artist, rating, image, and audio URL). All audio links must point to valid .mp3 URLs. Update them in the assets/songs.json or directly in the main.dart.

🛠 To-Do

 Add playlist feature

 Support offline downloads

 Add light/dark mode toggle

 Implement search functionality

🙌 Credits

UI Design & Animation by [You/YourName]

Album art from [YouTube Thumbnails]

Audio files (placeholder samples) via SoundHelix

📜 License

This project is for educational and personal use only. Do not distribute copyrighted songs without proper licensing.













🧱 Widget Tree of Your Music Player App

This tree will reflect:

A home screen that lists all songs.

A detail screen that plays a song.

Standard controls: Play/Pause, Next/Previous, Shuffle, Repeat.

Album art and info.

Favorite button.

MaterialApp
└── Scaffold (HomeScreen)
    ├── AppBar
    ├── ListView.builder
    │   └── ListTile / SongCard
    │       ├── Leading: CircleAvatar or Image
    │       ├── Title: Song Title
    │       ├── Subtitle: Artist Name
    │       └── onTap: Navigate to SongDetailScreen
    └── BottomNavigationBar (optional)

└── Scaffold (SongDetailScreen)
    ├── AppBar
    │   ├── Leading: Back Button
    │   └── Actions: Favorite Icon
    └── Padding
        └── Column
            ├── AnimatedBuilder (Album Art with Rotation)
            │   └── Transform.rotate
            │       └── Container (Album Art Image)
            ├── SizedBox
            ├── Text (Song Title)
            ├── Text (Artist Name)
            ├── Row (Rating stars and number)
            ├── SizedBox
            ├── SliderTheme
            │   └── Slider (Progress Bar)
            ├── Row
            │   ├── Text (Current Time)
            │   └── Text (Total Duration)
            ├── SizedBox
            ├── Row (Playback Controls)
            │   ├── IconButton (Previous)
            │   ├── IconButton (Play/Pause)
            │   └── IconButton (Next)
            ├── SizedBox
            └── Row (Shuffle & Repeat Buttons)
                ├── IconButton (Shuffle)
                └── IconButton (Repeat)