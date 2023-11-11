use std::env;
use std::future::Future;
use librespot::{
    connect::spirc::Spirc,
    core::{
        config::{ConnectConfig, SessionConfig},
        session::Session,
    },
    discovery::Credentials,
    playback::{
        audio_backend,
        config::{AudioFormat, PlayerConfig},
        mixer::{self, MixerConfig, NoOpVolume},
        player::Player,
    },
};
use librespot::playback::player::PlayerEventChannel;

pub async fn init() -> (Spirc, impl Future<Output=()> + Sized, PlayerEventChannel) {
    let session_config = SessionConfig::default();
    let player_config = PlayerConfig::default();
    let audio_format = AudioFormat::default();
    let connect_config = ConnectConfig::default();
    let mixer_config = MixerConfig::default();

    // Create new session
    print!("Connecting session... ");
    // Read credentials
    let mut user = String::new();
    let mut pass = String::new();
    match env::var("USER") {
        Ok(username) => user = username,
        Err(e) => println!("Unable to retrieve username ({e})"),
    }
    match env::var("PASS") {
        Ok(password) => pass = password,
        Err(e) => println!("Unable to retrieve password ({e})"),
    }

    let credentials = Credentials::with_password(user, pass);
    let (session, _) = Session::connect(session_config, credentials, None, false)
        .await
        .unwrap();
    println!("Done");

    // Create mixer
    print!("Creating mixer... ");
    let mixerfn = mixer::find(Some("alsa")).unwrap();
    println!("Done");

    // Creating spirc
    print!("Creating spirc task... ");
    let mixer = (mixerfn)(mixer_config);
    let backend = audio_backend::find(None).unwrap();
    let (player, event_channel) = Player::new(
        player_config,
        session.clone(),
        Box::new(NoOpVolume),
        move || backend(None, audio_format),
    );
    let (spirc_, spirc_task_) =
        Spirc::new(connect_config.clone(), session.clone(), player, mixer);

    return (spirc_, spirc_task_, event_channel);
}