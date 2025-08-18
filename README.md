# 🎵 Flutter Music Player App

A sleek and simple Flutter-based music player that allows users to browse, select, and listen to popular songs with album art, ratings, and full playback controls. Built using `just_audio`, this app features animations, shuffle/repeat modes, and a responsive UI.

---

## 📱 Screenshots

> _(Add your own screenshots here after running the app)_

- 🏠 Home Screen — Song list  
- 🎶 Player Screen — Album art with controls

---

## 🚀 Features

- 🎧 Stream and play music from URLs  
- 🖼️ Display album art from the internet  
- ⭐ Rate and favorite songs  
- 🔀 Shuffle & 🔁 Repeat modes  
- ⏯️ Playback controls (Play, Pause, Next, Previous)  
- 🎛️ Animated spinning album art while playing  
- ⏱️ Audio progress slider with time labels  

---

## 📂 Project Structure

lib/
├── main.dart # Entry point
├── home_screen.dart # Song list screen
├── song_detail_screen.dart # Song player screen
├── app_colors.dart # Custom color definitions
└── assets/
└── songs.json # List of songs with metadata


---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  just_audio: ^0.9.36
  audio_session: ^0.1.13
  path_provider: ^2.1.1



🔧 Setup Instructions
1. Clone the repo

git clone https://github.com/your-username/flutter-music-player.git
cd flutter-music-player

2. Install dependencies

flutter pub get

3. Run the app

flutter run

4. (Optional) Update Android NDK

If you're facing build issues related to audio plugins, update your android/app/build.gradle.kts:

android {
    ndkVersion = "27.0.12077973" // Recommended for audio plugins
}

🎶 Song Data

The app uses a list of 20 popular songs (title, artist, rating, image, and audio URL).
Make sure all audio links point to valid .mp3 URLs. You can update them in assets/songs.json or directly in the code.

🛠 To-Do

 Add playlist feature

 Support offline downloads

 Add light/dark mode toggle

 Implement search functionality

🙌 Credits

UI Design & Animation by [Your Name]

Album art from YouTube Thumbnails

Sample audio files via SoundHelix

📜 License

This project is for educational and personal use only.
🚫 Do not distribute copyrighted songs

🧱 Widget Tree
App Navigation
MaterialApp
└── HomeScreen (Scaffold)
    ├── AppBar
    ├── ListView.builder
    │   └── ListTile (Song Item)
    │       ├── Leading: Album Art
    │       ├── Title: Song Title
    │       ├── Subtitle: Artist
    │       └── onTap: Navigate to SongDetailScreen
    └── BottomNavigationBar (Optional)

Song Detail Screen
Scaffold
├── AppBar
│   ├── Back Button
│   └── Favorite Icon
└── Column
    ├── AnimatedBuilder
    │   └── Transform.rotate
    │       └── Album Art (Container)
    ├── Text (Song Title)
    ├── Text (Artist Name)
    ├── Row (Rating)
    ├── Slider (Progress Bar)
    ├── Row (Time: Current / Total)
    ├── Row (Playback Controls)
    │   ├── Previous
    │   ├── Play/Pause
    │   └── Next
    └── Row (Shuffle & Repeat Buttons)


Made with ❤️ using Flutter


Let me know if you'd like a `.md` file download or if you want to publish it to a pub
```