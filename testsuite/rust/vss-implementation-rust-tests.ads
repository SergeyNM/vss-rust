package VSS.Implementation.Rust.Tests is

   procedure In_Str_Println (S : Slice_Str)
     --  FIXME: warning: cannot pass "S : Slice_Str" by copy (for limited)
     --  type Slice_Str is limited record
     --
     with Import, Convention => C,
       External_Name => "vss_rust_interop_tests_in_str_println";
   --  extern "C" fn vss_rust_interop_tests_in_str_println(s: SliceStr)

   function String_From_Rust return String_Handle
     with Import, Convention => C,
       External_Name => "vss_rust_interop_tests_string_from_rust";
   --  fn vss_rust_interop_tests_string_from_rust() -> *const StringHandle

   function In_Str_Ret_String (S : Slice_Str) return String_Handle
     with Import, Convention => C,
       External_Name => "vss_rust_interop_tests_in_str_ret_string";
   --  fn vss_rust_interop_tests_in_str_ret_string(s: SliceStr) ->
   --  * const StringHandle
end VSS.Implementation.Rust.Tests;
