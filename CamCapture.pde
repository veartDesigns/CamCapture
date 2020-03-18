import processing.video.*;
import ddf.minim.analysis.*;
import ddf.minim.*;


Movie myMovie;
String movieName = "careto.mov";
Capture cam;
Minim minim;
AudioPlayer song;
String songName = "saintmotel2.mp3";
FFT fft;  

int webCamCellSize = 4;
int videoCellSize = 6;
int cellsize = 0;
int columns, rows;

float spectrumScale = 0;
float ZbrightDisplace = 1;
float zMusicDisplace = 1f;
float mutualDisplace = 1;
int freqAverages = 30;
float rectSize = 1;

int xOffset = 00;  
int yOffset = 00; 
int zOffset = 400; 

int brightnessTolerance = 100;

int  snareSize, hatSize;
color currentColors[];
boolean _switchToCam = false;
int currentInputWidth;
int currentInputHeight;
BeatDetect beat;
BeatListener bl;
PVector cameraSize= null;
PVector videoSize = null;

GravitySquare gravitySquares[];
boolean _groupPixels; 
boolean _animatingRegroup;
float regroupSpeed = 0.1f;
float maxZDisplace = 2;

void setup() {

  frameRate(30);
  size(1280, 720, P3D);
  InitializeVideoInputParams();
  InitializeMusic();
  myMovie = new Movie(this, movieName);
  myMovie.loop();

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {

    cam = new Capture(this, cameras[0]);
    cam.start();
    if (_switchToCam)InitializeWebCamParams(); 

    println(cameras[0]);
  }
}

void draw() 
{
  if (!cam.available()) return;

  background(0);

  if (_switchToCam) {

    ReadCameraColors();
  }
  rectSize = 1;
  fft.forward(song.mix);
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
      float brightFactor =(bright*ZbrightDisplace);
      float musicFactor = (fft.getAvg(j)*zMusicDisplace);
      float z = (musicFactor*brightFactor)*mutualDisplace;

      PVector position = new PVector(-x+width-xOffset, y-yOffset, z -zOffset);
      PVector size = new PVector(cellsize*rectSize, cellsize*rectSize);
      GravitySquare gSquare = gravitySquares[cntr];
      gSquare.DrawRect(size, c, draw, position);
      cntr++;
    }
  }

  CheckForAnimationPixels();
}
void CheckForAnimationPixels() {

  if (_animatingRegroup)
  {
    if (_groupPixels) 
    { 
      mutualDisplace -=regroupSpeed;
      if (mutualDisplace<0.1f)
      {
        _animatingRegroup = false;
        mutualDisplace = 0.1f;
      }
    } else 
    {
      mutualDisplace +=regroupSpeed;
 
      if (mutualDisplace>maxZDisplace) 
      {
        _animatingRegroup = false;
        mutualDisplace = maxZDisplace;
      }
    }
  }
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
  m.loadPixels();

  if (videoSize == null) { 
    videoSize = new PVector(m.width, m.height);
    currentInputWidth =(int) videoSize.x;
    currentInputHeight =(int) videoSize.y;
    xOffset = (width/2) -(currentInputWidth/2);
    yOffset = -(height/2) + (currentInputHeight/2);

    GetInputRowsColumns();
    FillGravitySquares();

    println(cellsize + "videoSize HARE " + videoSize + " columns " +columns + " rows "+rows);
  }
  currentColors = m.pixels;
}
void ReadCameraColors() {

  if (cam.available() == true) {
    cam.read();
    cam.loadPixels();

    if (cameraSize == null) { 
      cameraSize = new PVector(cam.width, cam.height);

      currentInputWidth = (int)cameraSize.x;
      currentInputHeight =(int) cameraSize.y;

      GetInputRowsColumns();
      FillGravitySquares();

      println("CAM HARE " + cameraSize + " columns " +columns + " rows "+rows);
    }
  }
  currentColors =  cam.pixels;
}
void InitializeWebCamParams() 
{
  ResetInputSizes();
  currentColors =  cam.pixels;
  _switchToCam = true;
  yOffset = 0;
  xOffset = 0;
  cellsize = webCamCellSize;
  zOffset = 800;

  println("InitializeWebCamParams  " + cellsize);
}
void InitializeVideoInputParams() 
{
  ResetInputSizes();
  _switchToCam = false;
  cellsize = videoCellSize;
  zOffset = 200;

  println("InitializeVideoInputParams  " + cellsize);
}

void InitializeMusic()
{
  minim = new Minim(this);
  song = minim.loadFile(songName, 2048);
  fft = new FFT(song.bufferSize(), song.sampleRate());
  fft.linAverages(512);
}
void ResetInputSizes() 
{
  videoSize = null;
  cameraSize = null;
}
void GetInputRowsColumns() 
{
  columns = currentInputWidth / cellsize;  // Calculate # of columns
  rows = currentInputHeight / cellsize;  // Calculate # of rows
}

void FillGravitySquares() 
{
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
void keyPressed() {
  if (key == ' ') {

    myMovie.stop();
    InitializeWebCamParams();
  }
  if (key == 'a') 
  {
    InitializeVideoInputParams();
    myMovie.play();
  }
  if (key == 'b') {
    song.rewind();
    song.play();
  }
  if (key == 'r') 
  {
    _groupPixels = true;
    _animatingRegroup = true;
  }
  if (key == 't') 
  {
    _groupPixels = false;
    _animatingRegroup = true;
  }
}
