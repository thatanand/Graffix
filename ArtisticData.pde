public class ArtisticData extends PApplet {
  int grid = 50;
  Capture motionCam;

  Boolean beatCalculate = false;


  public void setup() {
    size(960, 600);
    cp5 = new ControlP5(this);
    smooth();
    minim = new Minim(this);
    selectInput("Select a song:", "songSelected");

    // replace the default controlP5 button with an image.
    // button.setImages(defaultImage, rolloverImage, pressedImage);
    // use button.updateSize() to adjust the size of the button and 
    // resize to the dimensions of the defaultImage


    background(0);
    noStroke();
    motionCam = new Capture(this, 160, 90, 30);
    motionCam.start();
  }

  void songSelected(File selection) {
    if (selection == null) {
      println("No music track was loaded.");
    } 
    else {
      println("You have selected " + selection.getAbsolutePath());
      player = minim.loadFile(selection.getAbsolutePath(), 2048);
      musicTrack = selection.getAbsolutePath();
      beat = new BeatDetect(player.bufferSize(), player.sampleRate());
       beat.setSensitivity(200);
  hatSize = 16;
  bl = new BeatListener(beat, player);
  beatCalculate = true;
    }
  }

  public void draw() {

    background(0);
    if (beatCalculate) {
      if ( beat.isHat() ) hatSize = 32;
      hatSize = constrain(hatSize * 0.95, 10, 50);
    }
    stroke(255);
    strokeWeight(2);
    noFill();
    ellipse(finger_pos_x, finger_pos_y, sprayProximity, sprayProximity);
    //println(finger_pos_y);
    display();
    if (motionCam.available()) {
      motionCam.read();
    }
    image(motionCam, 800, 0);
  }


    void display() {
      strokeWeight(2);
      stroke(255);
      rect(0, 0, 800, 500);
      for (int i = 0; i < 800; i+=grid) {
        strokeWeight(1);
        stroke(60);
        line (i, 0, i, 500);
      }
      for (int i = 0; i < 500; i+=grid) {
        strokeWeight(1);
        stroke(60);
        line (0, i, 800, i);
      }
      fill(sprayColor);
      ellipse(width-80, 160, sprayProximity, sprayProximity);
      fill(sprayColor, 255);
      ellipse(width-80, 160, sprayProximity, sprayProximity);
    }



    public void controlEvent(ControlEvent theEvent) {
      // println(theEvent.getController().getName());
    }

    // function buttonA will receive changes from 
    // controller with name buttonA
    public void buttonA(int theValue) {
      // println("a button event from buttonA: "+theValue);
      playPressed=true;
    }

    public void buttonB(int theValue) {
      //println("a button event from buttonB: "+theValue);
      println("Music has been stopped");
      stopMusicPressed = true;
      //STOP MUSIC
    }

    public void buttonC(int theValue) {
      //println("a button event from buttonC: "+theValue);
      println("Recording Canvas and Artistic Date windows");
      recordPressed=true;
      //RECORD THE SKETCH
    }

    public void buttonD(int theValue) {
      // println("a button event from buttonD: "+theValue);
      println("You have stopped recording. Please check folder");
      stopRecordPressed=true;
      //STOP RECORDING THE STRETCH
    }

    public void buttonE(int theValue) {
      println("Canvas has been reset");
      resetPressed=true;
      //RESET THE SKETCH
    }



    public void buttonF(int theValue) {
      println("Image has been saved. Check for \"spray.jpg\"");
      saveFramePressed = true;
    }
    
    public void buttonG(int theValue) {
      println("Music loaded");
      playPressed = true;
    }
  }

