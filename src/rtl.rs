
/// Check if a character is Persian/Arabic
pub fn is_persian_char(c: char) -> bool {
    matches!(c as u32, 0x0600..=0x06FF | 0x0750..=0x077F | 0xFB50..=0xFDFF | 0xFE70..=0xFEFF)
}

/// Check if a character is a number
#[allow(dead_code)]
fn is_number_char(c: char) -> bool {
    c.is_ascii_digit() || matches!(c as u32, 0x06F0..=0x06F9) // Include Persian-Arabic digits
}

/// Reverse the characters in a Persian word for terminal display
pub fn reverse_persian_word(word: &str) -> String {
    if word.chars().any(is_persian_char) && !word.chars().all(is_number_char) {
        // Only reverse if it contains Persian and is not purely numbers
        word.chars().rev().collect()
    } else {
        word.to_string()
    }
}

/// Process RTL text for terminal display
#[allow(dead_code)]
pub fn process_rtl_text(text: &str) -> String {
    // Handle empty text
    if text.is_empty() {
        return String::new();
    }

    // Split on spaces, which preserves empty strings between consecutive spaces
    let words: Vec<&str> = text.split(' ').collect();

    // Process each word and reverse the order
    let processed_words: Vec<String> = words
        .iter()
        .map(|word| {
            if word.is_empty() {
                // Empty string from consecutive spaces
                String::new()
            } else if word.chars().any(is_persian_char) {
                // Reverse Persian words character by character
                reverse_persian_word(word)
            } else {
                // Keep non-Persian text as-is (English, numbers, etc.)
                word.to_string()
            }
        })
        .collect();

    // Reverse the order of words for RTL display
    let mut reversed_words = processed_words;
    reversed_words.reverse();

    // Join with spaces (this preserves multiple spaces)
    reversed_words.join(" ")
}

/// Process a line of text for RTL display
#[allow(dead_code)]
pub fn process_rtl_line(line: &str) -> String {
    process_rtl_text(line)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_is_persian_char() {
        // Persian characters
        assert!(is_persian_char('س'));
        assert!(is_persian_char('ل'));
        assert!(is_persian_char('ا'));
        assert!(is_persian_char('م'));
        assert!(is_persian_char('پ'));
        assert!(is_persian_char('چ'));
        assert!(is_persian_char('ژ'));
        assert!(is_persian_char('گ'));

        // Arabic characters used in Persian
        assert!(is_persian_char('ع'));
        assert!(is_persian_char('غ'));
        assert!(is_persian_char('ض'));
        assert!(is_persian_char('ث'));

        // Non-Persian characters
        assert!(!is_persian_char('a'));
        assert!(!is_persian_char('Z'));
        assert!(!is_persian_char('1'));
        assert!(!is_persian_char('!'));
        assert!(!is_persian_char(' '));
    }

    #[test]
    fn test_is_number_char() {
        // ASCII digits
        assert!(is_number_char('0'));
        assert!(is_number_char('5'));
        assert!(is_number_char('9'));

        // Persian-Arabic digits
        assert!(is_number_char('۰'));
        assert!(is_number_char('۵'));
        assert!(is_number_char('۹'));

        // Non-numbers
        assert!(!is_number_char('a'));
        assert!(!is_number_char('س'));
    }

    #[test]
    fn test_reverse_persian_word() {
        // Persian words should be reversed
        assert_eq!(reverse_persian_word("سلام"), "مالس");
        assert_eq!(reverse_persian_word("خوب"), "بوخ");
        assert_eq!(reverse_persian_word("دنیا"), "ایند");

        // English words should stay the same
        assert_eq!(reverse_persian_word("hello"), "hello");
        assert_eq!(reverse_persian_word("world"), "world");

        // Numbers should stay the same
        assert_eq!(reverse_persian_word("123"), "123");
        assert_eq!(reverse_persian_word("۱۲۳"), "۱۲۳"); // Persian numbers

        // Mixed content
        assert_eq!(reverse_persian_word("test123"), "test123"); // No Persian chars
    }

    #[test]
    fn test_process_rtl_text_simple() {
        // Simple Persian text - words reversed, then order reversed
        assert_eq!(process_rtl_text("سلام دنیا"), "ایند مالس");

        // Single word
        assert_eq!(process_rtl_text("سلام"), "مالس");

        // Three words
        assert_eq!(process_rtl_text("من خوب هستم"), "متسه بوخ نم");
    }

    #[test]
    fn test_process_rtl_text_mixed() {
        // Mixed Persian and English
        let mixed = "این یک test است";
        let processed = process_rtl_text(mixed);
        // Words should be reversed in order, Persian words reversed internally
        assert!(processed.contains("تسا"));
        assert!(processed.contains("test"));
        assert!(processed.contains("کی"));
        assert!(processed.contains("نیا"));
    }

    #[test]
    fn test_punctuation_handling() {
        // Persian text with ASCII punctuation attached
        assert_eq!(process_rtl_text("سلام."), ".مالس");
        assert_eq!(process_rtl_text("سلام!"), "!مالس");
        assert_eq!(process_rtl_text("سلام?"), "?مالس");

        // Persian punctuation
        assert_eq!(process_rtl_text("سلام؟"), "؟مالس");
        assert_eq!(process_rtl_text("سلام،"), "،مالس");
        assert_eq!(process_rtl_text("سلام؛"), "؛مالس");

        // Multiple words with punctuation
        assert_eq!(process_rtl_text("سلام، دنیا!"), "!ایند ،مالس");
    }

    #[test]
    fn test_complex_sentences() {
        // Sentence with multiple words and punctuation
        let sentence = "این یک جمله است.";
        let processed = process_rtl_text(sentence);

        // Words should be reversed and reordered
        assert_eq!(processed, ".تسا هلمج کی نیا");

        // Question
        let question = "آیا شما خوب هستید؟";
        let processed_q = process_rtl_text(question);

        assert_eq!(processed_q, "؟دیتسه بوخ امش ایآ");
    }

    #[test]
    fn test_numbers_in_text() {
        // Persian text with ASCII numbers
        assert_eq!(process_rtl_text("من 25 سال دارم"), "مراد لاس 25 نم");

        // Persian text with Persian numbers
        assert_eq!(process_rtl_text("من ۲۵ سال دارم"), "مراد لاس ۲۵ نم");
    }

    #[test]
    fn test_empty_and_whitespace() {
        // Empty string
        assert_eq!(process_rtl_text(""), "");

        // Only whitespace - spaces are preserved
        assert_eq!(process_rtl_text("   "), "   ");

        // Persian with extra spaces - multiple spaces are preserved
        let text_with_spaces = "سلام  دنیا";
        let processed = process_rtl_text(text_with_spaces);
        // Multiple spaces are preserved in the output
        assert_eq!(processed, "ایند  مالس");
    }
}