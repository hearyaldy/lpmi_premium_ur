class UnifiedSong {
  final String songNumber;
  final String songTitle;
  final List<Verse> verses;
  final String? url;

  UnifiedSong({
    required this.songNumber,
    required this.songTitle,
    required this.verses,
    this.url,
  });

  // Factory method to create UnifiedSong instance from JSON
  factory UnifiedSong.fromJson(Map<String, dynamic> json) {
    var versesJson = json['verses'] as List;
    List<Verse> versesList = versesJson.map((i) => Verse.fromJson(i)).toList();

    return UnifiedSong(
      songNumber: json['song_number'] as String,
      songTitle: json['song_title'] as String,
      verses: versesList,
      url: json['url'] as String?,
    );
  }

  // Method to convert UnifiedSong instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'song_number': songNumber,
      'song_title': songTitle,
      'verses': verses.map((verse) => verse.toJson()).toList(),
      'url': url,
    };
  }
}

class Verse {
  final String verseNumber;
  final String lyrics;

  Verse({
    required this.verseNumber,
    required this.lyrics,
  });

  // Factory method to create Verse instance from JSON
  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      verseNumber: json['verse_number'] as String,
      lyrics: json['lyrics'] as String,
    );
  }

  // Method to convert Verse instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'verse_number': verseNumber,
      'lyrics': lyrics,
    };
  }
}