with Ada.Unchecked_Conversion;
with System.Address_To_Access_Conversions;

with VSS.Implementation.Interfaces_C;
with VSS.Implementation.Text_Storages.Heap;
with VSS.Implementation.UTF8_Encoding;

package body VSS.Implementation.Text_Storages.Rust is

   function Get_Bytes
     (Self : Rust_Text_Storage'Class)
      return VSS.Implementation.Rust.String_Handle;

   procedure Set_Bytes
     (Self  : in out Rust_Text_Storage'Class;
      Bytes : VSS.Implementation.Rust.String_Handle);

   --------------
   -- Capacity --
   --------------

   overriding function Capacity
     (Self : in out Rust_Text_Storage)
      return VSS.Unicode.UTF8_Code_Unit_Count is
   begin
      return 0;  --  FIXME: ? Rust String have capacity.
   end Capacity;

   ---------------
   -- Get_Bytes --
   ---------------

   function Get_Bytes
     (Self : Rust_Text_Storage'Class)
     return VSS.Implementation.Rust.String_Handle
   is
      package Conversions is
        new System.Address_To_Access_Conversions
          (VSS.Implementation.Rust.String_Handle_Opaque);

   begin
      return
        VSS.Implementation
          .Rust.String_Handle (Conversions.To_Pointer (Self.Pointer));
   end Get_Bytes;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Self            : in out Rust_Text_Storage'Class;
      Storage_Address : out System.Address;
      Bytes           : VSS.Implementation.Rust.String_Handle)
   is
      function To_Address is
        new Ada.Unchecked_Conversion
          (VSS.Implementation.Interfaces_C.UTF8_Code_Unit_Constant_Access,
           System.Address);

   begin
      Self.Set_Bytes (Bytes);
      Storage_Address :=
        To_Address (VSS.Implementation.Rust.String_Get_Data (Bytes));
   end Initialize;

   ------------
   -- Mutate --
   ------------

   overriding procedure Mutate
     (Self            : in out Rust_Text_Storage;
      Storage_Address : in out System.Address;
      Size            : VSS.Unicode.UTF8_Code_Unit_Count;
      Capacity        : VSS.Unicode.UTF8_Code_Unit_Count)
   is
      use type VSS.Unicode.UTF8_Code_Unit_Offset;

      Bytes : constant VSS.Implementation.Rust.String_Handle := Self.Get_Bytes;

      Bytes_Size : constant VSS.Unicode.UTF8_Code_Unit_Count :=
        VSS.Unicode.UTF8_Code_Unit_Count
          (VSS.Implementation.Rust.String_Get_Size (Bytes));

      Storage : constant VSS.Implementation.UTF8_Encoding.UTF8_Code_Unit_Array
        (0 .. Bytes_Size - 1)
        with Import, Address => Storage_Address;

      Manager : VSS.Implementation.Text_Storages.Heap.Heap_Storage :=
        (others => <>)
        with Address => Self'Address;

   begin
      pragma Assert (Bytes_Size = Size);

      Manager.Initialize
        (Storage_Address,
         Storage,
         Bytes_Size);
      VSS.Implementation.Rust.String_Dec_Ref (Bytes);
   end Mutate;

   ---------------
   -- Reference --
   ---------------

   overriding procedure Reference (Self : in out Rust_Text_Storage) is
      use type VSS.Implementation.Rust.String_Handle;

      Bytes : constant VSS.Implementation.Rust.String_Handle := Self.Get_Bytes;

   begin
      if Bytes /= null then
         VSS.Implementation.Rust.String_Inc_Ref (Bytes);
      end if;
   end Reference;

   ---------------
   -- Set_Bytes --
   ---------------

   procedure Set_Bytes
     (Self  : in out Rust_Text_Storage'Class;
      Bytes : VSS.Implementation.Rust.String_Handle)
   is
      package Conversions is
        new System.Address_To_Access_Conversions
          (VSS.Implementation.Rust.String_Handle_Opaque);

   begin
      Self.Pointer :=
        Conversions.To_Address (Conversions.Object_Pointer (Bytes));
   end Set_Bytes;

   -----------------
   -- Unreference --
   -----------------

   overriding procedure Unreference (Self : in out Rust_Text_Storage) is
      use type VSS.Implementation.Rust.String_Handle;

      Bytes : constant VSS.Implementation.Rust.String_Handle := Self.Get_Bytes;

   begin
      if Bytes /= null then
         Self.Pointer := System.Null_Address;
         VSS.Implementation.Rust.String_Dec_Ref (Bytes);
      end if;
   end Unreference;

end VSS.Implementation.Text_Storages.Rust;
