with Ada.Calendar;
with Ada.Numerics.Float_Random;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;
use Ada.Numerics.Float_Random;

procedure Comm1 is
   Message : constant String := "Process communication";

   -- float random generator for delays
   Delay_Gen : Generator;

   -- integer random generator for items
   subtype Integer_Range is Integer range 0 .. 20;
   package Random_Integer is new Ada.Numerics.Discrete_Random (Integer_Range);
   Int_Gen : Random_Integer.Generator;

   task Buffer is
      entry Put (Item : in Integer);
      entry Get (Item : out Integer);
      entry Stop;
   end Buffer;

   task Producer is
      entry Stop;
   end Producer;
   task Consumer;

   task body Buffer is
      Message : constant String := "buffer executing";
      type Int_Array is array (0 .. 9) of Integer;
      Buf : Int_Array;
      Head, Tail, Count : Integer := 0;
      Capacity : constant Integer := 10;
   begin
      Put_Line(Message);
      loop
         select
            when Count < Capacity =>
               accept Put(Item : in Integer) do
                  Buf(Tail) := Item;
                  Tail := (Tail + 1) mod Capacity;
                  Count := Count + 1;
               end Put;
         or
            when Count > 0 =>
               accept Get(Item : out Integer) do
                  Item := Buf(Head);
                  Head := (Head + 1) mod Capacity;
                  Count := Count - 1;
               end Get;
         or accept Stop do 
            null;
         end Stop;
         exit;
         end select;
      end loop;
   end Buffer;

   task body Producer is
      Message : constant String := "producer executing";
      Item : Integer;
      Delay_Time : Float;

   begin
      Put_Line(Message);
      Reset(Delay_Gen);
      Random_Integer.Reset(Int_Gen);

      loop
         Delay_Time := Random(Delay_Gen) * 0.1;
         select
            delay Duration(Delay_Time);
            Item := Random_Integer.Random(Int_Gen);
            Put_Line("Put item" & Integer'Image(Item));

            Buffer.Put(Item);
            or 
               accept Stop do
                  null;
               end Stop;
               exit;
         end select;
      end loop;
   end Producer;

   task body Consumer is
      Message : constant String := "consumer executing";
      Item : Integer;
            Delay_Time : Float;

      Sum : Integer := 0;
   begin
      Put_Line(Message);
      loop
         Delay_Time := Random(Delay_Gen) * 10.0;

         delay Duration(Delay_Time);
         Buffer.Get(Item);
         Sum := Sum + Item;
         if (Sum >= 100) then 
            Put_Line("Färdig!");
            Buffer.Stop;
            Producer.Stop;
            exit;
         end if;
         Put_Line("Got item" & Integer'Image(Item));
      end loop;
   end Consumer;

begin
   Put_Line(Message);
end Comm1;
