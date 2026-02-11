with Ada.Text_IO;

with VSS.Strings;
with VSS.Text_Streams.Standards;

with VSS.Implementation.Rust.Tests;

procedure test_1 is
   Std_Out : VSS.Text_Streams.Output_Text_Stream'Class :=
               VSS.Text_Streams.Standards.Standard_Output;
   Success : Boolean := True;
begin
   --  In_Str_Println
   VSS.Implementation.Rust.Tests.In_Str_Println
     (VSS.Implementation.Rust.To_Slice_Str
        (VSS.Strings.To_Virtual_String ("https://httpbin.org")));

   VSS.Implementation.Rust.Tests.In_Str_Println
     (VSS.Implementation.Rust.To_Slice_Str
        (VSS.Strings.To_Virtual_String ("Hello World")));

   VSS.Implementation.Rust.Tests.In_Str_Println
     (VSS.Implementation.Rust.To_Slice_Str
        (VSS.Strings.To_Virtual_String ("Привет Мир")));

   declare
      Message : constant VSS.Strings.Virtual_String := VSS.Strings
        .To_Virtual_String ("Привіт Світ");
   begin
      VSS.Implementation.Rust.Tests.In_Str_Println
        (VSS.Implementation.Rust.To_Slice_Str (Message));
   end;

   declare
      Message : constant VSS.Strings.Virtual_String := VSS.Strings
        .To_Virtual_String ("Прывітанне Свет");
   begin
      VSS.Implementation.Rust.Tests.In_Str_Println
        (VSS.Implementation.Rust.To_Slice_Str (Message));
   end;

   Ada.Text_IO.New_Line;

   --  String_From_Rust
   declare
      Result   : VSS.Strings.Virtual_String;
      Expected : constant VSS.Strings.Virtual_String :=
        VSS.Strings.To_Virtual_String
          ("This is message from Rust. Это сообщение из Rust.");

   begin
      Result := VSS.Implementation.Rust.To_Virtual_String
        (VSS.Implementation.Rust.Tests.String_From_Rust);

      if Result.Starts_With (Expected) then
         Ada.Text_IO.Put ("Ada : Starts  : ");
         Std_Out.Put_Line (Expected, Success);
      end if;

      if Result.Ends_With (Expected) then
         Ada.Text_IO.Put ("Ada : Ends    : ");
         Std_Out.Put_Line (Expected, Success);
      end if;

      Ada.Text_IO.Put ("Ada : Output  : ");
      Std_Out.Put_Line (Result, Success);
      Ada.Text_IO.New_Line;
   end;

   --  In_Str_Ret_String
   declare
      Argument : constant VSS.Strings.Virtual_String := VSS.Strings
        .To_Virtual_String ("Grzegorz Brzęczyszczykiewicz");

      Result   : VSS.Strings.Virtual_String;
      Expected : constant VSS.Strings.Virtual_String := VSS.Strings
      .To_Virtual_String ("Cześć, Grzegorzu Brzęczyszczykiewiczu, wiem,"
                          & " że jesteś z wioski Chrząszczyżewoszyce.");

   begin
      Result := VSS.Implementation.Rust.To_Virtual_String
        (VSS.Implementation.Rust.Tests.In_Str_Ret_String
           (VSS.Implementation.Rust.To_Slice_Str (Argument)));

      if Result.Starts_With (Expected) then
         Ada.Text_IO.Put ("Ada : Starts  : ");
         Std_Out.Put_Line (Expected, Success);
      end if;

      if Result.Ends_With (Expected) then
         Ada.Text_IO.Put ("Ada : Ends    : ");
         Std_Out.Put_Line (Expected, Success);
      end if;

      Ada.Text_IO.Put ("Ada : Output  : ");
      Std_Out.Put_Line (Result, Success);
      Ada.Text_IO.New_Line;
   end;

end test_1;
