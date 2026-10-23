package body Brain is

   protected body BrainData is
      
      entry Insert(front : in sensor_distance; right : in sensor_distance; left : in sensor_distance) when Count < Max_Capacity is
      begin
         BrainBuffer(Head).FrontDistance := front;
         BrainBuffer(Head).RightDistance := right;
         BrainBuffer(Head).LeftDistance := left;

         Head := (Head + 1) mod Max_Capacity;
         Count := Count + 1;

      end Insert;

      entry Get(values : out SensorData) when Count > 0 is
      begin
         values := BrainBuffer(Tail);
         Tail := (Tail + 1) mod Max_Capacity;
         Count := Count - 1;

      end Get;

   end BrainData;

end Brain;