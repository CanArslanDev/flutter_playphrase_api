```markdown
# Movie Phrase Search App

A Flutter application that allows users to search for movie phrases and watch the corresponding video clips. The app uses the PlayPhrase.me API to fetch video content and display synchronized subtitles.

## 📱 Features

- Search for specific phrases from movies
- Watch video clips with synchronized subtitles
- Word-by-word subtitle highlighting
- Next word suggestions
- Play/Pause functionality
- Modern dark UI theme with purple accents

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- An IDE (VS Code, Android Studio, etc.)
- Basic knowledge of Flutter development

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/movie-phrase-search.git
```

2. Navigate to project directory:
```bash
cd movie-phrase-search
```

3. Install dependencies:
```bash
flutter pub get
```

4. Update CSRF Token (Required):
   - Visit [PlayPhrase.me](https://www.playphrase.me/)
   - Open Developer Tools (F12 in most browsers)
   - Go to the Network tab
   - Search for any phrase on PlayPhrase.me
   - Find the API request to `/api/v1/phrases/search`
   - Scroll down to the request headers
   - Copy the `X-Csrf-Token` value
   - Update it in `lib/constants.dart`:
```dart
static const String csrfToken = 'your-new-token-here';
```

5. Run the app:
```bash
flutter run
```

## 🛠️ Built With

- Flutter - UI framework
- http package - API calls
- video_player package - Video playback
- Dart Timer - Subtitle synchronization

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📸 Screenshots

[Add your app screenshots here]

## 🙏 Acknowledgments

- [PlayPhrase.me](https://www.playphrase.me/) for providing the API
- Flutter team for the amazing framework
- All contributors who help improve this project

## 👤 Contact

Your Name - [@yourusername](https://twitter.com/yourusername)

Project Link: [https://github.com/yourusername/movie-phrase-search](https://github.com/yourusername/movie-phrase-search)

---
⭐️ If you found this project helpful, please give it a star!
```

Would you like me to explain any part of the README or modify it further?