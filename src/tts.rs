#[cfg(target_os = "macos")]
use cocoa_foundation::base::id;
#[cfg(target_os = "macos")]
use cocoa_foundation::foundation::NSDefaultRunLoopMode;
#[cfg(target_os = "macos")]
use cocoa_foundation::foundation::NSRunLoop;
#[cfg(target_os = "macos")]
use objc::class;
#[cfg(target_os = "macos")]
use objc::{msg_send, sel, sel_impl};
use std::{thread, time};
use tts::*;

pub fn speak(tts: &mut Tts, text: &str) {
    let voices = tts.voices().unwrap();
    let voice = voices.iter().find(|voice| voice.name() == "Lesya").unwrap();
    tts.set_voice(&voice).unwrap();

    tts.speak(text, false).unwrap();

    loop {
        #[cfg(target_os = "macos")]
        {
            let run_loop: id = unsafe { NSRunLoop::currentRunLoop() };
            unsafe {
                let date: id = msg_send![class!(NSDate), distantFuture];
                let _: () = msg_send![run_loop, runMode:NSDefaultRunLoopMode beforeDate:date];
            }
        }
        let time = time::Duration::from_millis(100);
        thread::sleep(time);
        if !tts.is_speaking().unwrap() {
            break;
        }
    }
}
