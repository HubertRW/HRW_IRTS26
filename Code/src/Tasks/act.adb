with Ada.Real_Time; use Ada.Real_Time;
with Controller; use Controller;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with DFR0548;
with Ada.Execution_Time; use Ada.Execution_Time;
with MicroBit; use MicroBit;
with MicroBit.Console; use MicroBit.Console;

package body Act is
   
   procedure Move(state: Controller.CarState; front_next: Controller.AfterFrontState) is
   begin 
      case state is 
            when Idle => 
               MicroBit.MotorDriver.Drive(Stop,(0,0,0,0));
            when Driving =>
               MicroBit.MotorDriver.Drive(Forward,(4095,4095,4095,4095));
            when ForwardCol =>
               case front_next is
                  when RightShift =>
                     MicroBit.MotorDriver.Drive(Right, (2048,2048,2048,2048));                  
                  when LeftShift =>
                     MicroBit.MotorDriver.Drive(Left, (2048,2048,2048,2048));
                  when ReverseShift =>
                     MicroBit.MotorDriver.Drive(Backward, (4095,4095,4095,4095));
                  end case;
            when RightCol =>
               MicroBit.MotorDriver.Drive(Forward_Left,(4095,4095,4095,4095));
            when LeftCol =>
               MicroBit.MotorDriver.Drive(Right,(4095,4095,4095,4095));
            when others =>
               MicroBit.MotorDriver.Drive(Forward,(4095,4095,4095,4095));
         end case;
   end Move;
   
   task body ActTask is

      CurrentTime, StopTime : Time;
      StateNow : Controller.CarState;
      FrontOption : Controller.AfterFrontState;

      StartCPU, StopCPU : CPU_Time;
      Elapsed_Time, TimeCPU : Time_Span;

      begin
      MicroBit.MotorDriver.Servo(1,90);

         loop
            CurrentTime := Clock;
            StartCPU := Clock;

            StateNow := MotorController.GetState;
            FrontOption := MotorController.GetFrontNext;

            Move(StateNow, FrontOption);

            StopTime := Clock;
            StopCPU := Clock;

            Elapsed_Time := StopTime - CurrentTime;
            TimeCPU := StopCPU - StartCPU;

            MicroBit.Console.Put_Line("Act Elapsed Time: " & Duration'Image(To_Duration(Elapsed_Time)) & " seconds");
            MicroBit.Console.Put_Line("Act CPU time: " & Duration'Image(To_Duration(TimeCPU)) & " seconds");

            delay until CurrentTime + Milliseconds(50);

         end loop;

   end ActTask;
   

end Act;
