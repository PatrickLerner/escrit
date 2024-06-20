use super::*;

#[test]
fn handle_key_input() {
    let mut note = NoteState::default();

    note.handle_key_input(KeyCode::Char('S'));
    note.handle_key_input(KeyCode::Char('u'));
    note.handle_key_input(KeyCode::Char('n'));
    note.handle_key_input(KeyCode::Char('t'));
    assert_eq!(note.content, "Sunt");

    note.handle_key_input(KeyCode::Backspace);
    assert_eq!(note.content, "Sun");

    note.handle_key_input(KeyCode::Left);
    note.handle_key_input(KeyCode::Backspace);
    note.handle_key_input(KeyCode::Char('o'));
    assert_eq!(note.content, "Son");

    note.handle_key_input(KeyCode::Right);
    note.handle_key_input(KeyCode::Char('n'));
    note.handle_key_input(KeyCode::Char('e'));
    assert_eq!(note.content, "Sonne");

    // does nothing
    note.handle_key_input(KeyCode::Tab);
    assert_eq!(note.content, "Sonne");
}

#[test]
fn update_content() {
    let mut note = NoteState::default();
    assert_eq!(note.content, "");
    note.update_content("hello");

    assert_eq!(note.content, "hello");
}

#[test]
fn reset_cursor() {
    let mut note = NoteState::default();
    note.content = "Hello".to_owned();
    assert_eq!(note.character_index, 0);
    note.reset_cursor();
    assert_eq!(note.character_index, 5);
}
