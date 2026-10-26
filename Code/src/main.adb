with MicroBit.Console; use MicroBit.Console;
--  with MicroBit.Time; use MicroBit.Time;
with MicroBit.DisplayRT; use MicroBit.DisplayRT;
use MicroBit;
with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with MicroBit.Ultrasonic;
with MicroBit.Types; use MicroBit.Types;
with DFR0548;
with MicroBit.Music; use MicroBit.Music;

with Sense;
with Think;
with Act;

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




procedure Main with Priority => 0 is
   
   Start : Time;

begin


   loop

      --  MotorDriver.Drive(Forward,(4095,4095,4095,4095));

      -- simple test, can and will be improved
      --  if sensor1.read < Distance then -- front ultrasonic sensor
      --     MotorDriver.Drive(Lateral_Left,(4095,4095,4095,4095));
      --     MicroBit.Music.Play(27, AlarmFront);
      --     delay 0.05;
      --  elsif sensor2.read < Distance then --detection at the right
      --     MotorDriver.Drive(Forward_Left,(4095,4095,4095,4095));
      --     MicroBit.Music.Play(27, AlarmRight);
      --     delay 0.05;
      --  elsif sensor3.read < Distance then -- detection at the left
      --     MotorDriver.Drive(Right,(4095,4095,4095,4095));
      --     MicroBit.Music.Play(27, AlarmLeft);
      --     delay 0.05;
      --  end if;

      Start := Clock;

      delay until Start + Milliseconds(10);
   end loop;
end Main;
