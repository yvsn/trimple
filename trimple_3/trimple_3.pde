/*
Referances:
 Code for contour detection: https://github.com/bitcraftlab/opencv-webcam-processing/blob/master/examples/LiveCamFindContours/LiveCamFindContours.pde
 Library used: OpenCV  https://github.com/bitcraftlab/opencv-webcam-processing
 Help with Arduino to Processing connection: https://sites.google.com/site/ryoung/Home/tej3m/sending-numbers-from-arduino-to-processing
 Minim library for sound manipulation: https://github.com/ddf/Minim
 */
import processing.video.Capture;
import gab.opencv.OpenCV;
import gab.opencv.Contour;
import java.awt.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

//arduino port
import processing.serial.*;
int end = 10; 
String receivedString;
Serial myPort;
Capture cam;
OpenCV opencv;
Minim minim;
AudioPlayer jingle;
AudioInput input;
FFT fft;
int[][] colo=new int[300][3];

// input resolution
int w = 640, h = 360;

// output zoom
int zoom = 2;

// target frameRate
int fps = 30;

// contour threshold ( 0 .. 255)
int threshold = 100;

// display options
boolean showOutput = true;
boolean showContours = true;
boolean showPolys = true;

// drawing style
boolean fillShapes;
color contourColor = color(255, 50, 50, 150);
color polyColor = color(50, 255, 50, 150);


void setup() {
  myPort= new Serial(this, Serial.list()[1], 9600);
  myPort.clear();
  receivedString = myPort.readStringUntil(end);
  // actual size is a result of input resolution and zoom factor
  size(1280, 720);

  // limit redrawing to the target frame rate
  frameRate(fps);

  // capture camera with input resolution and target frame rate
  cam = new Capture(this, w, h, fps);
  cam.start();

  // init OpenCV with input resolution 
  opencv = new OpenCV(this, w, h);
  opencv.gray();

  // drawing style
  smooth();
  strokeWeight(2);
  strokeJoin(ROUND);
  minim = new Minim(this);


  input = minim.getLineIn();

  fft = new FFT(input.bufferSize(), input.sampleRate());
}


void draw() {

  background(0);
  while (myPort.available () > 0) { //as long as there is data coming from serial port, read it and store it 
    receivedString = myPort.readStringUntil(end);
  }
  if (receivedString != null) { 
    String[] a = split(receivedString, ',');  // a new array (called 'a') that stores values into separate cells (separated by commas specified in your Arduino program)

    int distance = Integer.parseInt(a[0].trim()); // This is probably the scariest line of code here. For now, you...
    int light = Integer.parseInt(a[1].trim()); // ...just need to know that it converts the string into an integer.
    int heat = Integer.parseInt(a[2].trim());
    light /= 3;
    heat /= 3;
    println(distance); //print the first string value of the array
    println(light); //print to the console the second string value
    println(heat);
    if (distance > 255) {
      distance= 250;
    }
    threshold = light/2;
    contourColor = color(distance+heat, 0, light, light);
    polyColor = color(heat, distance*2, 0, light);
    // read a single frame
    opencv.loadImage(cam); 
    fft.forward(input.mix);
    // init OpenCV for thresholding
    opencv.gray();
    opencv.threshold(threshold);

    // find contours
    ArrayList<Contour> contours = opencv.findContours();

    // zoom to input resolution
    scale(zoom);

    // get output image
    PImage output = opencv.getOutput();

    // Show camera or OpenCV input
    image(showOutput ? output : cam, fft.getBand(light/4)*5, fft.getBand(light/4)*5);


    // draw on top of output image
    for (Contour contour : contours) {

      fill(distance, fillShapes ? 150 : 0);
      // draw the contour


      stroke(contourColor);
      contour.draw();


      // draw a polygonal approximation

      stroke(polyColor);
      beginShape();
      for (PVector point : contour.getPolygonApproximation().getPoints()) {
      //  vertex(point.x, point.y);   
        vertex(point.x + fft.getBand(light/4)*2, point.y - fft.getBand(light/4)*2);
        vertex(point.x - fft.getBand(light/4)*2, point.y - fft.getBand(light/4)*2);
        ellipse(point.x - fft.getBand(light/4)*5, point.y-fft.getBand(light/4), 1 + fft.getBand(light), 1 + fft.getBand(light));
        //Check voice value
        //println(fft.getBand(light/4));
      }
      endShape(CLOSE);
    }
  }
}


void captureEvent(Capture cam) {
  cam.read();
}
