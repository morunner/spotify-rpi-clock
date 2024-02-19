use log::info;
use std::io::Error;
use tokio::io::{stdin, AsyncBufReadExt, BufReader, Stdin};

pub struct Keyboard {
    reader: BufReader<Stdin>,
}

impl Keyboard {
    pub fn new() -> Keyboard {
        info!("Initializing Keyboard");
        let stdin = stdin();
        let reader = BufReader::new(stdin);

        info!("Done");
        return Keyboard { reader };
    }

    pub async fn read_line(&mut self) -> Result<String, Error> {
        let mut buffer = String::new();
        return match self.reader.read_line(&mut buffer).await {
            Ok(_size) => {
                let command = buffer.trim().to_string();
                info!("Received command: {}", command);
                Ok(command)
            }
            Err(e) => Err(e),
        };
    }
}
