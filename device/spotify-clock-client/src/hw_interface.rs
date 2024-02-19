use crate::keyboard::Keyboard;
use librespot::playback::mixer;
use librespot::playback::mixer::{Mixer, MixerConfig};
use log::{error, info};
use num_traits::real::Real;
use pcf8591::{Pin, PCF8591};
use std::io;
use std::io::{Error, ErrorKind, Write};
use std::time::Duration;
use tokio::sync::mpsc::Sender;
use tokio::time::sleep;

pub struct HardwareInterface {
    hw_enabled: bool,
    adc_pin: Option<Pin>,
    adc: Option<PCF8591>,
    keyboard: Option<Keyboard>,
    volume_percent: f32,
    tx_spotify_ctrl: Sender<SpotifyCmd>,
    tx_spotify_vol: Sender<f32>,
}

impl HardwareInterface {
    pub fn new(
        hardware_type: String,
        tx_spotify_ctrl: Sender<SpotifyCmd>,
        tx_spotify_vol: Sender<f32>,
    ) -> HardwareInterface {
        info!(
            "Initializing HardwareInterface with hardware type {}...",
            hardware_type
        );
        io::stdout().flush().unwrap();

        let mut hw_enabled = false;
        let mut input_pin = None;
        let mut adc = None;
        let mut keyboard = None;
        let volume_percent = 0.0;

        match hardware_type.as_str() {
            "ADC" => match PCF8591::new("/dev/i2c-1", 0x48, 5.0) {
                Ok(i2c_dev) => {
                    hw_enabled = true;
                    input_pin = Some(Pin::AIN0);
                    adc = Some(i2c_dev);
                }
                Err(e) => error!("Unable to attach to i2c adc. Reason: {}", e),
            },
            "keyboard" => keyboard = Some(Keyboard::new()),
            _ => {}
        }

        info!("Done");
        HardwareInterface {
            hw_enabled,
            adc_pin: input_pin,
            adc,
            keyboard,
            volume_percent,
            tx_spotify_ctrl,
            tx_spotify_vol,
        }
    }

    pub async fn run(&mut self) {
        loop {
            match self.read().await {
                Ok(cmd) => {
                    match cmd {
                        SpotifyCmd::Ctrl(SpotifyCtrl::VOLUME_KEEP) => {},
                        _ => {
                            let _ = self.tx_spotify_ctrl.send(cmd).await;
                        }
                    }
                }
                Err(e) => error!("Unable to read volume. Reason: {}", e),
            }
            sleep(Duration::from_millis(100)).await;
        }
    }

    pub async fn read(&mut self) -> Result<SpotifyCmd, Error> {
        match self.hw_enabled {
            true => match self.read_hw().await {
                Ok(cmd) => Ok(cmd),
                Err(e) => Err(e),
            },
            false => match self.read_keyboard().await {
                Ok(cmd) => Ok(cmd),
                Err(e) => Err(e),
            },
        }
    }

    async fn read_hw(&mut self) -> Result<SpotifyCmd, Error> {
        match &mut self.adc {
            Some(adc) => match self.adc_pin {
                Some(pin) => match adc.analog_read(pin) {
                    Ok(voltage) => {
                        let volume_percent = (voltage / 5.0 * 100.0) as f32;
                        if volume_percent > (self.volume_percent + 1.0) {
                            self.volume_percent = volume_percent;
                            Ok(SpotifyCmd::Volume(volume_percent))
                        } else if volume_percent < (self.volume_percent - 1.0) {
                            self.volume_percent = volume_percent;
                            Ok(SpotifyCmd::Volume(volume_percent))
                        } else {
                            Ok(SpotifyCmd::Ctrl(SpotifyCtrl::VOLUME_KEEP))
                        }
                    }
                    Err(e) => Err(Error::from(e)),
                },
                None => Err(Error::new(
                    ErrorKind::NotFound,
                    "No pin configured for VolumeReader.",
                )),
            },
            None => Err(Error::new(
                ErrorKind::NotFound,
                "No hardware attached to VolumeReader.",
            )),
        }
    }

    async fn read_keyboard(&mut self) -> Result<SpotifyCmd, Error> {
        match &mut self.keyboard {
            Some(keyboard) => match keyboard.read_line().await {
                Ok(cmd) => match cmd.as_str() {
                    "+" => Ok(SpotifyCmd::Ctrl(SpotifyCtrl::VOLUME_UP)),
                    "=" => Ok(SpotifyCmd::Ctrl(SpotifyCtrl::VOLUME_KEEP)),
                    "-" => Ok(SpotifyCmd::Ctrl(SpotifyCtrl::VOLUME_DOWN)),
                    "play" => Ok(SpotifyCmd::Ctrl(SpotifyCtrl::PLAY)),
                    "pause" => Ok(SpotifyCmd::Ctrl(SpotifyCtrl::PAUSE)),
                    _ => match cmd.parse::<f32>() {
                        Ok(vol) => Ok(SpotifyCmd::Volume(vol)),
                        Err(_) => Err(Error::new(
                            ErrorKind::InvalidInput,
                            format!("Unknown command: {}", cmd),
                        )),
                    },
                },
                Err(e) => Err(e),
            },
            None => Err(Error::new(
                ErrorKind::NotFound,
                "No keyboard attached to VolumeReader.",
            )),
        }
    }
}

pub enum SpotifyCmd {
    Ctrl(SpotifyCtrl),
    Volume(f32),
}

pub enum SpotifyCtrl {
    VOLUME_UP,
    VOLUME_KEEP,
    VOLUME_DOWN,
    PLAY,
    PAUSE,
}
