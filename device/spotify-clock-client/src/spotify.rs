use librespot::connect::config::ConnectConfig;
use librespot::core::SessionConfig;
use librespot::playback::mixer::Mixer;
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
use std::env;
use std::future::Future;

pub async fn init() -> (Spirc, impl Future<Output = ()> + Sized) {
    let session_config = SessionConfig::default();
    let player_config = PlayerConfig::default();
    let audio_format = AudioFormat::default();
    let mut connect_config = ConnectConfig::default();
    connect_config.name = String::from("Wecker 42");
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
    user = String::from("janos823@gmail.com");
    pass = String::from("H3llo76w0rld$");

    let credentials = Credentials::with_password(user, pass);
    let session = Session::new(session_config, None);

    // Create mixer
    print!("Creating mixer... ");
    let mut backend = None;
    if cfg!(feature = "alsa-backend") {
        println!("Using alsa backend for mixer");
        backend = Some("alsa");
    }
    let mixerfn = mixer::find(backend).unwrap();
    println!("Done");

    // Creating spirc
    print!("Creating spirc task... ");
    let mixer = (mixerfn)(mixer_config);
    let backend = audio_backend::find(None).unwrap();
    let player = Player::new(
        player_config,
        session.clone(),
        mixer.get_soft_volume(),
        move || backend(None, audio_format),
    );
    let (spirc, spirc_task) =
        Spirc::new(connect_config, session.clone(), credentials, player, mixer)
            .await
            .unwrap();
    return (spirc, spirc_task);
}
