float r,speed,angle=0; float flag,x=1; int i = 0; void setup(){ size(800,800); background(255);
rectMode(CENTER);

}

void draw(){

strokeWeight(15); background(random(0,255));
background(255);
line(100,0,100,800); line(0,160,800,160); line(100,650,800,650); line(600,170,600,800); line(220,160,220,650); line(220,500,600,500);
line(100,280,220,280); line(100,550,220,550); line(700,0,700,160);

translate(160, 220); 
rotate(r);
rect(0,0,120,120);
fill(150);
resetMatrix();

translate(825, 405);
rotate(r); 
rect(0, 0, 450, 490);

fill(0); resetMatrix();

translate(160, 590); 
rotate(r); 
rect(0, 0, 120, 120);

fill(240); resetMatrix();

translate(400, -100); 
rotate(r); 
rect(0, 0, 600, 520);

fill(180); resetMatrix();

r = r + 0.02; if(x<=0){ flag = 1; } if(x>=1){ flag = -1; } x+=0.01*flag;

}
