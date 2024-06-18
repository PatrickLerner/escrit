mod dictionary;
mod note_state;
mod text_state;

use app_dirs2::AppInfo;
use crossterm::{
    event::{self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{
    prelude::*,
    widgets::{Block, Paragraph, Wrap},
};
use std::{
    collections::{HashMap, HashSet},
    env,
    error::Error,
    fs, io,
    time::{Duration, Instant},
};

use dictionary::{normalize_word, Dictionary};
use note_state::NoteState;
use text_state::{KnowledgeLevel, TextState};

const APP_INFO: AppInfo = AppInfo {
    name: "escrit",
    author: "ptlerner",
};

enum InputMode {
    Normal,
    Editing,
}

struct App {
    scroll: u16,
    pub text: TextState,
    dictionary: Dictionary,
    note: NoteState,
    input_mode: InputMode,
    statistics: Vec<(KnowledgeLevel, usize)>,
    page_height: u16,
    text_lines: usize,
}

fn color_by_language_level(span: Span, level: KnowledgeLevel) -> Span {
    match level {
        KnowledgeLevel::Unknown => span.on_red(),
        KnowledgeLevel::Encountered => span.red(),
        KnowledgeLevel::Learning => span.yellow(),
        KnowledgeLevel::Retained => span.blue(),
        KnowledgeLevel::Known => span,
    }
}

impl App {
    fn new(text: TextState, dictionary: Dictionary) -> Self {
        Self {
            scroll: 0,
            text,
            dictionary,
            note: NoteState::default(),
            input_mode: InputMode::Normal,
            statistics: vec![],
            page_height: 1,
            text_lines: 1,
        }
    }

    fn max_scroll_position(&self) -> u16 {
        (self.text_lines as i32 - self.page_height as i32).max(0) as u16
    }

    fn submit_message(&mut self) {
        self.input_mode = InputMode::Normal;

        let token = self.text.current_token();
        self.dictionary.set_note(&token.content, &self.note.content);

        self.text.rebuild_knowledge_levels(&self.dictionary);
        self.dictionary.save();
    }

    fn update_definition(&mut self) {
        let token = self.text.current_token();
        let entry = self.dictionary.get(&token.content);

        self.note.update_content(if let Some(entry) = entry {
            &entry.note
        } else {
            ""
        })
    }

    fn set_level(&mut self, word: &str, level: KnowledgeLevel) {
        self.dictionary.set_level(word, level);
        self.text.rebuild_knowledge_levels(&self.dictionary);
        self.update_statistics();
        self.dictionary.save();
    }

    fn update_statistics(&mut self) {
        let mut words: HashMap<KnowledgeLevel, HashSet<String>> = HashMap::new();

        for paragraph in self.text.paragraphs.iter() {
            for token in paragraph.iter() {
                if token.selectable {
                    words
                        .entry(token.level)
                        .and_modify(|e| {
                            e.insert(normalize_word(&token.content));
                        })
                        .or_insert(HashSet::from([normalize_word(&token.content)]));
                }
            }
        }

        self.statistics = vec![
            KnowledgeLevel::Unknown,
            KnowledgeLevel::Encountered,
            KnowledgeLevel::Learning,
            KnowledgeLevel::Retained,
            KnowledgeLevel::Known,
        ]
        .into_iter()
        .map(|level| {
            (
                level,
                words.get(&level).unwrap_or(&HashSet::<String>::new()).len(),
            )
        })
        .collect();
    }

    fn statistics(&self) -> &Vec<(KnowledgeLevel, usize)> {
        &self.statistics
    }
}

fn run_app<B: Backend>(
    terminal: &mut Terminal<B>,
    mut app: App,
    tick_rate: Duration,
) -> io::Result<()> {
    let mut last_tick = Instant::now();
    loop {
        terminal.draw(|f| ui(f, &mut app))?;

        let timeout = tick_rate.saturating_sub(last_tick.elapsed());
        if crossterm::event::poll(timeout)? {
            if let Event::Key(key) = event::read()? {
                match app.input_mode {
                    InputMode::Normal => match key.code {
                        KeyCode::Char('q') => return Ok(()),
                        KeyCode::Char('g') | KeyCode::Home => {
                            app.scroll = 0;
                        }
                        KeyCode::Char('G') | KeyCode::End => {
                            app.scroll = app.max_scroll_position();
                        }
                        KeyCode::Up | KeyCode::Char('w') | KeyCode::Char('k') => {
                            if app.scroll > 0 {
                                app.scroll -= 1
                            }
                        }
                        KeyCode::PageUp => {
                            app.scroll -= app.page_height.min(app.scroll);
                        }
                        KeyCode::PageDown => {
                            app.scroll += app.page_height;
                            if app.scroll > app.max_scroll_position() {
                                app.scroll = app.max_scroll_position();
                            }
                        }
                        KeyCode::Down | KeyCode::Char('s') | KeyCode::Char('j') => {
                            app.scroll += 1;
                            if app.scroll > app.max_scroll_position() {
                                app.scroll = app.max_scroll_position();
                            }
                        }
                        KeyCode::Right | KeyCode::Char('d') | KeyCode::Char('l') => {
                            app.text.select_next_token();
                            app.update_definition();
                        }
                        KeyCode::Left | KeyCode::Char('a') | KeyCode::Char('h') => {
                            app.text.select_previous_token();
                            app.update_definition();
                        }
                        KeyCode::Char('e') => {
                            app.input_mode = InputMode::Editing;
                            app.note.reset_cursor();
                        }
                        KeyCode::Char('<') => {
                            app.text.select_previous_token_by_level(HashSet::from([
                                KnowledgeLevel::Unknown,
                            ]));
                            app.update_definition();
                        }
                        KeyCode::Char('>') => {
                            app.text.select_next_token_by_level(HashSet::from([
                                KnowledgeLevel::Unknown,
                            ]));
                            app.update_definition();
                        }
                        KeyCode::Char(',') => {
                            app.text.select_previous_token_by_level(HashSet::from([
                                KnowledgeLevel::Unknown,
                                KnowledgeLevel::Encountered,
                                KnowledgeLevel::Learning,
                                KnowledgeLevel::Retained,
                            ]));
                            app.update_definition();
                        }
                        KeyCode::Char('.') => {
                            app.text.select_next_token_by_level(HashSet::from([
                                KnowledgeLevel::Unknown,
                                KnowledgeLevel::Encountered,
                                KnowledgeLevel::Learning,
                                KnowledgeLevel::Retained,
                            ]));
                            app.update_definition();
                        }
                        KeyCode::Char('t') => open::that(format!(
                            "https://translate.google.com/details?sl=uk&tl=en&text={}&op=translate",
                            app.text.current_token().content
                        ))
                        .unwrap(),
                        KeyCode::Char('T') => open::that(format!(
                            "https://translate.google.com/details?sl=uk&tl=en&text={}&op=translate",
                            app.text.current_token_context()
                        ))
                        .unwrap(),
                        KeyCode::Char('1') => {
                            let token = app.text.current_token().content.to_owned();
                            app.set_level(&token, KnowledgeLevel::Unknown);
                        }
                        KeyCode::Char('2') => {
                            let token = app.text.current_token().content.to_owned();
                            app.set_level(&token, KnowledgeLevel::Encountered);
                        }
                        KeyCode::Char('3') => {
                            let token = app.text.current_token().content.to_owned();
                            app.set_level(&token, KnowledgeLevel::Learning);
                        }
                        KeyCode::Char('4') => {
                            let token = app.text.current_token().content.to_owned();
                            app.set_level(&token, KnowledgeLevel::Retained);
                        }
                        KeyCode::Char('5') => {
                            let token = app.text.current_token().content.to_owned();
                            app.set_level(&token, KnowledgeLevel::Known);
                        }
                        _ => {}
                    },
                    InputMode::Editing => match key.code {
                        KeyCode::Enter => app.submit_message(),
                        KeyCode::Esc => {
                            app.input_mode = InputMode::Normal;
                            app.update_definition();
                        }
                        key => app.note.handle_key_input(key),
                    },
                }
            }
        }
        if last_tick.elapsed() >= tick_rate {
            last_tick = Instant::now();
        }
    }
}

fn ui(f: &mut Frame, app: &mut App) {
    let size = f.size();

    let sidebar_size = 50;
    let text_width = 80;

    let block = Block::new().black();
    f.render_widget(block, size);

    let base_layout = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Fill(0), Constraint::Max(sidebar_size)])
        .split(size);
    let text_layout = base_layout[0];
    let right_layout = base_layout[1];

    let width = (text_layout.width - 2).min(text_width);
    let offset_x = ((text_layout.width - 2) - width) / 2;
    let text_inner = Rect::new(
        text_layout.x + 1 + offset_x,
        text_layout.y + 1,
        width,
        text_layout.height - 2,
    );

    app.page_height = text_inner.height;

    let right_layout = Layout::vertical([Constraint::Ratio(2, 1); 2]).split(right_layout);
    let definition_layout = right_layout[0];
    let statistic_layout = right_layout[1];

    let text: Vec<Line> = app
        .text
        .paragraphs
        .iter()
        .enumerate()
        .map(|(line_id, paragraph)| {
            Line::from(
                paragraph
                    .iter()
                    .enumerate()
                    .map(|(token_id, token)| {
                        let span = Span::from(&token.content);
                        if !token.selectable {
                            return span;
                        }

                        let span = color_by_language_level(span, token.level);

                        if line_id == app.text.selected_paragraph
                            && token_id == app.text.selected_token
                        {
                            span.bold()
                        } else {
                            span
                        }
                    })
                    .collect::<Vec<Span>>(),
            )
        })
        .collect();

    let create_block = |title| {
        Block::bordered()
            .style(Style::default().fg(Color::Gray))
            .title(Span::styled(
                title,
                Style::default().add_modifier(Modifier::BOLD),
            ))
    };

    let text_container = Paragraph::new("")
        .style(Style::default().fg(Color::Gray))
        .block(create_block("Text"))
        .wrap(Wrap { trim: true })
        .scroll((app.scroll, 0));
    f.render_widget(text_container, text_layout);

    let paragraph = Paragraph::new(text.clone())
        .style(Style::default().fg(Color::Gray))
        .wrap(Wrap { trim: true })
        .scroll((app.scroll, 0));
    app.text_lines = paragraph.line_count(text_inner.width);
    f.render_widget(paragraph, text_inner);

    let paragraph = Paragraph::new(Text::from(Span::from(&app.note.content)))
        .style(match app.input_mode {
            InputMode::Normal => Style::default().fg(Color::Gray),
            InputMode::Editing => Style::default().fg(Color::Yellow),
        })
        .block(create_block("Definition"))
        .wrap(Wrap { trim: true });
    f.render_widget(paragraph, definition_layout);

    match app.input_mode {
        InputMode::Normal => {}

        InputMode::Editing => {
            #[allow(clippy::cast_possible_truncation)]
            f.set_cursor(
                definition_layout.x + app.note.character_index as u16 + 1,
                definition_layout.y + 1,
            );
        }
    }

    let total = app.statistics().iter().fold(0, |a, (_, c)| a + c);
    let statistics: Vec<Line> = app
        .statistics()
        .iter()
        .filter_map(|(level, count)| {
            if *count == 0 {
                return None;
            }

            let content = vec![
                color_by_language_level(Span::from(format!("{:?}", level)), *level),
                Span::from(format!(" – {}", count)),
                Span::from(format!(" ({:.1} %)", *count as f32 / total as f32 * 100.0)),
            ];

            Some(Line::from(content))
        })
        .collect();

    let paragraph = Paragraph::new(statistics)
        .style(Style::default().fg(Color::Gray))
        .block(create_block("Statistics"))
        .wrap(Wrap { trim: true });
    f.render_widget(paragraph, statistic_layout);
}

fn main() -> Result<(), Box<dyn Error>> {
    let args: Vec<String> = env::args().collect();
    assert!(args.len() == 2);
    let file_name = &args[1];
    let text = fs::read_to_string(&file_name).expect("File to be readable");

    // setup terminal
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let text = TextState::from_string(&text);

    // create app and run it
    let tick_rate = Duration::from_millis(250);

    let dictionary = Dictionary::new();
    let mut app = App::new(text, dictionary);
    // TODO: move logic here
    app.text.rebuild_knowledge_levels(&app.dictionary);
    app.update_definition();
    app.update_statistics();

    let res = run_app(&mut terminal, app, tick_rate);

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
