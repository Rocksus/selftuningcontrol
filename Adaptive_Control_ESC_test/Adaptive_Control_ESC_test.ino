#include <Servo.h>

Servo left;
Servo right;
float time;
void setup() {
  Serial.begin(250000);
  left.attach(5); //attach to esc
  right.attach(3);

  time = millis();

  left.writeMicroseconds(1000);
  right.writeMicroseconds(1000);
  delay(7000); //Delay to ensure everything is connected
  
}

int potPin = 2;

void loop() {
  // put your main code here, to run repeatedly:
  int thrott = analogRead(potPin);
  left.write(map(thrott,0,1023,1000,2000));
  right.write(map(thrott,0,1023,1000,2000));
  
}
