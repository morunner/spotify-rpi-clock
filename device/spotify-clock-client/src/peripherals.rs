use std::sync::Arc;
use std::time::Duration;
use debounce::EventDebouncer;
use pcf8591::{PCF8591, Pin};
use tokio::sync::mpsc;
use futures::executor;
use librespot::connect::spirc::Spirc;
use rppal::{
    gpio::{Gpio, Trigger},
};
use rppal::gpio::{InputPin, Level, OutputPin};

use tokio::sync::mpsc::{Receiver, Sender};
use tokio::time::sleep;

struct VolumeController {
    adc: PCF8591,
    volume_percent: u8,
    pin: Pin,
}

impl VolumeController {
    fn new() -> VolumeController {
        // Set up i2c for potentiometer ADC
        let potentiometer_reader_i2c = PCF8591::new("/dev/i2c-1", 0x48, 5.0).unwrap();
        let current_volume_percent: u8 = 0;

        return VolumeController {
            adc: potentiometer_reader_i2c,
            pin: Pin::AIN0,
            volume_percent: current_volume_percent,
        };
    }

    async fn run(&mut self) {
        println!("Start reading potentiometer input.");

        loop {
            let current_volume_v = self.adc.analog_read(Pin::AIN0).unwrap();
            let volume_percent = (current_volume_v / 5.0 * 100.0).round() as u8;
            if volume_percent != self.volume_percent {
                println!("Set volume {}, previously {}", volume_percent, self.volume_percent);
                self.set_alsa_volume(volume_percent as u16);
                self.volume_percent = volume_percent;
            }
            sleep(Duration::from_millis(100)).await;
        }
    }

    fn set_alsa_volume(&self, volume_percent: u16) {
        let mixer = alsa::mixer::Mixer::new("default", false).unwrap();
        let selem_id = alsa::mixer::SelemId::new("PCM", 0);
        let selem = mixer.find_selem(&selem_id).unwrap();
        let (min, max) = selem.get_playback_volume_range();

        let resolution = (max - min) as f64;
        let volume: i64 = (volume_percent as f64 / 100.0 * (resolution)) as i64;
        selem.set_playback_volume_all(volume).unwrap();
    }
}

struct PlaybackController {
    connect_device: Spirc,
    input_pin: InputPin,
    tx: Arc<Sender<Level>>,
    rx: Receiver<Level>,
    playing: bool,
    led_pin: OutputPin,
}

impl PlaybackController {
    fn new(spirc: Spirc) -> PlaybackController {
        let (button_tx, button_rx) = mpsc::channel::<Level>(32);
        let transceiver1 = Arc::new(button_tx).clone();
        let transceiver2 = transceiver1.clone();

        let delay = Duration::from_millis(50);
        let debouncer = EventDebouncer::new(delay, move |gpio_level: Level| {
            println!("Play/Pause");
            executor::block_on(transceiver1.send(gpio_level)).expect("TODO: panic message");
        });
        let callback = move |gpio_level| {
            debouncer.put(gpio_level);
        };

        let gpio = Gpio::new().unwrap();
        let mut input = gpio.get(24).unwrap().into_input();
        input.set_async_interrupt(Trigger::RisingEdge, callback).expect("TODO: panic message");

        const GPIO_LED: u8 = 23;
        let mut pin = Gpio::new().unwrap().get(GPIO_LED).unwrap().into_output();


        return PlaybackController {
            connect_device: spirc,
            input_pin: input,
            tx: transceiver2,
            rx: button_rx,
            playing: false,
            led_pin: pin,
        };
    }

    async fn run(&mut self) {
        println!("Start reading button input.");
        loop {
            let gpio_level = self.rx.recv().await.unwrap_or(Level::Low);

            if gpio_level == Level::High {
                self.playing = !self.playing;
                if self.playing == false {
                    self.led_pin.set_low();
                    self.connect_device.pause();
                } else {
                    self.led_pin.set_high();
                    self.connect_device.play();
                }

                // self.connect_device.play_pause();
            }
        }
    }
}

pub async fn read_input(spirc: Spirc) {
    // Set up GPI for play/pause button
    let mut button = PlaybackController::new(spirc);
    tokio::spawn(async move { button.run().await });

    let mut adc = VolumeController::new();
    tokio::spawn(async move { adc.run().await });
}
