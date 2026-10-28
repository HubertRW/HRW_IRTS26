with Brain;
with Controller;

package Think is

   Threshold : Brain.sensor_distance := 20;

   procedure SelectState;
   task ThinkTask with Priority => 2;
   
end Think;