with Ada.Text_IO;
with Ada.Wide_Wide_Text_IO;

with VSS.Strings;
with VSS.Text_Streams.Standards;

with VSS.Implementation.Rust.Tests;

procedure test_1 is
begin
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

   --  FIXME: Strange behavior
   --  Strange_1 : declare
   --     Sl : constant VSS.Implementation.Rust.Slice_Str := VSS.Implementation
   --       .Rust.To_Slice_Str
   --         (VSS.Strings.To_Virtual_String ("https://httpbin.org"));
   --         --  (VSS.Strings.To_Virtual_String ("Привет Мир"));
   --     --  FIXME: Illegal character, Rust print `..httpbin.org`
   --  begin
   --     VSS.Implementation.Rust.Tests.In_Str_Println (Sl);
   --     --  FIXME: Illegal character, Rust print `..
   --  end Strange_1;

   --  String_From_Rust
   declare
      Message : VSS.Strings.Virtual_String;

      Std_Out : VSS.Text_Streams.Output_Text_Stream'Class :=
                  VSS.Text_Streams.Standards.Standard_Output;
      Success : Boolean := True;
   begin
      Message := VSS.Implementation.Rust.To_Virtual_String
        (VSS.Implementation.Rust.Tests.String_From_Rust);

      --  Check `Message`
      if Message.Starts_With
        (VSS.Strings.To_Virtual_String
           ("This is message from Rust. Это сообщение из Rust."))
      then
         Ada.Wide_Wide_Text_IO.Put_Line
           ("Starts_With `This is message from Rust`");
      end if;

      if Message.Ends_With
        (VSS.Strings.To_Virtual_String
           ("This is message from Rust. Это сообщение из Rust."))
      then
         Ada.Wide_Wide_Text_IO.Put_Line
           ("Ends_With `This is message from Rust`");
      end if;

      Std_Out.Put_Line (Message, Success);
      --  FIXME: ^ Blank in output
      Ada.Text_IO.Put_Line ("Status :" & Success'Image);

      Ada.Text_IO.New_Line;
   end;

   --  In_Str_Ret_String
   declare
      Argument : constant VSS.Strings.Virtual_String := VSS.Strings
        .To_Virtual_String ("Grzegorz Brzęczyszczykiewicz.");
      Message : VSS.Strings.Virtual_String;
   begin
      Message := VSS.Implementation.Rust.To_Virtual_String
        (VSS.Implementation.Rust.Tests.In_Str_Ret_String
           (VSS.Implementation.Rust.To_Slice_Str (Argument)));

      --  Check `Message`
      if Message.Starts_With
        (VSS.Strings.To_Virtual_String
           ("Hello, Grzegorz Brzęczyszczykiewicz."))
      then
         Ada.Wide_Wide_Text_IO.Put_Line
           ("Ada : Starts_With "
            & "`Hello, Grzegorz Brzęczyszczykiewicz.`");
      end if;

      if Message.Ends_With
        (VSS.Strings.To_Virtual_String
           ("Hello, Grzegorz Brzęczyszczykiewicz."))
      then
         Ada.Wide_Wide_Text_IO.Put_Line
           ("Ada : Ends_With "
            & "`Hello, Grzegorz Brzęczyszczykiewicz.`");
      end if;

      Ada.Text_IO.New_Line;
   end;

end test_1;
