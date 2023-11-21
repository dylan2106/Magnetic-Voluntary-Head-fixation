#include <Wire.h>
#include <Adafruit_ADS1015.h>
Adafruit_ADS1015 ads;     /* Use thi for the 12-bit version */
int16_t adc0;

#include "Adafruit_MCP23017.h"
Adafruit_MCP23017 mcp;
Adafruit_MCP23017 mcp1;

#define CLR(x,y) (x&=(~(1<<y)))
#define SET(x,y) (x|=(1<<y))

int highThres = 970;
int lowThres = 50;

int inputPin[8] = {A0, A1, A2, A3, A4, A5, A6, A7};
int inputTypeHigh[8] = {0, 1, 0, 1, 0, 1, 0, 1};
int inputValue[8];
int inputValueRaw[8];
int inputTestStateRaw = 0;    
int inputTestStateRawPrev = 0;    
int inputTestState = 0;    //compare the inputValue to the thres 
int inputTestStatePrev = 0;
int inputLEDpin[8] = {7, 6, 5, 4, 3, 2, 22, 23};

// switches on the remote board
uint8_t inputOverrideState = 0;
int inputOverridePin[8] = {8, 9, 10, 11, 12, 13, 14, 15};
uint8_t bearingNoutputOverrideState = 0;
int bearingNoutputOverridePin[8] = {8, 9, 10, 11, 12, 13, 14, 15};

long loopInd = 0;
long sampleRemoteEvery = 100;

int adjVoltagePin = A8;
int adjVoltageVal = 0;

boolean localLEDdisp = true;
int localLEDdispPin = 27;

int bearingState[4] = {0, 0, 0, 0};
int bearingOutput[4] = {0, 0, 0, 0};
//// brearing is for each bearing (yellow light - 4x) the pins that need to be pulled low (or high) that bearing to be triggered
//int bearingOutTrig [4] = {1 << 0 | 1 << 1 | 1 << 5,
//                          1 << 2 | 1 << 3,
//                          1 << 4,
//                          1 << 6 | 1 << 7
//                         };
int bearingOutTrig [4] = {1 << 0 | 1 << 1 | 1 << 2 ,
                          1 << 4 | 1 << 5,
                          1 << 6,
                          1 << 7
                         };
//int bearingOutTrig [4] = {1 << 0 | 1 << 1,
//                          1 << 2 | 1 << 3,
//                          1 << 4,
//                          1 << 6 | 1 << 7
//                         };

//int bearingOutTrig [4] = {0,
//                          1 << 2 | 1 << 3,
//                          1 << 4,
//                          1 << 6 | 1 << 7
//                         };


boolean testResult = false;

int outputPins[]    = {11, 9};
int outputLedPins[] = {10, 8};
int outputState[] = {0, 0};   // the state of the two outputs (after debouncing)
int outputStatePrev[] = {0, 0};   // the state of the two outputs (after debouncing) prev loop

int outputInd;

//this is an off debounce for the output
unsigned long lastDebounceTime[] = {0, 0};  // the last time the output pin was toggled
unsigned long debounceDelay[] = {0, 0};    // the debounce time; increase if the output flickers
boolean  debounceReadPot = true;           // if true, the debounce delay on the output pin to be read from an potentiometer
//int debouncePotPin = A14;
boolean debounceWindow[] = {false, false};
long debounceReadLoopCounter = 0;
long debounceReadEvery = 1000;   //only read the debounce pot every 1000 loops;

//this is an on debounce for the bearings
unsigned long lastBearingDebounceTime[] = {0, 0, 0, 0};  // the last time the output pin was toggled
unsigned long bearingDebounceDelay[] = {50, 50, 50, 50};    // the debounce time for individual bearings
boolean bearingDebounceWindow[] = {false, false, false, false};      // flag to keep track of the test being passed, so we don't have to keep on running it

//this is an off debounce for the BNC (only actually supported for BNC0
unsigned long lastBNCDebounceTime[] = {0, 0, 0};  // the last time the output pin was toggled
unsigned long BNCDebounceDelay[] = {1000, 0, 0};    // the debounce time for individual bearings
boolean BNCDebounceWindow[] = {false, false, false};      // flag to keep track of the test being passed, so we don't have to keep on running it
int BNCPins[] = {24, 25, 26};

boolean serialEnable = false;

void setup() {
  if (serialEnable) {
    delay(500);
    Serial.begin(115200);
  }
  delay(500);

  for (int i = 0; i < 8; i++) {
    pinMode(inputPin [i], INPUT);
    pinMode(inputLEDpin[i], OUTPUT);
  }

  pinMode(localLEDdispPin, INPUT);
  digitalWrite(localLEDdispPin, HIGH);

  pinMode(adjVoltagePin, INPUT);

  for (int i = 0; i < 2; i++) {
    pinMode(outputPins[i], OUTPUT);
    pinMode(outputLedPins[i], OUTPUT);
  }

  //BNC outputs
  pinMode(BNCPins[0], OUTPUT);
  pinMode(BNCPins[1], OUTPUT);
  pinMode(BNCPins[2], OUTPUT);

  ads.begin();
  delay(100);

  mcp.begin();      // use default address 0
  mcp1.begin(1);      // use address 1

  for (int i = 0; i < 8; i++) {
    mcp.pinMode(i, OUTPUT);
    mcp1.pinMode(i, OUTPUT);

    mcp.pinMode(inputOverridePin[i], INPUT);
    mcp.pullUp(inputOverridePin[i], HIGH);  // turn on a 100K pullup internally
   
    mcp1.pinMode(bearingNoutputOverridePin[i], INPUT);
    mcp1.pullUp(bearingNoutputOverridePin[i], HIGH);  // turn on a 100K pullup internally
    
  }
}

void loop() {
  loopInd = loopInd+1;

  //read the state of remote input overrides
  if(loopInd >  sampleRemoteEvery){
    inputOverrideState = ~mcp.readGPIO(1);
    bearingNoutputOverrideState = ~mcp1.readGPIO(1);
    loopInd  = 0;
  }
  
adjVoltageVal  = analogRead(adjVoltagePin);

  //read the state of the bearing inputs
  inputTestState  = 0;
  inputTestStateRaw = 0;
  for (int i = 0; i < 8; i++) {
    inputValueRaw[i] = analogRead(inputPin[i]);
    inputValue[i] = map(inputValueRaw[i], 0, adjVoltageVal , 0, 1024);
    if (serialEnable) {
      Serial.print(inputValueRaw[i]);
      Serial.print(',');
    }
    //write the bit as a one if the threshold is passed
    if (inputTypeHigh[i] ) {
      if (inputValue[i] < highThres){
        inputTestStateRaw = inputTestStateRaw | 1 << i;
      }  
    } else {
      if (inputValue[i] > lowThres) {
        inputTestStateRaw = inputTestStateRaw | 1 << i;
      }
    }
      if (bitRead(inputTestStateRaw ,i) == 1 || bitRead(inputOverrideState,i) == 1) {
        inputTestState = inputTestState | 1 << i;
      }
  }
  
  // read the display input pin (determins if the local LEDs are triggered)
  if (digitalRead(localLEDdispPin) == 1) {
    localLEDdisp = true;
  } else {
    localLEDdisp = false;
  }

  // display the LED for the bearing input Pins
  for (int i = 0; i < 8; i++) {
    
    if (bitRead(inputTestStateRaw, i) != bitRead(inputTestStateRawPrev, i)) {
      if (localLEDdisp && bitRead(inputTestStateRaw, i) == 1) {
        digitalWrite(inputLEDpin[i],1);
      }else if(bitRead(inputTestStateRaw, i) == 0) {
        digitalWrite(inputLEDpin[i],0);
      }
      mcp.digitalWrite(i, bitRead(inputTestStateRaw, i));
    }
  }
  inputTestStateRawPrev = inputTestStateRaw;
  inputTestStatePrev = inputTestState;
  

  //loop over the four bearings
  for (int i = 0; i < 4; i++) {
    testResult = (inputTestState & bearingOutTrig[i]) == bearingOutTrig[i] || bitRead(bearingNoutputOverrideState,i);

    //if the bearing state has changed
    if (testResult + 0 != bearingState[i]) {
      //update the bearing state
      bearingState[i] =  testResult + 0;

      //if the new bearing state is high, start the debounce clock
      if ( bearingState[i]  == 1) {
        bearingDebounceWindow[i] = true;
        lastBearingDebounceTime[i] = millis();

        // if the new bearing state is low
      } else {
        //if the output is currently high set the output to low (if the output was low, we must have still been in the debounce period, so no need to change anything
        if ( bearingOutput[i] == 1) {
          bearingOutput[i] = 0;
          mcp1.digitalWrite(i, 0);
        }
      }
    }

    //check to see if the bearing state is high and we were in the debounce window (ie we are waiting to turn high)
    if (bearingState[i] == 1 && bearingDebounceWindow[i] == true) {
      //test the debounce window
      if (millis() - lastBearingDebounceTime[i] > bearingDebounceDelay[i]) {
        bearingDebounceWindow[i] = false;
        //set the output as high now
        bearingOutput[i] = 1;
        mcp1.digitalWrite(i, 1);
      }
    }
  }
 

  //if requested, we can read the output debounce on the pin of an output pot
  if (debounceReadPot) {
    if (debounceReadLoopCounter == debounceReadEvery) {
      adc0 = ads.readADC_SingleEnded(0);
      debounceDelay[0] = 100 - map(adc0, 0, 1675, 0, 100);
      debounceDelay[1] =  debounceDelay[0];
      //      if (serialEnable) {
      //        Serial.print("DebounceDelay:");
      //        Serial.println(debounceDelay[0]);
      //      }
      debounceReadLoopCounter = 0;
    } else {
      debounceReadLoopCounter = debounceReadLoopCounter + 1;
    }
  }

  // OUTPUTs///
  // now go the two outputs and check conditions for being high
  outputInd = 0;
  if ( bearingOutput[0] == 1 &   bearingOutput[1] == 1 || bitRead(bearingNoutputOverrideState,4)) {
    SET(PORTB, 5);
    if (localLEDdisp) {
      SET(PORTB, 4);
    }
    outputState[outputInd] = 1;
    debounceWindow[outputInd] = false;

  } else {
    if (debounceWindow[outputInd] == false) {
      lastDebounceTime[outputInd] = millis();
      debounceWindow[outputInd] = true;
    } else {
      if (millis() - lastDebounceTime[outputInd] > debounceDelay[outputInd]) {
        CLR(PORTB, 5);
        CLR(PORTB, 4);
        outputState[outputInd] = 0;
      }
    }
  }
  //update the LED on teh remote board (if there has been a change)
  if (outputStatePrev[outputInd] != outputState[outputInd]){
     mcp1.digitalWrite(4, outputState[outputInd]);
  }
  outputStatePrev[outputInd]  = outputState[outputInd];

  //BNC output
  if (outputState[outputInd] == 1) {
    SET(PORTA, 2); //BNC0
    BNCDebounceWindow[outputInd] = false;
  } else {
    if (BNCDebounceWindow[outputInd] == false) {
      lastBNCDebounceTime[outputInd] = millis();
      BNCDebounceWindow[outputInd] = true;
    } else {
      if (millis() - lastBNCDebounceTime[outputInd] > BNCDebounceDelay[outputInd]) {
        CLR(PORTA, 2); //BNC0
      }
    }
  }


  outputInd = 1;
  if ( bearingOutput[0] == 1 &  bearingOutput[1] == 1 &  bearingOutput[2] == 1  || bitRead(bearingNoutputOverrideState,5)) {
    SET(PORTH, 6);
    if (localLEDdisp) {
      SET(PORTH, 5);
    }
    outputState[outputInd] = 1;

    SET(PORTA, 3); //BNC 1
    CLR(PORTA, 4); //BNC 2
    debounceWindow[outputInd] = false;


  } else {
    if (debounceWindow[outputInd] == false) {
      lastDebounceTime[outputInd] = millis();
      debounceWindow[outputInd] = true;
    } else {
      if (millis() - lastDebounceTime[outputInd] > debounceDelay[outputInd]) {
        CLR(PORTH, 6);
        CLR(PORTH, 5);
        outputState[outputInd] = 0;

        CLR(PORTA, 3); //BNC 1
        SET(PORTA, 4); //BNC 2

        debounceWindow[outputInd] = false;
      }
    }
  }
  //update the LED on teh remote board (if there has been a change)
  if (outputStatePrev[outputInd] != outputState[outputInd]){
     mcp1.digitalWrite(5, outputState[outputInd]);
  }
  outputStatePrev[outputInd]  = outputState[outputInd];


      if (serialEnable) {
              Serial.println(' ');
      }
}




