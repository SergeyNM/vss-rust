--  Storage manager to wrap Rust's StringHandle bytes object.

with VSS.Implementation.Rust;

package VSS.Implementation.Text_Storages.Rust is

   ----------------------------------------------------------------------------
   --  @summary VSS Text Storage backed by a Rust String.
   --
   --  Rust_Text_Storage is a concrete implementation of Abstract_Text_Storage.
   --  It wraps a String_Handle to provide a zero-copy bridge between Ada's
   --  Virtual_String and Rust-managed memory.
   --
   --  @description
   --  This type manages shared ownership of the Rust string. It assumes
   --  that the provided String_Handle already has an active reference.
   --
   --  Memory Management Logic:
   --  - @b Initialize: Associates the Rust String_Handle with the storage
   --    instance and provides the memory address to the VSS core.
   --  - @b Reference: Increments the internal Rust reference counter
   --    via `String_Inc_Ref` when a new Virtual_String starts using this
   --    storage.
   --  - @b Unreference: Decrements the Rust reference counter via
   --    `String_Dec_Ref`. When the last Virtual_String is destroyed, the
   --    Rust memory is automatically deallocated.
   ----------------------------------------------------------------------------
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
