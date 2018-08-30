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

int webCamCellSize = 8;
int videoCellSize = 6;
int cellsize = 0;
int columns, rows;

float spectrumScale = 0;
float ZbrightDisplace = 0;
int kickSize = 1;

int freqAverages = 30;
float rectSize = 1;

int xOffset = 00;  
int yOffset = 00; 
int zOffset = 200; 

int brightnessTolerance = 100;
int gravitySquaresFramesDuration = 10;

int frameCntr;
int  snareSize, hatSize;
color currentColors[];
boolean _switchToCam;
int currentInputWidth;
int currentInputHeight;
BeatDetect beat;
BeatListener bl;
PVector cameraSize;
PVector videoSize;

GravitySquare gravitySquares[];

void setup() {

  frameRate(30);
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

  InitializeVideoInputParams();

  // make a new beat listener, so that we won't miss any buffers for the analysis
}

void draw() {

  background(0);

  if (_switchToCam) {

    ReadCameraColors();
  }

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
    rectSize = kickSize;
  }
  int cntr = 0;
  for ( int j = 0; j < rows; j++) {
    for ( int i = 0; i < columns; i++) {

      int x = ( i*cellsize) ;  // x position
      int y = (j*cellsize);  // y position
      int loc = x + y*currentInputWidth;
      color c = currentColors[loc];  // Grab the color

      float bright = brightness(c);
      boolean draw = true;
      if (bright <brightnessTolerance) {
        draw = false;
      }
      float z = (bright*ZbrightDisplace);
      // Translate to the location, set fill and stroke, and draw the rect

      PVector position = new PVector(-x+width-xOffset, y-yOffset, z -zOffset);
      PVector size = new PVector(cellsize*rectSize, cellsize*rectSize);
      GravitySquare gSquare = gravitySquares[cntr];
      gSquare.DrawRect(size, c, draw, position);
      cntr++;
    }
  }
  FramesCicleCheck();
}

void FramesCicleCheck() {
  frameCntr++;
  if (frameCntr>= gravitySquaresFramesDuration) {
    println("ENDCICLE");
    frameCntr = 0;
  }
} 
// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
  m.loadPixels();
  if (cameraSize == null) videoSize = new PVector(m.width, m.height);
  currentColors = m.pixels;
}
void keyPressed() {
  if (key == ' ') {

    myMovie.stop();
    InitializeWebCamParams();
  }
  if (key == 'a') {

    myMovie.play();
    InitializeVideoInputParams();
  }
  if (key == 'b') {
    song.rewind();
    song.play();
  }
}

void InitializeWebCamParams() {

  currentColors =  cam.pixels;
  _switchToCam = true;
  yOffset = 0;
  xOffset = 0;
  cellsize = webCamCellSize;
  zOffset = 800;

  GetInputRowsColumns();

  FillGravitySquares();
}
void InitializeVideoInputParams() {

  _switchToCam = false;
  cellsize = videoCellSize;
  zOffset = 200;
  currentInputWidth =(int) videoSize.x;
  currentInputHeight =(int) videoSize.y;
  xOffset = (width/2) -(currentInputWidth/2);
  yOffset = -(height/2) + (currentInputHeight/2);

  GetInputRowsColumns();

  FillGravitySquares();
}
void GetInputRowsColumns() {

  columns = currentInputWidth / cellsize;  // Calculate # of columns
  rows = currentInputHeight / cellsize;  // Calculate # of rows
}

void FillGravitySquares() {

  int totalInputShapes = rows*columns;
  gravitySquares  = null;
  gravitySquares = new GravitySquare[totalInputShapes];
  int cntr =0;

  for ( int j = 0; j < rows; j++) {
    for ( int i = 0; i < columns; i++) {

      gravitySquares[cntr] = new GravitySquare(false, true);
      cntr++;
    }
  }
}

void ReadCameraColors() {

  if (cam.available() == true) {
    cam.read();
    cam.loadPixels();

    if (cameraSize == null) cameraSize = new PVector(cam.width, cam.height);

    currentInputWidth = (int)cameraSize.x;
    currentInputHeight =(int) cameraSize.y;
  }
  currentColors =  cam.pixels;
}