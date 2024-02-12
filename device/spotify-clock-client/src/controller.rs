use librespot::connect::spirc::Spirc;
use log::info;
use tokio::sync::mpsc::{channel, Receiver, Sender};
use crate::hw_interface::HardwareInterface;
use crate::spotify;
use crate::hw_interface::SpotifyCtrl;

pub struct ClockController {
    connect_client: Spirc,
    cmd_rx_spotify: Receiver<SpotifyCtrl>,
}

impl ClockController {
    pub fn new(connect_client: Spirc, cmd_rx_volume: Receiver<SpotifyCtrl>) -> ClockController {
        info!("Initializing clock controller...");

        info!("Done");
        ClockController {
            connect_client,
            cmd_rx_spotify: cmd_rx_volume,
        }
    }

    pub async fn run(&mut self) {
        loop {
            let volume_cmd = self.cmd_rx_spotify.recv().await;
            match volume_cmd {
                Some(cmd) => match cmd {
                    SpotifyCtrl::VOLUME_UP => {
                        info!("Increasing volume");
                        self.connect_client.volume_up();
                    }
                    SpotifyCtrl::VOLUME_KEEP => info!("Keeping volume"),
                    SpotifyCtrl::VOLUME_DOWN => {
                        info!("Decreasing volume");
                        self.connect_client.volume_down();
                    }
                    SpotifyCtrl::PLAY => {
                        info!("Resuming playback");
                        self.connect_client.play();
                    }
                    SpotifyCtrl::PAUSE => {
                        info!("Pausing playback");
                        self.connect_client.pause();
                    }
                },
                None => {}
            }
        }
    }
}