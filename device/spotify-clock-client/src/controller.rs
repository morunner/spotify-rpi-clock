use librespot::connect::spirc::Spirc;
use log::info;
use tokio::sync::mpsc::{channel, Receiver, Sender};
use crate::hw_interface::HardwareInterface;
use crate::spotify;
use crate::hw_interface::VolumeCtrl;

pub struct ClockController {
    connect_client: Spirc,
    cmd_rx_volume: Receiver<VolumeCtrl>,
}

impl ClockController {
    pub fn new(connect_client: Spirc, cmd_rx_volume: Receiver<VolumeCtrl>) -> ClockController {
        info!("Initializing clock controller...");

        info!("Done");
        ClockController {
            connect_client,
            cmd_rx_volume,
        }
    }

    pub async fn run(&mut self) {
        loop {
            let volume_cmd = self.cmd_rx_volume.recv().await;
            match volume_cmd {
                Some(cmd) => match cmd {
                    VolumeCtrl::UP => {
                        info!("Increasing volume");
                        self.connect_client.volume_up();
                    }
                    VolumeCtrl::KEEP => info!("Keeping volume"),
                    VolumeCtrl::DOWN => {
                        info!("Decreasing volume");
                        self.connect_client.volume_down();
                    }
                },
                None => {}
            }
        }
    }
}