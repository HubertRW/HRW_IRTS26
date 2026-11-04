with Brain; use Brain;
with Ada.Real_Time; use Ada.Real_Time;
with Controller; use Controller;
with Ada.Execution_Time; use Ada.Execution_Time;
with MicroBit.Console; use MicroBit.Console;

package body Think is
   function Evaluate
     (Data : SensorData; Now : Time;
      Threshold : sensor_distance) return Decision
   is
      Result : Decision := (State => Driving, Valid_Until => Time_Last);
   begin
      for Sensor in Sensor_Id loop
         if not Is_Fresh (Data (Sensor), Now) then
            -- Unknown is not clear space, nor a valid collision measurement.
            return (State => Idle, Valid_Until => Time_First);
         end if;
         if Data (Sensor).Valid_Until < Result.Valid_Until then
            Result.Valid_Until := Data (Sensor).Valid_Until;
         end if;
      end loop;

      -- Preserve the existing front/right/left collision priority.
      if Data (Front).Distance <= Threshold then
         Result.State := ForwardCol;
      elsif Data (Right).Distance <= Threshold then
         Result.State := RightCol;
      elsif Data (Left).Distance <= Threshold then
         Result.State := LeftCol;
      end if;
      return Result;
   end Evaluate;

   procedure SelectState is
      Data : Brain.SensorData;
      Choice : Decision;
   begin
      Brain.BrainData.Get (Data);
      Choice := Evaluate
        (Data, Ada.Real_Time.Clock, Threshold);
      MotorController.SetState (Choice.State, Choice.Valid_Until);
   end SelectState;


   task body ThinkTask is

      CurrentTime, EndTime : Time;
      StartCPU, StopCPU : CPU_Time;
      Elapsed_Time, TimeCPU : Time_Span;
      
   begin 
      loop 
         CurrentTime := Clock;
         StartCPU := Clock;

         SelectState;

         EndTime := Clock;
         StopCPU := Clock;

         Elapsed_Time := EndTime - CurrentTime;
         TimeCPU := StopCPU - StartCPU;

         MicroBit.Console.Put_Line("Think Elapsed time: " & Duration'Image(To_Duration(Elapsed_Time)) & " seconds");
         MicroBit.Console.Put_Line("Think CPU time: " & Duration'Image(To_Duration(TimeCPU)) & " seconds");

         delay until CurrentTime + Milliseconds(100);
      end loop;
   end ThinkTask;

end Think;
