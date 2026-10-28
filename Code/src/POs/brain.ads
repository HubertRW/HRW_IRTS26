with Microbit.Types; use MicroBit.Types;
with Ada.Real_Time; use Ada.Real_Time;


package Brain is 

   subtype sensor_distance is Distance_cm;

   type SensorData is record
      LeftDistance : sensor_distance;
      RightDistance : sensor_distance;
      FrontDistance : sensor_distance;
      Recorded_At : Time;
      Valid_Until : Time;
   end record;

   type Index is new Integer range 0 .. 1000;
   type DataBuffer is array(Index) of SensorData;
   
   protected BrainData is

      entry Insert(front : in sensor_distance; right : in sensor_distance;
                   left : in sensor_distance; Valid_Until : in Time := Time_Last);
      entry Get(values : out SensorData);

   private
      BrainBuffer : DataBuffer;
      Head : Index := 0;
      Tail : Index := 0;
      Count : Index := 0;
      Max_Capacity : Index := Index'Last;
   end BrainData;

end Brain;
