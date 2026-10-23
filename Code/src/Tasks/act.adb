with Ada.Real_Time; use Ada.Real_Time;
with Controller; use Controller;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with DFR0548;

package body Act is

   CurrentTime : Time;
   StateNow : Controller.CarState;

   procedure Move(state: Controller.CarState) is
   begin 
      case state is 
            when Idle => 
               MotorDriver.Drive(Stop,(0,0,0,0));
            when Driving =>
               MotorDriver.Drive(Forward,(4095,4095,4095,4095));
            when ForwardCol =>
               MotorDriver.Drive(Lateral_Left,(4095,4095,4095,4095));
            when RightCol =>
               MotorDriver.Drive(Forward_Left,(4095,4095,4095,4095));
            when LeftCol =>
               MotorDriver.Drive(Right,(4095,4095,4095,4095));
         end case;
   end Move;

   task body ActTask is
      begin
         loop
            CurrentTime := Clock;
            StateNow := MotorController.GetState;

            Move(StateNow);

            delay until CurrentTime + Milliseconds(50);
         end loop;

   end ActTask;
   

end Act;
