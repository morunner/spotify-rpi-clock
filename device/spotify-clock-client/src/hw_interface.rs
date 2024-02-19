use std::io;
use std::io::{Error, ErrorKind, Write};
use log::{error, info};
use pcf8591::{PCF8591, Pin};
use tokio::sync::mpsc::Sender;
use crate::keyboard::Keyboard;
use num_traits::real::Real;

pub struct HardwareInterface {
    hw_enabled: bool,
    adc_pin: Option<Pin>,
    adc: Option<PCF8591>,
    keyboard: Option<Keyboard>,
    volume_percent: u8,
    cmd_tx_volume: Sender<SpotifyCtrl>,
}

impl HardwareInterface {
    pub fn new(hardware_type: String, tx_channel: Sender<SpotifyCtrl>) -> HardwareInterface {
        info!("Initializing HardwareInterface with hardware type {}...", hardware_type);
        io::stdout().flush().unwrap();

        let mut hw_enabled = false;
        let mut input_pin = None;
        let mut adc = None;
        let mut keyboard = None;
        let volume_percent = 0;

        match hardware_type.as_str() {
            "ADC" => match PCF8591::new("/dev/i2c-1", 0x48, 5.0) {
                Ok(i2c_dev) => {
                    hw_enabled = true;
                    input_pin = Some(Pin::AIN0);
                    adc = Some(i2c_dev);
                }
                Err(e) => error!("Unable to attach to i2c adc. Reason: {}", e)
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
            cmd_tx_volume: tx_channel,
        }
    }

    pub async fn run(&mut self) {
        loop {
            match self.read().await {
                Ok(cmd) => {
                    let _ = self.cmd_tx_volume.send(cmd).await;
                }
                Err(e) => error!("Unable to read volume. Reason: {}", e)
            }
        }
    }

    pub async fn read(&mut self) -> Result<SpotifyCtrl, Error> {
        match self.hw_enabled {
            true => match self.read_hw().await {
                Ok(cmd) => Ok(cmd),
                Err(e) => Err(e)
            }
            false => match self.read_keyboard().await {
                Ok(cmd) => Ok(cmd),
                Err(e) => Err(e)
            },
        }
    }

    async fn read_hw(&mut self) -> Result<SpotifyCtrl, Error> {
        match &mut self.adc {
            Some(adc) => {
                match self.adc_pin {
                    Some(pin) => {
                        match adc.analog_read(pin) {
                            Ok(voltage) => {
                                let volume_frac = (voltage / 5.0);
                                let volume_percent = (volume_frac * 100.0).round() as u8;
                                if volume_percent > (self.volume_percent + 1) {
                                    self.volume_percent = volume_percent;
                                    Ok(SpotifyCtrl::VOLUME_UP)
                                } else if volume_percent < (self.volume_percent - 1) {
                                    self.volume_percent = volume_percent;
                                    Ok(SpotifyCtrl::VOLUME_DOWN)
                                } else {
                                    Ok(SpotifyCtrl::VOLUME_KEEP)
                                }
                            }
                            Err(e) => Err(Error::from(e))
                        }
                }
                None => Err(Error::new(ErrorKind::NotFound, "No pin configured for VolumeReader."))
            }
        }
        None => Err(Error::new(ErrorKind::NotFound, "No hardware attached to VolumeReader."))
    }
}

async fn read_keyboard(&mut self) -> Result<SpotifyCtrl, Error> {
    match &mut self.keyboard {
        Some(keyboard) => {
            match keyboard.read_line().await {
                Ok(cmd) => match cmd.as_str() {
                    "+" => Ok(SpotifyCtrl::VOLUME_UP),
                    "=" => Ok(SpotifyCtrl::VOLUME_KEEP),
                    "-" => Ok(SpotifyCtrl::VOLUME_DOWN),
                    "play" => Ok(SpotifyCtrl::PLAY),
                    "pause" => Ok(SpotifyCtrl::PAUSE),
                    _ => Err(Error::new(ErrorKind::InvalidInput, format!("Unknown command: {}", cmd))),
                },
                Err(e) => Err(e),
            }
        }
        None => Err(Error::new(ErrorKind::NotFound, "No keyboard attached to VolumeReader."))
    }
}
}
pub enum SpotifyCtrl {
    VOLUME_UP,
    VOLUME_KEEP,
    VOLUME_DOWN,
    PLAY,
    PAUSE,
}
