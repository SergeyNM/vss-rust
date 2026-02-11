with VSS.Implementation.Strings;
with VSS.Implementation.Text_Storages.Rust;
with VSS.Implementation.UTF8_Strings;
with VSS.Strings.Internals;
with VSS.Unicode;

package body VSS.Implementation.Rust is

   --  function To_String_Handle
   --    (Item : VSS.Strings.Virtual_String) return String_Handle;

   procedure Initialize
     (Text   : in out VSS.Implementation.UTF8_Strings.UTF8_String_Data;
      Object : VSS.Implementation.Rust.String_Handle);

   procedure Initialize
     (Text   : in out VSS.Implementation.UTF8_Strings.UTF8_String_Data;
      Object : VSS.Implementation.Rust.String_Handle)
   is
      use type VSS.Implementation.Interfaces_C.UTF8_Code_Unit_Constant_Access;

      Data : VSS.Implementation.Interfaces_C.UTF8_Code_Unit_Constant_Access;
   begin
      --  Note : Rust represents owned strings with the Strings type, and
      --  borrowed slices of strings with the str primitive.
      --  Both are always in UTF-8 encoding, and may contain nul bytes in the
      --  middle, i.e., if you look at the bytes that make up the string,
      --  there may be a \0 among them.

      Data := VSS.Implementation.Rust.String_Get_Data (Object);

      if Data = null then
         Text := (others => <>);
         return;
      end if;

      declare
         Manager :
           VSS.Implementation.Text_Storages.Rust.Rust_Text_Storage :=
             (others => <>)
           with Address => Text.Manager'Address;
      begin
         Manager.Initialize (Text.Storage_Address, Object);
         Text.Size   :=
           VSS.Unicode.UTF8_Code_Unit_Offset
             (VSS.Implementation.Rust.String_Get_Size (Object));
         Text.Length :=
           VSS.Implementation.Strings.Character_Count
             (VSS.Implementation.Rust.String_Get_Length (Object));
         Text.Flags  := 1;
      end;
   end Initialize;

   -----------------------
   -- To_Virtual_String --
   -----------------------

   function To_Virtual_String
     (Item : String_Handle) return VSS.Strings.Virtual_String
   is
   begin
      return Result : VSS.Strings.Virtual_String do
         Initialize
           (VSS.Strings.Internals.Data_Access_Variable (Result).all, Item);
      end return;
   end To_Virtual_String;

   ------------------
   -- To_Slice_Str --
   ------------------

   function To_Slice_Str
     (Item : VSS.Strings.Virtual_String) return Slice_Str
   is
      Text : VSS.Implementation.UTF8_Strings.UTF8_String_Data
        renames VSS.Strings.Internals.Data_Access_Constant (Item).all;

   begin
      if VSS.Implementation.UTF8_Strings.Is_Empty (Text) then
         return Slice_Str'(Data => null, Size => 0);
      else
         declare
            D : VSS.Implementation.Interfaces_C.UTF8_Code_Unit_Constant_Access
              with Import, Address => Text.Storage_Address'Address;
         begin
            return Slice_Str'
              (Data => D, Size => Interfaces.C.size_t (Text.Size));
         end;
      end if;
   end To_Slice_Str;

end VSS.Implementation.Rust;
