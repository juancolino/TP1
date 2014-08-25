import twitter4j.util.*;
import twitter4j.*;
import twitter4j.management.*;
import twitter4j.api.*;
import twitter4j.conf.*;
import twitter4j.json.*;
import twitter4j.auth.*;
import java.util.*;

import processing.serial.*;
import http.requests.*;

Serial myPort;  // Create object from Serial class
String myString = null;
int lf = 10;    // Linefeed in ASCII

int likes = 0; // represents a "+1"
int flags = 0; // represents a "Elaborate more" button press
int displayCounter = 0;
String displayText = ""; // the number that shows on the screen at a given time
boolean statsMode = false; // when it's true the program goes for the statistics screen
int life = 0; // it determines for how long are the likes grouped together if they arrive within the lifeLimit
int initialLifeLimit = 50;
int lifeLimit = initialLifeLimit; // it sets the frame for how long the likes are grouped together to be displayed
int lifeLimitDecrement = 3; // it sets how fast does the lifeLimit decreses. For every like that arrives the time frame to group likes resets but shrinks.
String directMessageReceiver = "juancolino";
int[][] likeHistory;
int historyIndex = 0;

// URL's
//String resetURL = "http://127.0.0.1:8000/votingapp/resetCounters"; // URL to reset the counters on the webapp
String resetURL = "http://jair.lab.inf.uva.es:8006/votingapp/resetCounters"; // URL to reset the counters on the webapp
//String getCountersURL = "http://127.0.0.1:8000/votingapp/getCounters"; // URL to obtain the counters from the webapp
String getCountersURL = "http://jair.lab.inf.uva.es:8006/votingapp/getCounters"; // URL to obtain the counters from the webapp

PFont font;

Twitter twitter;

void setup() {
  // I know that the first port in the serial list on my mac
  // is Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.

  //String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  //myPort = new Serial(this, portName, 9600);
  //myPort.clear();
  //myString = myPort.readStringUntil(lf);
  //myString = null;

  // Twitter auth
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("2fLX9G7i9Vik9q5WCYrhz1KKK");
  cb.setOAuthConsumerSecret("aiImDPh9MzjJKGTYF2q58Z5onAO4xrSNd8pUvCBrP4UVYv6LZk");
  cb.setOAuthAccessToken("2765785566-jgCjL5GEi4wj7U0yUXFhtD4YjIsrmTMh2Y4bkJB");
  cb.setOAuthAccessTokenSecret("w4LS5TWu13wBux2adEBbLJmAcRdtXGBzWKpeZEezT7Qk1");
  TwitterFactory tf = new TwitterFactory(cb.build());
  twitter = tf.getInstance();

  size(1000, 700);
  background(255);
  fill(#50a950);

  font = loadFont("Bauhaus93-120.vlw");
  textFont(font, 500);
  textAlign(CENTER);

  // reset web app counters:
  GetRequest get = new GetRequest(resetURL);
  get.send();
}

void draw() {
  if (statsMode == true) {
    showStatistics();
  } 
  else {
    // Pool server and get counter values:
    GetRequest get = new GetRequest(getCountersURL);
    get.send();
    String[] content = splitTokens(get.getContent());
    println("\"+1\" counter value: " + content[0]);
    println("\"Elaborate more\" counter value: " + content[1]);
    int updatedLikes = int(content[0]);
    int updatedFlags = int(content[1]);

    // Save like to the historyLikes array and update display
    if (updatedLikes > likes) { // a like arrives
      /*String date = splitTokens(get.getHeader("Date"))[4]; // get the date 18:23:43 (get.getHeader("Date") -> Thu,[0] 14[1] Aug[2] 2014[3] 18:11:23[4] GMT[5])
      String[] components = split(date, ":");
      int[] linea = new int[4];
      linea[1] = (updatedLikes - likes);
      linea[2] = int(components[0]);
      linea[3] = int(components[1]);
      linea[4] = int(components[2]);
      if (historyIndex < 1000) {
        append(likeHistory[historyIndex], linea);
        historyIndex++;
      }*/
      
      displayCounter = displayCounter + (updatedLikes - likes);
      likes = updatedLikes;
      life = 0;
      if (lifeLimit - lifeLimitDecrement < 10) {
        lifeLimit = 10;
      } else {
        lifeLimit = lifeLimit - lifeLimitDecrement;
      }
    }

    if (displayCounter != 0) {
      displayText = "+" + str(displayCounter);
    } 
    else {
      displayText = "";
    }

    // Get serial signals from Arduino
    /*while (myPort.available () > 0) {
     myString = myPort.readStringUntil(lf);
     if (myString != null) {
     myString = trim(myString);
     
     if (myString.equals("n")) {
     println("next slide");
     } 
     else if (myString.equals("p")) {
     println("previews slide");
     } 
     }
     }*/

    life++;
    if (life > lifeLimit) {
      life = 0;
      lifeLimit = initialLifeLimit;
      displayCounter = 0;
    }
    println("Life counter: " + str(life) + ", Life limit: " + str(lifeLimit));
    println();
    //   if needed trigger twitter
    if (updatedFlags > flags) {
      // send twitter PM
      try {
        DirectMessage message = twitter.sendDirectMessage(directMessageReceiver, "Elaborate more " + str(updatedFlags));
        System.out.println("Direct message successfully sent to " + message.getRecipientScreenName());
      } 
      catch (TwitterException te) {
        te.printStackTrace();
        System.out.println("Failed to send a direct message: " + te.getMessage());
      }
      flags = updatedFlags;
    }

    background(255);
    text(displayText, width/2, height/2+100);
  }
}

void showStatistics() {
  // draw the statistics screen
  textFont(font, 210);
  displayText = "Total: " + str(likes);
  background(255);
  text(displayText, width/2, height/2+50);
}

void keyReleased() {
  if (key == 'e') {
    statsMode = true;
  }
}

