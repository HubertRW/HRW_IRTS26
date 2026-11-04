with MicroBit.MotorDriver; use MicroBit.MotorDriver;
with Controller;

package Act is

   task ActTask with Priority => 4;
   procedure Move(state : Controller.CarState);

end Act;
