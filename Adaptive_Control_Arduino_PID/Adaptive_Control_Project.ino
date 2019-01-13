#include <Servo.h>
#include <Wire.h>
#define ENABLE_PID_FROM_ARDUINO
Servo motor;

int16_t Acc_rawX, Acc_rawY, Acc_rawZ, Gyr_rawX, Gyr_rawY, Gyr_rawZ;
float Acceleration_angle[2];
float Gyro_angle[2];
float Total_angle[2];

float elapsedTime, time, timePrev;
int i;
float rad_to_deg = 180 / 3.141592654;

float PID, pwm, error, previous_error;
float pid_p = 0;
float pid_i = 0;
float pid_d = 0;
/////////////////PID CONSTANTS/////////////////
double kp = 2.7; //3.55
double ki = 0.006; //0.003
double kd = 1.4; //2.05
///////////////////////////////////////////////

double throttle = 1100; //initial value of throttle to the motors
float desired_angle = 0; //Reference Point

void setup() {
  Wire.begin(); //begin the wire comunication
  Wire.beginTransmission(0x68);
  Wire.write(0x6B);
  Wire.write(0);
  Wire.endTransmission(true);

  Serial.begin(250000);
  motor.attach(3);

  time = millis();

  motor.writeMicroseconds(1000);
  delay(7000); //Delay to ensure everything is connected

}

void loop() {
  timePrev = time;  // the previous time is stored before the actual time read
  time = millis();  // actual time read
  elapsedTime = (time - timePrev) / 1000;

  Wire.beginTransmission(0x68);
  Wire.write(0x3B); //Ask for the 0x3B register- correspond to AcX
  Wire.endTransmission(false);
  Wire.requestFrom(0x68, 6, true);

  Acc_rawX = Wire.read() << 8 | Wire.read(); //each value needs two registres
  Acc_rawY = Wire.read() << 8 | Wire.read();
  Acc_rawZ = Wire.read() << 8 | Wire.read();

  /*---X---*/
  Acceleration_angle[0] = atan((Acc_rawY / 16384.0) / sqrt(pow((Acc_rawX / 16384.0), 2) + pow((Acc_rawZ / 16384.0), 2))) * rad_to_deg;
  /*---Y---*/
  Acceleration_angle[1] = atan(-1 * (Acc_rawX / 16384.0) / sqrt(pow((Acc_rawY / 16384.0), 2) + pow((Acc_rawZ / 16384.0), 2))) * rad_to_deg;

  Wire.beginTransmission(0x68);
  Wire.write(0x43); //Gyro data first adress
  Wire.endTransmission(false);
  Wire.requestFrom(0x68, 6, true); //Requests 6 registers

  Gyr_rawX = Wire.read() << 8 | Wire.read(); //Once again we shif and sum
  Gyr_rawY = Wire.read() << 8 | Wire.read();
  Gyr_rawZ = Wire.read() << 8 | Wire.read();

  /*---X---*/
  Gyro_angle[0] = Gyr_rawX / 131.0;
  /*---Y---*/
  Gyro_angle[1] = Gyr_rawY / 131.0;

  /*---X axis angle---*/
  Total_angle[0] = 0.98 * (Total_angle[0] + Gyro_angle[0] * elapsedTime) + 0.02 * Acceleration_angle[0];
  /*---Y axis angle---*/
  Total_angle[1] = 0.98 * (Total_angle[1] + Gyro_angle[1] * elapsedTime) + 0.02 * Acceleration_angle[1];

  Serial.println(Total_angle[0]);

#ifdef ENABLE_PID_FROM_ARDUINO
  /*PID*/
  error = Total_angle[0] - desired_angle;

  pid_p = kp * error;

  if (-3 < error < 3)
  {
    pid_i = pid_i + (ki * error);
  }

  pid_d = kd * ((error - previous_error) / elapsedTime);

  /*The final PID values is the sum of each of this 3 parts*/
  PID = pid_p + pid_i + pid_d;

  pwm = throttle + PID;
  if (pwm < 1080)
  {
    pwm = 1080;
  }
  if (pwm > 1300)
  {
    pwm = 1300;
  }
  motor.writeMicroseconds(pwm);
  previous_error = error;
 #endif
  //
  //pwm = 1091 + (Total_angle[0]>0 ? Total_angle[0]*abs(0-(Total_angle[0])/4):max(Total_angle[0]*1.5, -15));
  //motor.writeMicroseconds(pwm);
  Serial.println(pwm);
  delay(5);
}
