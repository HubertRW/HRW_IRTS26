with Brain;
with Ada.Real_Time; use Ada.Real_Time;
with Controller;

package body Think is

   procedure SelectState is
      data : Brain.SensorData;
   begin

      Brain.Get(data);

      if data.FrontDistance <= Threshold then
         SetState(FrontCol);
      elsif data.RightDistance <= Threshold then
         SetState(RightCol);
      elsif data.LeftDistance <= Threshold then
         SetState(LeftCol);
      end if;

   end SelectState;


   task body ThinkTask is
      CurrentTime : Time;
   begin
      CurrentTime := Clock;

      SelectState;

      delay until CurrentTime + Milliseconds(50);
   end ThinTask;

end Think;