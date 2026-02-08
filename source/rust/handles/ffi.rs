/*
 * FFI ARCHITECTURE & TERMINOLOGY GUIDE
 * ------------------------------------
 * This file provides a C-compatible interface for Rust's StringHandle.
 *
 * For C++/Python developers:
 * 
 * 1. StringHandle (Opaque Pointer)
 *    - Rust: Arc<String> (Atomic Reference Counted).
 *    - C++ Analog: std::shared_ptr<const std::string>.
 *    - Python Analog: A native object with its own reference counter.
 *
 * 2. Thread Safety (Concurrency)
 *    - The 'A' in Arc stands for ATOMIC. Unlike a standard C++ shared_ptr,
 *      Arc's reference counter is updated using atomic operations (lock-free).
 *    - Thread Safety: It is safe to clone (inc_ref) and drop (dec_ref) 
 *      the same StringHandle from multiple threads simultaneously.
 *    - Data Constancy: The underlying string is IMMUTABLE. You can read it 
 *      from any number of threads, but you cannot modify it.
 *
 * 3. ptr.cast::<String>()
 *    - C-style cast: (const String*)ptr.
 *    - Tells Rust: "Treat this void* as a pointer to an immutable String".
 *
 * 4. rust_string_inc_ref / dec_ref
 *    - Analogous to Py_INCREF / Py_DECREF in Python C-API.
 *    - Memory is automatically freed when the atomic counter reaches zero.
 *
 * 5. SliceStr
 *    - A "view" into a string. Does not own memory.
 *    - C++ Analog: std::string_view.
 *    - Memory is managed by the caller; Rust only "borrows" it.
 */

use std::sync::Arc;
use crate::handles::StringHandle;

/// Returns a raw pointer to the underlying UTF-8 encoded byte buffer.
/// The pointer points to the first byte of the string and is guaranteed 
/// to be valid as long as the StringHandle's reference count is > 0.
/// Note: The buffer is NOT null-terminated.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn rust_string_get_data(ptr: *const StringHandle) -> *const u8 {
    if ptr.is_null() { return std::ptr::null(); }

    unsafe { (&*ptr.cast::<String>()).as_ptr() }
}

/// Returns the number of bytes in the string.
/// Note: This is the byte count, not the character count. 
/// Since Rust strings are UTF-8, a single character may take 1 to 4 bytes.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn rust_string_get_size(ptr: *const StringHandle) -> usize {
    if ptr.is_null() { return 0; }

    unsafe { (&*ptr.cast::<String>()).len() }
}

/// Analogous to Py_INCREF in Python C-API.
/// Increments the atomic reference counter of the StringHandle.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn rust_string_inc_ref(ptr: *const StringHandle) {
    if ptr.is_null() { return; }

    // Restore the Arc from the raw pointer to access the reference counter.
    let arc = unsafe { Arc::from_raw(ptr.cast::<String>()) };

    // Increment the reference count by cloning and then "forgetting" the clone.
    // This ensures the extra reference remains valid for the FFI consumer.
    std::mem::forget(Arc::clone(&arc));

    // "Forget" the original Arc we restored from_raw to prevent it 
    // from being dropped (decremented) when this function scope ends.
    std::mem::forget(arc);
}

/// Analogous to Py_DECREF in Python C-API.
/// Decrements the atomic reference counter. If the counter reaches zero, 
/// the underlying memory is deallocated.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn rust_string_dec_ref(ptr: *mut StringHandle) {
    if ptr.is_null() { return; }

    // Restore the Arc from the raw pointer to access the reference counter.
    // Dropping this Arc will automatically decrement the atomic counter.
    let _ = unsafe { Arc::from_raw(ptr.cast::<String>()) };
}
