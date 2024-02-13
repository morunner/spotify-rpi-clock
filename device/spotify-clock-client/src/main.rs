mod spotify;
mod peripherals;
mod keyboard;
mod hw_interface;
mod controller;

use std::{error::Error};
use std::ops::Deref;
use tokio::sync::mpsc::channel;
use crate::controller::ClockController;
use crate::hw_interface::HardwareInterface;
use hw_interface::SpotifyCtrl;
use clap::{Arg, Command};

struct Options {
    log_level: String,
    input_type: String,
}


#[tokio::main]
async fn main() {
    let opts = parse_args();
    std::env::set_var("RUST_LOG", opts.log_level);
    env_logger::init();

    let (connect_device, connect_task, player_event_channel) = spotify::init().await;

    let mut handles = vec![];

    handles.push(tokio::spawn(async move { connect_task.await }));

    let (cmd_tx_spotify,
        cmd_rx_spotify) = channel::<SpotifyCtrl>(32);
    let mut hw_interface = HardwareInterface::new(opts.input_type,
                                                  cmd_tx_spotify.clone());
    handles.push(tokio::spawn(async move { hw_interface.run().await }));

    let mut main_controller = ClockController::new(connect_device, cmd_rx_spotify);
    handles.push(tokio::spawn(async move { main_controller.run().await }));

    futures::future::join_all(handles).await;
}

fn parse_args() -> Options {
    let matches = Command::new("Spotify Clock App")
        .version("0.1.0")
        .author("morunner")
        .arg(Arg::new("log_level")
            .short('l')
            .long("log_level")
            .help("log level of the app"))
        .arg(Arg::new("input_type")
            .short('i')
            .long("input_type")
            .help("input type for commands"))
        .get_matches();

    let log_level = String::from(matches.get_one::<String>("log_level").unwrap().deref());
    let input_type = String::from(matches.get_one::<String>("input_type").unwrap().deref());
    Options {
        log_level,
        input_type,
    }
}
