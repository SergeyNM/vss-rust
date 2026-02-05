--  Storage manager to wrap Rust's StringHandle bytes object.

with VSS.Implementation.Rust;

package VSS.Implementation.Text_Storages.Rust is

   type Rust_Text_Storage is
     new Abstract_Text_Storage with null record;

   procedure Initialize
     (Self            : in out Rust_Text_Storage'Class;
      Storage_Address : out System.Address;
      Bytes           : VSS.Implementation.Rust.String_Handle);

   overriding function Capacity
     (Self : in out Rust_Text_Storage)
      return VSS.Unicode.UTF8_Code_Unit_Count;

   overriding procedure Reference (Self : in out Rust_Text_Storage);

   overriding procedure Unreference (Self : in out Rust_Text_Storage);

   overriding procedure Mutate
     (Self            : in out Rust_Text_Storage;
      Storage_Address : in out System.Address;
      Size            : VSS.Unicode.UTF8_Code_Unit_Count;
      Capacity        : VSS.Unicode.UTF8_Code_Unit_Count);

end VSS.Implementation.Text_Storages.Rust;
