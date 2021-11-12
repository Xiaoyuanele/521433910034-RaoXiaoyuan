PFont f;
color couleur;
ArrayList<Particle> pts;
boolean onPressed,showInstruction;
int appui;
int rayon=10;
int flag = 0;

void setup() 
{
  background(0);
  size(800,800);
  smooth();
  colorMode(RGB);
  rectMode(CENTER);
  pts = new ArrayList<Particle>();
  f = createFont("Calibri", 24, true);
  noStroke();
  fill(#82ADE5); //blue
  rect(45, 30, 60, 60); 
  fill(#C09FDE);//li zi hua bi
  rect(45, 110, 60, 60);
  fill(255);//white
  rect(45, 190, 60, 60); 

}

void draw()
{

  if (onPressed && flag == 1) //button 1
  {
    noStroke();
    fill(#82ADE5); //blue 
    //point(mouseX, mouseY);
    ellipse(mouseX, mouseY, 50, 50);
    fill(#82ADE5); //blue
    rect(45, 30, 60, 60); 
    fill(#C09FDE);//purple
    rect(45, 110, 60, 60);
    fill(255);//white
    rect(45, 190, 60, 60); 
  }
  if (onPressed && flag == 2) //button 3
  {
    noStroke();
    fill(0);//black/xiang pi 
    //point(mouseX, mouseY);
    ellipse(mouseX, mouseY, 50, 50);
    fill(#82ADE5); //blue
    rect(45, 30, 60, 60); 
    fill(#C09FDE);//purple
    rect(45, 110, 60, 60);
    fill(255);//white
    rect(45, 190, 60, 60); 
  }

  if (onPressed && flag == 0)
  {
    for (int i=0;i<10;i++)
    {
      Particle newP = new Particle(mouseX, mouseY, i+pts.size(), i+pts.size());
      pts.add(newP);
    }
  }

  for (int i=pts.size()-1; i>-1; i--)
  {
    Particle p = pts.get(i);
    if (p.dead)
    {
      pts.remove(i);
    }
    else
    {
      p.update();
       p.display();
    }
  }
  noStroke();
  fill(#82ADE5); //blue
  rect(45, 30, 60, 60); 
  fill(#C09FDE);//purple
  rect(45, 110, 60, 60);
  fill(255);//white
  rect(45, 190, 60, 60); 
}

void mousePressed()
{
  onPressed = true;
  if (showInstruction)
  {
    background(255);
    showInstruction = false;
  }
  if (mouseX > 15 && mouseX < 75 && mouseY > 0 && mouseY < 65) {
    flag = 1;
  }
  if (mouseX > 15 && mouseX < 75 && mouseY > 80 && mouseY < 140) {
    flag = 0;
  }
  if (mouseX > 15 && mouseX < 75 && mouseY > 160 && mouseY < 220) {
    flag = 2;
  }
}

void mouseReleased() 
{
  onPressed = false;
}

void keyPressed()
{
  if (key == 'c')
  {
    for (int i=pts.size()-1; i>-1; i--)
    {
      Particle p = pts.get(i);
      pts.remove(i);
    }
    background(0);
    noStroke();
    fill(#82ADE5); //blue
    rect(45, 30, 60, 60); 
    fill(#C09FDE);//purple
    rect(45, 110, 60, 60);
    fill(255);//white
    rect(45, 190, 60, 60); 
  }

  if(key == 'a')
  { 
    if(mouseX>120)
    {
      if(appui==0)
      {
        fill( random(255), random(255), random(255),random(255));
        noStroke();
        variableEllipse(mouseX,mouseY,pmouseX,pmouseY);
      }
    }
  }

   if(key=='s')
   {
     if(mouseX>105)
     {
       if(appui==0)
       {
         stroke(couleur);
         strokeWeight(rayon);
         line(pmouseX,pmouseY,mouseX,mouseY);
       }
     }
   }
   if(key=='w')
   {
     noStroke();
     fill(couleur);
     beginShape();
     vertex(mouseX,mouseY+30);
     vertex(mouseX-15,mouseY-17);
     vertex(mouseX+25,mouseY+10);
     vertex(mouseX-25,mouseY+10);
     vertex(mouseX+15,mouseY-17);
     endShape(CLOSE);
   }
 }

void variableEllipse(int x, int y, int px, int py) 
{
  noStroke();
  float speed = abs(x-px) + abs(y-py);
  //stroke(speed);
  ellipse(x, y, speed, speed);
}
