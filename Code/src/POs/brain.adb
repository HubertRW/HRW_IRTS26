package body Brain is

   protected body BrainData is
      
      entry Insert(front : in sensor_distance; right : in sensor_distance;
                   left : in sensor_distance; Valid_Until : in Time := Time_Last)
        when Count < Max_Capacity is
      begin
         BrainBuffer(Head).FrontDistance := front;
         BrainBuffer(Head).RightDistance := right;
         BrainBuffer(Head).LeftDistance := left;
         BrainBuffer(Head).Recorded_At := Ada.Real_Time.Clock;
         BrainBuffer(Head).Valid_Until := Valid_Until;

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
