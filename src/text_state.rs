use std::collections::HashSet;

use crate::dictionary::{Dictionary, KnowledgeLevel};

use regex::Regex;

pub struct Token {
    pub content: String,
    pub selectable: bool,
    pub level: KnowledgeLevel,
}

fn split_keep<'a>(r: &Regex, text: &'a str) -> Vec<&'a str> {
    let mut result = Vec::new();
    let mut last = 0;
    for (index, matched) in text.match_indices(r) {
        if last != index {
            result.push(&text[last..index]);
        }
        result.push(matched);
        last = index + matched.len();
    }
    if last < text.len() {
        result.push(&text[last..]);
    }
    result
}

pub struct TextState {
    pub paragraphs: Vec<Vec<Token>>,
    pub selected_paragraph: usize,
    pub selected_token: usize,
}

impl TextState {
    pub fn from_string(content: String) -> Self {
        let seperator = Regex::new(r####"([ ,./\-–—!\?«»":;…""\(\)\[\]]+|[0-9]+|[\p{Emoji_Presentation}\p{Extended_Pictographic}\u{1F000}-\u{1FFFF}]+)"####)
            .expect("Invalid regex");
        let paragraphs = content
            .split('\n')
            .map(|line| {
                split_keep(&seperator, line)
                    .iter()
                    .map(|content| {
                        let content = String::from(*content);

                        Token {
                            selectable: !seperator.is_match(&content),
                            content,
                            level: KnowledgeLevel::Unknown,
                        }
                    })
                    .collect()
            })
            .collect();

        Self {
            paragraphs,
            selected_paragraph: 0,
            selected_token: 0,
        }
    }

    pub fn rebuild_knowledge_levels(&mut self, dictionary: &Dictionary) {
        for paragraph in self.paragraphs.iter_mut() {
            for token in paragraph.iter_mut() {
                let entry = dictionary.get(&token.content);

                token.level = if let Some(entry) = entry {
                    entry.level
                } else {
                    KnowledgeLevel::default()
                };
            }
        }
    }

    pub fn current_paragraph(&self) -> &Vec<Token> {
        &self.paragraphs[self.selected_paragraph]
    }

    pub fn current_token(&self) -> &Token {
        &self.paragraphs[self.selected_paragraph][self.selected_token]
    }

    // returns a sentence the current token is in
    pub fn current_token_context(&self) -> String {
        let paragraph = self.current_paragraph();
        let mut start = self.selected_token;
        while start > 0 && !paragraph[start - 1].content.contains('.') {
            start -= 1;
        }

        let mut end = self.selected_token;
        while end < paragraph.len() - 1 && !paragraph[end].content.contains('.') {
            end += 1;
        }
        if end < paragraph.len() {
            end += 1;
        }

        paragraph
            .get(start..end)
            .unwrap()
            .iter()
            .fold("".to_string(), |string, token| {
                format!("{}{}", string, token.content.to_owned())
            })
            .trim()
            .to_owned()
    }

    fn any_unknown_tokens(&self) -> bool {
        self.paragraphs.iter().any(|paragraph| {
            paragraph
                .iter()
                .any(|token| token.level != KnowledgeLevel::Known && token.selectable)
        })
    }

    pub fn select_next_token_by_level(&mut self, levels: HashSet<KnowledgeLevel>) {
        if !self.any_unknown_tokens() {
            return;
        }

        loop {
            self.select_next_token();

            if levels.contains(&self.current_token().level) {
                break;
            }
        }
    }

    pub fn select_previous_token_by_level(&mut self, levels: HashSet<KnowledgeLevel>) {
        if !self.any_unknown_tokens() {
            return;
        }

        loop {
            self.select_previous_token();

            if levels.contains(&self.current_token().level) {
                return;
            }
        }
    }

    pub fn select_next_token(&mut self) {
        loop {
            self.selected_token += 1;

            if self.selected_token >= self.current_paragraph().len() {
                self.selected_paragraph += 1;
                self.selected_token = 0;
            }

            if self.selected_paragraph + 1 >= self.paragraphs.len()
                && self.selected_token + 1 >= self.current_paragraph().len()
            {
                self.selected_token = 0;
                self.selected_paragraph = 0;
            }

            if self.current_paragraph().len() > self.selected_token
                && self.current_paragraph()[self.selected_token].selectable
            {
                break;
            }
        }
    }

    pub fn select_previous_token(&mut self) {
        loop {
            if self.selected_token == 0 {
                if self.selected_paragraph == 0 {
                    self.selected_paragraph = self.paragraphs.len();
                }

                self.selected_paragraph -= 1;
                self.selected_token = self.current_paragraph().len();
            } else {
                self.selected_token -= 1;
            }

            if self.current_paragraph().len() > self.selected_token
                && self.current_paragraph()[self.selected_token].selectable
            {
                break;
            }
        }
    }
}
