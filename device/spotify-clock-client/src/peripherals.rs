use std::error::Error;
use std::time::Duration;
use debounce::EventDebouncer;
use pcf8591::{PCF8591, Pin};
use tokio::sync::mpsc;
use futures::executor;
use librespot::connect::spirc::Spirc;
use rppal::{
    gpio::{Gpio, Trigger},
};
use rppal::gpio::{InputPin, Level};

async fn set_alsa_volume(volume_percent: u16) {
    let volume_percent = volume_percent / 5;
    let mixer = alsa::mixer::Mixer::new("default", false).unwrap();
    let selem_id = alsa::mixer::SelemId::new("PCM", 0);
    let selem = mixer.find_selem(&selem_id).unwrap();
    let (min, max) = selem.get_playback_volume_range();

    let resolution = (max - min) as f64;
    // let factor: u16 = (((0xFFFF + 1) / resolution) - 1) as u16;
    let volume: i64 = (volume_percent as f64 / 100.0 * (resolution)) as i64;
    println!("Setting volume: {:?}, max: {}, §§min: {}", volume, max, min);
    selem.set_playback_volume_all(volume).unwrap();
}

fn read_volume_ctl() {}



pub async fn read_input(spirc: Spirc) -> Result<(), Box<dyn Error>> {
    // Set up GPI for play/pause button
    let (button_tx, mut button_rx) = mpsc::channel::<Level>(32);

    let delay = Duration::from_millis(50);
    let debouncer = EventDebouncer::new(delay, move |gpio_level: Level| {
        println!("Play/Pause");
        executor::block_on(button_tx.send(gpio_level)).expect("TODO: panic message");
    });
    let callback = move |gpio_level| {
        debouncer.put(gpio_level);
    };

    let gpio = Gpio::new().unwrap();
    let mut input = gpio.get(24).unwrap().into_input();
    input.set_async_interrupt(Trigger::RisingEdge, callback).expect("TODO: panic message");

    // Set up i2c for potentiometer ADC
    let mut converter = PCF8591::new("/dev/i2c-1", 0x48, 5.0).unwrap();
    let mut current_volume_percent: u16 = 0;

    loop {
        println!("Enter loop");
        let gpio_level = button_rx.recv().await.unwrap_or(Level::Low);
        // let current_volume_v = converter.analog_read(Pin::AIN0).unwrap();
        // let volume_percent = (current_volume_v / 5.0 * 100.0).round() as u16;
        // if volume_percent != current_volume_percent {
        //     set_alsa_volume(volume_percent).await;
        //     println!("Set volume {}, previously {}", volume_percent, current_volume_percent);
        //     current_volume_percent = volume_percent;
        // }

        if gpio_level == Level::High {
            spirc.play_pause();
        }
    }
}
