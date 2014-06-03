#include <ledRings.h>

/********| BEGIN CONFIGURATION |********/
#define NUM_LED_RINGS  3 	// The number of LED Ring boards

#define LED_RING_OE    6 	// Output Enable pin of the board
#define LED_RING_SDI   2 	// Data pin of the board
#define LED_RING_CLK   3 	// Clock pin of the board
#define LED_RING_LE    4 	// Latch pin of the board

#define ENC_A          8    // Encoder A output pin of the board
#define ENC_B          9    // Encoder B output pin of the board
#define ENC_SW         10   // Encoder switch pin of the board
#define ENC_PORT       PINB // The port that the rotary encoder is on (see http://www.arduino.cc/en/Reference/PortManipulation)

#define LED_RING_GREEN 0 	// This is entirely up to you.
#define LED_RING_RED   1 	// It's used to refer to the individual led boards by name.
#define LED_RING_BLUE  2 	// Use whatever works for your purpose, or none at all :)
/*********| END CONFIGURATION |*********/

ledRings ring(LED_RING_SDI, LED_RING_CLK, LED_RING_LE, LED_RING_OE, NUM_LED_RINGS);

uint16_t patterns[3][16] = {
  {0x0, 0x1,    0x2,    0x4,    0x8,   0x10,  0x20,  0x40,  0x80, 0x100, 0x200, 0x400, 0x800, 0x1000, 0x2000, 0x4000},
  {0x0, 0x1,    0x3,    0x7,    0xf,   0x1f,  0x3f,  0x7f,  0xff, 0x1ff, 0x3ff, 0x7ff, 0xfff, 0x1fff, 0x3fff, 0x7fff},
  {0x0, 0x7fff, 0x3ffe, 0x1ffc, 0xff8, 0x7f0, 0x3e0, 0x1c0, 0x80, 0x1c0, 0x3e0, 0x7f0, 0xff8, 0x1ffC, 0x3ffe, 0x7fff},
};

byte scaledCounter = 0;
static uint8_t currentPattern = 0;
static uint8_t counter = 0;
static unsigned long last = 0;
static uint8_t button, lastButtonState = 1;
int8_t tmpdata;

void setup() {
  initEncoders();
  ring.allRingsOff();
}

void loop() {
  button = digitalRead(ENC_SW);                                                // Read button state
  if ((button != lastButtonState) && (micros() - last > 250)) {                // Check if the button has changed and debounce button input
    lastButtonState = button;                                                  // Save current button state
    last = micros();                                                           // Update debounce timer
    if (!button) currentPattern = (++currentPattern%3);                        // Cycle through patterns if the button was pressed
    ring.setRingBottomLed(LED_RING_BLUE, !button);                             // Set the button state (0=button pressed, 1=button released)
  }
  tmpdata = read_encoder();                                                    // Get encoder value
  if(tmpdata) {                                                                // If the encoder has moved
    counter += tmpdata;                                                        // Set the new counter value of the encoder
    scaledCounter = map(counter, 0, 255, 0, ring.num_leds_arc);                // Scale the counter value down to the number of leds
    ring.setRingState(LED_RING_BLUE, patterns[currentPattern][scaledCounter]); // Update the ring with the current pattern based on the number of leds to light
  }
}

void initEncoders() {
  // Set encoder pins to input
  pinMode(ENC_A, INPUT);
  pinMode(ENC_B, INPUT);
  pinMode(ENC_SW, INPUT);

  // Turn internal pull-ups on
  digitalWrite(ENC_A, HIGH);
  digitalWrite(ENC_B, HIGH);
  digitalWrite(ENC_SW, HIGH);
}

/*************************************************************************
*    read_encoder() function as provided by Oleg:                        *
*    http://www.circuitsathome.com/mcu/reading-rotary-encoder-on-arduino *
*    Returns change in encoder state (-1,0,1)                            *
************************************************************************ */
int8_t read_encoder() {
  int8_t enc_states[] = {0,-1,1,0,1,0,0,-1,-1,0,0,1,0,1,-1,0};
  static uint8_t old_AB = 0;
  old_AB <<= 2;                   //remember previous state
  old_AB |= ( ENC_PORT & 0x03 );  //add current state
  return ( enc_states[( old_AB & 0x0f )]);
}