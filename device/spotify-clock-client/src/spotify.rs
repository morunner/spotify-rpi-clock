use librespot::connect::config::ConnectConfig;
use librespot::core::SessionConfig;
use librespot::{
    connect::spirc::Spirc,
    core::session::Session,
    discovery::Credentials,
    playback::{
        audio_backend,
        config::{AudioFormat, PlayerConfig},
        mixer::{self, MixerConfig},
        player::Player,
    },
};
use log::{error, info};
use std::future::Future;
use librespot::playback::player::PlayerEventChannel;

pub async fn init(
    device_id: String,
    device_name: String,
    username: String,
    password: String,
) -> Option<(Spirc, impl Future<Output = ()> + Sized, PlayerEventChannel)> {
    info!("Initializing spotify client...");
    let mut session_config = SessionConfig::default();
    session_config.device_id = device_id;
    let player_config = PlayerConfig::default();
    let audio_format = AudioFormat::default();
    let mut connect_config = ConnectConfig::default();
    connect_config.name = device_name;
    let mixer_config = MixerConfig::default();

    // Create new session
    info!("Connecting session... ");
    let credentials = Credentials::with_password(username, password);
    let session = Session::new(session_config, None);

    // Create mixer
    info!("Creating mixer... ");
    let mut backend = None;
    if cfg!(feature = "alsa-backend") {
        println!("Using alsa backend for mixer");
        backend = Some("alsa");
    }

    let mixerfn = mixer::find(backend).unwrap();

    // Creating spirc
    info!("Creating spirc task... ");
    let mixer = (mixerfn)(mixer_config);
    let backend = audio_backend::find(None).unwrap();
    let player = Player::new(
        player_config,
        session.clone(),
        mixer.get_soft_volume(),
        move || backend(None, audio_format),
    );

    match Spirc::new(connect_config, session.clone(), credentials, player.clone(), mixer).await {
        Ok(result) => {
            info!("Done initializing spotify client");
            let retval = (result.0, result.1, player.get_player_event_channel());
            Some(retval)
        }
        Err(e) => {
            error!("Unable to initialize spotify device. Reason: {}", e);
            None
        }
    }
}
