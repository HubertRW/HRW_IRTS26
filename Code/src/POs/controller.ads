package Controller is

   type CarState is (Idle, Driving, ForwardCol, RightCol, LeftCol);

   protected MotorController is
      function GetState return CarState;
      procedure SetState(state : CarState);
   private
      CurrentState : CarState := Driving;
   end MotorController;

end Controller;
