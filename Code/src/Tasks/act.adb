with Ada.Real_Time; use Ada.Real_Time;
with Controller; use Controller;
with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with DFR0548;
with Ada.Execution_Time; use Ada.Execution_Time;
with MicroBit.Music; use MicroBit.Music;
with MicroBit; use MicroBit;
with MicroBit.Console; use MicroBit.Console;

package body Act is

   CurrentTime : Time;
   StateNow : Controller.CarState;

   --  AlarmFront : MicroBit.Music.Melody := ((G5, 100), (C5, 200), (F5,50), (A5,50));
   --  AlarmRight : MicroBit.Music.Melody := ((B4, 50), (A4, 100), (B4, 50), (A4, 100));
   --  AlarmLeft : MicroBit.Music.Melody := ((DS5, 100), (CS5, 50), (DS5, 100), (FS5, 50));

   StartCPU, StopCPU : CPU_Time;
   Elapsed_Time : Time_Span;

   procedure Move(state: Controller.CarState) is
   begin 
      case state is 
            when Idle => 
               MicroBit.MotorDriver.Drive(Stop,(0,0,0,0));
            when Driving =>
               MicroBit.MotorDriver.Drive(Forward,(4095,4095,4095,4095));
            when ForwardCol =>
               MicroBit.MotorDriver.Drive(Lateral_Left,(4095,4095,4095,4095));
               --  MicroBit.Music.Play(27, AlarmFront);
            when RightCol =>
               MicroBit.MotorDriver.Drive(Forward_Left,(4095,4095,4095,4095));
               --  MicroBit.Music.Play(27, AlarmRight);
            when LeftCol =>
               MicroBit.MotorDriver.Drive(Right,(4095,4095,4095,4095));
               --  MicroBit.Music.Play(27, AlarmLeft);
            when others =>
               MicroBit.MotorDriver.Drive(Forward,(4095,4095,4095,4095));
         end case;
   end Move;

   task body ActTask is
      begin
      MicroBit.MotorDriver.Servo(1,90);

         loop
            --  CurrentTime := Clock;
            StartCPU := Clock;

            MicroBit.MotorDriver.Drive(Forward,(4095,4095,4095,4095));
            
            StateNow := MotorController.GetState;

            Move(StateNow);

            StopCPU := Clock;
            Elapsed_Time := StopCPU - StartCPU;

            MicroBit.Console.Put_Line("Act Elapsed Time: " & Duration'Image(To_Duration(Elapsed_Time)) & " seconds");

            --  delay until CurrentTime + Milliseconds(50);
            delay 0.1;
         end loop;

   end ActTask;
   

end Act;
