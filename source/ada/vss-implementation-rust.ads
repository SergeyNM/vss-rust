-------------------------------------------------------------------------------
--  Memory Safety Guidelines for Slice_Str
-------------------------------------------------------------------------------
--
--  Slice_Str is a NON-OWNING VIEW (equivalent to std::string_view in C++
--  or &str in Rust). It contains a raw pointer to a memory buffer owned
--  by another object (e.g., VSS.Strings.Virtual_String).
--
--  DANGER: Because Slice_Str does not increment reference counters, it
--  becomes "dangling" as soon as the source object is modified or destroyed.
--
-------------------------------------------------------------------------------
--
--  1. RULE: AVOID TEMPORARY ASSIGNMENT
--  The source object must outlive the Slice_Str.
--
--  INCORRECT:
--  ```
--  declare
--     Slice : Slice_Str;
--  begin
--     --  The temporary Virtual_String created by To_Virtual_String is
--     --  destroyed immediately after the assignment.
--     Slice := To_Slice_Str (To_Virtual_String ("https://httpbin.org"));
--
--     --  CRASH: Slice.Data now points to deallocated memory!
--     In_Str_Println (Slice);
--  end;
--  ```
--
--  CORRECT:
--  ```
--  declare
--     --  Named object ensures the string lives until the end of the block.
--     Message : constant Virtual_String := To_Virtual_String ("...");
--  begin
--     In_Str_Println (To_Slice_Str (Message)); -- Safe
--  end;
--  ```
--
--  2. RULE: NO PERSISTENCE
--  Never store a Slice_Str in a structure that lasts longer than the scope.
--
--  INCORRECT:
--  type Global_State is record
--     Last_URL : Slice_Str; -- Extremely dangerous!
--  end record;
--
--  procedure Store_URL (S : Virtual_String) is
--  begin
--     --  S is a local parameter (passed by value or short-lived reference).
--     My_Global.Last_URL := To_Slice_Str (S);
--     --  As soon as Store_URL returns, Last_URL is a "time bomb".
--  end Store_URL;
--  ```
--
--  3. RULE: NESTED CALLS ARE SAFE
--  Passing a temporary directly to a function is safe because the
--  temporary lives until the function returns.
--
--  CORRECT:
--  ```
--  In_Str_Println (To_Slice_Str (To_Virtual_String ("Safe Call")));
--  ```

with Interfaces.C;

with VSS.Strings;
with VSS.Implementation.Interfaces_C;

package VSS.Implementation.Rust is

   -------------
   -- Objects --
   -------------

   type String_Handle_Opaque is limited private;
   --  Representing the Rust `struct StringHandle`

   ----------------------------------------------------------------------------
   --  @summary Reference-Counted Handle to a Rust String
   --
   --  Equivalent to `*mut StringHandle` in Rust FFI.
   --
   --  String_Handle represents an object with SHARED OWNERSHIP managed by
   --  Rust's reference counting mechanism.
   --
   --  @important To ensure memory safety, every time this handle is copied
   --  in Ada for long-term storage, `String_Inc_Ref` must be called. When
   --  the handle is no longer needed, `String_Dec_Ref` MUST be called to
   --  decrement the counter and potentially trigger destruction.
   --
   --  @note Convention => C ensures ABI compatibility with Rust's
   --  `extern "C"` functions.
   ----------------------------------------------------------------------------
   type String_Handle is access all String_Handle_Opaque with Convention => C;
   --  Equivalent to `* StringHandle` in Rust FFI

   ----------------------------------------------------------------------------
   --  @summary Memory Safety Guidelines for Slice_Str
   --
   --  Slice_Str is a NON-OWNING VIEW (equivalent to `std::string_view` in C++
   --  or `&str` in Rust). It contains a raw pointer to a memory buffer owned
   --  by another object (e.g., VSS.Strings.Virtual_String).
   --
   --  @warning DANGER: Because Slice_Str does not increment reference
   --  counters, it becomes "dangling" as soon as the source object is
   --  modified or destroyed.
   ----------------------------------------------------------------------------
   type Slice_Str is private;
   --  type Slice_Str is limited private;
   --  Note: warning: cannot pass "S : Slice_Str" by copy (for limited type)

   -----------------
   -- Subprograms --
   -----------------

   procedure String_Inc_Ref (Ptr : String_Handle)
     with Import, Convention => C, External_Name => "rust_string_inc_ref";
   --  @description Increments the Rust reference count.
   --  Must be called within the `Reference` method of Rust_Text_Storage.
   --
   --  fn rust_string_inc_ref(ptr: *const StringHandle)

   procedure String_Dec_Ref (Ptr : String_Handle)
     with Import, Convention => C, External_Name => "rust_string_dec_ref";
   --  @description Decrements the Rust reference count.
   --  Must be called within the `Unreference` method of Rust_Text_Storage.
   --
   --  fn rust_string_dec_ref(ptr: *mut StringHandle)

   function String_Get_Data
     (Ptr : String_Handle)
      return VSS.Implementation.Interfaces_C.UTF8_Code_Unit_Constant_Access
     with Import, Convention => C, External_Name => "rust_string_get_data";
   --
   --  TODO: Improve Docs
   --  @description Provides direct buffer access for Rust_Text_Storage.
   --  Used by VSS to implement zero-copy string views.
   --
   --  @summary Returns a raw pointer to the underlying UTF-8 buffer.
   --
   --  @return A constant access to the Rust-managed memory buffer.
   --
   --  @warning This pointer is valid ONLY as long as the `String_Handle`
   --  remains alive and its reference count is greater than zero.
   --  Do not store this pointer; use it immediately or copy the data.
   --
   --  fn rust_string_get_data(ptr: *const StringHandle) -> *const u8

   function String_Get_Size (Ptr : String_Handle) return Interfaces.C.size_t
     with Import, Convention => C, External_Name => "rust_string_get_size";
   --
   --  TODO: Improve Docs
   --  @summary Returns the size of the string in bytes (UTF-8 code units).
   --
   --  @return The exact length of the buffer, excluding any null terminators
   --  (standard Rust `str` behavior).
   --
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
      Data : VSS.Implementation.Interfaces_C.UTF8_Code_Unit_Constant_Access;
      --  Note: ^ Empty_Virtual_String - `null pointer`. Check it in receiver!
      Size : Interfaces.C.size_t;
   end record with Convention => C_Pass_By_Copy;

end VSS.Implementation.Rust;
