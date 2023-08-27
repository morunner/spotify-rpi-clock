import 'package:flutter/material.dart';
import 'package:spotify_clock/style_scheme.dart';

class DeviceSettings extends StatefulWidget {
  const DeviceSettings({super.key});

  @override
  State<DeviceSettings> createState() => _DeviceSettingsState();
}

class _DeviceSettingsState extends State<DeviceSettings> {
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
        children: [
          Row(
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
          ),
          Container(
            color: MyColorScheme.white.withOpacity(0.5),
            margin: EdgeInsets.only(top: 4),
            child: Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NixieClock32',
                    style: TextStyle(
                      color: MyColorScheme.darkGreen,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Icon(Icons.expand_more),
                ],
              ),
            ),
          ),
        ],
      ),
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
}
