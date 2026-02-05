with Interfaces.C;

with VSS.Strings;
with VSS.Implementation.Interfaces_C;

package VSS.Implementation.Rust is

   -------------
   -- Objects --
   -------------

   type String_Handle_Opaque is limited private;
   --  Representing the Rust `struct StringHandle`

   type String_Handle is access all String_Handle_Opaque with Convention => C;
   --  Equivalent to `* StringHandle` in Rust FFI

   type Slice_Str is private;
   --  type Slice_Str is limited private;
   --  Note: warning: cannot pass "S : Slice_Str" by copy (for limited)

   -----------------
   -- Subprograms --
   -----------------

   procedure String_Inc_Ref (Ptr : String_Handle)
   with Import, Convention => C, External_Name => "rust_string_inc_ref";
   --  fn rust_string_inc_ref(ptr: *const StringHandle)

   procedure String_Dec_Ref (Ptr : String_Handle)
   with Import, Convention => C, External_Name => "rust_string_dec_ref";
   --  fn rust_string_dec_ref(ptr: *mut StringHandle)

   function String_Get_Data
     (Ptr : String_Handle)
      return VSS.Implementation.Interfaces_C.UTF8_Code_Unit_Constant_Access
   with Import, Convention => C, External_Name => "rust_string_get_data";
   --  fn rust_string_get_data(ptr: *const StringHandle) -> *const u8

   function String_Get_Size (Ptr : String_Handle) return Interfaces.C.size_t
   with Import, Convention => C, External_Name => "rust_string_get_size";
   --  fn rust_string_get_size(ptr: *const StringHandle) -> usize

   -----------------------
   -- To_Virtual_String --
   -----------------------

   function To_Virtual_String
     (Item : String_Handle) return VSS.Strings.Virtual_String;

   --  function To_String_Handle
   --    (Item : VSS.Strings.Virtual_String) return String_Handle;

   ------------------
   -- To_Slice_Str --
   ------------------

   function To_Slice_Str
     (Item : VSS.Strings.Virtual_String) return Slice_Str;

private

   type String_Handle_Opaque is null record with Convention => C;

   type Slice_Str is record
   --  type Slice_Str is limited record
   --  Note: warning: cannot pass "S : Slice_Str" by copy (for limited record)
      Data : VSS.Implementation.Interfaces_C.UTF8_Code_Unit_Constant_Access;
      --  Note: ^ Empty_Virtual_String - `null pointer`. Check it in receiver!
      Size : Interfaces.C.size_t;
   end record with Convention => C_Pass_By_Copy;

end VSS.Implementation.Rust;
