#include <Drv8860.h>
#include <Tsunami.h>            // Include the Tsunami library header
#include <Wire.h>

//=====[drv8860 ]============================================================
const int numDaisy  = 4;
Drv8860 valveDriver(46, 47, numDaisy, false);

//=====[PINS ]============================================================

const int numOdor  = 10;

int odorSourcePins[] = {6, 7, 8, 9, 10, 16, 17, 18, 19, 20};       //the upstream valve to the odor vial
int odorSourcePinsExh[] = {11, 12, 13, 14, 15, 21, 22, 23, 24, 25}; // the downstream (exhaust) valve to the odor vial

int odorVacPin  = 1;
int odorLocPins[] = {0, 36, 34, 32, 30, 28};

int IRLocPins[]  = {A0, A1, A2, A3, A4, A5, A6, A7};
int LEDLocPins[] = {42, 43, 44, 53,  4,  3, 2, 14};

int REWLocPins[] = {12, 11, 10, 9, 8, 7, 6, 5};

//set high when there is an olfacotory command
int odorTriggerPin = 35;

//                ------------BNC-----------------|----------wire terminal-----------
//                       1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
int  GPIOPins[] =       {41, 39, 37, 35, 40, 38, 36, 34, 33, 31, 29, 27, 32, 30, 28, 26};
//                      PG0 PG2 PC0 PC2 PG1 PD7 PC1 PC3 PC4 PC6 PA7 PA5 PC5 PC7 PA6 PA4
bool GPIOinput[] =     { 0,  0,  0,  0,  1,  1,  1,  0,  0,  0,  0,  1,  1,  1,  1,  1}; //is that pin idicates whether the pin is an output or an input
int  GPIOstate[] =     { 0,  0,  0,  0,  0,  0,  0,  0, 0,  0,  0,  0,  0,  0,  0,  0};  //stores the state
int  GPIOprevstate[] = { 0,  0,  0,  0,  0,  0,  0,  0, 0,  0,  0,  0,  0,  0,  0,  0};  //stores the prevstate
//                                                   ^
//                                                   currently used to test loop speed
bool loopSpeedState = 0;

int GPOlocation = 0;
int GPOValue    = 0;

//=====[ CONSTANTS ]============================================================
#define   DEBUG   1   // 0 = debugging disabled, 1 = enabled
#define VER  5.1        // version number
// 1.1 UPDATED PINS FOR PCB OLFACTORY_CONTROL_V1
// 2.0 integrating new megabase staion hardware
// 3.0 adding I2C capability
// 4.0 adding shift out syn stratergy
// 5.0 full I2C syn stratergy
// 5.1 added extra reward locations

const int bSize = 34;

//=====[ VARIABLES ]============================================================

char Buffer[bSize];  // Serial buffer
char BufferI2C[bSize];  // i2c buffer

char Command[4];    // 3 character command (+nul terminator)
int ByteCount;

int odorSource;
int odorLocation;

int REWstate = 0;
int REWduration  = 0;
int long REWtime = 0;
int REWlocation = 0;

int LEDcount = 0;
int LEDstate = 0;
int LEDlocation = 0;
unsigned long  LEDtime = 0;
int LEDinterval = 0;

int IRstate[]     = {0, 0, 0, 0, 0, 0, 0, 0};
int IRprevstate[] = {0, 0, 0, 0, 0, 0, 0, 0};
int IRremotestate[] = {0, 0, 0, 0, 0, 0, 0, 0};                         // the last state send out as a packet
int long IRlastChange[] = {0, 0, 0, 0, 0, 0, 0, 0};                     //for an IR debounce
int IRdeboucneTime[] = {20, 20, 20, 20, 20, 20, 20, 20};                       // time in ms for for off debounce
bool IRDebounceWindow[] = {false, false, false, false, false, false, false, false}; // if we are in a down deounce period

Tsunami tsunami;                // Our Tsunami object
char gTsunamiVersion[VERSION_STRING_LEN];    // Tsunami version string
int TONtrack    = 0;
int TONlocation = 0;
int TONrun = 0;
int TONloop = 0;
int TONMod = 0;
int TONModValue = 0;

//I2C configuration
bool i2cTransmit = true;
int i2cAddress = 0;
char i2cCharBuf[16];
int i2cGPIOGate = 15-1; //the index of teh GPIO input that must be high for the I2C packet to be sent
int i2cGPIOGateExcpt = 16-1; //the index of teh GPIO input that is exempt from the gate

//shift out based sync
int SYNtype = 0;
int SYNvalue = 0;
int SYNdataPin = 39;   //bnc 2
int SYNclockPin = 37;  //bnc 3

void setup() {
  //intialise the serial communication
  Serial.begin(115200);
  delay(10);
  Serial.print("STA,");
  Serial.println(VER);

  // initialise the I2C bus as the master

  if (i2cTransmit) {
    Wire.begin(); // join i2c bus (address optional for master)
  }


  // set the pins for the ofactory channels
  valveDriver.begin();

  //set the location pins
  for (int i = 0; i < 8; i++) {
    // now handled by the drv8860
    //    pinMode(odorLocPins[i], OUTPUT);
    //    digitalWrite(odorLocPins[i], LOW);

    pinMode(LEDLocPins[i], OUTPUT);
    digitalWrite(LEDLocPins[i], LOW);

    pinMode(REWLocPins[i], OUTPUT);
    digitalWrite(REWLocPins[i], LOW);

    pinMode(IRLocPins[i], INPUT_PULLUP);
    //digitalWrite(IRLocPins[i], HIGH);
  }

  //set the GPIOpins
  for (int i = 0; i < 16; i++) {
    if (GPIOinput[i]) {
      pinMode(GPIOPins[i], INPUT_PULLUP);
    } else {
      pinMode(GPIOPins[i], OUTPUT);
      Serial.print("GPIO,");
      Serial.print(i + 1);
      Serial.print(",");
      Serial.println(2);
    }
  }

  //set the syn  pins
  pinMode(SYNdataPin, OUTPUT);
  pinMode(SYNclockPin, OUTPUT);

  // Tsunami startup at 57600 on hardware serial port #1
  tsunami.start();
  delay(10);
  // Send a stop-all command and reset the sample-rate offset, in case we have
  //  reset while the Tsunami was already playing.
  tsunami.stopAllTracks();
  tsunami.samplerateOffset(0, 0);
  // Allow time for the Tsunami to respond with the version string and
  //  number of tracks.
  delay(100);
  tsunami.masterGain(0, 0);              // Reset the master gain to 0dB



}

void loop() {
  SerialParser();
  processOLF();
  processREW();
  processLED();
  processTON();
  processMOD();
  checkIR();
  checkGPIO();
  processGPO();
  processSYN();
  driveLoopClock();
}

void SerialParser(void) {
  if (Serial.available() > 0) {
    ByteCount = -1;
    ByteCount =  Serial.readBytesUntil('\n', Buffer, bSize);
    strcpy(BufferI2C,Buffer);
    
    //Serial.println(ByteCount);
    strcpy(Command, strtok(Buffer, ","));
    Command[3] = '\0';                      //null to make into a string

    if (ByteCount  > 0) {

      if (strcmp(Command, "OLF") == 0) {           //OLF command//
        odorLocation =  atoi(strtok(NULL, ","));
        odorSource   =  atoi(strtok(NULL, ","));
      }
      if (strcmp(Command, "LED") == 0) {          //LED command//
        LEDlocation = atoi(strtok(NULL, ","));
        LEDinterval = atoi(strtok(NULL, ","));
        LEDcount = atoi(strtok(NULL, ","));
      }
      if (strcmp(Command, "REW") == 0)  {
        REWlocation = atoi(strtok(NULL, ","));
        REWduration = atoi(strtok(NULL, ","));
      }
      if (strcmp(Command, "TON") == 0)  {
        TONtrack    = atoi(strtok(NULL, ","));
        TONlocation = atoi(strtok(NULL, ","));
        TONrun = atoi(strtok(NULL, ","));
        TONloop =  atoi(strtok(NULL, ","));
      }
      if (strcmp(Command, "MOD") == 0)  {
        TONMod = atoi(strtok(NULL, ","));
        TONlocation = atoi(strtok(NULL, ","));
        TONModValue = atoi(strtok(NULL, ","));
      }
      if (strcmp(Command, "GPO") == 0)  {
        GPOlocation = atoi(strtok(NULL, ","));
        GPOValue = atoi(strtok(NULL, ","));
      }
      if (strcmp(Command, "SYN") == 0)  {
        SYNtype = atoi(strtok(NULL, ","));
        SYNvalue = atoi(strtok(NULL, ","));
      }
      Serial.flush();
      memset(Buffer, 0, sizeof(Buffer));   // Clear contents of Buffer

    }
  }

}
//sets the appropriate pins for an olfactory command
void processOLF(void) {
  if (strcmp(Command, "OLF") == 0) {

    Serial.print("CON,OLF,");
    Serial.print(odorLocation);
    Serial.print(',');
    Serial.println(odorSource);

    ///set the source of the odor///
    for (int i = 0; i < 8; i++) {                    //set the defaults
      //digitalWrite(odorSourcePins[i], LOW);
      valveDriver.updateValveData(odorSourcePins[i], LOW);
      valveDriver.updateValveData(odorSourcePinsExh[i], LOW);
    }
    valveDriver.updateValveData(odorVacPin, LOW);

    // set the correct odour  channel on
    if (odorSource > 0) {
      valveDriver.updateValveData(odorSourcePins[odorSource - 1], HIGH);
      valveDriver.updateValveData(odorSourcePinsExh[odorSource - 1], HIGH);
    } else if (odorSource < 0) {
      valveDriver.updateValveData(odorVacPin, HIGH);
    }

    ///set the locations of the odor///
    for (int i = 0; i < 6; i++) {                 //set the defaults
      valveDriver.updateValveData(odorLocPins[i], LOW);
    }

    if (odorLocation > 0) {
      valveDriver.updateValveData(odorLocPins[odorLocation - 1], HIGH);   //set the location
    }

    //valveDriver.printValveData(); //prints to the serial port for debugging

    //send the command out to the driver chip
    sendBufferI2C();
    digitalWrite(odorTriggerPin, HIGH);
    valveDriver.sendValveData();
    digitalWrite(odorTriggerPin, LOW);
    //
    strcpy(Command, "000");


  }
}

void processREW(void) {
  if (strcmp(Command, "REW") == 0) {
    Serial.print("CON,REW,");
    Serial.print(REWduration);
    Serial.print(',');
    Serial.println(REWlocation);
    sendBufferI2C();

    for (int i = 0; i < 8; i++) {                 //set the defaults
      digitalWrite(REWLocPins[i], LOW);
    }
    if (REWlocation > 0) {
      digitalWrite(REWLocPins[REWlocation - 1], HIGH);
    }

    REWtime = millis();
    REWstate = 1;    //set the REWstate to 1;
    strcpy(Command, "000");

  } else if (REWstate == 1) {
    if ((millis() - REWtime) > REWduration ) {
      if (REWlocation > 0) {
        digitalWrite(REWLocPins[REWlocation - 1], LOW);
      }
      REWstate = 0;
    }
  }
}

void processLED(void) {
  if (strcmp(Command, "LED") == 0) {
    Serial.print("CON,LED,");
    Serial.print(LEDlocation);
    Serial.print(',');
    Serial.print( LEDinterval );
    Serial.print(',');
    Serial.println(LEDcount);
    sendBufferI2C();

    strcpy(Command, "000");
    if (LEDcount == 0) {
      digitalWrite(LEDLocPins[LEDlocation - 1], LOW);
    }
    //set all the other LED PINS to off
    for (int i = 0; i < 8; i++) {
      digitalWrite(LEDLocPins[i], LOW);
    }

  }
  if (LEDcount != 0) {
    flash(LEDLocPins[LEDlocation - 1], &LEDtime, LEDinterval, &LEDstate, &LEDcount);
    if (LEDcount == 0) {
      digitalWrite(LEDLocPins[LEDlocation - 1], LOW);

    }
  }
}

void processTON(void) {
  if (strcmp(Command, "TON") == 0) {
    Serial.print("CON,TON,");
    Serial.print(TONtrack);
    Serial.print(',');
    Serial.print(TONlocation);
    Serial.print(',');
    Serial.print(TONrun);
    Serial.print(',');
    Serial.println(TONloop);
    sendBufferI2C();

    tsunami.trackLoop(TONtrack, TONloop);
    //turn on tracks
    if (TONrun == 1) {

      if (TONloop == 1) {
        tsunami.trackLoop(TONtrack, true);
      } else {
        tsunami.trackLoop(TONtrack, false);
      }

      if (TONlocation == 0) {
        //not implemented yet, play at all locations
      } else {
        //just play the track at a certain locaion
        tsunami.trackPlayPoly(TONtrack, TONlocation - 1, true);
      }

      //turn off tracks
    } else if (TONrun == 0) {
      if (TONlocation == 0) {
        //turn off (all? tracks for all locations)
        tsunami.stopAllTracks();

      } else {
        //unfourtunately this stops this track for all the locations
        //and leaves other tracks possbily running at this location
        tsunami.trackStop(TONtrack);
      }
    }
    strcpy(Command, "000");
  }
}

void processMOD(void) {
  if (strcmp(Command, "MOD") == 0) {
    Serial.print("CON,MOD,");
    Serial.print(TONMod);
    Serial.print(',');
    Serial.print(TONlocation);
    Serial.print(',');
    Serial.println(TONModValue);
    sendBufferI2C();

    if (TONMod == 1) {
      tsunami.masterGain(0, TONModValue);
    } else if (TONMod == 2) {
      tsunami.samplerateOffset(0, TONModValue);
    }

    strcpy(Command, "000");
  }

}

void checkIR(void) {
  for (int i = 0; i < 8; i++) {
    IRstate[i] = digitalRead(IRLocPins[i]);

    if (IRstate[i] != IRprevstate[i]) {
      if (IRstate[i] == 1) {
        if (IRremotestate[i] == 0) {
          IRremotestate[i] = IRstate[i];
          Serial.print("IRB,");
          Serial.print(i + 1);
          Serial.print(",");
          Serial.println(IRstate[i]);

          if (i2cTransmit && GPIOstate[i2cGPIOGate] == 1) {
            Wire.beginTransmission(i2cAddress); // transmit to scanimage
            Wire.write("IRB,");
            Wire.write(itoa(i + 1, i2cCharBuf, 10));
            Wire.write(",");
            Wire.write(itoa(IRstate[i], i2cCharBuf, 10));
            Wire.endTransmission();     // stop transmitting
          }
        }
        IRprevstate[i] = IRstate[i];
        IRDebounceWindow[i] = false;
        
      } else if(IRstate[i] == 0) {
        IRlastChange[i] = millis();
        IRprevstate[i] = IRstate[i];
        IRDebounceWindow[i] = true;
      }
      
      //
    } else if (IRDebounceWindow[i]) {
      if (IRremotestate[i] == 1 && IRstate[i] == 0  && millis() - IRlastChange[i] > IRdeboucneTime[i]) {
        IRremotestate[i] = IRstate[i];
        Serial.print("IRB,");
        Serial.print(i + 1);
        Serial.print(",");
        Serial.println(IRstate[i]);
        if (i2cTransmit && GPIOstate[i2cGPIOGate] == 1) {
          Wire.beginTransmission(i2cAddress); // transmit to scanimage
          Wire.write("IRB,");
          Wire.write(itoa(i + 1, i2cCharBuf, 10));
          Wire.write(",");
          Wire.write(itoa(IRstate[i], i2cCharBuf, 10));
          Wire.endTransmission();     // stop transmitting
        }
        IRDebounceWindow[i] = false;
      }
    }
  }
}

void checkGPIO(void) {
  for (int i = 0; i < 16; i++) {
    if (GPIOinput[i]) {
      GPIOstate[i] = digitalRead(GPIOPins[i]);
      if (GPIOstate[i] != GPIOprevstate[i]) {
        Serial.print("GPIO,");
        Serial.print(i + 1);
        Serial.print(",");
        Serial.println(GPIOstate[i]);
        GPIOprevstate[i] = GPIOstate[i];
        if (i2cTransmit &&  (GPIOstate[i2cGPIOGate] == 1 || i == i2cGPIOGate || i == i2cGPIOGateExcpt)) {
          Wire.beginTransmission(i2cAddress); // transmit to scanimage
          Wire.write("GPIO,");
          Wire.write(itoa(i + 1, i2cCharBuf, 10));
          Wire.write(",");
          Wire.write(itoa(GPIOstate[i], i2cCharBuf, 10));
          Wire.endTransmission();     // stop transmitting
        }
      }
    }
  }
}
void processGPO() {
  if (strcmp(Command, "GPO") == 0) {

    Serial.print("CON,GPO,");
    Serial.print(GPOlocation);
    Serial.print(',');
    if (GPOlocation < 1 | GPOlocation > 16) {
      Serial.println(3); //out of range location
    } else {
      if  (GPIOinput[GPOlocation - 1]) {
        Serial.println(2); //tried to set an input as an output
      } else {
        digitalWrite(GPIOPins[GPOlocation - 1], GPOValue);
        Serial.println(GPOValue);
      }
    }
    sendBufferI2C();
    strcpy(Command, "000");
  }
}
void processSYN() {
  if (strcmp(Command, "SYN") == 0) {
    Serial.print("CON,SYN,");
    Serial.print(SYNtype);
    Serial.print(',');
    Serial.println(SYNvalue);
    sendBufferI2C();
    strcpy(Command, "000");

    // commented since we are using the I2C sync
    //    //only support trial number reporting as of now
    //    if (SYNtype == 1) {
    //      if (SYNvalue <= 255) {
    //        shiftOutEdge(SYNdataPin, SYNclockPin, LSBFIRST, SYNvalue);
    //      } else {
    //        shiftOutEdge(SYNdataPin, SYNclockPin, LSBFIRST, SYNvalue);
    //        shiftOutEdge(SYNdataPin, SYNclockPin, LSBFIRST, SYNvalue >> 8);
    //      }
    //    }

  }
}

void driveLoopClock() {
  if (loopSpeedState == 1) {
    loopSpeedState = 0;
    digitalWrite(34, HIGH);
  } else {
    loopSpeedState = 1;
    digitalWrite(34, LOW);
  }
}

///helper functions (not called directly from main look)
void sendBufferI2C() {
  if (i2cTransmit && GPIOstate[i2cGPIOGate] == 1) {
    Wire.beginTransmission(i2cAddress); // transmit to scanimage
    for (int i = 0; i < ByteCount; i++) {
      Wire.write(BufferI2C[i]);
    }
    Wire.endTransmission();     // stop transmitting
  }
}


//this function does a non delay based flash using a timer, a state and a counter
//the imputs are all pointers so that we can pass by reference and update all the requisite variables
void flash(int pin, unsigned long * clockr, int interval, int *state, int *count) {

  //there are remaining flashes to do
  if (*count != 0) {
    if ((millis() - *clockr) >= interval) { //it is time to change state

      if (*state) {                          //pin is currently High
        digitalWrite(pin, LOW);           //set it low
        *clockr = millis();                 //reset the clock
        *state = 0;                           //set the state
        *count = *count - 1;                   //count down the counter
      }
      else {                                 //pin is currently low
        digitalWrite(pin, HIGH);           //set it low
        *clockr = millis();                 //reset the clock
        *state = 1;                           //set the state
        //do not count down the counter
      }
    }

    if (*count == 0) {
      //we just turned off pin for the last time, we should send the confirm flash stop command
    }
    if (*count < 0) {
      *count = -1;  //Prvents overflow
    }
  }
}

//based on teh shiftOut function, but to shift a byte out
//when you can only detect rising edges.
void shiftOutEdge(uint8_t dataPin, uint8_t clockPin, uint8_t bitOrder, uint8_t val)
{
  uint8_t i;
  bool bitVal;

  for (i = 0; i < 8; i++)  {
    digitalWrite(clockPin, HIGH);

    if (bitOrder == LSBFIRST) {
      bitVal = !!(val & (1 << i));
    } else {
      bitVal = !!(val & (1 << (7 - i)));
    }

    if (bitVal) {
      digitalWrite(dataPin, HIGH);
      digitalWrite(dataPin, LOW);
    }
    digitalWrite(clockPin, LOW);
  }
}


