use super::{SliceStr, StringHandle};

#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_interop_tests_in_str_println(s: SliceStr) {
    println!("Rust: Received message: {}", s.as_str());
    println!("Rust: Size in bytes of message is: {}", s.as_str().len());
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_interop_tests_string_from_rust() -> *const StringHandle {
    let result: String = "This is message from Rust. Это сообщение из Rust.".to_string();
    println!("Rust: Content of result is: {}", result);
    return StringHandle::from_string(result);
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_interop_tests_in_str_ret_string(s: SliceStr) -> *const StringHandle {
    println!("Rust: Received message: {}", s.as_str());
    println!("Rust: Size in bytes of message is: {}", s.as_str().len());

    let result: String = "Hello, ".to_string() + s.as_str();
    println!("Rust: Content of result is: {}", result);
    return StringHandle::from_string(result);
}