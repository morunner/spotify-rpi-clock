use crate::keyboard::Keyboard;
use debounce::EventDebouncer;
use futures::executor;
use log::{error, info};
use pcf8591::{Pin, PCF8591};
use rppal::gpio::{Gpio, InputPin, Level, OutputPin, Trigger};
use std::io;
use std::io::{Error, ErrorKind, Write};
use std::time::Duration;
use tokio::sync::mpsc::{Receiver, Sender};
use tokio::time::sleep;

pub enum SpotifyCmd {
    Ctrl(SpotifyCtrl),
    Volume(f32),
}

pub enum SpotifyCtrl {
    VolumeUp,
    VolumeKeep,
    VolumeDown,
    Play,
    Pause,
}

pub enum HwCtrl {
    LedOn,
    LedOff,
}

pub struct HardwareInterface {
    hw_enabled: bool,
    adc_pin: Option<Pin>,
    adc: Option<PCF8591>,
    button_pin: Option<InputPin>,
    led_pin: Option<OutputPin>,
    keyboard: Option<Keyboard>,
    volume_percent: f32,
    tx_spotify_ctrl: Sender<SpotifyCmd>,
    rx_hw_ctrl: Receiver<HwCtrl>,
}

impl HardwareInterface {
    pub fn new(
        hardware_type: String,
        tx_spotify_ctrl: Sender<SpotifyCmd>,
        rx_hw_ctrl: Receiver<HwCtrl>,
    ) -> HardwareInterface {
        info!(
            "Initializing HardwareInterface with hardware type {}...",
            hardware_type
        );
        io::stdout().flush().unwrap();
        let mut hw_enabled = false;

        info!("Initializing potentiometer ADC");
        let mut adc_pin = None;
        let mut adc = None;
        let mut keyboard = None;
        let volume_percent = 0.0;

        match hardware_type.as_str() {
            "hw" => match PCF8591::new("/dev/i2c-1", 0x48, 5.0) {
                Ok(i2c_dev) => {
                    hw_enabled = true;
                    adc_pin = Some(Pin::AIN0);
                    adc = Some(i2c_dev);
                }
                Err(e) => error!("Unable to attach to i2c adc. Reason: {}", e),
            },
            "keyboard" => keyboard = Some(Keyboard::new()),
            _ => {}
        }
        info!("Initializing play/pause button GPIO");
        let playing = false;
        let mut debouncer_playing = playing.clone();
        let debouncer_spotify_ctrl = tx_spotify_ctrl.clone();
        let debouncer =
            EventDebouncer::new(
                Duration::from_millis(50),
                move |gpio_level: Level| match gpio_level {
                    Level::High => {
                        debouncer_playing = !debouncer_playing;
                        match debouncer_playing {
                            true => match executor::block_on(
                                debouncer_spotify_ctrl.send(SpotifyCmd::Ctrl(SpotifyCtrl::Pause)),
                            ) {
                                Ok(_) => {}
                                Err(e) => error!("Unable to send pause command. Reason: {}", e),
                            },
                            false => match executor::block_on(
                                debouncer_spotify_ctrl.send(SpotifyCmd::Ctrl(SpotifyCtrl::Play)),
                            ) {
                                Ok(_) => {}
                                Err(e) => error!("Unable to send play command. Reason: {}", e),
                            },
                        }
                    }
                    Level::Low => {}
                },
            );
        let callback = move |gpio_level| {
            debouncer.put(gpio_level);
        };
        let mut button_pin = None;
        match Gpio::new() {
            Ok(gpio) => match gpio.get(25) {
                Ok(pin) => {
                    let mut input_pin = pin.into_input();
                    input_pin
                        .set_async_interrupt(Trigger::RisingEdge, callback)
                        .expect("REASON");
                    button_pin = Some(input_pin);
                }
                Err(e) => error!("Unable to get gpio {}. Reason: {}", 24, e),
            },
            Err(e) => error!("unable to init Gpio for play/pause button. Reason: {}", e),
        }

        info!("Initializing LED pin");
        let mut led_pin = None;
        match Gpio::new() {
            Ok(gpio) => match gpio.get(23) {
                Ok(pin) => {
                    led_pin = Some(pin.into_output());
                }
                Err(e) => error!("Unable to get gpio {}. Reason: {}", 23, e),
            },
            Err(e) => error!("Unable to init Gpio for LED. Reason: {}", e),
        }

        HardwareInterface {
            hw_enabled,
            adc_pin,
            adc,
            button_pin,
            led_pin,
            keyboard,
            volume_percent,
            tx_spotify_ctrl,
            rx_hw_ctrl,
        }
    }

    pub async fn run(&mut self) {
        loop {
            match self.read().await {
                Ok(cmd) => match cmd {
                    SpotifyCmd::Ctrl(SpotifyCtrl::VolumeKeep) => {}
                    _ => {
                        let _ = self.tx_spotify_ctrl.send(cmd).await;
                    }
                },
                Err(e) => error!("Unable to read volume. Reason: {}", e),
            }
            match self.rx_hw_ctrl.try_recv() {
                Ok(ctrl) => match ctrl {
                    HwCtrl::LedOn => {
                        if self.led_pin.is_some() {
                            self.led_pin.as_mut().expect("").set_high();
                        }
                    }
                    HwCtrl::LedOff => {
                        if self.led_pin.is_some() {
                            self.led_pin.as_mut().expect("").set_low();
                        }
                    }
                },
                Err(_) => {}
            }
            sleep(Duration::from_millis(25)).await;
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
                        let volume_percent = (voltage / 5.0 * 100.0).round() as f32;
                        if volume_percent > (self.volume_percent + 1.0) {
                            self.volume_percent = volume_percent;
                            Ok(SpotifyCmd::Volume(volume_percent))
                        } else if volume_percent < (self.volume_percent - 1.0) {
                            self.volume_percent = volume_percent;
                            Ok(SpotifyCmd::Volume(volume_percent))
                        } else {
                            Ok(SpotifyCmd::Ctrl(SpotifyCtrl::VolumeKeep))
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
                    "+" => Ok(SpotifyCmd::Ctrl(SpotifyCtrl::VolumeUp)),
                    "=" => Ok(SpotifyCmd::Ctrl(SpotifyCtrl::VolumeKeep)),
                    "-" => Ok(SpotifyCmd::Ctrl(SpotifyCtrl::VolumeDown)),
                    "play" => Ok(SpotifyCmd::Ctrl(SpotifyCtrl::Play)),
                    "pause" => Ok(SpotifyCmd::Ctrl(SpotifyCtrl::Pause)),
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
