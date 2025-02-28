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
use crate::app::Language;

pub fn speak(tts: &mut Tts, text: &str, language: Language) {
    let _ = tts.stop();

    if let Ok(voices) = tts.voices() {
        let language_code = match language {
            Language::Ukrainian => "uk-UA",
            Language::Turkish => "tr-TR",
        };

        let mut voices = voices
            .iter()
            .filter(|voice| voice.language() == language_code)
            .collect::<Vec<&Voice>>();

        voices.sort_by_key(|v| !v.id().contains("enhanced"));
        let voice = voices.first();

        if let Some(voice) = voice {
            let _ = tts.set_voice(voice);
        }
    }

    let _ = tts.set_rate(0.5);
    let _ = tts.set_pitch(1.0);

    if tts.speak(text, false).is_ok() {
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

            if !tts.is_speaking().unwrap_or(false) {
                break;
            }
        }
    }
}
