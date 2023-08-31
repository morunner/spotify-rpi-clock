import 'package:flutter/material.dart';
import 'package:spotify_clock/src/backend/spotify_client.dart';
import 'package:spotify_clock/src/data/device.dart';
import 'package:spotify_clock/style_scheme.dart';

class DeviceSettings extends StatefulWidget {
  const DeviceSettings({super.key});

  @override
  State<DeviceSettings> createState() => _DeviceSettingsState();
}

class _DeviceSettingsState extends State<DeviceSettings> {
  final SpotifyClient _spotifyClient = SpotifyClient();
  late double _volumeSliderValue;

  @override
  void initState() {
    super.initState();

    _volumeSliderValue = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _devicePlaybackSettings(),
          _deviceSelect(),
        ],
      ),
    );
  }

  _devicePlaybackSettings() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(left: 15, right: 15),
          child: Icon(Icons.shuffle, color: MyColorScheme.white),
        ),
        Container(
          margin: EdgeInsets.only(left: 15),
          child: Icon(_volumeIcon(), color: MyColorScheme.white),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
                trackShape: RoundedRectSliderTrackShape(),
                thumbShape: RoundSliderThumbShape(),
                thumbColor: MyColorScheme.white,
                activeTrackColor: MyColorScheme.darkGreen,
                inactiveTrackColor: MyColorScheme.white,
                trackHeight: 10),
            child: Slider(
              value: _volumeSliderValue,
              min: 0,
              max: 100,
              onChanged: (double value) {
                setState(() => _volumeSliderValue = value);
              },
            ),
          ),
        ),
      ],
    );
  }

  IconData _volumeIcon() {
    if (_volumeSliderValue == 0) {
      return Icons.volume_mute;
    } else if (_volumeSliderValue < 50) {
      return Icons.volume_down;
    } else {
      return Icons.volume_up;
    }
  }

  _deviceSelect() {
    return Container(
      color: MyColorScheme.white.withOpacity(0.5),
      margin: EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Expanded(
            flex: 9,
            child: Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              child: _listAvailableDevices(),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                color: MyColorScheme.darkGreen,
                size: 24.0,
              ),
              onPressed: () => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  FutureBuilder<List<Device>> _listAvailableDevices() {
    return FutureBuilder<List<Device>>(
        future: _spotifyClient.getAvailableDevices(),
        builder: (context, snapshot) =>
            _availableDevicesDropdownBuilder(context, snapshot));
  }

  _availableDevicesDropdownBuilder(context, snapshot) {
    const color = MyColorScheme.darkGreen;
    const fontSize = 16.0;

    if (!snapshot.hasData) {
      return Text('No active devices found',
          style: TextStyle(color: color, fontSize: fontSize));
    }

    List<Device> deviceNames = snapshot.data ?? [];
    if (deviceNames.isEmpty) {
      deviceNames.add(Device(
          spotifyId: '0', name: 'No active devices found', volumePercent: 0));
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<Device>(
          value: deviceNames.first,
          icon: const Icon(
            Icons.expand_more,
            color: color,
          ),
          style: TextStyle(color: color, fontSize: fontSize),
          items: deviceNames.map<DropdownMenuItem<Device>>((Device device) {
            return DropdownMenuItem<Device>(
              value: device,
              child: Text(device.name),
            );
          }).toList(),
          onTap: () => setState(() => {}),
          onChanged: (value) => {}),
    );
  }
}
