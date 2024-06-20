use super::*;

fn temp_file() -> String {
    let temp_file = std::env::temp_dir().join("escrit_dictionary.yml");
    temp_file.to_string_lossy().to_string()
}

fn cleanup() {
    let _ = std::fs::remove_file(&temp_file());
}

#[test]
fn get_set_load_and_save() {
    cleanup();
    {
        let mut dictionary = Dictionary::new(&temp_file());
        // file does not exist, so no entries exist
        assert_eq!(dictionary.entries.len(), 0);
        assert!(dictionary.get("rust").is_none());

        // adding word via level
        dictionary.set_level("rust", KnowledgeLevel::Learning);

        let word = dictionary.get("rust");
        assert!(word.is_some());
        let word = word.unwrap();
        assert!(word.note.is_empty());
        assert_eq!(word.level, KnowledgeLevel::Learning);

        // adding word via note
        dictionary.set_note("python", "programming language");

        let word = dictionary.get("python");
        assert!(word.is_some());
        let word = word.unwrap();
        assert_eq!(word.note, "programming language");
        assert_eq!(word.level, KnowledgeLevel::Unknown);

        // normalize case
        dictionary.set_note("RUBY", "programming language");

        let word = dictionary.get("Ruby");
        assert!(word.is_some());

        // it does not create a file yet
        assert!(!Path::new(&temp_file()).exists());

        // creates file when saving
        dictionary.save();
    }
    assert!(Path::new(&temp_file()).exists());

    // can load file again
    let dictionary = Dictionary::new(&temp_file());
    assert_eq!(dictionary.entries.len(), 3);

    cleanup();
}

#[test]
fn updating_words() {
    let mut dictionary = Dictionary::new(&temp_file());
    // file does not exist, so no entries exist
    assert_eq!(dictionary.entries.len(), 0);

    dictionary.set_note("rust", "old note");
    dictionary.set_level("rust", KnowledgeLevel::Learning);

    dictionary.set_note("rust", "new note");
    dictionary.set_level("rust", KnowledgeLevel::Known);

    let word = dictionary.get("rust");
    assert!(word.is_some());
    let word = word.unwrap();
    assert_eq!(word.level, KnowledgeLevel::Known);
    assert_eq!(word.note, "new note");
}

#[test]
fn test_dictionary_file_path() {
    let path = dictionary_file_path();
    assert!(path.ends_with("dictionary.yml"));
}
