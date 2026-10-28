with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO;
with Controller; use Controller;

procedure Controller_Watchdog_Test is
begin
   pragma Assert (MotorController.GetState = Idle,
                  "Startup must be stopped");

   MotorController.SetState (Driving);
   pragma Assert (MotorController.GetState = Driving,
                  "Fresh command must be available");

   delay until Clock + Command_Timeout + Milliseconds (20);
   pragma Assert (MotorController.GetState = Idle,
                  "Expired command must stop");

   MotorController.SetState (LeftCol);
   pragma Assert (MotorController.GetState = LeftCol,
                  "Fresh command must recover after timeout");

   MotorController.SetState (Idle);
   pragma Assert (MotorController.GetState = Idle,
                  "Explicit stop must be preserved");

   Ada.Text_IO.Put_Line ("PASS: startup, fresh command, expiry, recovery, stop");
end Controller_Watchdog_Test;
