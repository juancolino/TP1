import processing.serial.*;
import ddf.minim.*;
Minim minim;

AudioPlayer player;

Serial myPort;  // Create object from Serial class
String myString = null;
int lf = 10;    // Linefeed in ASCII

String inputString = "";
int counter = 0;

PFont font;

boolean lost = false;
float time = 0;

void setup() {
  // I know that the first port in the serial list on my mac
  // is Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
  myPort.clear();
  myString = myPort.readStringUntil(lf);
  myString = null;
  
  minim = new Minim(this);
  player = minim.loadFile("help.mp3");

  size(1000, 700);
  background(255);
  fill(0);

  font = loadFont("Bauhaus93-120.vlw");
  textFont(font, 500);
  textAlign(CENTER);
}

void draw() {
  if (lost) {
    background(255, 0, 0);
    fill(255);
    text("HELP", width/2, height/2+100);
  } 
  else {
    background(255);
    fill(0);
    text(counter, width/2, height/2+100);
  }

  while (myPort.available () > 0) {
    myString = myPort.readStringUntil(lf);
    if (myString != null) {
      myString = trim(myString);

      if (myString.equals("+1")) {
        println("+1");
        counter++;
      } 
      else if (myString.equals("-1")) {
        println("-1");
        counter--;
      } 
      else if (myString.equals("lost")) {
        println("I'm lost!");
        player.play();
        player.rewind();
        lost = true;
        time = 0;
      }
    }
  }
  time--;
  if (time % 500 == 0) {
    lost = false;
  }
}

void stop() {
  minim.stop();
  super.stop();
}

