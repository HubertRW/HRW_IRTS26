with Ada.Real_Time; use Ada.Real_Time;

package body Sensor_Filter is
   procedure Observe(Item : in out History; Reading : Natural; Now : Time) is
   begin
      if Reading in 2 .. 400 then
         Item.Last_Distance := Reading;
         Item.Last_Valid_At := Now;
         Item.Has_Valid := True;
         Item.Consecutive_Failures := 0;
      elsif Item.Consecutive_Failures < Natural'Last then
         Item.Consecutive_Failures := Item.Consecutive_Failures + 1;
      end if;
   end Observe;

   function Valid_Until (Item : History) return Time is
   begin
      if not Item.Has_Valid then
         return Time_First;
      end if;
      return Item.Last_Valid_At + Max_Age;
   end Valid_Until;

   function Value (Item : History; Now : Time) return Natural is
   begin
      if Item.Has_Valid and then Now < Valid_Until (Item) then
         return Item.Last_Distance;
      end if;
      return 0;
   end Value;
end Sensor_Filter;
