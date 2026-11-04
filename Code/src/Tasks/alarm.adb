with Ada.Real_Time; use Ada.Real_Time;
with Controller; use Controller;
with MicroBit.Music; use MicroBit.Music;
with MicroBit.Console; use MicroBit.Console;
with Ada.Execution_Time; use Ada.Execution_Time;

package body Alarm is
   AlarmFront : constant Melody := ((G5, 25), (C5, 50), (F5, 50), (A5, 25));
   AlarmRight : constant Melody := ((B4, 25), (A4, 50), (B4, 25), (A4, 50));
   AlarmLeft : constant Melody := ((DS5, 50), (CS5, 25), (DS5, 50), (FS5, 25));
   Check_Interval : constant Time_Span := Milliseconds (300); -- was initially 10ms, then 50ms

   -- Use the pitch overload, not the blocking note/melody overloads.
   -- Only this task owns audio output. MotorController is read briefly,
   -- and no protected operation contains playback or a delay.
   procedure Play_While_Current (Expected : CarState; Sound : Melody) is
      Note_End, Wake_At, Now : Time;
   begin

      for N of Sound loop
         exit when MotorController.GetState /= Expected;
         MicroBit.Music.Play (27, N.P);
         Note_End := Ada.Real_Time.Clock + Milliseconds (N.Ms);
         loop
            exit when MotorController.GetState /= Expected;
            Now := Ada.Real_Time.Clock;
            exit when Now >= Note_End;
            Wake_At := Now + Check_Interval;

            if Wake_At > Note_End then
               Wake_At := Note_End;
            end if;

            delay until Wake_At;
         end loop;
      end loop;
      MicroBit.Music.Play (27, Rest);
   end Play_While_Current;

   task body PlaySound is

      Current_State : CarState;
      Previous_State : CarState := Idle;

      CurrentTime, EndTime : Time;
      StartCPU, StopCPU : CPU_Time;
      Elapsed_Time, Elapsed_CPU : Time_Span;

   begin
      MicroBit.Music.Play (27, Rest);
      loop

        CurrentTime := Clock;
        StartCPU := Clock;

         Current_State := MotorController.GetState;
         if Current_State /= Previous_State then
            Previous_State := Current_State;
            case Current_State is
               when ForwardCol =>
                  Play_While_Current (Current_State, AlarmFront);
               when RightCol =>
                  Play_While_Current (Current_State, AlarmRight);
               when LeftCol =>
                  Play_While_Current (Current_State, AlarmLeft);
               when Idle | Driving =>
                  MicroBit.Music.Play (27, Rest);
            end case;
         end if;
         -- No catch-up loop or pending melody queue. Always re-read the
         -- effective state, including watchdog/reading expiry, on waking.

         EndTime := Clock;
         StopCPU := Clock;

         Elapsed_Time := EndTime - CurrentTime;
         Elapsed_CPU := StopCPU - StartCPU;

         --  Put_Line("AlarmTask Elapsed Time: " & Duration'Image(To_Duration(Elapsed_Time)) & " seconds");
         --  Put_Line("AlarmTask CPU Time: " & Duration'Image(To_Duration(Elapsed_CPU)) & " seconds");


         delay until Ada.Real_Time.Clock + Check_Interval;
      end loop;
   end PlaySound;
end Alarm;
