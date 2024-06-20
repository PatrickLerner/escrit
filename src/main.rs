mod app;
mod dictionary;
mod input;
mod note_state;
mod text_state;
mod tts;
mod ui;

use app_dirs2::AppInfo;
use crossterm::{
    event::{DisableMouseCapture, EnableMouseCapture},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::prelude::*;
use std::{env, error::Error, io, time::Duration};

const APP_INFO: AppInfo = AppInfo {
    name: "escrit",
    author: "ptlerner",
};

fn main() -> Result<(), Box<dyn Error>> {
    let args = env::args().collect::<Vec<_>>();
    let stdin = io::stdin();
    let text = input::read_input(&args, stdin);
    let text = text.unwrap_or_else(String::new);
    if text.is_empty() {
        eprintln!("Empty input. Run with a file or stdin.");
        std::process::exit(1);
    }

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
        eprintln!("{err:?}");
    }

    Ok(())
}
