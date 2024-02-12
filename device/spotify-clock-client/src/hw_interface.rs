use std::io;
use std::io::{Error, ErrorKind, Write};
use log::{error, info};
use pcf8591::{PCF8591, Pin};
use tokio::sync::mpsc::Sender;
use crate::keyboard::Keyboard;

pub struct HardwareInterface {
    hw_enabled: bool,
    input_pin: Option<Pin>,
    adc: Option<PCF8591>,
    keyboard: Option<Keyboard>,
    volume_percent: u8,
    cmd_tx_volume: Sender<VolumeCtrl>,
}

impl HardwareInterface {
    pub fn new(hardware_type: String, tx_channel: Sender<VolumeCtrl>) -> HardwareInterface {
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
            input_pin,
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
                    println!("Received cmd");
                    let _ = self.cmd_tx_volume.send(cmd).await;
                }
                Err(e) => error!("Unable to read volume. Reason: {}", e)
            }
        }
    }

    pub async fn read(&mut self) -> Result<VolumeCtrl, Error> {
        match self.hw_enabled {
            // TODO: Implement ADC readout
            true => Err(Error::new(ErrorKind::Unsupported, "Readout for ADC not implemented yet")),
            false => match self.read_keyboard().await {
                Ok(cmd) => Ok(cmd),
                Err(e) => Err(e)
            },
        }
    }

    async fn read_keyboard(&mut self) -> Result<VolumeCtrl, Error> {
        match &mut self.keyboard {
            Some(keyboard) => {
                match keyboard.read_line().await {
                    Ok(cmd) => match cmd.as_str() {
                        "+" => Ok(VolumeCtrl::UP),
                        "=" => Ok(VolumeCtrl::KEEP),
                        "-" => Ok(VolumeCtrl::DOWN),
                        _ => Err(Error::new(ErrorKind::InvalidInput, format!("Unknown command: {}", cmd))),
                    },
                    Err(e) => Err(e),
                }
            }
            None => Err(Error::new(ErrorKind::NotFound, "No keyboard attached to VolumeReader."))
        }
    }
}

#[derive(Debug)]
pub enum VolumeCtrl {
    UP = 1,
    KEEP = 0,
    DOWN = -1,
}
