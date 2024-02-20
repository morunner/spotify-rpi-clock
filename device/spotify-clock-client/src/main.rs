mod controller;
mod hw_interface;
mod keyboard;
mod spotify;
mod player_event_handler;

use crate::controller::ClockController;
use crate::hw_interface::{HardwareInterface, SpotifyCmd};

use clap::{Arg, Command};
use configparser::ini::Ini;
use log::{error, info};


use std::ops::Deref;
use tokio::sync::mpsc::channel;

struct Options {
    log_level: String,
    input_type: String,
    config_path: String,
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
                let mut handles = vec![];
                handles.push(tokio::spawn(async move { result.1.await }));

                let (tx_spotify_cmd, rx_spotify_cmd) = channel::<SpotifyCmd>(256);
                let mut hw_interface =
                    HardwareInterface::new(opts.input_type, tx_spotify_cmd.clone(), result.2);
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
        .get_matches();

    let log_level = String::from(matches.get_one::<String>("log_level").unwrap().deref());
    let input_type = String::from(matches.get_one::<String>("input_type").unwrap().deref());
    let config_path = String::from(matches.get_one::<String>("config_path").unwrap().deref());

    Options {
        log_level,
        input_type,
        config_path,
    }
}
