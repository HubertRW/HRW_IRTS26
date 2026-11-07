with Brain;
with Controller;
with Ada.Real_Time;

package Think is

   Threshold : Brain.sensor_distance := 15;

   type Decision is record
      State : Controller.CarState;
      Valid_Until : Ada.Real_Time.Time;
      AFState : Controller.AfterFrontState;
   end record;

   -- Evaluate a snapshot without modifying Controller. SelectState applies it.
   function Evaluate(Data : Brain.SensorData; Now : Ada.Real_Time.Time; 
      Threshold : Brain.sensor_distance) return Decision;

   procedure SelectState;
   task ThinkTask with Priority => 3;

   --  function LeftAvailable(Data : Brain.SensorData) return Boolean;
   --  function RightAvailable(Data: Brain.SensorData) return Boolean;   
end Think;
