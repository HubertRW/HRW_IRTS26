with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;
with Brain; use Brain;
with Controller; use Controller;
with Think; use Think;
with Sensor_Filter;

procedure Snapshot_Pipeline_Test is
   Base : constant Time := Clock;
   Data, Copy : SensorData;
   Choice : Decision;
   Values : constant array (Positive range <>) of sensor_distance :=
     [0, 1, 2, 10, 11, 400];
   Expected : CarState;
   Cases : Natural := 0;

   procedure Publish_Clear is
   begin
      for Sensor in Sensor_Id loop
         BrainData.Update
           (Sensor, (Distance => 100, Recorded_At => Base,
                     Valid_Until => Base + Milliseconds (300)));
      end loop;
   end Publish_Clear;
begin
   -- The native test exercises Think's real decision implementation directly.
   -- Stop its periodic task so this test controls updates and can terminate.
   -- This test-only abort is not part of the embedded application.
   abort Think.ThinkTask;
   while not Think.ThinkTask'Terminated loop
      delay until Clock + Milliseconds (1);
   end loop;

   -- This call must return before any publication, not wait for a producer.
   BrainData.Get (Data);
   for Sensor in Sensor_Id loop
      pragma Assert (Data (Sensor).Distance = 0);
      pragma Assert (not Is_Fresh (Data (Sensor), Base));
   end loop;
   Choice := Evaluate (Data, Base, 10);
   pragma Assert (Choice.State = Idle);
   Put_Line ("PASS: empty snapshot returns immediately and startup is Idle");

   BrainData.Update
     (Front, (5, Base, Base + Milliseconds (300)));
   BrainData.Get (Data);
   Choice := Evaluate (Data, Base, 10);
   pragma Assert (Choice.State = Idle, "Partial startup cannot permit movement");
   Publish_Clear;
   BrainData.Get (Data);
   BrainData.Get (Copy);
   pragma Assert (Data = Copy, "Reads do not consume the snapshot");
   Choice := Evaluate (Data, Base, 10);
   pragma Assert (Choice.State = Driving);

   -- More writes than the previous queue capacity, with no intervening reads.
   for I in 1 .. 10_000 loop
      BrainData.Update
        (Front, (sensor_distance (2 + I mod 399),
                 Base + Microseconds (I), Base + Milliseconds (300)));
   end loop;
   BrainData.Get (Copy);
   pragma Assert (Copy (Front).Distance = 2 + 10_000 mod 399);
   pragma Assert (Copy (Front).Recorded_At = Base + Microseconds (10_000));
   pragma Assert (Copy (Right) = Data (Right));
   pragma Assert (Copy (Left) = Data (Left));
   Put_Line ("PASS: partial startup, repeated Get, 10000 overwrites, independent directions");

   -- A front update is usable before the next right/left updates arrive.
   Publish_Clear;
   BrainData.Update (Front, (5, Base + Milliseconds (100),
                               Base + Milliseconds (400)));
   BrainData.Get (Data);
   Choice := Evaluate (Data, Base + Milliseconds (100), 10);
   pragma Assert (Choice.State = ForwardCol);
   pragma Assert (Choice.Valid_Until = Base + Milliseconds (300));
   Choice := Evaluate (Data, Base + Milliseconds (300), 10);
   pragma Assert (Choice.State = Idle,
                  "Updating front must not refresh expired side sensors");
   for Sensor in Sensor_Id loop
      Publish_Clear;
      BrainData.Update (Sensor, (0, Base, Base + Milliseconds (300)));
      BrainData.Get (Data);
      pragma Assert (Evaluate (Data, Base, 10).State = Idle);
      BrainData.Update (Sensor, (100, Base + Milliseconds (1),
                                    Base + Milliseconds (301)));
      BrainData.Get (Data);
      pragma Assert (Evaluate (Data, Base, 10).State = Idle,
                     "Future-dated readings are not fresh");
      BrainData.Update (Sensor, (100, Base, Base));
      BrainData.Get (Data);
      pragma Assert (Evaluate (Data, Base, 10).State = Idle);
   end loop;
   Put_Line ("PASS: early obstacle publication, exact expiry, zero and future-date rejection");

   -- Exercise the actual Think decision function across all distance branches.
   for F of Values loop
      for R of Values loop
         for L of Values loop
            Data := [Front => (F, Base, Base + Milliseconds (300)),
                     Right => (R, Base, Base + Milliseconds (300)),
                     Left => (L, Base, Base + Milliseconds (300))];
            if F < 2 or else R < 2 or else L < 2 then
               Expected := Idle;
            elsif F <= 10 then
               Expected := ForwardCol;
            elsif R <= 10 then
               Expected := RightCol;
            elsif L <= 10 then
               Expected := LeftCol;
            else
               Expected := Driving;
            end if;
            pragma Assert (Evaluate (Data, Base, 10).State = Expected);
            Cases := Cases + 1;
         end loop;
      end loop;
   end loop;
   Put_Line ("PASS: decision combinations" & Cases'Image);

   for Sensor in Sensor_Id loop
      BrainData.Update
        (Sensor, (2, Base + Microseconds (2), Base + Milliseconds (300)));
   end loop;
   declare
      protected Outcome is
         procedure Fail;
         function Failed return Boolean;
      private
         Error : Boolean := False;
      end Outcome;
      protected body Outcome is
         procedure Fail is
         begin
            Error := True;
         end Fail;
         function Failed return Boolean is (Error);
      end Outcome;
   begin
      declare
         task Producer;
         task type Reader;
         First_Reader, Second_Reader : Reader;

         task body Producer is
            Distance : sensor_distance;
         begin
            for I in 1 .. 10_000 loop
               Distance := 2 + I mod 399;
               for Sensor in Sensor_Id loop
                  BrainData.Update
                    (Sensor, (Distance, Base + Microseconds (Distance),
                              Base + Milliseconds (300)));
               end loop;
            end loop;
         exception
            when others => Outcome.Fail;
         end Producer;

         task body Reader is
            Snapshot : SensorData;
         begin
            for I in 1 .. 20_000 loop
               BrainData.Get (Snapshot);
               for Sample of Snapshot loop
                  pragma Assert
                    (Sample.Recorded_At = Base + Microseconds (Sample.Distance),
                     "A reading's distance and timestamp must be copied together");
                  pragma Assert (Sample.Valid_Until = Base + Milliseconds (300));
               end loop;
            end loop;
         exception
            when others => Outcome.Fail;
         end Reader;
      begin
         null;
      end;
      -- The nested block waits for all three dependent tasks to terminate.
      pragma Assert (not Outcome.Failed, "Concurrent snapshot access failed");
   end;
   Put_Line ("PASS: concurrent 30000 updates and 40000 snapshot reads, no torn readings");

   -- Exercise the same public operation called by the embedded Think task,
   -- including its configured threshold and actual Controller update.
   declare
      Now : constant Time := Clock;
   begin
      for Sensor in Sensor_Id loop
         BrainData.Update (Sensor, (100, Now, Now + Milliseconds (300)));
      end loop;
      Think.SelectState;
      pragma Assert (MotorController.GetState = Driving);
      BrainData.Update (Front, (Think.Threshold, Now, Now + Milliseconds (300)));
      Think.SelectState;
      pragma Assert (MotorController.GetState = ForwardCol);
      BrainData.Update (Front, (Think.Threshold + 1, Now,
                               Now + Milliseconds (300)));
      Think.SelectState;
      pragma Assert (MotorController.GetState = Driving);
      BrainData.Update (Right, (Think.Threshold, Now, Now + Milliseconds (300)));
      Think.SelectState;
      pragma Assert (MotorController.GetState = RightCol);
      BrainData.Update (Right, (100, Now, Now + Milliseconds (300)));
      BrainData.Update (Left, (Think.Threshold, Now, Now + Milliseconds (300)));
      Think.SelectState;
      pragma Assert (MotorController.GetState = LeftCol);
      BrainData.Update (Left, (0, Now, Now + Milliseconds (300)));
      Think.SelectState;
      pragma Assert (MotorController.GetState = Idle);
      BrainData.Update (Left, (100, Now - Milliseconds (300), Now));
      Think.SelectState;
      pragma Assert (MotorController.GetState = Idle);
   end;
   Put_Line ("PASS: Think.SelectState uses configured threshold, all branches and freshness");

   -- The real Controller must stop at sensor expiry even if Think stops running.
   declare
      Now : constant Time := Clock;
   begin
      for Sensor in Sensor_Id loop
         BrainData.Update (Sensor, (100, Now, Now + Milliseconds (30)));
      end loop;
      BrainData.Get (Data);
      Choice := Evaluate (Data, Now, 10);
      MotorController.SetState (Choice.State, Choice.Valid_Until);
      pragma Assert (MotorController.GetState = Driving);
      delay until Now + Milliseconds (50);
      pragma Assert (MotorController.GetState = Idle);
      for Sensor in Sensor_Id loop
         BrainData.Update
           (Sensor, (100, Clock, Clock + Sensor_Filter.Max_Age));
      end loop;
      BrainData.Get (Data);
      Choice := Evaluate (Data, Clock, 10);
      MotorController.SetState (Choice.State, Choice.Valid_Until);
      pragma Assert (MotorController.GetState = Driving);
      MotorController.SetState (Idle);
   end;
   Put_Line ("PASS: snapshot -> production decisions -> Controller expiry and recovery");
end Snapshot_Pipeline_Test;
