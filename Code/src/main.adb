with MicroBit.Console; use MicroBit.Console;
--  with MicroBit.Time; use MicroBit.Time;
--  with MicroBit.DisplayRT; use MicroBit.DisplayRT;
use MicroBit;
with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with DFR0548;



-- USN PROJECT TEMPLATE INTELLIGENT REAL-TIME SYSTEMS
-- Project name: [project name]
-- Project members: [name, name, .. ]


--This is a project template for the MicroBit v2, built against the embedded-nrf52833
--runtime (a Ravenscar/Jorvik-style profile) so we have a language-supported real-time
--OS for embedded targets. The runtime ships with the gnat_arm_elf toolchain that Alire
--installs, so there is nothing to copy by hand.

--Check out the many examples in the ADL for the MicroBit v2 to see:
--  1) How the various drivers can be used like the accelerometer,speaker  or wireless communication via radio
--  2) How ADA features like the Math library and Bounded_Vectors (Containers) can be used
--  3) How to structure your Ada tasks with a protected object to synchronize data or with entries to synchronize flow
--  4) How to perform a execution time analysis
--  5) How to integrate your Ada project with a Unity project over USB

-- Open a View > Cross Platforms > Serial Ports to see Put_Line output. Set the baud rate to 115.200


-- Hoved:
--  procedure Main is 
--  teller : Integer := 0;
--  Input : Character;

--  begin
   
--     Put_Line ("TEST START");
--     loop
--        Put_Line("hello from Hubert");

--        if(teller = Integer'Last) then
--           goto EndLoop;
--        end if;

--        teller := teller + 1;
--        Put_Line("count: ");
--        Put_Line(Integer'Image(teller));
      
--        Put_Line("Write your input: ");
--        Get(Input);

--        exit when Input = '1';

--        Put("Output: ");
--        Put(Input);
--        New_Line;

--     end loop;
--     <<EndLoop>> null;
--  end Main;


procedure Main is

begin
   MotorDriver.Servo(1,90);
   delay 1.0; -- equivalent of Time.Sleep(1000) = 1 second

   loop
      -- DEMONSTRATION ROUTINE 4 MOTORS (useful for checking your wiring)
      MotorDriver.Drive(Forward,(4095,0,0,0)); --right front wheel to M4
      Console.Put_Line("RF");
      delay 1.0;
      MotorDriver.Drive(Forward,(0,4095,0,0)); --right back wheel to M3
      Console.Put_Line("RB");
      delay 1.0;
      MotorDriver.Drive(Forward,(0,0,4095,0)); --left front wheel to M2
      Console.Put_Line("LF");
      delay 1.0;
      MotorDriver.Drive(Forward,(0,0,0,4095)); --left back wheel to M1
      Console.Put_Line("LB");
      delay 1.0;
      MotorDriver.Drive(Stop);

      -- DEMONSTRATION ROUTINE SERVO
      for I in reverse DFR0548.Degrees range 0..90 loop
         MotorDriver.Servo(1,I);
          delay 0.02; --20 ms
      end loop;

      for I in DFR0548.Degrees range 90..180 loop
         MotorDriver.Servo(1,I);
         delay 0.02; --20 ms
      end loop;

      for I in reverse DFR0548.Degrees range 90..180 loop
         MotorDriver.Servo(1,I);
          delay 0.02; --20 ms
      end loop;

   end loop;
end Main;
