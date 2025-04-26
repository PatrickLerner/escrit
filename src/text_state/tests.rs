#[cfg(test)]
mod tests {
    use crate::text_state::TextState;

    #[test]
    fn test_tokenization_with_emoji() {
        // Test with emoji characters in different contexts
        let input = "Hello 😊 world! This is a test 🚀 with emoji. Try emoji👋in words too!";
        let text_state = TextState::from_string(input.to_string());

        let first_paragraph = &text_state.paragraphs[0];

        // Verify that emojis are treated as separators and not as words
        let selectable_tokens: Vec<String> = first_paragraph
            .iter()
            .filter(|token| token.selectable)
            .map(|token| token.content.clone())
            .collect();

        // Expected selectable tokens - emojis should not be in this list
        let expected_tokens = vec![
            "Hello".to_string(),
            "world".to_string(),
            "This".to_string(),
            "is".to_string(),
            "a".to_string(),
            "test".to_string(),
            "with".to_string(),
            "emoji".to_string(),
            "Try".to_string(),
            "emoji".to_string(),
            "in".to_string(),
            "words".to_string(),
            "too".to_string(),
        ];

        assert_eq!(
            selectable_tokens, expected_tokens,
            "Emoji characters should not be selectable tokens"
        );

        // Verify that emojis are tokenized separately
        let non_selectable_tokens: Vec<String> = first_paragraph
            .iter()
            .filter(|token| !token.selectable)
            .map(|token| token.content.clone())
            .collect();

        // The non-selectable tokens should include spaces, punctuation, and emojis
        assert!(
            non_selectable_tokens.contains(&"😊".to_string()),
            "Emoji 😊 should be tokenized separately"
        );
        assert!(
            non_selectable_tokens.contains(&"🚀".to_string()),
            "Emoji 🚀 should be tokenized separately"
        );
        assert!(
            non_selectable_tokens.contains(&"👋".to_string()),
            "Emoji 👋 should be tokenized separately"
        );
    }

    #[test]
    fn test_emoji_in_middle_of_word() {
        // This tests emoji handling when they appear in the middle of words
        let input = "word👻word should split at emoji";
        let text_state = TextState::from_string(input.to_string());

        let first_paragraph = &text_state.paragraphs[0];

        // Expected selectable tokens - the word should be split by the emoji
        let selectable_tokens: Vec<String> = first_paragraph
            .iter()
            .filter(|token| token.selectable)
            .map(|token| token.content.clone())
            .collect();

        assert_eq!(
            selectable_tokens,
            vec![
                "word".to_string(),
                "word".to_string(),
                "should".to_string(),
                "split".to_string(),
                "at".to_string(),
                "emoji".to_string()
            ],
            "Words with emoji in the middle should be split"
        );

        // Verify the emoji is separate
        let non_selectable_tokens: Vec<String> = first_paragraph
            .iter()
            .filter(|token| !token.selectable)
            .map(|token| token.content.clone())
            .collect();

        assert!(
            non_selectable_tokens.contains(&"👻".to_string()),
            "Emoji 👻 should be tokenized separately"
        );
    }
}
