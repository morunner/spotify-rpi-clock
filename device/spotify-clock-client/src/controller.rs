use crate::hw_interface::{SpotifyCmd, SpotifyCtrl};
use librespot::connect::spirc::Spirc;
use log::{error, info};
use tokio::sync::mpsc::Receiver;

pub struct ClockController {
    connect_client: Spirc,
    rx_spotify_ctrl: Receiver<SpotifyCmd>,
}

impl ClockController {
    pub fn new(connect_client: Spirc, rx_spotify_ctrl: Receiver<SpotifyCmd>) -> ClockController {
        info!("Initializing clock controller...");

        info!("Done");
        ClockController {
            connect_client,
            rx_spotify_ctrl,
        }
    }

    pub async fn run(&mut self) {
        loop {
            let spotify_ctrl = self.rx_spotify_ctrl.recv().await;
            match spotify_ctrl {
                Some(cmd) => match cmd {
                    SpotifyCmd::Ctrl(ctrl) => match ctrl {
                        SpotifyCtrl::VolumeUp => match self.connect_client.volume_up() {
                            Ok(_) => info!("Increasing volume"),
                            Err(e) => error!("Unable to increase volume. Reason: {}", e),
                        },
                        SpotifyCtrl::VolumeKeep => info!("Keeping volume"),
                        SpotifyCtrl::VolumeDown => match self.connect_client.volume_down() {
                            Ok(_) => info!("Decreasing volume"),
                            Err(e) => error!("Unable to decrease volume. Reason {}", e),
                        },
                        SpotifyCtrl::Play => match self.connect_client.play() {
                            Ok(_) => info!("Resuming playback"),
                            Err(e) => error!("Unable to resume playback. Reason: {}", e),
                        },
                        SpotifyCtrl::Pause => match self.connect_client.pause() {
                            Ok(_) => info!("Pausing playback"),
                            Err(e) => error!("Unable to pause playback. Reason: {}", e),
                        },
                    },
                    SpotifyCmd::Volume(vol) => {
                        match self
                            .connect_client
                            .set_volume((vol / 100.0 * 64.0 * 1024.0).round() as u16)
                        {
                            Ok(_) => info!("Setting volume to {}%", vol),
                            Err(e) => error!("Unable to set volume. Reason: {}", e),
                        }
                    }
                },
                None => {}
            }
        }
    }
}
