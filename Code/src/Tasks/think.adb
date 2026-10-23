with Brain;
with Ada.Real_Time; use Ada.Real_Time;
with Controller; use Controller;
with MicroBit.Types;

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
   begin
      CurrentTime := Clock;

      SelectState;

      delay until CurrentTime + Milliseconds(50);
   end ThinkTask;

end Think;
