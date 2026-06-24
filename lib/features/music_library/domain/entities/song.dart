class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String uri;
  final String? artworkUri;
  final String? path;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.uri,
    this.artworkUri,
    this.path,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration_ms': duration.inMilliseconds,
      'uri': uri,
      'artwork_uri': artworkUri,
      'path': path,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      duration: Duration(milliseconds: json['duration_ms'] as int),
      uri: json['uri'] as String,
      artworkUri: json['artwork_uri'] as String?,
      path: json['path'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
