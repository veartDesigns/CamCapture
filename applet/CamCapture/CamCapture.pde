/**
 * Getting Started with Capture.
 * 
 * Reading and displaying an image from an attached Capture device. 
 */
import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.video.*;

Minim minim;
AudioPlayer jingle;
FFT fft;
int varianzaZ=2;
int  varianzaAudio=550;
int distanciaZ=-1500;
int numPixelsx;
int numPixelsy;
int blockSize=7;
float z;
Capture cam;
void setup() {
frameRate(60);
  size(1280, 720, P3D);
  colorMode(RGB,255,255,255,100);
   noStroke();
  minim = new Minim(this);
  jingle = minim.loadFile("audio3.mp3", 2048);
  jingle.play();
  fft = new FFT(jingle.bufferSize(), jingle.sampleRate());
  fft.linAverages(512);
  cam = new Capture(this, 320, 240);
}


void draw() {

  background(0);
   fill(0, 10);
  rect(0, 0, width*6, height*6);
  
 translate(-500,-190,distanciaZ);
 
  fft.forward(jingle.mix);
  cam.read();
  for (int i = 0; i < cam.width; i+=2) {
    for (int j = 0; j < cam.height; j+=2) {

      color pix = (cam.get(i, j));
      z =brightness(pix);



      if(z>2) {
        //println("la z val= " + z);
        pushMatrix();
        translate(0,0,(-10+ fft.getAvg(j)* varianzaAudio+z*varianzaZ));
      //   strokeWeight(5);
       // stroke(pix);
         noStroke();
        fill(pix,90);
rect(350+(i*blockSize),10+(j*blockSize),blockSize,blockSize);
 //ellipse(350+(i*blockSize),10+(j*blockSize),blockSize,blockSize);
  
        popMatrix();
      }
 
    }
  }
}
void stop()
{
  // always close Minim audio classes when you finish with them
  jingle.close();
  minim.stop();

  super.stop();
}
void keyPressed() {
  if (key == '1') {
    jingle.close();
    minim.stop();
    minim = new Minim(this);
    jingle = minim.loadFile("audio.aif", 2048);
    jingle.play();
  }
  if (key == '2') {
    jingle.close();
    minim.stop();
    minim = new Minim(this);
    jingle = minim.loadFile("audio2.mp3", 2048);

    jingle.play();
  }
  if (key == '3') {
    jingle.close();
    minim.stop();
    minim = new Minim(this);
    jingle = minim.loadFile("audio3.mp3", 2048);

    jingle.play();
  }
}