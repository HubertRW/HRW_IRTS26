
package body Controller is 

   protected body MotorController is

      function GetState is
      begin
         return CurrentState;
      end GetState;

      function SetState(state : CarState) is
      begin
         CurrentState := state;
      end SetState;

   end MotorController;

end Controller;