use std::{env, error::Error, time::Duration};
use std::thread::current;
use debounce::EventDebouncer;
use pcf8591::{PCF8591, Pin};
use tokio::sync::mpsc;
use futures::executor;
use librespot::{
    connect::spirc::Spirc,
    core::{
        config::{ConnectConfig, SessionConfig},
        session::Session,
    },
    discovery::Credentials,
    playback::{
        audio_backend,
        config::{AudioFormat, PlayerConfig},
        mixer::{self, MixerConfig, NoOpVolume},
        player::Player,
    },
};
use rppal::{
    gpio::{Gpio, Trigger},
    system::DeviceInfo,
};
use rppal::gpio::Level;
use tokio::time::sleep;

async fn blink_led() -> Result<(), Box<dyn Error>> {
    const GPIO_LED: u8 = 23;
    println!("Blinking an LED on a {}.", DeviceInfo::new()?.model());

    let mut pin = Gpio::new()?.get(GPIO_LED)?.into_output();

    loop {
        pin.set_high();
        sleep(Duration::from_millis(1000)).await;
        pin.set_low();
        sleep(Duration::from_millis(1000)).await;
    }
}

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

async fn read_input(spirc: Spirc) -> Result<(), Box<dyn Error>> {
    let (sender, mut receiver) = mpsc::channel::<Level>(32);

    // Set up GPI for play/pause button
    const GPIO_BUTTON: u8 = 24;
    let mut input = Gpio::new()?.get(GPIO_BUTTON)?.into_input();
    let callback = move |level| {
        executor::block_on(sender.send(level)).expect("TODO: panic message");
    };
    input.set_async_interrupt(Trigger::RisingEdge, callback).expect("TODO: panic message");

    // Set up i2c for potentiometer ADC
    let mut converter = PCF8591::new("/dev/i2c-1", 0x48, 5.0).unwrap();
    let mut current_volume_percent: u16 = 0;

    let delay = Duration::from_millis(100);
    let debouncer = EventDebouncer::new(delay, move |data: Level| {
        println!("Play/Pause");
        spirc.play_pause();
    });
    loop {
        let gpio_level = receiver.recv().await.unwrap();
        let current_volume_v = converter.analog_read(Pin::AIN0).unwrap();
        let volume_percent = (current_volume_v / 5.0 * 100.0).round() as u16;
        if volume_percent != current_volume_percent {
            set_alsa_volume(volume_percent).await;
            println!("Set volume {}, previously {}", volume_percent, current_volume_percent);
            current_volume_percent = volume_percent;
        }

        if gpio_level == Level::High {
            debouncer.put(gpio_level);
        }
    }
}

#[tokio::main]
async fn main() {
    let session_config = SessionConfig::default();
    let player_config = PlayerConfig::default();
    let audio_format = AudioFormat::default();
    let connect_config = ConnectConfig::default();
    let mixer_config = MixerConfig::default();

    // Read credentials
    let args: Vec<_> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} USERNAME PASSWORD", args[0]);
        return;
    }
    let credentials = Credentials::with_password(&args[1], &args[2]);

    // Create new session
    print!("Connecting session... ");
    let (session, _) = Session::connect(session_config, credentials, None, false)
        .await
        .unwrap();
    println!("Done");

    // Create mixer
    print!("Creating mixer... ");
    let mixerfn = mixer::find(None).unwrap();
    println!("Done");

    // Creating spirc
    print!("Creating spirc task... ");
    let mixer = (mixerfn)(mixer_config);
    let backend = audio_backend::find(None).unwrap();
    let (player, _) = Player::new(
        player_config,
        session.clone(),
        Box::new(NoOpVolume),
        move || backend(None, audio_format),
    );
    let (spirc_, spirc_task_) =
        Spirc::new(connect_config.clone(), session.clone(), player, mixer);
    println!("Done");
    println!("Running connect device");

    let (_first, _second, _third) = tokio::join!(spirc_task_, blink_led(), read_input(spirc_));
}
