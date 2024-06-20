use super::*;
use std::{fs::remove_file, io::Write, os::fd::RawFd};

struct MockStdin {
    raw_fd: RawFd,
}

impl Default for MockStdin {
    fn default() -> Self {
        Self { raw_fd: 0 }
    }
}

impl AsRawFd for MockStdin {
    fn as_raw_fd(&self) -> RawFd {
        self.raw_fd
    }
}

impl Read for MockStdin {
    fn read(&mut self, _buf: &mut [u8]) -> std::io::Result<usize> {
        Ok(0)
    }
}

#[test]
fn no_input() {
    let stdin = MockStdin::default();

    let input = read_input(&vec![], stdin);
    assert!(input.is_none());

    let _ = remove_file(tty_device());
}

#[test]
fn read_file() {
    let stdin = MockStdin::default();
    let args = vec!["escit".to_owned(), file!().to_owned()];
    let input = read_input(&args, stdin);

    assert!(input.is_some());
    let text = input.unwrap();
    assert!(text.contains("use super::*;"));
}

#[test]
fn read_tty() {
    let stdin = MockStdin {
        raw_fd: RawFd::min_value(),
    };

    let temp_file = std::env::temp_dir().join("escrit_tty");
    let tty_device = temp_file.to_string_lossy().to_string();

    // create a fake tty
    {
        let mut f = File::create(&tty_device).unwrap();
        let _ = f.write(b"Hello World");
        let _ = f.sync_all();
    }

    // we map the file pointer to 0 (stdin) so the app reads from a file instead
    // of course it's complete BS to test like this. I just did it for fun because
    // I wanted to get 100% code coverage on the file
    unsafe {
        use std::os::unix::io::*;

        let f = File::open(&tty_device).unwrap();
        libc::dup2(f.as_raw_fd(), 0);
    };

    let input = read_input(&vec![], stdin);

    assert!(input.is_some());
    let text = input.unwrap();
    assert!(text.starts_with("Hello World"));

    let _ = remove_file(tty_device);
}
