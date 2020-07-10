with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;

package body Trains with SPARK_Mode is


   procedure AddControlRod is
   begin
      if (Train.trainReactors.noControlRods < 5)
      then  Train.trainReactors.noControlRods := Train.trainReactors.noControlRods + 1;
      end if;
      Put_Line("Number of Control Rods is" & Train.trainReactors.noControlRods'Image);
   end AddControlRod;

   procedure RemovingControlRod is
   begin
      if (Train.trainReactors.noControlRods > 1 )
      then Train.trainReactors.noControlRods := Train.trainReactors.noControlRods - 1;
      end if;
      Put_Line("Number of Control Rods is" & Train.trainReactors.noControlRods'Image);
   end RemovingControlRod;


   procedure AddCarriage is
   begin
      if (Train.noCarriages < 10 and  Train.currentSpeed = 0)
      then Train.noCarriages := Train.noCarriages + 1;
      end if;
      Put_Line("Number of Carriages" & Train.noCarriages'Image);
   end AddCarriage;

   procedure RemovingCarriage is
   begin
      if (Train.noCarriages > 0)
      then Train.noCarriages := Train.noCarriages - 1;
      end if;
      Put_Line("Number of Carriages" & Train.noCarriages'Image);
   end RemovingCarriage;

   procedure IncreaseCoolant is
   begin
      if (Train.trainReactors.amountOfWater < 10)
      then Train.trainReactors.amountOfWater := Train.trainReactors.amountOfWater + 1;
      end if;
      Put_Line("Amount of Water" & Train.trainReactors.amountOfWater'Image);
   end IncreaseCoolant;


   procedure DecreaseCoolant is
   begin
      if (Train.trainReactors.amountOfWater > 1)
      then Train.trainReactors.amountOfWater := Train.trainReactors.amountOfWater - 1;
      end if;
      Put_Line("Amount of Water" & Train.trainReactors.amountOfWater'Image);
   end DecreaseCoolant;

   procedure IncreaseTemp is
   begin
      if (Train.trainReactors.currentTemp < 100)
      then Train.trainReactors.currentTemp := Train.trainReactors.currentTemp + 10;
      end if;
      Put_Line("Current Temperature" & train.trainReactors.currentTemp'Image);
   end IncreaseTemp;



   procedure WarningLight is
   begin
      if (Train.trainReactors.currentTemp >= 60 and Train.trainReactors.currentTemp < 80)
      then Train.trainReactors.lightState := AMBER;
      else
         if (Train.trainReactors.currentTemp >= 80)
         then Train.trainReactors.lightState := RED;
         end if;
      end if;
   end WarningLight;

   procedure EmergencyStop is
   begin
      if (Train.trainReactors.currentTemp >= 95 )
      then Train.trainReactors.currentReactorState := off; Train.trainReactors.noControlRods := 5; Train.trainReactors.amountOfWater := 10; Train.currentSpeed := 0;
         Train.trainReactors.currentTemp := 0;
         train.trainReactors.lightState := GREEN;
         train.trainReactors.amountOfPower := 0;
         reactorEmer := True;
      end if;
   end EmergencyStop;



   procedure ManualShutDown is
   begin
      if (Train.trainReactors.noControlRods >= 3 and Train.trainReactors.amountOfWater >= 2)
      then Train.trainReactors.currentReactorState := off;
         Train.trainReactors.currentTemp := 0;
         Train.trainReactors.lightState := GREEN;
         Train.trainReactors.amountOfPower := 0;
         Train.currentSpeed := 0;
         reactorShutDown := True;
         trainStart2 := False;
      else if(Train.trainReactors.noControlRods < 3)
           then reactorNeedsControl := True;
         else if(Train.trainReactors.amountOfWater < 2)
            then
               reactorNeedsCoolant := True;
         end if;
      end if;
      end if;
   end ManualShutDown;

   procedure StartUpTheReactor is
   begin
      if (Train.trainReactors.currentReactorState = off and Train.trainReactors.noControlRods = 3 and Train.trainReactors.amountOfWater = 2)
      then Train.trainReactors.currentReactorState := on;
      end if;
   end StartUpTheReactor;


   procedure TrainStart is
   begin
      if (Train.currentSpeed = 0 and train.trainReactors.currentReactorState = on)
      then Train.currentSpeed := Train.currentSpeed + 10;
         trainStart1 := True;
         trainStart2 := True;
      else
         trainNeedsReactor := True;
      end if;
   end TrainStart;



   procedure CalculatePower is
      power : Integer := 10;
   begin
      power :=  power - Integer((Train.trainReactors.noControlRods * 2));
      Train.trainReactors.amountOfPower := PowerSupply(power);
   end CalculatePower;



   procedure CalculateSpeed is
      speed : Integer := 0;
   begin
      if (Train.trainReactors.currentReactorState = off or trainStart2 = False)
      then speed := 0;
         Train.currentSpeed := Velocity(speed);
      else if(Train.trainReactors.currentReactorState = on)
         then  speed := speed + (Integer((Train.trainReactors.amountOfPower * 10)) - Integer(Train.noCarriages * 5));
            if (speed < 0)
            then Train.currentSpeed := Velocity(0);
            else if (speed >= 0)
            then Train.currentSpeed := Velocity(speed);
               end if;
            end if;
         end if;
      end if;

   end CalculateSpeed;

   procedure CalculateTemperature is
      temperature : Integer := 100;
   begin
      temperature := temperature - Integer((Train.trainReactors.noControlRods * 5)) - Integer(Train.trainReactors.amountOfWater * 10);
      if (temperature < 0)
      then train.trainReactors.currentTemp := Temp(0);
      else if (temperature >= 0)
         then Train.trainReactors.currentTemp := Temp(temperature);
         end if;
      end if;
   end CalculateTemperature;

  procedure Restart is
  begin
      train.trainReactors.noControlRods := 3;
      train.trainReactors.amountOfWater := 2;
   end Restart;

   procedure Maintenance is
   begin
      if(train.trainReactors.currentReactorState = off)
      then reactorMaintenance := True;
      else
         reactorNotOff := True;
      end if;
   end Maintenance;

  procedure DisplayAll is
   begin
      Ada.Text_IO.Put(ASCII.ESC & "[2J");
      Put_Line("Current State of The Train and Reactor:                            Help Options: ");
      Put_Line("-------------------------------------------------------            1. Start Up The Reactor");
      Put_Line ("Train:                                                             2. Manual Shut Down");
      Put_Line ("Current Speed: "&Train.currentSpeed'Image & " mph                                              3. Train Start");
      Put_Line ("Number of Carriages: "&Train.noCarriages'Image &"                                            4. Add Carriage");
      Put_Line("-------------------------------------------------------            5. Remove Carriage");
      Put_Line("Reactor:                                                           6. Add Control Rod");
      Put_Line("Reactor State: " &Train.trainReactors.currentReactorState'Image & "                                                 7. Remove Control Rod");
      Put_Line("Light State: "&Train.trainReactors.lightState'Image & "                                                 8. Increase Coolant");
      Put_Line("Number of Control Rods Inserted: "&Train.trainReactors.noControlRods'Image & "                                9. Remove Coolant");
      Put_Line("Amount of Coolant In Reactor: " &Train.trainReactors.amountOfWater'Image & "                                   m. Reactor Maintenance");
      Put_Line("Current Temp: "&Train.trainReactors.currentTemp'Image & "C                                                  0. Reset Reactor");
      Put_Line("Amount of Power Being Produced: " &Train.trainReactors.amountOfPower'Image & " Mwh");
      Put_Line("-------------------------------------------------------");
      if(reactorShutDown = True)
      then Put_Line("Reactor has been Manually Shut Down Successfully");
          delay 2.0;
          reactorShutDown := False;
         else if(reactorNeedsControl = True)
         then Put_Line("MUST ADD MORE CONTROL RODS FOR MANUAL SHUTDOWN");
            delay 2.0;
            reactorNeedsControl := False;
           else if (reactorNeedsCoolant = True)
            then Put_Line("MUST ADD MORE COOLANT FOR MANUAL SHUTDOWN");
                delay 2.0;
               reactorNeedsCoolant := False;
            end if;
         end if;
      end if;
      if (reactorEmer = True)
      then Put_Line("EMERGENCY! Reactor Shutting Down, Temperature exceeded max operating temp: 95C" );
         delay 2.0;
         reactorEmer := False;
      end if;
      if (trainStart1 = True)
      then Put_Line("The Train Has Started Moving Successfully");
         delay 2.0;
         trainStart1 := False;
         else if(trainNeedsReactor = True)
         then Put_Line("Reactor Needs To Be Turned On First");
            delay 2.0;
            trainNeedsReactor := False;
         end if;
      end if;
      if (reactorMaintenance = True)
      then Put_Line("Reactor Is Under Maintanence");
              delay 5.0;
            Put_Line("Reactor Maintanence Complete");
            delay 2.0;
            reactorMaintenance := False;
         else if (reactorNotOff = True)
            then Put_Line("Reactor Needs To Be Shut Down For Maintancence, Please Follow Shut Down Procedures");
               delay 2.0;
                 reactorNotOff := False;
         end if;
      end if;
      Put_line("Enter what you want to do:");
   end DisplayAll;



end Trains;

