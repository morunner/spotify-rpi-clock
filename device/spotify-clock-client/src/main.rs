mod spotify;
mod peripherals;

use std::{error::Error};
#[tokio::main]
async fn main() {
    let (connect_device, connect_task, player_event_channel) = spotify::init().await;
    tokio::join!(connect_task, peripherals::read_input(connect_device, player_event_channel));
}
