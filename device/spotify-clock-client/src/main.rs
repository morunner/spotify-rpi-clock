mod spotify;
mod peripherals;
mod keyboard;
mod hw_interface;
mod controller;

use std::{error::Error};
use tokio::sync::mpsc::channel;
use crate::controller::ClockController;
use crate::hw_interface::HardwareInterface;
use crate::peripherals::{PlaybackController, PlayerEventHandler, VolumeController};
use hw_interface::VolumeCtrl;

#[tokio::main]
async fn main() {
    std::env::set_var("RUST_LOG", "info");
    env_logger::init();

    let (connect_device, connect_task, player_event_channel) = spotify::init().await;

    let mut handles = vec![];

    handles.push(tokio::spawn(async move { connect_task.await }));

    let (cmd_tx_volume,
        cmd_rx_volume) = channel::<VolumeCtrl>(32);
    let mut hw_interface = HardwareInterface::new(String::from("keyboard"),
                                                  cmd_tx_volume.clone());
    handles.push(tokio::spawn(async move { hw_interface.run().await }));

    let mut main_controller = ClockController::new(connect_device, cmd_rx_volume);
    handles.push(tokio::spawn(async move { main_controller.run().await }));

    futures::future::join_all(handles).await;
}
