/**
 * Caleidoscopio
 * La parte de la cámara y el GUI
 * se basan en el ejemplo
 * "CameraGettingted" de la
 * biblioteca Ketai.
 * Parts from 
 *    Ketai Sensor Library for Android:
 *    http://ketai.org
 *    2017-09-01 Daniel Sauter/j.duran
 * La parte de calidoscopio es de
 * 2018-12-8 Jose G Moya Y
 */
  /* 
  * https://github.com/jgmy/caleidoscopio-JG.git
  */
import android.os.Environment.*;
import ketai.camera.*;
import android.media.*;
import android.util.Log;
import android.net.Uri;
private static final String TAG = "com.josemoya.blogspot.com.caleidoscopio";
KetaiCamera cam;

final int HEXAGON=1;
final int HEXSTAR=2;
final int MEGAHEX=3;
int shapeType=MEGAHEX;
/* 
 * this changes to CANT SAVE if no
 * permission is granted:
 */
String saveWord="Save"; 

PImage imagen,imagen2,msk;
PImage miniPh;
PGraphics mskbuff;
int px,py;
void setup() {
  fullScreen();
  orientation(LANDSCAPE);

  imageMode(CENTER);
  textAlign(CENTER, CENTER);
  textSize(displayDensity * 25);
  cam = new KetaiCamera(this, 1280, 720, 24);
  imagen=createImage(
    min(cam.height,cam.width),
    min(cam.height,cam.width),
    ARGB
    );
    miniPh=createImage(min(height/4,width/4),min(height/4,width/4),ARGB);
 
  px=cam.width/2;
  py=cam.height/2;
  /* Setup a buffer to create the triangle mask */
  mskbuff=createGraphics(imagen.width,imagen.height);
  makemask(mskbuff);
  /* We can't use PGraphics as mask,
   * we need to use a PImage instead
  */
  msk=createImage(mskbuff.width,mskbuff.height,ARGB);
  msk=mskbuff.get(0,0,msk.width,msk.height);
  
  imageMode(CENTER);
  
}

void draw() {
//float absurd=0.01*((frameCount %300)-150);

  /* camera active? */
  if (cam != null && cam.isStarted()){
    /* preview camera */
    image(cam, width/2, height/2, width, height);
    /* imagen is a frame from camera */
    imagen=cam.get(
      max(0,px-imagen.width/2),
      max(0,py-imagen.height/2),
      imagen.width,
      imagen.height
      );
    
    /* mask image with a triangle shape */
    imagen.mask(msk);
    
    //image(imagen,width/2,height/2);
    //image(msk,width/2,height/2);
    
    /* 
     * 3 rotated images along with
     * 3 mirrored-rotated images
     */
      for (int f=0;f<6;f++){
        pushMatrix();
        /* move to center*/
        translate(width/2,height/2);
        /* mirror even images*/
        if (f%2==0) scale(1,-1);
        /* rotate image */
        rotate(f*2*PI/3);
        pushMatrix();
        /* move away from center half radius*/
        translate(0,imagen.height/2);
        image(imagen,0,0);
        if (shapeType==HEXSTAR||shapeType==MEGAHEX){
           /* and now another */
           /* same angle, opposite side*/
           translate(0,-1.5*imagen.height);
           image(imagen,0,0);
           
        }
        
        popMatrix();
        popMatrix();
      }
      if (shapeType==MEGAHEX){
        for (int f=0;f<6;f++){
          pushMatrix();
          /* move to center*/
          translate(width/2,height/2);
          /* mirror even images*/
          if (f%2==0) scale(1,-1);
             /* rotate image */
             rotate(f*2*PI/3);
             pushMatrix();
             /* sin( pi/3 ) to get apothem */
             translate(sin(PI/3)*1.5*imagen.height,-0.25*imagen.height);
             image(imagen,0,0);
             popMatrix();
             pushMatrix();
             translate(-sin(PI/3)*1.5*imagen.height,-0.25*imagen.height);
             image(imagen,0,0);
             popMatrix();
             popMatrix();
         }
         //text(nf(absurd,3,3),200,200);
        }
  }
  else
  {
    background(128);
    textSize(displayDensity*50);
    text ("Caleidoscopio de JG" , width/2, height/2-displayDensity*50);
    textSize(displayDensity*25);
    text("Camera is currently off.", width/2, height/2);
    text("See the source at",width/2, 3*height/4);
    text("https://github.com/jgmy/caleidoscopio-JG.git",width/2, 3*height/4+displayDensity*25);
  }
  image(miniPh,width-miniPh.width,height/2);
  drawUI();
}

 /* Create equilateral triangle mask */
 void makemask(PGraphics img){
 int wi=img.width;
 int he=img.height;
  float cx=wi/2;
  float cy=he/2;
  float r=min(wi,he)/2;
  float step=2*PI/3;
  float ang=PI/3+HALF_PI;
  noStroke();
  
  
  img.beginDraw();
  img.background(0,0,0,0);
  img.fill(255,255,255);
  img.triangle(
     cx+r*cos(ang+step*0),cy+r*sin(ang+step*0),cx+r*cos(ang+
     step*1),cy+r*sin(ang+step*1),
     cx+r*cos(ang+step*2),cy+r*sin(ang+step*2)
  );
  img.endDraw();
  
}

void capture(){
  PGraphics Ph;
  String salida;
  if ( (cam == null) || !cam.isStarted()){
    println("no camera - no photo");
    return;
  }
  /* imagen is a frame from camera */
      noFill();
      stroke(255,255,255);
      strokeWeight(5);
      rectMode(CORNERS);
      rect(0,0,width,height);
    switch (shapeType){
      case MEGAHEX:
      case HEXSTAR:
        Ph=createGraphics(imagen.width*4,imagen.height*4);
        break;
      case HEXAGON:
      default:
        Ph=createGraphics(imagen.width*2,imagen.height*2);
    }
    Ph.beginDraw();
    Ph.imageMode(CENTER);
    Ph.background(0,0,0,0);
    /* 
     * 3 rotated images along with
     * 3 mirrored-rotated images
     */
      for (int f=0;f<6;f++){
        Ph.pushMatrix();
        /* move to center*/
        Ph.translate(Ph.width/2,Ph.height/2);
        /* mirror even images*/
        if (f%2==0) Ph.scale(1,-1);
        /* rotate image */
        Ph.rotate(f*2*PI/3);
        /* move away from center half radius*/
        Ph.translate(0,imagen.height/2);
        Ph.image(imagen,0,0);
        if (shapeType==HEXSTAR||shapeType==MEGAHEX){
           /* and now another */
           /* same angle, opposite side*/
           Ph.translate(0,-1.5*imagen.height);
           Ph.image(imagen,0,0);
           
        }
     
        Ph.popMatrix();
      }
      if (shapeType==MEGAHEX){
        for (int f=0;f<6;f++){
          Ph.pushMatrix();
          /* move to center */
          Ph.translate(Ph.width/2,Ph.height/2);
          /* mirror even images*/
          if (f%2==0) scale(1,-1);
          /* rotate image */
          Ph.rotate(f*2*PI/3);
          Ph.pushMatrix();
          /* sin( pi/3 ) to get apothem */
          Ph.translate(sin(PI/3)*1.5*imagen.height,-0.25*imagen.height);
          Ph.image(imagen,0,0);
          Ph.popMatrix();
          Ph.pushMatrix();
          Ph.translate(-sin(PI/3)*1.5*imagen.height,-0.25*imagen.height);
          Ph.image(imagen,0,0);
          Ph.popMatrix();
          Ph.popMatrix();
        }
      }
      String outfolder=
      "//storage/emulated/0/"+
      android.os.Environment.DIRECTORY_DCIM;
     ;
      
      println(outfolder);
      
      salida=outfolder+"/Caleidoscopio_"+
             nf(year(),4)+
             nf(month(),2)+
             nf(day(),2)+"_"+
             nf(hour(),2)+
             nf(minute(),2)+
             nf(second(),2)+"_"+
             nf(millis(),6)+".png";
             
      Ph.endDraw();
      if(! hasPermission("android.permission.WRITE_EXTERNAL_STORAGE"))
      {
        requestPermission("android.permission.WRITE_EXTERNAL_STORAGE", "managewritepermission");
      }
      
      Ph.save(salida);
      miniPh=Ph.get();
      miniPh.resize(
        min(height/4,width/4),
        min(height/4,width/4)
      );
      
      /* Agregar la foto a la galería */
      MediaScannerConnection.scanFile(
        getContext(), 
        new String[] { 
            salida 
          }, 
          null, 
          new MediaScannerConnection.OnScanCompletedListener() 
          { 
            @Override public void onScanCompleted(String path, Uri uri)
              { 
               Log.i(TAG, "Scanned " + path); 
               } 
          
          }
        );
     
}
void managewritepermission(boolean granted){
  if(!granted) saveWord="CAN'T SAVE";
}

void onCameraPreviewEvent()
{
  cam.read();
}

void mousePressed()
{
  //Toggle Camera on/off
  if (mouseX < width/4 && mouseY < 100)
  {
    if (cam.isStarted())
    {
      cam.stop();
    } else
      cam.start();
  }

  if (mouseX < 2*width/4 && mouseX > width/4 && mouseY < 100)
  {
    if (cam.getNumberOfCameras() > 1)
    {
      cam.setCameraID((cam.getCameraID() + 1 ) % cam.getNumberOfCameras());
    }
  }
  if (mouseX < 3*width/4 && mouseX > 2*width/4 && mouseY < 100){
    capture();
  }
  //Toggle Camera Flash
  if (mouseX > 3*width/4 && mouseY < 100)
  {
    if (cam.isFlashEnabled())
      cam.disableFlash();
    else
      cam.enableFlash();
  }
}

void drawUI()
{
  pushStyle();
  textAlign(LEFT);
  fill(0);
  stroke(255);
  
  rect(0, 0, width/4, 100);
  rect(width/4, 0, width/4, 100);
  rect((width/4)*2, 0, width/4, 100);
  rect((width/4)*3, 0, width/4, 100);
  
  fill(255);
  if (cam.isStarted()) {
    text("Camera Off", 5, 80); 
    text(saveWord
    ,2*width/4+5,80);
  } else {
    text("Camera On", 5, 80);
  }

  if (cam.getNumberOfCameras() > 0)
  {
    text("Switch Camera", width/4 + 5, 80);
  }
  
  if (cam.isFlashEnabled())
    text("Flash Off", width/4*3 + 5, 80); 
  else
    text("Flash On", width/4*3 + 5, 80); 

  popStyle();
}
