with Controller; use Controller;
with MicroBit.Music; use MicroBit.Music;

package Alarm is

   task PlaySound with Priority => 1;
   procedure Play_While_Current(Expected : CarState; Sound : Melody);
   
end Alarm;
