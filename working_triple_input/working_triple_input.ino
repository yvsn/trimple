const int echoPin = 6;
const int trigPin = 7;

void setup() {
  Serial.begin(9600); //Begin Serial Communication with a baud rate of 9600
  pinMode(echoPin, INPUT);
  pinMode(trigPin, OUTPUT);
}

void loop() {
   //New variables are declared to store the readings of the respective pins
  int Value1 = analogRead(A0);
  int Value2 = analogRead(A1);
  int distanceValue = 0;

   digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  // wait for the echo
  delay(1);
  long duration = pulseIn(echoPin, HIGH);

  int cm = duration / 29 / 2;
  distanceValue = cm;

  Serial.print(distanceValue, DEC);
  Serial.print(",");
  
  /* The Serial.print() function does not execute a "return" or a space
     Also, the "," character is essential for parsing the values,
  */ //The comma is not necessary after the last variable is sent. 

  Serial.print(Value1, DEC); // DEC means "send the number in base-10"
  Serial.print(",");
  Serial.print(Value2, DEC);
  Serial.println(); // the "ln" will tack on a special character at the end of the transmission
  delay(20); // Don't use a delay smaller than 20 ms or so.
}
