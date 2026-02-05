use std::sync::Arc;
use super::StringHandle;

// FIXME: ? it is recommended to manage reference counting using
// Arc::increment_strong_count and Arc::decrement_strong_count
// directly, rather than involving Box in the FFI layer.

/// As Py_INCREF() in Python C-API
// FIXME: into Rust side?
#[unsafe(no_mangle)]
pub unsafe extern "C" fn rust_string_inc_ref(ptr: *const StringHandle) {
    let container: &StringHandle = unsafe { &*ptr };
    // Увеличиваем счетчик ссылок Arc
    std::mem::forget(Arc::clone(&container.0));
    // FIXME: ^ ?
}

/// As Py_DECREF() in Python C-API
#[unsafe(no_mangle)]
pub unsafe extern "C" fn rust_string_dec_ref(ptr: *mut StringHandle) {
    if !ptr.is_null() {
        // Уменьшаем счетчик Arc, если 0 — память очистится
        unsafe { drop(Box::from_raw(ptr)) };
        // FIXME: ^ !!!
    }
}

/// `pub fn as_ptr(&self) -> *const u8` - method from Deref<Target = str>
/// Converts a string slice to a raw pointer.
/// As string slices are a slice of bytes, the raw pointer points to a u8.
/// This pointer will be pointing to the first byte of the string slice.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn rust_string_get_data(ptr: *const StringHandle) -> *const u8 {
    if ptr.is_null() { return std::ptr::null(); }

    // (*ptr).0 дает Arc<String>, который разыменовывается в String, а затем в str
    unsafe { (*ptr).0.as_ptr() }
}

/// `pub fn len(&self) -> usize` - method from Deref<Target = str>
/// Returns the length (size) of String (under StringHandle), in bytes.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn rust_string_get_size(ptr: *const StringHandle) -> usize {
    unsafe { (*ptr).0.as_ref().len() }
}
