with Ada.Calendar;
with Ada.Text_IO;
use Ada.Calendar;
use Ada.Text_IO;

procedure cyclic is
   Message    : constant String := "Cyclic scheduler";

   -- period of each minor cycle
   d          : constant Duration := 0.5;

   Start_Time : Time := Clock;
   Next_Release : Time := Start_Time;  -- absolute wake-up time

   -- state for the 4 minor cycles
   s          : Integer := 0;

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
      Message : constant String := "f3 executing, time is now";
   begin
      Put (Message);
      Put_Line (Duration'Image (Clock - Start_Time));
   end f3;

begin
   loop
      -- choose what to run in this minor cycle
      case s is
         when 0 =>
            f1;
            f2;
         when 1 =>
               f3;
         when 2 =>
            f1;
            f2;
         when others =>
            null;  -- idle slot (your last "delay d")
      end case;

      -- advance scheduler state 0 → 1 → 2 → 3 → 0 ...
      s := (s + 1) mod 4;

      -- compute next absolute release time
      Next_Release := Next_Release + d;

      -- this delay effectively is: d - execution_time,
      -- because any time already spent reduces the remaining wait
      delay until Next_Release;
   end loop;
end cyclic;
