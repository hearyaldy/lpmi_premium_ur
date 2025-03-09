import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLooping = false;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Stream controller for playback state
  final _playbackStateController = StreamController<bool>.broadcast();

  bool get isPlaying => _audioPlayer.state == PlayerState.playing;
  bool get isLooping => _isLooping;

  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  Stream<Duration> get positionStream => _audioPlayer.onPositionChanged;
  Stream<Duration?> get durationStream => _audioPlayer.onDurationChanged;
  
  // New getter for playback state stream
  Stream<bool> get playbackStateStream => _playbackStateController.stream;

  AudioPlayerService() {
    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
    });

    // Listen to player state changes and update playback state stream
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _playbackStateController.add(state == PlayerState.playing);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (_isLooping) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.resume();
      }
      // Ensure playback state is updated
      _playbackStateController.add(false);
    });
  }

  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }

    final result = await Permission.storage.request();
    return result.isGranted;
  }

  Future<void> playOrPause(String url, String title) async {
    final filePath = await download(url, title);
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      print("Attempting to play file from: $filePath");
      await _audioPlayer.setSourceDeviceFile(filePath);
      await _audioPlayer.resume();
    }
  }

  Future<String> download(String url, String title) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$title.mp3';
    final file = File(filePath);

    if (!await file.exists()) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print("File downloaded to: $filePath");
      } else {
        throw Exception('Failed to download file');
      }
    } else {
      print("File already exists at: $filePath");
    }

    return filePath;
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    // Ensure playback state is updated
    _playbackStateController.add(false);
  }

  void toggleLooping() {
    _isLooping = !_isLooping;
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void setLoopMode(bool isLooping) {
    _isLooping = isLooping;
  }

  void dispose() {
    _audioPlayer.dispose();
    _playbackStateController.close();
  }
}