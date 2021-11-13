import processing.pdf.*;
import processing.svg.*;

import java.util.*;
ArrayList<ParticleSystem> systems;
//PVector gravity;

ArrayList<Agent> agents;
int totalNum = 2000;
int order = 0;
int index = 1;
PVector centerForce;
boolean center = false;

void setup() {
  size(800, 800);
  initiateCore();
  systems = new ArrayList<ParticleSystem>();
}

void draw() {
  background(0);
  if (index < totalNum) {
    PVector seeds = PVector.random2D().mult(width/2).add(new PVector(width/2, height/2));
    agents.add(new Agent(seeds, index));
    //agents.add(new Agent(new PVector(random(width/4, width*3/4), random(height)), index));
    index ++;
  }
  for (Agent a : agents) {
    PVector s = PVector.random2D().mult(4);
    a.update(s);
  }
  fill(255);
  text(index, 20, 20);
  
   Iterator<ParticleSystem> it = systems.iterator();
 while(it.hasNext()){
   ParticleSystem p = it.next();
  // gravity = new PVector(random(-0.1, 0.1), random(-0.1, 0.2));
  // p.applyForce(gravity);
   p.run();
   p.addParticle();
   if(p.isDead()){
     it.remove();
   }
 }
}

void initiateCore() {
  agents = new ArrayList<Agent>();
  agents.add(new Agent(new PVector(width/2, height/2), 0));
}

void keyPressed() {
  if (key == 'r') {
    center = false;
    agents.clear();
    order = 0;
    index = 1;
    initiateCore();
  }
  if (key =='s') {
    outputSVG();
  }
}

void outputSVG() {
  //beginRecord(SVG, "designOutput/drawConnection.svg");
  beginRecord(PDF, "designOutput/drawConnection.pdf"); 
  for (Agent a : agents) {
    a.drawConnection();
  }
  endRecord();
}

void mousePressed(){
  centerForce = new PVector(mouseX, mouseY);
  agents.get(0).location = centerForce;
  center = true;
  
  systems.add(new ParticleSystem(new PVector(mouseX,mouseY)));
  //gravity = new PVector(0, 0.1);
  
}
