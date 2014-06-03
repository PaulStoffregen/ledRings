/*
  ledRings.h - Library for the Mayhew Labs Rotary Encoder LED Ring.
  Created by Nick Van Dorsten, April 03, 2011.
  Version .5 beta: initial release
  Released into the public domain.
*/

#ifndef ledRings_h
#define ledRings_h
#include "WProgram.h"

class ledRings {
  public:
  uint16_t *ringState;
  uint16_t *lastRingState;
  byte num_led_rings;
  static const byte num_leds_arc = 15;
  byte dutyCycle;
  byte oldDutyCycle;
  byte sdi;
  byte clk;
  byte le;
  byte oe;

  ledRings(byte sdiPin, byte clkPin, byte lePin, byte oePin, byte numRings);
  void updateRings(void);
  void allRingsOff(void);
  void setRingState(byte ringNum, uint16_t state);
  void setRingLed(byte ringNum, byte ledNum, boolean state);
  void setRingBottomLed(byte ringNum, boolean state);
  void ringAllArcLedsOn(byte ringNum);
  void ringAllArcLedsOff(byte ringNum);
  void blinkAllRings(byte cnt, uint16_t dly);
  void blinkRing(byte ringNum, byte cnt, uint16_t dly);
  void interrupt(void);
};
/*************************| ISR Timer Functions |*************************/
void initInterrupt();
void startISR();
void stopISR();
/***********************| End ISR Timer Functions |***********************/
#endif
