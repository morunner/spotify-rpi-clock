mod spotify;
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
    let (connect_device, connect_task) = spotify::init().await;
    tokio::join!(connect_task, blink_led(), peripherals::read_input(connect_device));
}
