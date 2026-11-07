
with Ada.Real_Time; use Ada.Real_Time;

package body Controller is 

   protected body MotorController is

      function GetState return CarState is
      begin
         if Ada.Real_Time.Clock - Last_Updated >= Command_Timeout
           or else Ada.Real_Time.Clock >= Reading_Expiry
         then
            return Idle;
         end if;
         return CurrentState;
      end GetState;

      function GetFrontNext return AfterFrontState is
      begin
         return NextFront;
      end GetFrontNext;
      
      procedure SetState(state : CarState; Valid_Until : Time := Time_Last) is
      begin
         CurrentState := state;
         Last_Updated := Ada.Real_Time.Clock;
         Reading_Expiry := Valid_Until;
      end SetState;

      procedure SetAfterFront(next_state : AfterFrontState) is
         begin
            NextFront := next_state;
         end SetAfterFront;

   end MotorController;

end Controller;
