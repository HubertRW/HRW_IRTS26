with Ada.Real_Time; use Ada.Real_Time;
with Ada.Execution_Time; use Ada.Execution_Time;
with Brain; use Brain;
with MicroBit.Console; use MicroBit.Console;
with MicroBit; use MicroBit;
with Sensor_Filter;

package body Sense is

   CurrentTime, StopTime : Time;
   StartCPU, StopCPU : CPU_Time;
   Elapsed_Time, Elapsed_CPU : Time_Span;

   task body ReadSensorsTask is
      Front_History, Right_History, Left_History : Sensor_Filter.History;
      Acquisition_Start : Time;

      procedure Publish
        (Sensor : Sensor_Id; Reading : in out sensor_distance;
         History : in out Sensor_Filter.History; Started_At : Time)
      is
         Sample : Sensor_Reading;
      begin
         if Filter_Enabled then
            -- A retained reading keeps the original acquisition timestamp.
            -- Failed attempts must not make an old distance look new.
            Sensor_Filter.Observe (History, Reading, Started_At);
            Reading := Sensor_Filter.Value (History, Ada.Real_Time.Clock);
            Sample := (Distance => Reading,
                       Recorded_At => History.Last_Valid_At,
                       Valid_Until => Sensor_Filter.Valid_Until (History));
         else
            -- Age starts before acquisition, not after a potentially slow read.
            -- Zero remains invalid and will make Think request Idle.
            Sample := (Distance => Reading,
                       Recorded_At => Started_At,
                       Valid_Until => Started_At + Sensor_Filter.Max_Age);
         end if;
         BrainData.Update (Sensor, Sample);
      end Publish;
   begin
      loop
         CurrentTime := Clock;
         StartCPU := Clock;

         Acquisition_Start := Ada.Real_Time.Clock;
         FrontReading := Brain.sensor_distance (sensor1.Read);
         Publish (Front, FrontReading, Front_History, Acquisition_Start);

         Acquisition_Start := Ada.Real_Time.Clock;
         RightReading := Brain.sensor_distance (sensor2.Read);
         Publish (Right, RightReading, Right_History, Acquisition_Start);

         Acquisition_Start := Ada.Real_Time.Clock;
         LeftReading := Brain.sensor_distance (sensor3.Read);
         Publish (Left, LeftReading, Left_History, Acquisition_Start);

         StopTime := Clock;
         StopCPU := Clock;

         Elapsed_Time := StopTime - CurrentTime;
         Elapsed_CPU := StopCPU - StartCPU;

         --  MicroBit.Console.Put_Line("Sense Elapsed time: " & Duration'Image(To_Duration(Elapsed_Time)) & " seconds");
         --  MicroBit.Console.Put_Line("Sense CPU time: " & Duration'Image(To_Duration(Elapsed_CPU)) & " seconds");

         delay until CurrentTime + Milliseconds(200);
      end loop;
   end ReadSensorsTask;
end Sense;
