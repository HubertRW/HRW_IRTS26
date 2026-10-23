package Controller is

   type CarState is (Idle, Driving, ForwardCol, RightCol, LeftCol);

   protected MotorController is

      procedure GetPinConfig;
      function GetState return CarState;
      procedure SetState;
   private
      CurrentState : CarState := Driving;
   end MotorController;

end Controller;