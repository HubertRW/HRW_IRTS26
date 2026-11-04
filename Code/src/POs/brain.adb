package body Brain is
   function Is_Fresh (Reading : Sensor_Reading; Now : Time) return Boolean is
     (Reading.Distance >= 2
      and then Reading.Recorded_At <= Now
      and then Now < Reading.Valid_Until);

   protected body BrainData is
      procedure Update (Sensor : Sensor_Id; Reading : Sensor_Reading) is
      begin
         Latest (Sensor) := Reading;
      end Update;

      procedure Get (Values : out SensorData) is
      begin
         Values := Latest;
      end Get;
   end BrainData;
end Brain;
