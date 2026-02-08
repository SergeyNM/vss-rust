//! # VSS Rust Interop Utilities
//! 
//! This library provides a bridge for exchanging UTF-8 encoded strings between Rust 
//! and other languages (specifically Ada and C++, Python).
//!
//! ## Core Concepts for Interop
//!
//! * **Ownership**: In C terms, we distinguish between "owned" strings (Rust manages 
//!   the memory) and "borrowed" strings (Rust just looks at memory managed by others).
//!
//! * **Memory Layout**: Rust strings are **not** null-terminated. They consist of a 
//!   pointer and an explicit length.
//!
//! * **VSS (Ada)**: Compatible with Ada VSS `Virtual_String` as both follow UTF-8 
//!   encoding and explicit length contracts.

pub mod handles {
    use std::sync::Arc;
    use std::ops::Deref;
    use std::fmt;

    pub mod ffi;
    pub mod tests;

    /// # StringHandle (Owned Shared String)
    /// 
    /// **C++ Analog**: `std::shared_ptr<const std::string>`
    /// **Python Analog**: A reference-counted string object.
    ///
    /// This handle provides shared ownership of a Rust `String`. The data is 
    /// immutable and resides in the heap. The memory is managed by an Atomic 
    /// Reference Counter (Arc), making it thread-safe.
    #[repr(transparent)]
    pub struct StringHandle(Arc<String>);

    impl StringHandle {
        /// Wraps a Rust `String` into a heap-allocated `Arc` and returns a raw pointer.
        /// **Note**: The caller (FFI side) must eventually call `rust_string_dec_ref` 
        /// to avoid memory leaks.
        pub fn from_string(s: String) -> *const Self {
            let sh = Self(Arc::new(s));
            // Return raw pointer to the internal String; Arc ensures it stays alive.
            Arc::into_raw(sh.0).cast::<Self>()
        }

        /// Copies data from a foreign `SliceStr` to create a new owned `StringHandle`.
        /// This is a "deep copy" operation.
        pub fn from_slice(slice: SliceStr) -> *const Self {
            let s = unsafe { slice.as_str() }.to_string();
            Self::from_string(s)
        }
    }

    impl Deref for StringHandle {
        type Target = String;
        #[inline]
        fn deref(&self) -> &Self::Target {
            &self.0
        }
    }

    impl fmt::Debug for StringHandle {
        fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
            write!(f, "StringHandle({:?}, refs={})", 
                self.0.as_str(), 
                Arc::strong_count(&self.0)
            )
        }
    }

    impl fmt::Display for StringHandle {
        fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
            write!(f, "{}", self.0.as_str())
        }
    }

    /// # SliceStr (Borrowed String View)
    /// 
    /// **C++ Analog**: `std::string_view` or `struct { const char* data; size_t len; }`
    ///
    /// A lightweight structure used to pass existing string data into Rust 
    /// without copying. It does **not** own the memory and must not outlive 
    /// the source buffer on the FFI side.
    #[repr(C)]
    #[derive(Copy, Clone)]
    pub struct SliceStr {
        data: *const u8,
        size: usize,
    }

    impl SliceStr {
        /// Creates a new view from a native Rust string slice.
        #[inline]
        pub fn new(s: &str) -> Self {
            Self {
                data: s.as_ptr(),
                size: s.len(),
            }
        }

        /// Returns a Rust string slice (`&str`).
        /// # Safety
        /// The caller must ensure the pointer is valid and the data is UTF-8.
        pub unsafe fn as_str<'a>(&self) -> &'a str {
            if self.data.is_null() || self.size == 0 {
                return "";
            }
            unsafe {
                let bytes = std::slice::from_raw_parts(self.data, self.size);
                std::str::from_utf8_unchecked(bytes)
            }
        }
    }

    impl fmt::Debug for SliceStr {
        fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
            write!(f, "SliceStr({:?})", unsafe { self.as_str() })
        }
    }

    impl fmt::Display for SliceStr {
        fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
            write!(f, "{}", unsafe { self.as_str() })
        }
    }
}

#[cfg(test)]
mod tests {
    use super::handles::{SliceStr, StringHandle};
    use super::handles::ffi as ffi_api;
    use super::handles::tests as ffi_tests;

    #[test]
    fn test_length_consistency() {
        unsafe {
            let ptr: *const StringHandle = ffi_tests::vss_rust_interop_tests_string_from_rust();
            let len = ffi_api::rust_string_get_size(ptr);
            // "This is message from Rust. Это сообщение из Rust." 
            // 25 chars ASCII + 8 space + 2 dot + 14 chars Cyrillic (14*2) = 35 + 28 = 63 bytes            
            let expected_msg = "This is message from Rust. Это сообщение из Rust.";
            assert_eq!(len, expected_msg.len()); 
            // assert_eq!(len, 63); // Both assertions will now pass
            
            ffi_api::rust_string_dec_ref(ptr.cast_mut());
        }
    }

    #[test]
    fn test_slice_to_str() {
        let original = "Rust interop test";
        let slice = SliceStr::new(original);
        unsafe {
            assert_eq!(original, slice.as_str());
            ffi_tests::vss_rust_interop_tests_in_str_println(slice);
        }
    }

    #[test]
    fn test_handle_ref_counting() {
        unsafe {
            let name = "FFI Проверка";
            let ptr = ffi_tests::vss_rust_interop_tests_in_str_ret_string(SliceStr::new(name));
            
            // Manual Ref Count Test
            ffi_api::rust_string_inc_ref(ptr); // Count = 2
            assert_eq!(ffi_api::rust_string_get_size(ptr), 27); // "Hello, FFI Проверка"
            
            ffi_api::rust_string_dec_ref(ptr.cast_mut()); // Count = 1
            ffi_api::rust_string_dec_ref(ptr.cast_mut()); // Count = 0 (Free)
        }
    }
}
