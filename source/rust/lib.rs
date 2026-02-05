//! Utilities related to Foreign Function Interface (FFI) bindings.
//!
//! This module provides utilities to handle data across non-Rust interfaces.
//! It is mainly of use for FFI bindings and code that needs to exchange UTF-8 encoded strings with other languages.
//!
//! Overview.
//! Rust represents owned strings with the Strings type, and borrowed slices of strings with the str primitive.
//! Both are always in UTF-8 encoding, and may contain nul bytes in the middle, i.e., if you look at the bytes that
//! make up the string, there may be a \0 among them.
//! Both String and str store their length explicitly; there are no nul terminators at the end of strings like in C.
//!
//! Ada VSS Virtual_String are different from Rust strings. But also Virtual_String is UTF-8 encoded and have length.

pub mod handles {
    use std::sync::Arc;

    pub mod ffi;
    pub mod tests;

    // Opaque handle for owned string with the Strings type.
    pub struct StringHandle(Arc<String>);

    impl StringHandle {
        pub fn from_string(s: String) -> *const StringHandle {
            // String уже в куче, просто кладем его в Arc и Box
            Box::into_raw(Box::new(StringHandle(Arc::new(s))))
        }            
    }

    // Handle for borrowed slice of string (the str primitive).
    #[repr(C)]
    pub struct SliceStr {
        data: *const u8,
        size: usize,
    }

    impl SliceStr {
        pub fn new(s: &str) -> Self {
            Self { data: s.as_ptr(), size: s.len() }
        }
        // Получение &str из SliceStr
        pub fn as_str(&self) -> &str {
            if self.size > 0 {
                // TODO: ^ Improve check `null pointer` and length = 0
                let bytes: &[u8] = unsafe { std::slice::from_raw_parts(self.data, self.size) };
                return unsafe { std::str::from_utf8_unchecked(bytes) };
            } else {
                return "";
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::handles::{SliceStr, StringHandle};
    use super::*;

    #[test]
    fn length() {
        let ptr: *const StringHandle = unsafe { handles::tests::vss_rust_interop_tests_string_from_rust() };

        // let data:*const u8 = unsafe { rust_handles::ffi::rust_string_get_data(ptr) };
        // println!("{}", (*data).as_ref.);

        let len: usize = unsafe { handles::ffi::rust_string_get_size(ptr) };
        println!("{}", len);

        assert_eq!(len, 63);
    }

    #[test]
    fn slice_str() {
        let param: &str = "Param as string slice";
        let param_empty: &str = "";
        let ss: SliceStr = SliceStr::new(param);
        let ss_empty: SliceStr = SliceStr::new(param_empty);
        println!("{}", ss.as_str());

        let s: SliceStr = SliceStr::new(param);
        unsafe { handles::tests::vss_rust_interop_tests_in_str_println (s)};

        assert_eq!(param, ss.as_str());
        assert_eq!(true, ss_empty.as_str().is_empty());
    }

    #[test]
    fn in_str_ret_string() {
        let name: &str = "Grzegorz Brzęczyszczykiewicz.";
        let ptr: *const StringHandle = unsafe {
            handles::tests::vss_rust_interop_tests_in_str_ret_string(SliceStr::new(name)) };

        // FIXME: Increment only from FFI side?
        unsafe { handles::ffi::rust_string_inc_ref(ptr) };

        let len: usize = unsafe { handles::ffi::rust_string_get_size(ptr) };
        println!("{}", len);
        
        assert_eq!(len, 37);

        // FIXME: Decrement only from FFI side?
        unsafe { handles::ffi::rust_string_dec_ref(ptr.cast_mut()) };
    }
}
