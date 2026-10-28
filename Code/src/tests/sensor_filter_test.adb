with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO;
with Sensor_Filter; use Sensor_Filter;
with Controller; use Controller;

procedure Sensor_Filter_Test is
   Front, Right : History;
   Base : constant Time := Clock;
begin
   pragma Assert (Value (Front, Base) = 0);
   Observe (Front, 0, Base);
   pragma Assert (not Front.Has_Valid);
   Observe (Front, 150, Base);
   Observe (Front, 0, Base + Milliseconds (100));
   pragma Assert (Value (Front, Base + Milliseconds (100)) = 150);
   pragma Assert (Front.Last_Valid_At = Base);
   pragma Assert (Front.Consecutive_Failures = 1);
   Observe (Front, 0, Base + Milliseconds (200));
   pragma Assert (Value (Front, Base + Max_Age) = 0);
   pragma Assert (Front.Last_Valid_At = Base);
   Observe (Front, 5, Base + Milliseconds (310));
   Observe (Front, 0, Base + Milliseconds (320));
   pragma Assert (Value (Front, Base + Milliseconds (330)) = 5);
   Observe (Right, 400, Base);
   pragma Assert (Value (Right, Base + Milliseconds (10)) = 400);
   pragma Assert (Value (Front, Base + Milliseconds (330)) = 5);
   Observe (Right, 401, Base + Milliseconds (20));
   pragma Assert (Right.Last_Valid_At = Base);
   Observe (Right, 2, Base + Milliseconds (30));
   pragma Assert (Right.Consecutive_Failures = 0);
   pragma Assert (Value (Right, Base + Milliseconds (31)) = 2);
   Front.Consecutive_Failures := Natural'Last;
   Observe (Front, 0, Base + Milliseconds (340));
   pragma Assert (Front.Consecutive_Failures = Natural'Last);

   MotorController.SetState (Driving, Clock + Milliseconds (30));
   pragma Assert (MotorController.GetState = Driving);
   delay until Clock + Milliseconds (50);
   pragma Assert (MotorController.GetState = Idle);
   MotorController.SetState (Driving, Clock - Milliseconds (1));
   pragma Assert (MotorController.GetState = Idle);
   Ada.Text_IO.Put_Line
     ("PASS: startup, dropout, expiry boundary, obstacle retention, recovery, independent histories, range, saturation, command expiry");
end Sensor_Filter_Test;
