with Brain;
with Ada.Real_Time; use Ada.Real_Time;
with Controller; use Controller;
with MicroBit.Types;
with Ada.Execution_Time; use Ada.Execution_Time;
with MicroBit.Console; use MicroBit.Console;

package body Think is
   use type MicroBit.Types.Distance_cm;

   procedure SelectState is
      data : Brain.SensorData;
   begin

      Brain.BrainData.Get(data);

      if Ada.Real_Time.Clock - data.Recorded_At >= Command_Timeout
        or else Ada.Real_Time.Clock >= data.Valid_Until
        or else data.FrontDistance < 2
        or else data.RightDistance < 2
        or else data.LeftDistance < 2
      then
         Controller.MotorController.SetState(Controller.Idle, data.Valid_Until);
      elsif data.FrontDistance <= Threshold then
         Controller.MotorController.SetState(Controller.ForwardCol, data.Valid_Until);
      elsif data.RightDistance <= Threshold then
         Controller.MotorController.SetState(Controller.RightCol, data.Valid_Until);
      elsif data.LeftDistance <= Threshold then
         Controller.MotorController.SetState(Controller.LeftCol, data.Valid_Until);
      else
         Controller.MotorController.SetState(Controller.Driving, data.Valid_Until);
      end if;

   end SelectState;


   task body ThinkTask is

      CurrentTime : Time;
      StartCPU, StopCPU : CPU_Time;
      Elapsed_Time : Time_Span;
      
   begin 
      loop 
         CurrentTime := Clock;
         StartCPU := Clock;

         SelectState;

         StopCPU := Clock;
         Elapsed_Time := StopCPU - StartCPU;

         MicroBit.Console.Put_Line("Think Elapsed time: " & Duration'Image(To_Duration(Elapsed_Time)) & " seconds");

         delay until CurrentTime + Milliseconds(100);
      end loop;
   end ThinkTask;

end Think;
