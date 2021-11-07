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


class Agent {
  PVector location;
  float diameter = 10;
  boolean agentTouch;
  PVector speed;
  //PVector center;
  int agentIndex;
  int agentOrder = 0;
  //ArrayList<Agent> connected;
  ArrayList<PVector> pair;

  Agent(PVector loc, int i) {
    location = loc;
    agentIndex = i;
    //connected = new ArrayList<Agent>();
    pair = new ArrayList<PVector>();
    //center = new PVector(width/2, height/2);
  }

  void update(PVector s) {
    touch();
    move(s);
    show();
    drawConnection();
  }

  void move(PVector speed_) {
    //diameter = 40-agentOrder/10;
    if (agentTouch) {
      speed = new PVector(0, 0);
    } else {
      speed = speed_;
      speed.normalize().mult(2);
      if (center) {
        speed.add(PVector.sub(centerForce, location).normalize().mult(2));
      }
    }
    location.add(speed);
  }

  void show() {
    noStroke();
    if (agentTouch) {
      noFill();
      //fill(255, 0, 255);
    } else {
      fill(255);
    }
    ellipse(location.x, location.y, diameter, diameter); 
    fill(0);
    textAlign(CENTER, CENTER);
  }

  void touch() {
    agents.get(0).agentTouch = true;

    for (Agent a : agents) {
      if (this != a && a.agentTouch && !this.agentTouch) {
        float dd = PVector.dist(this.location, a.location);
        if (dd <= (this.diameter+a.diameter)/2) {
          this.agentTouch = true;
          //connected.add(this);
          pair.add(new PVector(this.agentIndex, a.agentIndex));
          order ++;
          agentOrder = order + 1;
        } else {
          this.agentTouch = false;
        }
      }
    }
  }

  void drawConnection() {
    if (pair != null) {
      for (PVector p : pair) {
        stroke(255);
        float sw = map(agentOrder, 0, agents.size(), diameter, 1);
        strokeWeight(sw);
        line(agents.get((int)p.x).location.x, agents.get((int)p.x).location.y, 
          agents.get((int)p.y).location.x, agents.get((int)p.y).location.y);
      }
    }
  }
}


class Particle{
  PVector location;               
  PVector velocity;             
  PVector acceleration;   
  float mass;                     
  float lifespan;            
  
  float R = random(255);     
  float G = random(255);
  float B = random(255);

  Particle(){
    location = new PVector(random(width), random(height));
    velocity = new PVector(random(-1, 1), random(-2, 0));
    acceleration = new PVector(0, 0);
    mass = 1;
    lifespan = 255;
  }
  Particle(PVector l){
    location = l.get();
    acceleration = new PVector(0, 0);
    velocity = new PVector(random(-1, 1),random(-2, 0));
    mass = 1;
    lifespan = 255;
  }
  void applyForce(PVector force){
    acceleration.add(PVector.div(force, mass));
  }
  void update(){
    velocity.add(acceleration);
    location.add(velocity);
    acceleration.mult(0);
    lifespan -= 0.5;
  }
  void display(){
    stroke(R,G,B,lifespan);
    fill(R,G,B,lifespan);
    ellipse(location.x, location.y, 20,20);
  }
  boolean isDead(){
    if(lifespan < 0.0){
      return true;
    }else{
      return false;
    }
  }
  void run(){
    update();
    display();
  }
}

class ParticleSystem{
  ArrayList<Particle> particles;          
  PVector origin;            
  float aliveTime;
  ParticleSystem(PVector location_){
    origin = location_.get();
    particles = new ArrayList<Particle>();
    aliveTime = 255;
  }
  void update(){
    origin = new PVector(mouseX,mouseY);
  }
  void addParticle(){                       
    float Rate = random(1);
    if(Rate < 0.5)
      particles.add(new Particle(origin));
    else
      particles.add(new Confetti(origin));
  }
  void run(){
    Iterator<Particle> it = particles.iterator();
    while(it.hasNext()){
      Particle p = it.next();
      p.run();
      if(p.isDead()){
        it.remove();
      }
    }
    aliveTime -=0.5;
  }
  boolean isDead(){
    if(aliveTime <= 0){
      return true;
    }else{
      return false;
    }
  }
  void applyForce(PVector force){        
    for(Particle p: particles){
      p.applyForce(force);
    } 
  }

class Confetti extends Particle{
  float R = random(255);
  float G = random(255);
  float B = random(255);
  Confetti(PVector l){
    super(l);
  }
  void display(){
    stroke(R, G, B, lifespan);
    fill(R,G,B,lifespan);
    ellipse(location.x, location.y,10,10);
  }
 }
}
