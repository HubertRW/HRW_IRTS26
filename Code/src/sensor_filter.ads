with Ada.Real_Time;

package Sensor_Filter is
   -- Provisional grace period. Validate against speed and stopping distance.
   Max_Age : constant Ada.Real_Time.Time_Span := Ada.Real_Time.Milliseconds (300);

   type History is record
      Last_Distance : Natural := 0;
      Last_Valid_At : Ada.Real_Time.Time := Ada.Real_Time.Time_First;
      Consecutive_Failures : Natural := 0;
      Has_Valid : Boolean := False;
   end record;

   procedure Observe(Item : in out History; Reading : Natural; Now : Ada.Real_Time.Time);
   function Value (Item : History; Now : Ada.Real_Time.Time) return Natural;
   function Valid_Until (Item : History) return Ada.Real_Time.Time;
end Sensor_Filter;
