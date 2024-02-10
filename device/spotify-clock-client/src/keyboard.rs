use log::info;
use tokio::io::{AsyncBufReadExt, BufReader, Stdin, stdin};

pub struct Keyboard {
    buffer: String,
    reader: BufReader<Stdin>,
}

impl Keyboard {
    pub fn new() -> Keyboard {
        info!("Initializing Keyboard");
        let stdin = stdin();
        let reader = BufReader::new(stdin);
        let mut buffer = String::new();

        return Keyboard {
            buffer,
            reader,
        };
    }

    pub async fn read_line(&mut self) -> String {
        return match self.reader.read_line(&mut self.buffer).await {
            Ok(_size) => {
                let command = self.buffer.trim().to_string();
                info!("Received command: {}", command);
                command
            }
            Err(e) => {
                info!("Could not read line. Reason: {}", e);
                String::from("")
            },
        }
    }
}