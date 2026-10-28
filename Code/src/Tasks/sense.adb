with Ada.Real_Time; use Ada.Real_Time;
with Ada.Execution_Time; use Ada.Execution_Time;
with Brain; use Brain;
with MicroBit.Console; use MicroBit.Console;
with MicroBit; use MicroBit;
with Sensor_Filter;

package body Sense is

   CurrentTime, StopTime : Time;
   StartCPU, StopCPU : CPU_Time;
   Elapsed_Time : Time_Span;

   task body ReadSensorsTask is
      Front_History, Right_History, Left_History : Sensor_Filter.History;
      Published_At, Expiry : Time;
   begin
      loop
         CurrentTime := Clock;
         StartCPU := Clock;

         FrontReading := Brain.sensor_distance(sensor1.read);
         Sensor_Filter.Observe(Front_History, Natural (FrontReading), Ada.Real_Time.Clock);
         --  Microbit.Console.Put_Line("Front sensor: " & sensor_distance'Image(FrontReading)); 

         RightReading := Brain.sensor_distance(sensor2.read);
         Sensor_Filter.Observe(Right_History, Natural (RightReading), Ada.Real_Time.Clock);
         --  MicroBit.Console.Put_Line("Right sensor: " & sensor_distance'Image(RightReading)); 
      
         LeftReading := Brain.sensor_distance(sensor3.read);
         Sensor_Filter.Observe(Left_History, Natural (LeftReading), Ada.Real_Time.Clock);
         --  MicroBit.Console.Put_Line("Left sensor: " & sensor_distance'Image(LeftReading)); 

         Published_At := Ada.Real_Time.Clock;
         FrontReading := Brain.sensor_distance(Sensor_Filter.Value (Front_History, Published_At));
         RightReading := Brain.sensor_distance(Sensor_Filter.Value (Right_History, Published_At));
         LeftReading := Brain.sensor_distance(Sensor_Filter.Value (Left_History, Published_At));
         Expiry := Sensor_Filter.Valid_Until (Front_History);
         
         if Sensor_Filter.Valid_Until (Right_History) < Expiry then
            Expiry := Sensor_Filter.Valid_Until (Right_History);
         end if;
         if Sensor_Filter.Valid_Until (Left_History) < Expiry then
            Expiry := Sensor_Filter.Valid_Until (Left_History);
         end if;
         Brain.BrainData.Insert (FrontReading, RightReading, LeftReading, Expiry);


         --  StopTime := Clock;
         StopCPU := Clock;

         Elapsed_Time := StopCPU - StartCPU;

         MicroBit.Console.Put_Line("Sense Elapsed time: " & Duration'Image(To_Duration(Elapsed_Time)) & " seconds");

         delay until CurrentTime + Milliseconds(100);

      end loop;
   end ReadSensorsTask;
end Sense;
