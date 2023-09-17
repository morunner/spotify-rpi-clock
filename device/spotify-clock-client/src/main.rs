use std::env;

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

#[tokio::main]
async fn main() {
    let session_config = SessionConfig::default();
    let player_config = PlayerConfig::default();
    let audio_format = AudioFormat::default();
    let connect_config = ConnectConfig::default();
    let mixer_config = MixerConfig::default();

    // Read credentials
    let args: Vec<_> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: {} USERNAME PASSWORD", args[0]);
        return;
    }
    let credentials = Credentials::with_password(&args[1], &args[2]);

    // Create new session
    print!("Connecting session... ");
    let (session, _) = Session::connect(session_config, credentials, None, false)
        .await
        .unwrap();
    println!("Done");

    // Create player
    print!("Creating player... ");
    let backend = audio_backend::find(None).unwrap();
    let (player, _) = Player::new(
        player_config,
        session.clone(),
        Box::new(NoOpVolume),
        move || backend(None, audio_format),
    );
    println!("Done");

    // Create mixer
    print!("Creating mixer... ");
    let mixerfn = mixer::find(None).unwrap();
    let mixer = (mixerfn)(mixer_config);
    println!("Done");

    // Creating spirc
    let (_, spirc_task_) = Spirc::new(connect_config, session, player, mixer);
    spirc_task_.await;
}
