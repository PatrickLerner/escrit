#[cfg(test)]
mod tests;

use clap::Parser;
#[cfg(not(test))]
use crossterm::tty::IsTty;
use std::{
    fs::{read_to_string, File},
    io::Read,
    os::fd::AsRawFd,
};

use crate::app::Language;

#[derive(Parser)]
#[command(version, about, long_about = None)]
pub struct Cli {
    file_name: Option<String>,
    #[arg(short, long, default_value = "ukrainian")]
    language: String,
}

impl Cli {
    pub fn get_language(&self) -> Language {
        match self.language.to_lowercase().as_str() {
            "turkish" | "tr" => Language::Turkish,
            _ => Language::Ukrainian,
        }
    }
}

#[allow(unreachable_code)]
fn tty_device() -> &'static str {
    #[cfg(test)]
    return concat!(env!("CARGO_MANIFEST_DIR"), "/", file!());

    #[cfg(all(target_os = "linux", not(test)))]
    return "/dev/tty";

    #[cfg(all(target_os = "macos", not(test)))]
    return "/dev/ttys010";
}

pub fn read_input<R>(args: &[String], stdin: R) -> (Option<String>, Language)
where
    R: Read + Sized + AsRawFd,
{
    let cli = Cli::parse_from(args);
    let language = cli.get_language();
    let text = if let Some(file_name) = cli.file_name {
        Some(read_to_string(file_name).expect("File to be readable"))
    } else {
        #[cfg(test)]
        let is_tty = stdin.as_raw_fd() == 0;
        #[cfg(not(test))]
        let is_tty = stdin.is_tty();

        let input = if !is_tty {
            // Swap stdin and TTY
            // https://github.com/tcr/rager/blob/master/src/main.rs
            // https://stackoverflow.com/a/29694013
            unsafe {
                use std::os::unix::io::*;

                let tty = File::open(tty_device()).expect("to open tty");
                let stdin_fd = libc::dup(0);
                let ret = std::fs::File::from_raw_fd(stdin_fd);
                libc::dup2(tty.as_raw_fd(), 0);
                ::std::mem::forget(tty);

                Some(ret)
            }
        } else {
            None
        };

        input.map(|mut input| {
            let mut text = String::new();
            let _ = input.read_to_string(&mut text);
            text
        })
    };
    (text, language)
}
