with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with trains; use trains;



procedure Main is

   Str : String (1..10);
   Last : Natural;

   task Start;
   task Parameters;
   task Safety;
   task Emergency is
      pragma Priority(10);
   end Emergency;



   task body Start is
   begin
      loop
         DisplayAll;
         Get_Line(Str, Last);
         case Str(1) is
         when '1' => StartUpTheReactor;
         when '2' => ManualShutDown;
         when '3' => TrainStart;
         when '4' => AddCarriage;
         when '5' => RemovingCarriage;
         when '6' => AddControlRod;
         when '7' => RemovingControlRod;
         when '8' => IncreaseCoolant;
         when '9' => DecreaseCoolant;
         when 'm' => Maintenance;
         when '0' => Restart;
         when others => DisplayAll;
         end case;
      end loop;
   end Start;


  task body Parameters is
  begin
    loop
         if train.trainReactors.currentReactorState = on then IncreaseTemp; CalculatePower; CalculateSpeed; DisplayAll; end if;
         delay 1.0;
      end loop;
   end Parameters;

   task body Safety is
   begin
      loop
         WarningLight;
         delay 0.5;
      end loop;
   end Safety;

   task body Emergency is
   begin
      loop
         EmergencyStop;
         delay 1.0;
      end loop;
   end Emergency;


  begin
    null;
end Main;
