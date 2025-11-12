--Cyclic scheduler with a watchdog:

with Ada.Calendar;
with Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
use Ada.Calendar;
use Ada.Text_IO;
-- add packages to use randam number generator


procedure cyclic_wd is
   Message            : constant String := "Cyclic scheduler with watchdog";
   -- change/add your declarations here
   d                  : constant Duration := 0.5;  -- minor cycle period
   Start_Time         : Time := Clock;
   Next_Release       : Time := Start_Time;
   s                  : Integer := 0;  -- scheduler state
   F3_Deadline_Missed : Boolean := False;

   -- Random number generator for f3 delays
   subtype Delay_Range is Integer range 1 .. 10;
   package Random_Delay is new Ada.Numerics.Discrete_Random (Delay_Range);
   Gen : Random_Delay.Generator;

   procedure f1 is
      Message : constant String := "f1 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (Clock - Start_Time));
   end f1;

   procedure f2 is
      Message : constant String := "f2 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (Clock - Start_Time));
   end f2;

   procedure f3 is
      Message      : constant String := "f3 executing, time is now";
      Random_Value : Delay_Range;
   begin
      Put (Message);
      Put_Line (Duration'Image (Clock - Start_Time));
      -- add a random delay here
      Random_Value := Random_Delay.Random (Gen);
      if Random_Value <= 3 then
         -- 30% chance of long delay
         delay 0.8;  -- exceeds 0.5s deadline

      else
         delay 0.1;  -- normal execution time
      end if;
   end f3;

   task Watchdog is
      -- add your task entries for communication
      entry Start_Monitoring;
      entry Stop_Monitoring;
   end Watchdog;

   task body Watchdog is
      Monitoring_Start : Time;
      Deadline_Time    : Time;
   begin
      loop
         -- add your task code inside this loop
         select
            accept Start_Monitoring do
               Monitoring_Start := Clock;
               Deadline_Time := Monitoring_Start + 0.5;
            end Start_Monitoring;

            select
               accept Stop_Monitoring;
            or
               delay until Deadline_Time;
               Put_Line
                 ("WARNING: F3 missed its deadline at time "
                  & Duration'Image (Clock - Start_Time));
               F3_Deadline_Missed := True;
               accept Stop_Monitoring;
            end select;
         or
            terminate;
         end select;
      end loop;
   end Watchdog;

begin
   -- Initialize random generator
   Random_Delay.Reset (Gen);

   loop
      -- change/add your code inside this loop
      case s is
         when 0      =>
            f1;
            f2;

         when 1      =>
            -- Start watchdog before f3
            Watchdog.Start_Monitoring;
            f3;
            Watchdog.Stop_Monitoring;

            -- Check if f3 missed deadline and resynchronize
            if F3_Deadline_Missed then
               Put_Line ("Re-synchronizing scheduler to whole seconds");
               -- Calculate next whole second
               declare
                  Current_Time      : Time := Clock;
                  Elapsed           : Duration := Current_Time - Start_Time;
                  Next_Whole_Second : Duration :=
                    Duration (Integer (Elapsed) + 1);
               begin
                  Next_Release := Start_Time + Next_Whole_Second;
                  F3_Deadline_Missed := False;
               end;
            end if;

         when 2      =>
            f1;
            f2;

         when others =>
            null;  -- idle slot
      end case;

      -- advance scheduler state 0 → 1 → 2 → 3 → 0 ...
      s := (s + 1) mod 4;

      -- compute next absolute release time
      if not F3_Deadline_Missed then
         Next_Release := Next_Release + d;
      end if;

      -- delay until next release
      delay until Next_Release;
   end loop;
end cyclic_wd;
