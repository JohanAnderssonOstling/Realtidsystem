--Protected types: Ada lab part 4
--@Copyright Johan Andersson Östling
with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;
use Ada.Calendar;
use Ada.Text_IO;use Ada.Numerics.Float_Random;

use Ada.Numerics.Float_Random;


procedure comm2 is
   subtype Integer_Range is Integer range 0 .. 20;
   package Random_Integer is new Ada.Numerics.Discrete_Random (Integer_Range);
   Int_Gen : Random_Integer.Generator;
    Message: constant String := "Protected Object";
    	type BufferArray is array (0 .. 9) of Integer;
        -- protected object declaration
	protected  buffer is
            entry Put (Item : in Integer);
            entry Get (Item : out Integer);
	private
            Buf : BufferArray;
            Head, Tail, Count : Integer := 0;
            Capacity : constant Integer := 10;
	end buffer;

	task producer is
		-- add task entries
	end producer;

	task consumer is
                -- add task entries
	end consumer;

	protected body buffer is
              entry Put (Item : in Integer) when Count < Capacity is
              begin
                  Buf(Tail) := Item;
                  Tail := (Tail + 1) mod Capacity;
                  Count := Count + 1;
              end Put;

              entry Get (Item : out Integer) when Count > 0 is
              begin
                  Item := Buf(Head);
                  Head := (Head + 1) mod Capacity;
                  Count := Count - 1;
              end Get;
	end buffer;

   task body producer is
		Message: constant String := "producer executing";
                Item : Integer;
                Delay_Time : Float;
                Delay_Gen : Ada.Numerics.Float_Random.Generator;


	begin
		Put_Line(Message);
		Ada.Numerics.Float_Random.Reset(Delay_Gen);
		Random_Integer.Reset(Int_Gen);

		loop
                Delay_Time := Ada.Numerics.Float_Random.Random(Delay_Gen) * 0.1;
                delay Duration(Delay_Time);
                Item := Random_Integer.Random(Int_Gen);
                Put_Line("Put item" & Integer'Image(Item));
                buffer.Put(Item);
		end loop;
	end producer;

	task body consumer is
		Message: constant String := "consumer executing";
                Item : Integer;
                Delay_Time : Float;
                Delay_Gen : Ada.Numerics.Float_Random.Generator;
                Sum : Integer := 0;
	begin
		Put_Line(Message);
		
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      .Numerics.Float_Random.Reset(Delay_Gen);

		Main_Cycle:
		loop
                Delay_Time := Ada.Numerics.Float_Random.Random(Delay_Gen) * 10.0;
                delay Duration(Delay_Time);
                buffer.Get(Item);
                Sum := Sum + Item;
                if (Sum >= 100) then
                    Put_Line("Färdig!");
                    abort producer;
                    exit;
                end if;
                Put_Line("Got item" & Integer'Image(Item));
		end loop Main_Cycle;

                -- add your code to stop executions of other tasks
		Put_Line("Ending the consumer");
	end consumer;

begin
   Put_Line(Message);
end comm2;
