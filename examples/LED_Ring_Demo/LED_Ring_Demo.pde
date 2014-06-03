#include "ledRings.h"
/********| BEGIN CONFIGURATION |********/
#define NUM_LED_RINGS  3 // The number of LED Ring boards

#define LED_RING_OE    6 // Output Enable pin of the board
#define LED_RING_SDI   2 // Data pin of the board
#define LED_RING_CLK   3 // Clock pin of the board
#define LED_RING_LE    4 // Latch pin of the board

#define LED_RING_GREEN 0 // This is entirely up to you.
#define LED_RING_RED   1 // It's used to refer to the individual led boards by name.
#define LED_RING_BLUE  2 // Use whatever works for your purpose, or none at all :)
/*********| END CONFIGURATION |*********/

ledRings ring(LED_RING_SDI, LED_RING_CLK, LED_RING_LE, LED_RING_OE, NUM_LED_RINGS);

void setup() {
  RunFullTestSuite();
}

void loop(){} // not needed for this demo...

/***********************| TEST FUNCTIONS |***********************/

void RunFullTestSuite() {
  blinkAllRingTest();
  ring.allRingsOff();
  delay(1000);
  blinkArcTest();
  ring.allRingsOff();
  delay(1000);
  blinkBottomLedTest();
  ring.allRingsOff();
  delay(1000);
  showFlashyDemo();
  ring.allRingsOff();
  delay(1000);
  patternAnimationTest();
  ring.allRingsOff();
}

void patternAnimationTest() {
  unsigned int sequence[3][16] = {
    {0x0, 0x1,    0x2,    0x4,    0x8,   0x10,  0x20,  0x40,  0x80, 0x100, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000},
    {0x0, 0x1,    0x3,    0x7,    0xf,   0x1f,  0x3f,  0x7f,  0xff, 0x1ff, 0x3ff, 0x7ff, 0xfff, 0x1fff, 0x3fff, 0x7fff},
    {0x0, 0x7fff, 0x3ffe, 0x1ffc, 0xff8, 0x7f0, 0x3e0, 0x1c0, 0x80, 0x1c0, 0x3e0, 0x7f0, 0xff8, 0x1ffC, 0x3ffe, 0x7fff},
  };
  for (byte i=0;i<16;i++) {
    ring.setRingState(LED_RING_RED, sequence[0][i]);
    ring.setRingState(LED_RING_GREEN, sequence[1][i]);
    ring.setRingState(LED_RING_BLUE, sequence[2][i]);
    delay(250);
  }
  for (byte i=0;i<16;i++) {
    ring.setRingState(LED_RING_RED, sequence[0][15-i]);
    ring.setRingState(LED_RING_GREEN, sequence[1][15-i]);
    ring.setRingState(LED_RING_BLUE, sequence[2][15-i]);
    delay(250);
  }
}

void showFlashyDemo() {
  for (byte i=0;i<ring.num_leds_arc;i++){
    ring.setRingLed(LED_RING_GREEN, ring.num_leds_arc-1-i,HIGH);
    delay(50);
  }
  for (byte i=0;i<ring.num_leds_arc;i++){
    ring.setRingLed(LED_RING_RED, ring.num_leds_arc-1-i,HIGH);
    delay(50);
  }
  for (byte i=0;i<ring.num_leds_arc;i++){
    ring.setRingLed(LED_RING_BLUE, ring.num_leds_arc-1-i,HIGH);
    delay(50);
  }
  ring.allRingsOff();
  unsigned long last = millis();
  while ((millis()-last) <= 5000) {
    for (byte i=0;i<ring.num_led_rings;i++) {
      ring.setRingState(i, random(1, 0x7FFF));
    }
    delay(25);
  }
  ring.allRingsOff();
  for (byte x=0;x<10;x++) {
    for (byte i=0;i<ring.num_leds_arc;i++){
      ring.setRingLed(LED_RING_RED, i, HIGH);
      ring.setRingLed(LED_RING_GREEN, i, HIGH);
      ring.setRingLed(LED_RING_BLUE, i, HIGH);
      delay(25);
    }
    for (byte i=0;i<ring.num_leds_arc;i++){
      ring.setRingLed(LED_RING_RED, ring.num_leds_arc-1-i, LOW);
      ring.setRingLed(LED_RING_GREEN, ring.num_leds_arc-1-i, LOW);
      ring.setRingLed(LED_RING_BLUE, ring.num_leds_arc-1-i, LOW);
      delay(25);
    }
  }
  ring.allRingsOff();
  for (byte x=0;x<3;x++) {
    for (byte i=0;i<ring.num_leds_arc;i++){
      ring.setRingLed(LED_RING_GREEN, ring.num_leds_arc-1-i,HIGH);
      delay(25);
    }
    for (byte i=0;i<ring.num_leds_arc;i++){
      ring.setRingLed(LED_RING_GREEN, ring.num_leds_arc-1-i,LOW);
      delay(25);
    }
    for (byte i=0;i<ring.num_leds_arc;i++){
      ring.setRingLed(LED_RING_RED, ring.num_leds_arc-1-i,HIGH);
      delay(25);
    }
    for (byte i=0;i<ring.num_leds_arc;i++){
      ring.setRingLed(LED_RING_RED, ring.num_leds_arc-1-i,LOW);
      delay(25);
    }
    for (byte i=0;i<ring.num_leds_arc;i++){
      ring.setRingLed(LED_RING_BLUE, ring.num_leds_arc-1-i,HIGH);
      delay(25);
    }
    for (byte i=0;i<ring.num_leds_arc;i++){
      ring.setRingLed(LED_RING_BLUE, ring.num_leds_arc-1-i,LOW);
      delay(25);
    }
  }
  ring.allRingsOff();
}

void blinkAllRingTest() {
  ring.blinkRing(LED_RING_RED,3,75);
  delay(50);
  ring.blinkRing(LED_RING_GREEN,3,75);
  delay(50);
  ring.blinkRing(LED_RING_BLUE,3,75);
  delay(50);
  ring.blinkAllRings(3,150);
}

void blinkArcTest() {
    ring.ringAllArcLedsOn(LED_RING_GREEN);
    delay(500);
    ring.ringAllArcLedsOff(LED_RING_GREEN);
    delay(500);
    ring.ringAllArcLedsOn(LED_RING_GREEN);
    delay(500);
    ring.ringAllArcLedsOff(LED_RING_GREEN);
    delay(500);

    ring.ringAllArcLedsOn(LED_RING_RED);
    delay(500);
    ring.ringAllArcLedsOff(LED_RING_RED);
    delay(500);
    ring.ringAllArcLedsOn(LED_RING_RED);
    delay(500);
    ring.ringAllArcLedsOff(LED_RING_RED);
    delay(500);

    ring.ringAllArcLedsOn(LED_RING_BLUE);
    delay(500);
    ring.ringAllArcLedsOff(LED_RING_BLUE);
    delay(500);
    ring.ringAllArcLedsOn(LED_RING_BLUE);
    delay(500);
    ring.ringAllArcLedsOff(LED_RING_BLUE);
}

void blinkBottomLedTest() {
  ring.setRingBottomLed(LED_RING_GREEN,HIGH);
  delay(500);
  ring.setRingBottomLed(LED_RING_GREEN,LOW);
  delay(500);
  ring.setRingBottomLed(LED_RING_GREEN,HIGH);
  delay(500);
  ring.setRingBottomLed(LED_RING_GREEN,LOW);
  delay(500);

  ring.setRingBottomLed(LED_RING_RED,HIGH);
  delay(500);
  ring.setRingBottomLed(LED_RING_RED,LOW);
  delay(500);
  ring.setRingBottomLed(LED_RING_RED,HIGH);
  delay(500);
  ring.setRingBottomLed(LED_RING_RED,LOW);
  delay(500);

  ring.setRingBottomLed(LED_RING_BLUE,HIGH);
  delay(500);
  ring.setRingBottomLed(LED_RING_BLUE,LOW);
  delay(500);
  ring.setRingBottomLed(LED_RING_BLUE,HIGH);
  delay(500);
  ring.setRingBottomLed(LED_RING_BLUE,LOW);
}