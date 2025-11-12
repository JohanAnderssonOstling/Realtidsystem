--Process commnication: Ada lab part 3

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;

procedure comm1 is
    Message: constant String := "Process communication";
	task buffer is
      entry Put (item: in Integer);
      entry Get (item: out Integer);
            -- add your task entries for communication 
	end buffer;

	task producer is
            -- add your task entries for communication  
	end producer;

	task consumer is
            -- add your task entries for communication 
	end consumer;

	task body buffer is 
		Message: constant String := "buffer executing";
      type Int_Array is array (0 .. 9) of Integer;
      buf : Int_Array;
      Head : Integer := 0;
      Tail: Integer := 0;
      Count: Integer := 0;
      Capacity: Integer := 10;
                -- change/add your local declarations here  
	begin
		Put_Line(Message);
		loop
         select
            when Count < Capacity =>
               accept Put(item : in Integer) do 
                  buf(Tail) := item;
                  Tail := (Tail + 1) mod Capacity;
                  Count := Count + 1;
               end Put; 
            or when Count > 0 => 
               accept Get(Item : out Integer) do 
                  Item := buf(Head + 1);
                  Head := (Heead + 1) mod Capacity;
                  Count := Count - 1;
               end get; 
            end select; 
		end loop;
	end buffer;

	task body producer is 
		Message: constant String := "producer executing";
                -- change/add your local declarations here
	begin
		Put_Line(Message);
		loop
                -- add your task code inside this loop  
		end loop;
	end producer;

	task body consumer is 
		Message: constant String := "consumer executing";
                -- change/add your local declarations here
	begin
		Put_Line(Message);
		Main_Cycle:
		loop 
                -- add your task code inside this loop 
		end loop Main_Cycle; 

                -- add your code to stop executions of other tasks     
		exception
			  when TASKING_ERROR =>
				  Put_Line("Buffer finished before producer");
		Put_Line("Ending the consumer");
	end consumer;
begin
	Put_Line(Message);
end comm1;
