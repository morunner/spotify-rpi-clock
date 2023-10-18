mod spotify_client;
mod peripherals;

use std::{error::Error, time::Duration};
use rppal::gpio::Gpio;
use rppal::system::DeviceInfo;
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



#[tokio::main]
async fn main() {
    let (connect_client, connect_client_task) = spotify_client::init().await;
    let (_first, _second, _third) = tokio::join!(connect_client_task, blink_led(), peripherals::read_input(connect_client));
}
