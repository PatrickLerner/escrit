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
};
use ratatui::prelude::*;
use std::{error::Error, fs, io, time::Duration};

const APP_INFO: AppInfo = AppInfo {
    name: "escrit",
    author: "ptlerner",
};

#[derive(Parser)]
#[command(version, about, long_about = None)]
struct Cli {
    file_name: String,
}

fn main() -> Result<(), Box<dyn Error>> {
    let cli = Cli::parse();
    let text = fs::read_to_string(cli.file_name).expect("File to be readable");

    // setup terminal
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let text = text_state::TextState::from_string(text);

    // create app and run it
    let tick_rate = Duration::from_millis(250);

    let dictionary = dictionary::Dictionary::new();
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
