class Device {
  Device({
    this.name = '',
    this.spotifyId = '',
    this.volumePercent = 0,
  });

  String name;
  String spotifyId;
  int volumePercent;

  setName(String name) {
    this.name = name;
  }

  setSpotifyId(String spotifyId) {
    this.spotifyId;
  }

  setVolumePercent(int volumePercent) {
    this.volumePercent = volumePercent;
  }

  getName() {
    return name;
  }

  getSpotifyId() {
    return spotifyId;
  }

  getVolumePercent() {
    return volumePercent;
  }

  get() {
    return {
      'name': name,
      'spotify_id': spotifyId,
      'volume_percent': volumePercent,
    };
  }
}
