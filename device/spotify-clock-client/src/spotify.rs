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
    let args: Vec<_> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} USERNAME PASSWORD", args[0]);
    }

    let credentials = Credentials::with_password(&args[1], &args[2]);
    let (session, _) = Session::connect(session_config, credentials, None, false)
        .await
        .unwrap();
    println!("Done");

    // Create mixer
    print!("Creating mixer... ");
    let mixerfn = mixer::find(None).unwrap();
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