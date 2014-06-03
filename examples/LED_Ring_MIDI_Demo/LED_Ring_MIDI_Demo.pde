#include <ledRings.h>
#include <Midi.h>

/********| BEGIN CONFIGURATION |********/
#define NUM_LED_RINGS  3 	 // The number of LED Ring boards

#define LED_RINGS_CHANNEL 15 // The midi channel for the rings

#define LED_RING_OE    6 	 // Output Enable pin of the board
#define LED_RING_SDI   2 	 // Data pin of the board
#define LED_RING_CLK   3 	 // Clock pin of the board
#define LED_RING_LE    4 	 // Latch pin of the board

#define LED_RING_GREEN 0 	 // This is entirely up to you.
#define LED_RING_RED   1 	 // It's used to refer to the individual led boards by name.
#define LED_RING_BLUE  2 	 // Use whatever works for your purpose, or none at all :)
/*********| END CONFIGURATION |*********/

ledRings ring(LED_RING_SDI, LED_RING_CLK, LED_RING_LE, LED_RING_OE, NUM_LED_RINGS);

class MyMidi : public Midi {
  public:
  MyMidi(HardwareSerial &s) : Midi(s) {}
  void handleControlChange(unsigned int channel, unsigned int controller, unsigned int value) {
    if (channel == LED_RINGS_CHANNEL) {                               // Filter the incoming midi, we only care about the led ring channel
      if (controller <= NUM_LED_RINGS) {                              // CC's For ring values are equal to their their number
        byte ledsToLight = map(value, 0,127, 0, ring.num_leds_arc);   // Convert the midi CC value to the number of LED's to light
        ring.ringAllArcLedsOff(controller-1);                         // Start blank
        for (byte i=0;i<ledsToLight;i++) {
          ring.setRingLed(controller-1, i, HIGH);                     // One by one turn on the led
        }
      }
    }
  }

  void handleNoteOn(unsigned int channel, unsigned int note, unsigned int velocity) {
    if (channel == LED_RINGS_CHANNEL) {                               // Filter the incoming midi, we only care about the led ring channel
      if ((note-50) <= NUM_LED_RINGS) {                               // Notes for the bottom leds are equal to their number + 50
        if (velocity >=105) ring.setRingBottomLed((note-50)-1, HIGH); // Turn bottom led on
      }
    }
  }

  void handleNoteOff(unsigned int channel, unsigned int note, unsigned int velocity) {
    if (channel == LED_RINGS_CHANNEL) {                               // Filter the incoming midi, we only care about the led ring channel
      if ((note-50) <= NUM_LED_RINGS) {                               // Notes for the bottom leds are equal to their number + 50
        if (velocity <= 15) ring.setRingBottomLed((note-50)-1, LOW);  // Turn bottom led off
      }
    }
  }
};

MyMidi midi(Serial);

void setup(){
  ring.allRingsOff();
  midi.begin(0);
}
void loop(){
  midi.poll();
}