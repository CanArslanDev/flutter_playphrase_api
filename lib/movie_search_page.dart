import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_playphrase_api/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';

class MovieSearchPage extends StatefulWidget {
  const MovieSearchPage({Key? key}) : super(key: key);

  @override
  _MovieSearchPageState createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> suggestions = [];
  String? currentVideoUrl;
  VideoPlayerController? _videoController;
  bool hasVideos = false;
  bool isLoading = false;
  bool isPlaying = true;
  List<Map<String, dynamic>> currentWords = [];
  int currentWordIndex = -1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _performSearch('what are you');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _videoController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer =
        Timer.periodic(const Duration(milliseconds: 50), (Timer timer) async {
      if (_videoController != null && _videoController!.value.isInitialized) {
        final position = await _videoController!.position;
        if (position != null) {
          _updateCurrentWord(position);
        }
      }
    });
  }

  void _updateCurrentWord(Duration position) {
    final milliseconds = position.inMilliseconds;
    int newWordIndex = -1;

    for (int i = 0; i < currentWords.length; i++) {
      final word = currentWords[i];
      if (milliseconds >= word['start'] && milliseconds <= word['end']) {
        newWordIndex = i;
        break;
      }
    }

    if (newWordIndex != currentWordIndex) {
      setState(() {
        currentWordIndex = newWordIndex;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      isLoading = true;
    });

    final baseUrl = 'https://www.playphrase.me/api/v1/phrases/search';
    final encodedQuery = Uri.encodeComponent(query);

    final url =
        Uri.parse('$baseUrl?limit=10&language=en&skip=0&q=$encodedQuery');

    try {
      final response = await http.get(
        url,
        headers: {
          'X-Csrf-Token': Constants.csrftoken,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          suggestions = List<String>.from(data['next-word-suggestions']);
          if (data['phrases'].isNotEmpty) {
            hasVideos = true;
            String newVideoUrl = data['phrases'][0]['video-url'];
            currentWords =
                List<Map<String, dynamic>>.from(data['phrases'][0]['words']);
            if (currentVideoUrl != newVideoUrl) {
              currentVideoUrl = newVideoUrl;
              _initializeVideo(newVideoUrl);
            }
          } else {
            hasVideos = false;
            currentVideoUrl = null;
            currentWords = [];
            _videoController?.dispose();
            _videoController = null;
          }
        });
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _initializeVideo(String url) async {
    _videoController?.dispose();
    _timer?.cancel();

    _videoController = VideoPlayerController.network(url);
    try {
      await _videoController!.initialize();
      setState(() {
        _videoController!.play();
        _videoController!.setLooping(true);
        isPlaying = true;
      });
      _startTimer();
    } catch (e) {
      print('Video initialization error: $e');
      setState(() {
        hasVideos = false;
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (isPlaying) {
        _videoController?.pause();
        _timer?.cancel();
      } else {
        _videoController?.play();
        _startTimer();
      }
      isPlaying = !isPlaying;
    });
  }

  Widget _buildSubtitleText() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(fontSize: 18),
          children: currentWords.asMap().entries.map((entry) {
            final index = entry.key;
            final word = entry.value;
            return TextSpan(
              text:
                  '${word['text']}${index < currentWords.length - 1 ? ' ' : ''}',
              style: TextStyle(
                color: index == currentWordIndex ? Colors.white : Colors.grey,
                fontWeight: index == currentWordIndex
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: Colors.purple,
        colorScheme: ColorScheme.dark(
          primary: Colors.purple,
          secondary: Colors.purpleAccent,
          surface: Colors.grey[900]!,
          background: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Colors.grey[850],
          elevation: 4,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Movie Phrase Search',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            if (hasVideos && _videoController != null) ...[
              Stack(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.all(16),
                    clipBehavior: Clip.antiAlias,
                    child: _videoController?.value.isInitialized ?? false
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.purpleAccent,
                            ),
                          ),
                  ),
                  if (_videoController?.value.isInitialized ?? false)
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              _buildSubtitleText(),
            ],
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        title: Text(
                          suggestions[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.purpleAccent,
                        ),
                        onTap: () {
                          setState(() {
                            _searchController.text = suggestions[index];
                          });
                          _performSearch(suggestions[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Enter search query...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.purpleAccent,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (value) {
                        _performSearch(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            _performSearch(_searchController.text);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: SizedBox(
                      width: isLoading ? 20 : 60,
                      height: 20,
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : const Text(
                                'Search',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
