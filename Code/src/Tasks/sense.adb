with Ada.Real_Time; use Ada.Real_Time;
with Ada.Execution_Time; use Ada.Execution_Time;
with Brain; use Brain;
with MicroBit.Console; use MicroBit.Console;
with MicroBit; use MicroBit;

package body Sense is

   CurrentTime, StopTime : Time;
   StartCPU, StopCPU : CPU_Time;
   Elapsed_Time : Time_Span;

   task body ReadSensorsTask is
   begin
      loop
         --  CurrentTime := Clock;
         StartCPU := Clock;

         FrontReading := Brain.sensor_distance(sensor1.read);
         --  Microbit.Console.Put_Line("Front sensor: " & sensor_distance'Image(FrontReading)); 

         RightReading := Brain.sensor_distance(sensor2.read);
         --  MicroBit.Console.Put_Line("Right sensor: " & sensor_distance'Image(RightReading)); 
      
         LeftReading := Brain.sensor_distance(sensor3.read);
         --  MicroBit.Console.Put_Line("Left sensor: " & sensor_distance'Image(LeftReading)); 

         Brain.BrainData.Insert(FrontReading, RightReading, LeftReading);


         --  StopTime := Clock;
         StopCPU := Clock;

         Elapsed_Time := StopCPU - StartCPU;

         MicroBit.Console.Put_Line("Sense Elapsed time: " & Duration'Image(To_Duration(Elapsed_Time)) & " seconds");

         --  delay until CurrentTime + Milliseconds(100);
         delay 0.1;
      end loop;
   end ReadSensorsTask;
end Sense;
