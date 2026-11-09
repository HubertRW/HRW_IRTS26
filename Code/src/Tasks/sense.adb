with Ada.Real_Time; use Ada.Real_Time;
with Ada.Execution_Time; use Ada.Execution_Time;
with Brain; use Brain;
with MicroBit.Console; use MicroBit.Console;
with MicroBit; use MicroBit;


package body Sense is

   CurrentTime, StopTime : Time;
   StartCPU, StopCPU : CPU_Time;
   Elapsed_Time, Elapsed_CPU : Time_Span;

   task body ReadSensorsTask is

      Acquisition_Start : Time;

      procedure Publish(Sensor : Sensor_Id; Reading : in out sensor_distance; Started_At : Time)
      is
         Sample : Sensor_Reading;
      begin
         
         Sample := (Distance => Reading, Recorded_At => Started_At, 
            Valid_Until => Started_At + Milliseconds(300));

         BrainData.Update (Sensor, Sample);
      end Publish;
   begin
      loop
         CurrentTime := Clock;
         StartCPU := Clock;

         Acquisition_Start := Ada.Real_Time.Clock;
         FrontReading := Brain.sensor_distance (sensor1.Read);
         Publish (Front, FrontReading, Acquisition_Start);

         Acquisition_Start := Ada.Real_Time.Clock;
         RightReading := Brain.sensor_distance (sensor2.Read);
         Publish (Right, RightReading, Acquisition_Start);

         Acquisition_Start := Ada.Real_Time.Clock;
         LeftReading := Brain.sensor_distance (sensor3.Read);
         Publish (Left, LeftReading, Acquisition_Start);

         StopTime := Clock;
         StopCPU := Clock;

         Elapsed_Time := StopTime - CurrentTime;
         Elapsed_CPU := StopCPU - StartCPU;

         --  MicroBit.Console.Put_Line("Front: " & Brain.sensor_distance'Image(FrontReading));
         --  MicroBit.Console.Put_Line("Right: " & Brain.sensor_distance'Image(RightReading));
         --  MicroBit.Console.Put_Line("Left: " & Brain.sensor_distance'Image(LeftReading));

         --  MicroBit.Console.Put_Line("Sense Elapsed time: " & Duration'Image(To_Duration(Elapsed_Time)) & " seconds");
         --  MicroBit.Console.Put_Line("Sense CPU time: " & Duration'Image(To_Duration(Elapsed_CPU)) & " seconds");

         delay until CurrentTime + Milliseconds(200);
      end loop;
   end ReadSensorsTask;
end Sense;
