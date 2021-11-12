PFont font;
String s;

void setup(){
  
frameRate(7);
size(1800,300);
background(0);

font=createFont("Arial",24);
s="I'll serenade you Swaying under the moonlight with me.";

}
void draw(){
background(0);

float ww = 0;
for (int i = 0; i < s.length(); i++) {
  fill(#D59AFA,#9AF3FA,#FA9AF5,#9AD1FA);
  char c = s.charAt(i); 
  textSize(floor(random(36,100))); 
  int cl = int(c); 
  //fill(#C890C9);
  //fill(random(154,209),100);
  fill(#C07BC1,cl); 
  text(c, ww, 150);
  ww += textWidth(c);
}
fill(20);
textFont(font);
textSize(64);
text(s,50,50);
}
