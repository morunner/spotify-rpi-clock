import 'package:flutter/material.dart';

class Track {
  Track({
    this.spotifyId = '',
    this.title = '',
    this.artist = '',
    this.album = '',
    this.coverUrl = '',
    this.playbackUri = '',
  }) {
    setAlbumCover(album, coverUrl);
  }

  String spotifyId;
  String title;
  String artist;
  String album;
  String coverUrl;
  String playbackUri;

  Image image = Image.asset(
    'assets/images/john_mayer_sobrock.jpeg',
    fit: BoxFit.fitWidth,
  );

  setTitle(String title) {
    this.title = title;
  }

  setArtist(String artist) {
    this.artist = artist;
  }

  setAlbumCover(String album, String coverUrl) {
    if (album.isNotEmpty && coverUrl.isNotEmpty) {
      this.album = album;
      this.coverUrl = coverUrl;
      image = Image.network(
        coverUrl,
      );
    } else {
      image = Image.asset(
        'assets/images/john_mayer_sobrock.jpeg',
      );
    }
  }

  getSpotifyId() {
    return spotifyId;
  }

  getTitle() {
    return title;
  }

  getArtist() {
    return artist;
  }

  getAlbum() {
    return album;
  }

  getCoverUrl() {
    return coverUrl;
  }

  getImage() {
    return image;
  }

  get() {
    return {
      'spotify_id': spotifyId,
      'title': title,
      'artist': artist,
      'album': album,
      'cover_url': coverUrl,
      'playback_uri': playbackUri,
    };
  }
}
