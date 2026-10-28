with Ada.Real_Time;

package Controller is

   -- Provisional watchdog interval, to be validated on the car.
   Command_Timeout : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds(500);

   type CarState is (Idle, Driving, ForwardCol, RightCol, LeftCol);

   protected MotorController is
      function GetState return CarState;
      procedure SetState(state : CarState;
                         Valid_Until : Ada.Real_Time.Time := Ada.Real_Time.Time_Last);
   private
      CurrentState : CarState := Idle;
      Last_Updated : Ada.Real_Time.Time := Ada.Real_Time.Clock;
      Reading_Expiry : Ada.Real_Time.Time := Ada.Real_Time.Time_Last;
   end MotorController;

end Controller;
