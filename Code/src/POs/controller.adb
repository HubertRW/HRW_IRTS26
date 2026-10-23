
package body Controller is 

   protected body MotorController is

      function GetState return CarState is
      begin
         return CurrentState;
      end GetState;

      procedure SetState(state : CarState) is
      begin
         CurrentState := state;
      end SetState;

   end MotorController;

end Controller;
