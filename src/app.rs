use ::tts::Tts;
use crossterm::event::{self, Event, KeyCode};
use ratatui::prelude::*;
use std::{
    collections::{HashMap, HashSet},
    io,
    time::{Duration, Instant},
};

use crate::{
    dictionary::{normalize_word, Dictionary, KnowledgeLevel},
    note_state::NoteState,
    text_state::TextState,
    tts,
    ui::ui,
};

pub enum InputMode {
    Normal,
    Editing,
}

#[derive(Clone, Copy, PartialEq, Debug)]
pub enum Language {
    Ukrainian,
    Turkish,
}

impl Default for Language {
    fn default() -> Self {
        Self::Ukrainian
    }
}

impl Language {
    fn google_translate_code(&self) -> &'static str {
        match self {
            Language::Ukrainian => "uk",
            Language::Turkish => "tr",
        }
    }
}

pub struct App {
    pub scroll: u16,
    pub text: TextState,
    pub dictionary: Dictionary,
    pub note: NoteState,
    pub input_mode: InputMode,
    pub language: Language,
    statistics: Vec<(KnowledgeLevel, usize)>,
    pub page_height: u16,
    pub text_lines: usize,
    pub tts: Tts,
}

impl App {
    pub fn new(text: TextState, dictionary: Dictionary) -> Self {
        let mut app = Self {
            scroll: 0,
            text,
            dictionary,
            note: NoteState::default(),
            input_mode: InputMode::Normal,
            language: Language::default(),
            statistics: vec![],
            page_height: 1,
            text_lines: 1,
            tts: Tts::default().unwrap(),
        };

        app.text.rebuild_knowledge_levels(&app.dictionary);
        app.update_definition();
        app.update_statistics();
        app
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

    pub fn update_definition(&mut self) {
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

    pub fn update_statistics(&mut self) {
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

    pub fn statistics(&self) -> &Vec<(KnowledgeLevel, usize)> {
        &self.statistics
    }
}

pub fn run_app<B: Backend>(
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
                            "https://translate.google.com/details?sl={}&tl=en&text={}&op=translate",
                            app.language.google_translate_code(),
                            app.text.current_token().content
                        ))
                        .unwrap(),
                        KeyCode::Char('T') => open::that(format!(
                            "https://translate.google.com/details?sl={}&tl=en&text={}&op=translate",
                            app.language.google_translate_code(),
                            app.text.current_token_context()
                        ))
                        .unwrap(),
                        KeyCode::Char('y') => tts::speak(
                            &mut app.tts,
                            &app.text.current_token().content,
                            app.language,
                        ),
                        KeyCode::Char('Y') => tts::speak(
                            &mut app.tts,
                            &app.text.current_token_context(),
                            app.language,
                        ),
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
