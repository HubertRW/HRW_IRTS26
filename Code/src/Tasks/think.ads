with Brain;
with Controller;

package Think is

   Threshold : Brain.sensor_distance := 10;

   procedure SelectState;
   task ThinkTask with Priority => 2;
   
end Think;