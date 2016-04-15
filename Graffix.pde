import controlP5.*;
import com.onformative.leap.*;
import processing.video.*;
import com.onformative.leap.LeapMotionP5;
import com.leapmotion.leap.Finger;
import javax.swing.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.serial.*;

boolean resetPressed = false;
boolean playPressed = false;
boolean saveFramePressed = false;
boolean stopMusicPressed = false;
boolean recordPressed = false;
boolean stopRecordPressed = false;





boolean freeFormMode = false;

Serial myPort;

float HueValue = 0;        // red value
float SatValue = 0;      // green value
float BriValue = 0;       // blue value
float state = 0;

boolean runonce = true;

Minim minim;
AudioPlayer player;
BeatDetect beat;
BeatListener bl;
float hatSize;
String musicTrack;


ArtisticData track;

LeapMotionP5 leap;
ControlP5 cp5;
boolean toggleValue = false;

PFont font;
color textColor = color(0, 0, 0);
Levels myLevels;
//create an image variable
PImage img;

float finger_pos_y;
float finger_pos_x;
float finger_pos_z;

float sprayProximity;
float colourVariance = 25;

color sprayColor; // Colour of the spray
int sprayWidth; // The width of the spray
int sprayTravel; // The distance travelled from one mouse
// move to another.
final int MAX_SPRAY_WIDTH = 50; // Maximum spray width [Constant]
final int MIN_SPRAY_WIDTH  = 1; // Minimum spray width [Constant]

public void setup() {
  size(800, 500, P3D);
  println(Serial.list());
  myPort = new Serial(this, Serial.list()[5], 9600);
  myPort.bufferUntil('\n');

  smooth(8);
  PFrame tracker = new PFrame(width+160, height+5);
  frame.setTitle("The Canvas");
  tracker.setTitle("Artistic Data");
  colorMode(HSB, 255);
  reset();
  noStroke(); 
  leap = new LeapMotionP5(this);
  myLevels = new Levels(0);//want our level to start at zero
  font = loadFont("HV48.vlw");
  textFont(font);








  cp5 = new ControlP5(this);

  // replace the default controlP5 button with an image.
  // button.setImages(defaultImage, rolloverImage, pressedImage);
  // use button.updateSize() to adjust the size of the button and 
  // resize to the dimensions of the defaultImage



  cp5.addButton("buttonA")
    .setPosition(865, 280)
      .setImages(loadImage("play.png"), loadImage("overplay.png"), loadImage("play.png"))
        .updateSize();

  cp5.addButton("buttonB")
    .setPosition(875, 280)
      .setImages(loadImage("stop.png"), loadImage("overstop.png"), loadImage("stop.png"))
        .updateSize();
  
  


  cp5.addButton("buttonE")
    .setPosition(835, 360)
      .setImages(loadImage("reset.png"), loadImage("overreset.png"), loadImage("reset.png"))
        .updateSize();

  cp5.addButton("buttonF")
    .setPosition(875, 360)
      .setImages(loadImage("save.png"), loadImage("oversave.png"), loadImage("save.png"))
        .updateSize();

  cp5.addButton("buttonG")
    .setPosition(835, 280)
      .setImages(loadImage("play2.png"), loadImage("overplay2.png"), loadImage("play2.png"))
        .updateSize();

        
  cp5.getTooltip().register("buttonA", "Play Music.");
  cp5.getTooltip().register("buttonB", "Stop Music.");
  cp5.getTooltip().register("buttonC", "Use Semi-Autonomous mode");
  cp5.getTooltip().register("buttonD", "Use Free-Form mode.");
  cp5.getTooltip().register("buttonE", "Reset sketch");
  cp5.getTooltip().register("buttonF", "Save sketch to file.");
  cp5.getTooltip().register("buttonG", "Play Music");

}





public void draw() {
  theLevels();
}//end of draw



void playMusic() {
  player.play();
}


void theLevels() {
  if (myLevels.level == 0) {
    background(255, 240, 5);
    //    myLevels.fontLoader();
    myLevels.startMenu();
  }
  if (myLevels.level == 1) {
    // vels.fontLoader();
    myLevels.orientation();
  }

  if (myLevels.level == 2) {
    //    myLevels.fontLoader();
    myLevels.startArt();
  }
}

class Levels {
  PFont ourFont; // enables a variable to hold our font for text
  String fontStyle;//font type
  int fontSize;//font size
  int fontSizeScroll;
  int level;

  //constructor
  Levels(int tempLevel) {
    level = tempLevel;
  }


  void startMenu() {
    background(0);
    img = loadImage("bk.png");
    image(img, 0, 0);
    fill(textColor);
    textAlign(CENTER);

    fill(0);
    ellipse(560, 410, 160, 80);
    fill(255);
    text("START", 562, 428);
    if (mouseX >=(480) && mouseX <=(640) && mouseY >=(369)&& mouseY <=(450)&& mousePressed) {
      level = 1;
      rectMode(CORNER);
      fill(255);
      rect(0, 0, 450, 450);
      fill(0);
    }
  }



  void orientation() {
    background(0);  
    fill(255);
    for (Finger finger : leap.getFingerList()) {
      //println(leap.getFingerList());
      PVector fingerPos = leap.getTip(finger);
      ellipse(fingerPos.x, fingerPos.y, 10, 10);
    }
    textSize(36);
    fill(255);
    text("Welcome to Orientation", 210, 35);  

    //next button
    fill(255);
    rectMode(CENTER);
    rect(730, 460, 130, 60);
    fill(0);
    text("Next", 730, 475);
    if (mouseX >=(635) && mouseX <=(763) && mouseY >=(429)&& mouseY <=(490)&& mousePressed) {
      // Quit running the sketch once the file is written
      //exit(); //exit out of application (only good in Java mode)
      delay(100);
      level = 2;
    }
  }


  public void startArt() {

    if (runonce) {
      background(255);
      delay(50);
      reset();
      runonce = false;
    }

    if (resetPressed) {
      reset();
      resetPressed = false;
    }

    if (playPressed) {
      playMusic();
      resetPressed = false;
    }

    if (saveFramePressed) {
      saveFrame("spray.jpg");
      saveFramePressed = false;
    }

    if (stopMusicPressed) {
      player.close();
      stopMusicPressed = false;
    }


    PVector fingerpos = leap.getTip(leap.getFinger(0));

    finger_pos_x = fingerpos.x;
    finger_pos_y = fingerpos.y;
    finger_pos_z = fingerpos.z;
    if (freeFormMode) {
      sprayProximity = fingerpos.z/10;
    }

    else if (freeFormMode == false) {
      sprayProximity = hatSize+(fingerpos.z/12);;
    }

    sprayColor = color(HueValue+(random(colourVariance)), SatValue+(random(colourVariance)), BriValue+(random(colourVariance)), random(60, 100)); 


    if (state == 0) {
      sprayCan();
    }
  }
}


void sprayCan() {

  noStroke();
  //bezier(finger_pos_x, finger_pos_y,  (finger_pos_x+(random(100))), (finger_pos_y+(random(100))),  (finger_pos_x+(random(100))), (finger_pos_y+(random(100))),  (finger_pos_x+(random(100))), (finger_pos_y+(random(100))) );
  ellipse(finger_pos_x, finger_pos_y, sprayProximity, sprayProximity);


  if (random(1) < 0.1)
  {
    drip();
  }

  if (random(1) > 0.5) {
    spray();
  }


  //}
  if (frameCount % 4 == 0) {
    sprayTravel = floor(dist(finger_pos_x, finger_pos_y, finger_pos_x, finger_pos_y));
    if (sprayTravel >= 1) {
      int oldWidth = sprayWidth;       
      sprayWidth = (oldWidth > sprayTravel ? sprayWidth-1 : sprayWidth+1);
      sprayWidth = constrain(sprayWidth, MIN_SPRAY_WIDTH, MAX_SPRAY_WIDTH);
    }
  }
}


void serialEvent(Serial myPort) { 
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');

  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    // split the string on the commas and convert the 
    // resulting substrings into an integer array:
    float[] colors = float(split(inString, ","));
    // if the array has at least three elements, you know
    // you got the whole thing.  Put the numbers in the
    // color variables:
    if (colors.length >=4) {
      // map them to the range 0-255:
      HueValue = map(colors[0], 0, 1023, 0, 255);
      SatValue = map(colors[1], 0, 1023, 0, 255);
      BriValue = map(colors[2], 0, 1023, 0, 255);
      state = colors[3];
      //println(state);
    }
  }
}




public void reset() {
  background(255);
  sprayWidth = 8;
  strokeCap(ROUND);
  strokeJoin(ROUND);
  stroke(sprayColor);
}


void mouseReleased() {
  drip();
  spray();
}


// Drip length is randomized. Use random opacity to create a fade like
// effect for the drippings.
void drip() {
  int dripLength = ceil(random(sprayWidth, 10 * sprayWidth));
  int dripWidth  = floor(random(sprayWidth/10, sprayWidth/2));
  strokeWeight(dripWidth);
  stroke(sprayColor, random(128, 255));
  line(finger_pos_x, finger_pos_y, finger_pos_x, finger_pos_y + dripLength);
}

// Randomly create droplets, as well as fade them to create the spray
// effect.
void spray() {

  float spotX = finger_pos_x + 6.0 * random(-sprayWidth, sprayWidth);
  float spotY = finger_pos_y + 6.0 * random(-sprayWidth, sprayWidth);
  int spotWidth = floor(random(sprayWidth / 4, sprayWidth));
  fill(sprayColor, random(64, 204));
  strokeWeight(random(4));
  ellipse(spotX, spotY, spotWidth, spotWidth);
}

// keyboard controls.
void keyPressed() {
  switch(key) {
  case 'r' :
    reset();
    break;
  case 'c' :
    sprayColor = color(random(255), random(255), random(128));
    break;
  case 'q' :
    exit();
    break;
  case 's' :
    saveFrame("spray.jpg");
    break;
  }
}


public class PFrame extends JFrame {
  public PFrame(int width, int height) {
    setBounds(width, height, width, height);
    track = new ArtisticData();
    add(track);
    track.init();
    setResizable(false);
    show();
  }
}



