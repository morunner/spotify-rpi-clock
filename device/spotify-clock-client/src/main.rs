mod spotify;
mod peripherals;

use std::{error::Error};
use crate::peripherals::{PlaybackController, PlayerEventHandler, VolumeController};

#[tokio::main]
async fn main() {
    let (connect_device, connect_task, player_event_channel) = spotify::init().await;

    let mut handles = vec![];

    handles.push(tokio::spawn( async move { connect_task.await }));

    let mut button = PlaybackController::new(connect_device);
    handles.push(tokio::spawn(async move { button.run().await }));

    let mut adc = VolumeController::new();
    handles.push(tokio::spawn(async move { adc.run().await }));

    let mut player_event_handler = PlayerEventHandler::new(player_event_channel);
    handles.push(tokio::spawn(async move { player_event_handler.run().await }));

    futures::future::join_all(handles).await;
}
