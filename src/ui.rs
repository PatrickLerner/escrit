use ratatui::{
    prelude::*,
    widgets::{Block, Paragraph, Wrap},
};

use crate::{
    app::{App, InputMode},
    dictionary::KnowledgeLevel,
};

fn color_by_language_level(span: Span, level: KnowledgeLevel) -> Span {
    match level {
        KnowledgeLevel::Unknown => span.on_red(),
        KnowledgeLevel::Encountered => span.red(),
        KnowledgeLevel::Learning => span.yellow(),
        KnowledgeLevel::Retained => span.blue(),
        KnowledgeLevel::Known => span,
    }
}

pub fn ui(f: &mut Frame, app: &mut App) {
    let size = f.area();

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
            f.set_cursor_position((
                definition_layout.x + app.note.character_index as u16 + 1,
                definition_layout.y + 1,
            ));
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
