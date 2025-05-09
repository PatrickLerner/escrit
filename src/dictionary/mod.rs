#[cfg(test)]
mod tests;

use std::{collections::HashMap, fs, path::Path};

use app_dirs2::*;
use serde::{Deserialize, Serialize};

use crate::{app::Language, APP_INFO};

#[derive(Clone, Copy, Serialize, Deserialize, PartialEq, Hash, Eq, Debug)]
pub enum KnowledgeLevel {
    Unknown,
    Encountered,
    Learning,
    Retained,
    Known,
}

impl Default for KnowledgeLevel {
    fn default() -> Self {
        Self::Unknown
    }
}

#[derive(Serialize, Deserialize, Default, Clone)]
pub struct DictionaryEntry {
    pub level: KnowledgeLevel,
    pub note: String,
}

impl DictionaryEntry {
    pub fn from_level(level: KnowledgeLevel) -> Self {
        Self {
            level,
            note: "".to_owned(),
        }
    }
}

pub struct Dictionary {
    file_name: String,
    entries: HashMap<String, DictionaryEntry>,
}

pub fn normalize_word(word: &str) -> String {
    word.to_lowercase().to_owned().replace('’', "'")
}

pub fn dictionary_file_path(language: Language) -> String {
    let base_path = app_root(AppDataType::UserData, &APP_INFO).expect("create app file path");

    let filename = match language {
        Language::Ukrainian => "dictionary_uk.yml",
        Language::Turkish => "dictionary_tr.yml",
    };

    base_path.join(filename).to_str().unwrap().to_owned()
}

impl Dictionary {
    pub fn new(file_name: &str) -> Self {
        let mut entries = HashMap::new();

        if Path::new(&file_name).exists() {
            let data = fs::read_to_string(file_name).unwrap();
            entries = serde_yaml::from_str(&data).unwrap();
        }

        Self {
            entries,
            file_name: file_name.to_owned(),
        }
    }

    pub fn get(&self, word: &str) -> Option<&DictionaryEntry> {
        self.entries.get(&normalize_word(word))
    }

    pub fn save(&self) {
        let dictionary = serde_yaml::to_string(&self.entries).unwrap();
        fs::write(&self.file_name, dictionary).unwrap();
    }

    pub fn set_level(&mut self, word: &str, level: KnowledgeLevel) {
        self.entries
            .entry(normalize_word(word))
            .and_modify(|e| e.level = level)
            .or_insert(DictionaryEntry::from_level(level));
    }

    pub fn set_note(&mut self, word: &str, note: &str) {
        self.entries
            .entry(normalize_word(word))
            .and_modify(|e| note.clone_into(&mut e.note))
            .or_insert(DictionaryEntry {
                note: note.to_owned(),
                ..Default::default()
            });
    }
}
