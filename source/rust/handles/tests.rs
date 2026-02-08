use super::{SliceStr, StringHandle};
use crate::handles::ffi as ffi_api;

/// Prints a SliceStr to stdout and shows its byte length.
/// Useful for verifying that a string from the host (Ada/C++/Python) is correctly seen by Rust.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_interop_tests_in_str_println(s: SliceStr) {
    let s_ref = unsafe { s.as_str() };
    println!("Rust: Received message: {}", s_ref);
    println!("Rust: Size in bytes of message is: {}", s_ref.len());
}

/// Creates an owned StringHandle in Rust and returns it to the host.
/// Host is responsible for calling rust_string_dec_ref().
#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_interop_tests_string_from_rust() -> *const StringHandle {
    let result = String::from("This is message from Rust. Это сообщение из Rust.");
    println!("Rust: Content of result is: {}", result);
    StringHandle::from_string(result)
}

/// Receives a SliceStr, prepends "Hello, " to it, and returns a new StringHandle.
/// Host is responsible for calling rust_string_dec_ref() on the returned pointer.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_interop_tests_in_str_ret_string(s: SliceStr) -> *const StringHandle {
    let s_ref = unsafe { s.as_str() };
    println!("Rust: Received message: {}", s_ref);
    
    let result = format!("Hello, {}", s_ref);
    println!("Rust: Content of result is: {}", result);
    StringHandle::from_string(result)
}

/// Helper for internal testing: Creates a fixed "Hello World" handle.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_interop_tests_create_handle() -> *const StringHandle {
    let s = String::from("Hello World");
    StringHandle::from_string(s)
}

/// Helper for internal testing: Wraps the production get_size API.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_interop_tests_get_size(ptr: *const StringHandle) -> usize {
    unsafe { ffi_api::rust_string_get_size(ptr) }
}

/// Helper for internal testing: Wraps the production dec_ref API.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_interop_tests_destroy_handle(ptr: *mut StringHandle) {
    unsafe { ffi_api::rust_string_dec_ref(ptr) }
}

/// Helper for internal testing: Checks if the input slice is not empty.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn vss_rust_interop_tests_slice_input(slice: SliceStr) -> bool {
    let s = unsafe { slice.as_str() };
    !s.is_empty()
}
