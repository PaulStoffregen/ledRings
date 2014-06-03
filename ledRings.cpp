/*
  ledRings.cpp - Library for the Mayhew Labs Rotary Encoder LED 
  Created by Nick Van Dorsten, April 03, 2011.
  Version .5 beta: initial release
  Released into the public domain.
*/
#include "ledRings.h"

ledRings::ledRings(byte sdiPin, byte clkPin, byte lePin, byte oePin, byte numRings) {
  ringState = (uint16_t *)malloc(sizeof(uint16_t) * numRings);
  lastRingState = (uint16_t *)malloc(sizeof(uint16_t) * numRings);
  allRingsOff();
  //Set SPI pins to output
  pinMode(sdiPin, OUTPUT);
  pinMode(clkPin, OUTPUT);
  pinMode(lePin,OUTPUT);
  sdi = sdiPin;
  clk = clkPin;
  le = lePin;
  oe = oePin; // To control PWM
  num_led_rings = numRings; // Number of LED Ring boards 
  dutyCycle = 0;
  oldDutyCycle = 255; // Keeps track of PWM duty cycle
  initInterrupt();
}  

void ledRings::updateRings() {
  digitalWrite(le,LOW);
  for (int currentRing = num_led_rings-1;currentRing >= 0;currentRing--) {
    shiftOut(sdi,clk,MSBFIRST,(ringState[currentRing] >> 8));    //High byte first
    shiftOut(sdi,clk,MSBFIRST,ringState[currentRing]);           //Low byte second
  }
  digitalWrite(le,HIGH);
}

void ledRings::allRingsOff() {
  for (byte i=0;i<num_led_rings;i++) {
    lastRingState[i] = 1;
    ringState[i] = 0;
  }
}

void ledRings::setRingState(byte ringNum, uint16_t state) {
  ringState[ringNum] = state;
}

void ledRings::setRingLed(byte ringNum, byte ledNum, boolean state) {
  bitWrite(ringState[ringNum], ledNum, state);
}

void ledRings::setRingBottomLed(byte ringNum, boolean state) {
  bitWrite(ringState[ringNum], 15, state);
}

void ledRings::ringAllArcLedsOn(byte ringNum) {
  ringState[ringNum] = 0x7FFF;
}

void ledRings::ringAllArcLedsOff(byte ringNum) {
  ringState[ringNum] &= 0x8000;
}

void ledRings::blinkAllRings(byte cnt, uint16_t dly) {
  for (byte x=0;x<cnt;x++) {
    for (byte i=0;i<num_led_rings;i++) ringState[i] = 0xFFFF;
    delay(dly);
    for (byte i=0;i<num_led_rings;i++) ringState[i] = 0;
    delay(dly);
  }
}

void ledRings::blinkRing(byte ringNum, byte cnt, uint16_t dly) {
  for (byte i=0;i<cnt;i++) {
    ringState[ringNum] = 0xFFFF;
    delay(dly);
    ringState[ringNum] = 0;
    delay(dly);
  }
}

void ledRings::interrupt() {
  // Do we need to update the pwm settings?
  if (oldDutyCycle != dutyCycle) {
    analogWrite(oe, dutyCycle);
    oldDutyCycle = dutyCycle;
  }
  // Do we need to refresh the rings?
  boolean updateReq = false;
  static unsigned long last = 0;
  for (byte i=0;i<num_led_rings;i++){
    if (ringState[i] != lastRingState[i]) {
      lastRingState[i] = ringState[i];
      updateReq = true;
    }
  }
  if (updateReq) updateRings();
}

//void printRingStates() {
//  Serial.println();
//  for (byte i=0;i<num_led_rings;i++) {
//    Serial.print(i+1, DEC);Serial.print(": ");Serial.print(ringState[i],BIN);Serial.print(" ");
//  }
//  Serial.println();
//}

/*************************| ISR Timer Functions |*************************/
extern ledRings ring;

#if defined(__AVR__)
ISR(TIMER2_COMPA_vect) {
  ring.interrupt();
}

void initInterrupt(){
  TCCR2A = 0x02; // WGM22=0 + WGM21=1 + WGM20=0 = Mode2 (CTC)
  TCCR2B = 0x05; // CS22=1 + CS21=0 + CS20=1 = /128 prescaler (125kHz)
  TCNT2 = 0;     // Clear counter
  OCR2A = 500;  // Sets the speed of the ISR - LOWER IS FASTER 
  startISR();
}

void startISR(){  // Starts the ISR
  TCNT2 = 0;                            // clear counter (needed here also)
  TIMSK2|=(1<<OCIE2A);                  // set interrupts=enabled (calls ISR(TIMER2_COMPA_vect)
}

void stopISR(){    // Stops the ISR
  TIMSK2&=~(1<<OCIE2A);                  // disable interrupts
}

#elif defined(__arm__) && defined(TEENSYDUINO) // Teensy 3.x

static IntervalTimer itimer;

void interruptFunction(void) {
  ring.interrupt();
}

void initInterrupt() {
}

void startISR() {
  itimer.begin(interruptFunction, 1952.0);
}

void stopISR() {
  itimer.end();
}

#endif

/***********************| End ISR Timer Functions |***********************/
