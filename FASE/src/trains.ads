with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;

package Trains with SPARK_Mode
is

   type Temp is range 0..100;
   type ControlRods is range 1..5;
   type WaterSupply is range 1..10;
   type PowerSupply is range 0..10;
   type Carriages is range 0..10;
   type Velocity is range 0..100;
   type ReactorState is (on, off);
   type Lights is (GREEN, AMBER, RED);


   type Reactors is record
      lightState : Lights;
      currentTemp : Temp;
      noControlRods : ControlRods;
      amountOfWater : WaterSupply;
      currentReactorState : ReactorState;
      amountOfPower : PowerSupply ;
   end record;

    type Trains is record
      noCarriages : Carriages;
      currentSpeed : Velocity;
      trainReactors : Reactors;
   end record;


    reactor : Reactors := (lightState => GREEN,
                          currentTemp => Temp'First,
                          noControlRods => 3,
                          amountofWater => 2,
                          currentReactorState => off,
                          amountOfPower => PowerSupply'First);


   train : Trains := (trainReactors => reactor,
                     noCarriages => Carriages'First,
                      currentSpeed => Velocity'First);


   reactorShutDown : Boolean := False;
   reactorNeedsControl : Boolean := False;
   reactorNeedsCoolant : Boolean := False;
   reactorEmer : Boolean := False;
   reactorMaintenance : Boolean := False;
   reactorNotOff : Boolean := False;
   trainStart1 : Boolean := False;
   trainStart2 : Boolean := False;
   trainNeedsReactor : Boolean := False;

   procedure AddControlRod with
     Global => (In_out => (train, Ada.Text_IO.File_System)),
     Pre => train.trainReactors.noControlRods > ControlRods'First and train.trainReactors.noControlRods < ControlRods'Last,
     Post => train.trainReactors.noControlRods = train.trainReactors.noControlRods'Old + 1;

   procedure RemovingControlRod with
     Global => (In_out => (train, Ada.Text_IO.File_System)),
     Pre => train.trainReactors.noControlRods > ControlRods'First and train.trainReactors.noControlRods < ControlRods'Last,
     Post => train.trainReactors.noControlRods = train.trainReactors.noControlRods'Old - 1;

   procedure AddCarriage with
     Global => (In_out => (train, Ada.Text_IO.File_System)),
     Pre => train.noCarriages > Carriages'First and train.noCarriages < Carriages'Last,
     Post => train.noCarriages <= train.noCarriages'OLd + 1;

   procedure RemovingCarriage with
     Global => (In_out => (train, Ada.Text_IO.File_System)),
     Pre => train.noCarriages > Carriages'First and train.noCarriages < Carriages'Last,
     Post => train.noCarriages = train.noCarriages'Old - 1;

   procedure IncreaseCoolant with
     Global => (In_out => (train, Ada.Text_IO.File_System)),
     Pre => train.trainReactors.amountOfWater > WaterSupply'First and train.trainReactors.amountOfWater < WaterSupply'Last,
     Post => train.trainReactors.amountOfWater = train.trainReactors.amountOfWater'Old + 1;

   procedure DecreaseCoolant with
     Global => (In_out => (train, Ada.Text_IO.File_System)),
     Pre => train.trainReactors.amountOfWater > WaterSupply'First and train.trainReactors.amountOfWater < WaterSupply'Last,
     Post => train.trainReactors.amountOfWater = train.trainReactors.amountOfWater'Old - 1;

   procedure IncreaseTemp with
     Global => (In_out => (train, Ada.Text_IO.File_System)),
     Pre => Train.trainReactors.currentTemp > Temp'First and Train.trainReactors.currentTemp < Temp'Last
     and Train.trainReactors.currentTemp < 91,
     Post => train.trainReactors.currentTemp = train.trainReactors.currentTemp'Old + 10;

   procedure WarningLight with
     Global => (In_out => (train)),
     Pre => Train.trainReactors.currentReactorState = on,
     Post => Train.trainReactors.lightState = GREEN or Train.trainReactors.lightState = AMBER or
     Train.trainReactors.lightState = RED;

   procedure EmergencyStop with
     Global => (In_out => (train, reactorEmer)),
     Pre => train.trainReactors.currentTemp >= 95 and train.trainReactors.currentTemp < Temp'Last,
     Post => train.trainReactors.currentTemp = 0 and Train.trainReactors.lightState = GREEN and
             train.trainReactors.amountOfPower = 0 and train.trainReactors.noControlRods = 5 and
             train.trainReactors.amountOfWater = 10 and train.currentSpeed = 0;

   procedure ManualShutDown with
     Global => (In_out => (train, reactorShutDown, reactorNeedsCoolant, reactorNeedsControl, trainStart2)),
     Pre => train.trainReactors.noControlRods >= 3 and Train.trainReactors.amountOfWater >= 2,
     Post => train.trainReactors.currentReactorState = off and train.trainReactors.currentTemp = 0 and
             train.trainReactors.lightState = GREEN and train.trainReactors.amountOfPower = 0 and
             train.currentSpeed = 0;

   procedure StartUpTheReactor with
     Global => (In_out => (train)),
     Pre => train.trainReactors.currentReactorState = off and train.trainReactors.noControlRods = 3
            and train.trainReactors.amountOfWater = 2,
     Post => train.trainReactors.currentReactorState = on;

   procedure TrainStart with
     Global => (In_out => (train, trainStart1, trainStart2, trainNeedsReactor)),
     Pre => train.trainReactors.currentReactorState = on and train.currentSpeed = 0,
     Post => train.currentSpeed = train.currentSpeed'Old + 10;

   procedure CalculatePower with
     Global => (In_out => (train)),
     Pre => train.trainReactors.amountOfPower > PowerSupply'First and train.trainReactors.amountOfPower < PowerSupply'Last
            and train.trainReactors.currentReactorState = on,
     Post => train.trainReactors.amountOfPower >= PowerSupply'First and
             train.trainReactors.amountOfPower <= PowerSupply'Last;

   procedure CalculateSpeed with
     Global => (In_out => (train),
               Input => (trainStart2)),
     Pre => Train.currentSpeed > Velocity'First and Train.currentSpeed < Velocity'Last
            and train.trainReactors.currentReactorState = on,
     Post => Train.currentSpeed >= Velocity'First and Train.currentSpeed <= Velocity'Last;

   procedure CalculateTemperature with
     Global => (In_out => (train)),
     Pre => train.trainReactors.currentTemp > Temp'First and train.trainReactors.currentTemp < Temp'Last
            and train.trainReactors.currentReactorState = on,
     Post => train.trainReactors.currentTemp >= Temp'First and train.trainReactors.currentTemp <= Temp'last;

   procedure DisplayAll with
     Global => (In_out => (Ada.Text_IO.File_System, reactorShutDown, reactorNeedsControl, reactorNeedsCoolant,
                         reactorEmer, trainStart1, trainNeedsReactor, reactorMaintenance, reactorNotOff),
                Input => (Ada.Real_Time.Clock_Time, train));

   procedure Restart with
     Global => (In_out => (train)),
     Post => train.trainReactors.noControlRods = 3 and train.trainReactors.amountOfWater = 2;

   procedure Maintenance with
     Global => (In_out => (reactorMaintenance, reactorNotOff),
                Input => train),
     Pre => train.trainReactors.currentReactorState = off;



end Trains;
