with Ada.Real_Time; use Ada.Real_Time;
with Brain; use Brain;

package body Sense is

   CurrentTime : Time;

   task body ReadSensorsTask is
   begin
      loop
         CurrentTime := Clock;

         FrontReading := Brain.sensor_distance(sensor1.read);
         delay 0.05;

         RightReading := Brain.sensor_distance(sensor2.read);
         delay 0.05;

         LeftReading := Brain.sensor_distance(sensor3.read);
         delay 0.05;

         Brain.BrainData.Insert(FrontReading, RightReading, LeftReading);

         delay until CurrentTime + Milliseconds(50); -- total: 150ms + 50ms;
      end loop;
   end ReadSensorsTask;
end Sense;
