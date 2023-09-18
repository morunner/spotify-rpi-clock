use std::{env, error::Error, time::Duration};

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
use rppal::{gpio::Gpio, system::DeviceInfo};
use tokio::{
    io::{self, AsyncBufReadExt, BufReader},
    time::sleep,
};

async fn rpi_gpio_ex() -> Result<(), Box<dyn Error>> {
    const GPIO_LED: u8 = 23;
    println!("Blinking an LED on a {}.", DeviceInfo::new()?.model());

    let mut pin = Gpio::new()?.get(GPIO_LED)?.into_output();

    loop {
        pin.set_high();
        sleep(Duration::from_millis(1000)).await;
        pin.set_low();
    }
}

async fn read_commandline(spirc: &mut Spirc) -> Result<(), Box<dyn Error>> {
    let stdin = io::stdin();
    let mut reader = BufReader::new(stdin);
    loop {
        let mut buffer = String::new();
        reader.read_line(&mut buffer).await?;

        println!("Received input: {}", buffer);

        let play = String::from("play");
        let pause = String::from("pause");
        let trimmed_buffer = buffer.trim().to_string();

        if trimmed_buffer == play {
            println!("playing");
            spirc.play();
        } else if trimmed_buffer == pause {
            println!("pausing");
            spirc.pause();
        } else {
            println!("Unknown command");
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
    let (mut spirc_, spirc_task_) =
        Spirc::new(connect_config.clone(), session.clone(), player, mixer);
    println!("Done");
    println!("Running connect device");

    let (first, second) = tokio::join!(spirc_task_, read_commandline(&mut spirc_));
}
