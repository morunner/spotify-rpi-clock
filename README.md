# spotify-rpi-clock

The alarm clock should consist of two components - hardware and software. It should provide a web (or app) interface where
one can set wake-up songs, albums, artists and/or playlists. It should also enable selecting a playback device and setting its volume. Furthermore, one should be able to set the volume and activate the clock in hardware
by means of knobs and potentiometers.

## Components
### Hardware

| Component                          | Description                                            |
|------------------------------------|--------------------------------------------------------|
| Raspberry Pi Zero                  | For the Spotify connect client                         |
| Adafruit I2S 3W Speaker Bonnet     | Audio Interface between speakers and Raspberry Pi Zero |
| 2x Visaton SC 5.9 ND 4 Ohm Speaker | Speakers playing the audio                             |
| Push buttons, Potentiometers, LEDs | For fast control, still TBD                            |

### Software

#### Spotify Client
There are two options to make the Raspberry Pi Zero a Spotify Client:
    - cspot: https://github.com/feelfreelinux/cspot
    - spotifyd (librespot): https://github.com/Spotifyd/spotifyd (https://github.com/librespot-org/librespot)
They are still to be evaluated

#### Backend
Supabase is used.

#### Frontend: Webapp
The Web-UI is written in dart using flutter.