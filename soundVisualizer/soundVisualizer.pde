import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;
AudioPlayer audioPlayer;
FFT fft;

int bandAmount = 250;
float bandDistance;
float audioAmp = .2;

float[] lastBands = new float[bandAmount];

float circleSize = 3;
int rowAmount = 30;
int rowsShown = 5;
float showRowsFrom = rowAmount - rowsShown;
float upL = .1f;
float upC = .1f;
float upR = .9f;

void setup(){
  size(800,500,P3D);
  minim = new Minim(this);
  
  audioPlayer = minim.loadFile("song.wav",2048);
  audioPlayer.loop();
  
  fft = new FFT(audioPlayer.bufferSize(), audioPlayer.sampleRate());
  
  //fft.linAverages(bandAmount);
  //fft.window(fft.TRIANGULAR);

  
  //fft.window(FFT.BARTLETTHANN);
  bandDistance = (fft.specSize()-fft.specSize()*.1)  / bandAmount;
  frameRate(60);
  smooth();
  
  for(int i = 0; i < bandAmount; i++){
    lastBands[i]=0;
  }
}

void draw(){
  background(30);
  stroke(250);
  camera(width/2+circleSize, height/2, 700, width/2+10, height/2, 1, 0,1,0);
  
  float rowDist = height/(rowAmount+2);
  
  float[][] carry = new float[rowAmount][bandAmount];
  
  translate(bandDistance/2+circleSize, height-(rowDist+rowDist/2));
  //rotateX(radians(45));
  fft.forward(audioPlayer.mix);

  
  int i = 0;
  for (float band = fft.specSize() * .1; i < bandAmount; band+=bandDistance) {
    float amp = fft.getFreq(band) * audioAmp;
    float x = map(band, 0, bandDistance * bandAmount, 0, width);
    
    lastBands[i] = lerp(lastBands[i], amp, .1);
    if(i - 1 > 0) lastBands[i] = lerp(lastBands[i], lastBands[i-1], .3);
    carry[0][i] = lastBands[i];
    
    i++;
  }

  for(int row = 0; row < rowAmount; row++){
    
    if(row >= showRowsFrom)translate(0, -rowDist*rowsShown);
    
    for(int col = 0; col < bandAmount; col++){
      float x1 = map(col, 0, bandAmount, 0, width);
      float x2 = map(col+1, 0, bandAmount, 0, width);

      if(row >= showRowsFrom){
        
        pushMatrix();
        //translate(x1, -carry[row][col]);
        if(col+1<bandAmount)line(x1, -carry[row][col], x2, -carry[row][col+1]);
        //circle(0,0,circleSize);
        
        popMatrix();
      }
      
      if(row+1<rowAmount){
        
        if(col-1>0)
          carry[row+1][col-1] += carry[row][col] * upL;
          
        carry[row+1][col] += carry[row][col] * upC;
        
        if(col+1<bandAmount)
          carry[row+1][col+1] += carry[row][col] * upR;
      } 
    } 
  }
}
