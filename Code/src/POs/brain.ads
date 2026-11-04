with Ada.Real_Time; use Ada.Real_Time;

package Brain is
   -- Application data does not depend on the microcontroller drivers.
   subtype sensor_distance is Natural range 0 .. 400;
   type Sensor_Id is (Front, Right, Left);

   type Sensor_Reading is record
      Distance : sensor_distance := 0;
      Recorded_At : Time := Time_First;
      Valid_Until : Time := Time_First;
   end record;
   type SensorData is array (Sensor_Id) of Sensor_Reading;

   function Is_Fresh (Reading : Sensor_Reading; Now : Time) return Boolean;

   protected BrainData is
      -- Updating one direction never renews the other directions' timestamps.
      procedure Update (Sensor : Sensor_Id; Reading : Sensor_Reading);
      -- Copy the latest coherent snapshot without consuming it or waiting
      -- for the producer. Only brief protected-object mutual exclusion applies.
      procedure Get (Values : out SensorData);
   private
      Latest : SensorData := [others => <>];
   end BrainData;
end Brain;
