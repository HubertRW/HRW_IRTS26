with Ada.Real_Time; use Ada.Real_Time;
with MicroBit; use MicroBit;
with MicroBit.Ultrasonic;
With Brain;

package Sense is

   -- Temporary test switch. Set True to restore sensor-filter retention.
   Filter_Enabled : constant Boolean := False;

   FrontReading : Brain.sensor_distance := 0;
   RightReading : Brain.sensor_distance := 0;
   LeftReading : Brain.sensor_distance := 0;

   package sensor1 is new Ultrasonic(MB_P16, MB_P0); --front
   package sensor2 is new Ultrasonic(MB_P13, MB_P2); --right
   package sensor3 is new Ultrasonic(MB_P14, MB_P1); --left

   task ReadSensorsTask with Priority => 2;

   -- warnings from documentation: 
   -- there is a blocking by 10us (microseconds) for every read
   -- minimum delay after a read operation should be 50 ms, anything lower can flood the serial
   

end Sense;
