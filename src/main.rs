mod app;
mod dictionary;
mod note_state;
mod text_state;
mod tts;
mod ui;

use app_dirs2::AppInfo;
use clap::Parser;
use crossterm::{
    event::{DisableMouseCapture, EnableMouseCapture},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
    tty::IsTty,
};
use ratatui::prelude::*;
use std::{
    error::Error,
    fs,
    io::{self, Read},
    time::Duration,
};

const APP_INFO: AppInfo = AppInfo {
    name: "escrit",
    author: "ptlerner",
};

#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Cli {
    file_name: Option<String>,
}

fn main() -> Result<(), Box<dyn Error>> {
    let cli = Cli::parse();
    let text = if let Some(file_name) = cli.file_name {
        fs::read_to_string(file_name).expect("File to be readable")
    } else {
        let stdin = std::io::stdin();

        let input = if !stdin.is_tty() {
            // Swap stdin and TTY
            // https://github.com/tcr/rager/blob/master/src/main.rs
            // https://stackoverflow.com/a/29694013
            unsafe {
                use std::os::unix::io::*;

                #[cfg(target_os = "linux")]
                let tty = std::fs::File::open("/dev/tty").unwrap();

                #[cfg(target_os = "macos")]
                let tty = std::fs::File::open("/dev/ttys010").unwrap();

                let stdin_fd = libc::dup(0);

                let ret = std::fs::File::from_raw_fd(stdin_fd);

                libc::dup2(tty.as_raw_fd(), 0);

                ::std::mem::forget(tty);

                Some(ret)
            }
        } else {
            None
        };

        if let Some(mut input) = input {
            let mut text = String::new();
            let _ = input.read_to_string(&mut text);
            text
        } else {
            "".to_owned()
        }
    };

    if text.trim().is_empty() {
        eprintln!("Empty input. Run with a file or stdin.");
        std::process::exit(1);
    }

    // setup terminal
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let text = text_state::TextState::from_string(text);

    // create app and run it
    let tick_rate = Duration::from_millis(250);

    let dictionary = dictionary::Dictionary::new(&dictionary::dictionary_file_path());
    let app = app::App::new(text, dictionary);

    let res = app::run_app(&mut terminal, app, tick_rate);

    // restore terminal
    disable_raw_mode()?;
    execute!(
        terminal.backend_mut(),
        LeaveAlternateScreen,
        DisableMouseCapture
    )?;
    terminal.show_cursor()?;

    if let Err(err) = res {
        println!("{err:?}");
    }

    Ok(())
}
