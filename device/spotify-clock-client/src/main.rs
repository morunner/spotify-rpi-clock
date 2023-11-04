mod spotify;
mod peripherals;

use std::{error::Error};
#[tokio::main]
async fn main() {
    let (connect_device, connect_task) = spotify::init().await;
    tokio::join!(connect_task, peripherals::read_input(connect_device));
}
