class Device {
  Device({
    this.name = '',
    this.spotifyId = '',
    this.volumePercent = 0,
  });

  String name;
  String spotifyId;
  int volumePercent;

  getName() {
    return name;
  }

  getId() {
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
