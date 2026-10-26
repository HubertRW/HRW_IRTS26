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

      if data.FrontDistance <= Threshold then
         Controller.MotorController.SetState(Controller.ForwardCol);
      elsif data.RightDistance <= Threshold then
         Controller.MotorController.SetState(Controller.RightCol);
      elsif data.LeftDistance <= Threshold then
         Controller.MotorController.SetState(Controller.LeftCol);
      end if;

   end SelectState;


   task body ThinkTask is

      CurrentTime : Time;
      StartCPU, StopCPU : CPU_Time;
      Elapsed_Time : Time_Span;
      
   begin 
      loop 
         --  CurrentTime := Clock;
         StartCPU := Clock;

         SelectState;

         StopCPU := Clock;
         Elapsed_Time := StopCPU - StartCPU;

         MicroBit.Console.Put_Line("Think Elapsed time: " & Duration'Image(To_Duration(Elapsed_Time)) & " seconds");

         delay 0.1;
         --  delay until CurrentTime + Milliseconds(50);
      end loop;
   end ThinkTask;

end Think;
