mod controller;
mod hw_interface;
mod keyboard;
mod player_event_handler;
mod spotify;

use crate::controller::ClockController;
use crate::hw_interface::{HardwareInterface, HwCtrl, SpotifyCmd};
use std::fs;

use clap::{value_parser, Arg, Command};
use configparser::ini::Ini;
use log::{error, info};

use crate::player_event_handler::PlayerEventHandler;
use std::ops::Deref;
use tokio::sync::mpsc::channel;

struct Options {
    log_level: String,
    input_type: String,
    config_path: String,
    pi_led_off: bool,
}

#[tokio::main]
async fn main() {
    let opts = parse_args();
    std::env::set_var("RUST_LOG", opts.log_level);
    env_logger::init();

    let mut config = Ini::new();
    match config.load(opts.config_path) {
        Ok(_) => match spotify::init(
            config.get("spotify", "device_id").unwrap(),
            config.get("spotify", "device_name").unwrap(),
            config.get("spotify", "username").unwrap(),
            config.get("spotify", "password").unwrap(),
        )
        .await
        {
            Some(result) => {
                if opts.pi_led_off == true {
                    info!("Turning off ACT led");
                    match fs::write("/sys/class/leds/ACT/brightness", b"0") {
                        Ok(_) => info!("Turned off ACT LED"),
                        Err(e) => error!("Unable to write to file. Reason: {}", e),
                    }
                }

                let mut handles = vec![];
                handles.push(tokio::spawn(async move { result.1.await }));

                let (tx_spotify_cmd, rx_spotify_cmd) = channel::<SpotifyCmd>(256);
                let (tx_hw_ctrl, rx_hw_ctrl) = channel::<HwCtrl>(32);

                let mut player_event_handler = PlayerEventHandler::new(result.2, tx_hw_ctrl);
                handles.push(tokio::spawn(
                    async move { player_event_handler.run().await },
                ));

                let mut hw_interface =
                    HardwareInterface::new(opts.input_type, tx_spotify_cmd.clone(), rx_hw_ctrl);
                handles.push(tokio::spawn(async move { hw_interface.run().await }));

                let mut main_controller = ClockController::new(result.0, rx_spotify_cmd);
                handles.push(tokio::spawn(async move { main_controller.run().await }));

                futures::future::join_all(handles).await;
            }
            None => info!("Exiting"),
        },
        Err(e) => error!("Unable to load config. Reason: {}", e),
    }
}

fn parse_args() -> Options {
    let matches = Command::new("Spotify Clock App")
        .version("0.1.0")
        .author("morunner")
        .arg(
            Arg::new("log_level")
                .short('l')
                .long("log_level")
                .help("log level of the app")
                .default_value("error"),
        )
        .arg(
            Arg::new("input_type")
                .short('i')
                .long("input_type")
                .help("input type for commands")
                .required(true),
        )
        .arg(
            Arg::new("config_path")
                .short('c')
                .long("config_path")
                .help("Absolute path to where the config file is located")
                .required(true),
        )
        .arg(
            Arg::new("pi_led_off")
                .short('p')
                .long("pi_led_off")
                .help("set to true if Raspberry Pi (Zero 2W) LED should be turned off")
                .value_parser(value_parser!(bool))
                .default_value("false"),
        )
        .get_matches();

    let log_level = String::from(matches.get_one::<String>("log_level").unwrap().deref());
    let input_type = String::from(matches.get_one::<String>("input_type").unwrap().deref());
    let config_path = String::from(matches.get_one::<String>("config_path").unwrap().deref());
    let pi_led_off = *matches.get_one::<bool>("pi_led_off").unwrap();

    Options {
        log_level,
        input_type,
        config_path,
        pi_led_off,
    }
}
