# escrit

Read texts similar to the Birkenbihl method or applications like lingq.
Read the text and add words to a dictionary file (if you want with
a description).

The idea is to learn vocabulary in a foreign language by going through
input in the form of texts quickly. I use it for Ukrainian language
acquisition. No support for multiple languages is given, it assumes
currently the user using it for only one language.

![](https://raw.githubusercontent.com/PatrickLerner/escrit/main/assets/screenshot.png)

## Run

`cargo run -- %file` to open a file in reading mode.

## Keys / Usages

See source code for `KeyCode`, but roughly:

- Arrow keys / `awsd` / `hjkl` for navigation in texts. Up and down
  scrolls, while left and right moves the word cursor
- Home/`g` for jumping to beginning of text
- End/`G` for jumping to end of text
- PageUp/PageDown for faster navigation in scroll position
- `,` and `.` jump to next word that is not rated as "Known". `<` and `>`
  jump to next word that is specifically `Unknown`
- `1` mark word as Unknown (default for new words)
- `2` mark word as Encountered (seen it, but don't know it very well)
- `3` mark word as Learning (encountered it a few times, roughly know it)
- `4` mark word as Retained (seen it often, think I know it well)
- `5` mark word as Known (I don't even think about it)
- `t` open google translate for a word
- `e` add a note/definition to a word. When editing press `enter` to save,
  and `escape` to abort

## Dictionary file page

Depends on the operating sysem, see
[`app_dirs2`](https://docs.rs/app_dirs2/latest/app_dirs2/) crate. It will
be in the `escrit` directory.
