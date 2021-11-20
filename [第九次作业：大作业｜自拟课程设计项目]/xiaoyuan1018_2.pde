//import processing.pdf.*;

PImage img;
boolean SaveImage;

void setup(){
  size(1200,1900);
  initiate();
}

void initiate(){
  img=loadImage("mianbao.JPG");//zhi ding di fang chu cun

}
void draw(){
  //background(255);
  //image(img,0,0);
  
 
  img.loadPixels();
  
  
 // if(savePDF==true){   beginRecord(PDF,"mianbao.pdf");}//cun wei PDF 
  for(int i=0;i<50;i++){//for=frameRate  
  int xx=int(random(width));
  int yy=int(random(height));
  
  color c=img.get(xx,yy);
  
  
  float b=brightness(c);
  float eSize=map(b,0,255,5,50);
  
  noStroke();
  
  //fill(c);
  fill(c,105);//tou ming du
  ellipse(xx,yy,eSize,eSize);
 
}

//if(savePDF==true){   endRecord(); savePDF=false}
    //cun wei PDF
    
if(SaveImage){
  save("outPut/mianbao"+year()+month()+day()+"_"+hour()+minute()+second()+".JPG");
  SaveImage=false;
}
}

void keyPressed(){
  if(key=='s'){
  SaveImage=true;
}

}
