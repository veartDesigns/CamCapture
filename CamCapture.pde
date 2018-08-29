import processing.video.*;
import ddf.minim.analysis.*;
import ddf.minim.*;

Movie myMovie;
Capture cam;
Minim minim;  

AudioPlayer song;
FFT fftLin;
FFT fftLog;
float height3;
float height23;
float spectrumScale = 3f;
int cellsize = 4;
int columns, rows;
float ZbrightDisplace = 1;
int freqAverages = 30;
float rectSize = 1;

int xOffset = 00;  
int yOffset = 00; 
int zOffset = 200; 
int kickSize = 4;
int  snareSize, hatSize;
color currentColors[];
boolean _switchToCam;
int currentInputWidth;
int currentInputHeight;
BeatDetect beat;
BeatListener bl;

void setup() {
  frameRate(60);
  size(1280, 720, P3D);

  myMovie = new Movie(this, "careto.mov");
  myMovie.loop();

  minim = new Minim(this);
  song = minim.loadFile("saintmotel2.mp3", 1024);
  // loop the file
  song.loop();
  song.pause();
  //song.mute();
  fftLin = new FFT( song.bufferSize(), song.sampleRate() );
  // calculate the averages by grouping frequency bands linearly. use 30 averages.
  fftLin.linAverages( freqAverages );
  // create an FFT object for calculating logarithmically spaced averages
  fftLog = new FFT( song.bufferSize(), song.sampleRate() ); 
  // calculate averages based on a miminum octave width of 22 Hz
  // split each octave into three bands
  // this should result in 30 averages
  fftLog.logAverages( 22, 3 );

  beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  beat.setSensitivity(300);  
  bl = new BeatListener(beat, song); 

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {

    cam = new Capture(this, cameras[0]);
    cam.start();
    println(cameras[0]);
  }


  // make a new beat listener, so that we won't miss any buffers for the analysis
}

void draw() {

  background(0);

  if (_switchToCam) {

    if (cam.available() == true) {
      cam.read();
      cam.loadPixels();
      currentInputWidth = cam.width;
      currentInputHeight = cam.height;

      // println("columns " + columns + " rows " +rows);
    }
    currentColors =  cam.pixels;
  }
  columns = currentInputWidth / cellsize;  // Calculate # of columns
  rows = currentInputHeight / cellsize;  // Calculate # of rows

  fftLin.forward( song.mix );
  fftLog.forward( song.mix );

  float averageFreq = 0;
  color cOfsset = color(0, 0, 0);
  rectSize = 1;
  // Begin loop for columns
  int lowBand = 10;
  int highBand = 15;
  // at least this many bands must have an onset 
  // for isRange to return true
  int numberOfOnsetsThreshold = 1;

  if ( beat.isRange(lowBand, highBand, numberOfOnsetsThreshold) )
  {
    //fill(255, 0, 0, 200);
    // rect(0, 0, (highBand-lowBand)*100, 100*lowBand);
    rectSize = kickSize;
  }

  //if ( beat.isKick() ) rectSize = kickSize;
  //if ( beat.isSnare() ) snareSize = 32;
  //if ( beat.isHat() ) rectSize = 32;


  //if ( beat.isOnset() ) rectSize = kickSize;
  //if ( beat.isKick() ) rectSize = kickSize;
  //if ( beat.isSnare() && j <= rows/3 && i<=(columns/3)*2) rectSize = 6;
  //if ( beat.isHat() && j>(rows/3)*2) rectSize = 6;
  //if ( beat.isSnare()) cOfsset = color(0, 100, 0);
  // Begin loop for rows
  for ( int j = 0; j < rows; j++) {
    for ( int i = 0; i < columns; i++) {

      int x = ( i*cellsize) ;  // x position
      int y = (j*cellsize);  // y position
      int loc = x + y*currentInputWidth;  // Pixel array location
      color c = currentColors[loc];  // Grab the color
      c += cOfsset;
      float percentSpectrum = ((float)j/(float)rows );
      int soundIndexFreq =(int)(percentSpectrum*(float)fftLin.specSize());
      //println(i+ " " +columns+" "+percentSpectrum + " "+  soundIndexFreq + "  "+fftLin.specSize() );
      averageFreq = fftLin.getBand(soundIndexFreq);
      float bright = brightness(c);
     
      if(bright <100){
        continue;
      } 
      float z = (bright*ZbrightDisplace)*(averageFreq*spectrumScale);
      // Translate to the location, set fill and stroke, and draw the rect
      pushMatrix();
      translate(-x+width-xOffset, y-yOffset, z -zOffset);//likea a mirror
      /*noFill();
       stroke(c);*/
      noStroke();
      fill(c);

      /*beginShape();
       vertex(-cellsize/2, -cellsize/2);
       vertex(-cellsize/2, cellsize/2);
       vertex(cellsize/2, cellsize/2);
       vertex(cellsize/2, -cellsize/2);
       endShape(CLOSE);*/

      //ellipseMode(CENTER);
      //ellipse(cellsize*rectSize, cellsize*.9f*rectSize, cellsize*rectSize, cellsize*rectSize);
      //rectMode(CENTER);
      rect(0, 0, cellsize*rectSize, cellsize*rectSize);
      popMatrix();
    }
  }
}
// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
  m.loadPixels();

  currentInputWidth = m.width;
  currentInputHeight = m.height;
  xOffset = (width/2) -(currentInputWidth/2);
  yOffset = -(height/2) + (currentInputHeight/2);
  currentColors = m.pixels;
}
void keyPressed() {
  if (key == ' ') {

    myMovie.stop();
    currentColors =  cam.pixels;
    _switchToCam = true;
    yOffset = 0;
    xOffset = 0;
    cellsize = 6;
    zOffset = 800;
  }
  if (key == 'a') {

    myMovie.play();
    _switchToCam = false;
    cellsize = 1;
    zOffset = 200;
  }
  if (key == 'b') {
    song.rewind();
    song.play();
  }
}