use crate::hw_interface::HwCtrl;
use librespot::playback::player::{PlayerEvent, PlayerEventChannel};
use tokio::sync::mpsc::Sender;

pub struct PlayerEventHandler {
    player_event_channel: PlayerEventChannel,
    tx_hw_ctrl: Sender<HwCtrl>,
}

impl PlayerEventHandler {
    pub(crate) fn new(
        player_event_channel: PlayerEventChannel,
        tx_hw_ctrl: Sender<HwCtrl>,
    ) -> PlayerEventHandler {
        PlayerEventHandler {
            player_event_channel,
            tx_hw_ctrl,
        }
    }

    pub async fn run(&mut self) {
        loop {
            match self.player_event_channel.recv().await {
                Some(event) => match event {
                    PlayerEvent::PlayRequestIdChanged { .. } => {}
                    PlayerEvent::Stopped { .. } => {
                        let _ = self.tx_hw_ctrl.send(HwCtrl::LedOff).await;
                    }
                    PlayerEvent::Loading { .. } => {}
                    PlayerEvent::Preloading { .. } => {}
                    PlayerEvent::Playing { .. } => {
                        let _ = self.tx_hw_ctrl.send(HwCtrl::LedOn).await;
                    }
                    PlayerEvent::Paused { .. } => {
                        let _ = self.tx_hw_ctrl.send(HwCtrl::LedOff).await;
                    }
                    PlayerEvent::TimeToPreloadNextTrack { .. } => {}
                    PlayerEvent::EndOfTrack { .. } => {}
                    PlayerEvent::Unavailable { .. } => {}
                    PlayerEvent::VolumeChanged { .. } => {}
                    PlayerEvent::PositionCorrection { .. } => {}
                    PlayerEvent::Seeked { .. } => {}
                    PlayerEvent::TrackChanged { .. } => {}
                    PlayerEvent::SessionConnected { .. } => {}
                    PlayerEvent::SessionDisconnected { .. } => {}
                    PlayerEvent::SessionClientChanged { .. } => {}
                    PlayerEvent::ShuffleChanged { .. } => {}
                    PlayerEvent::RepeatChanged { .. } => {}
                    PlayerEvent::AutoPlayChanged { .. } => {}
                    PlayerEvent::FilterExplicitContentChanged { .. } => {}
                },
                None => {}
            }
        }
    }
}
