 import java.util.*;
ArrayList<ParticleSystem> systems;
PVector gravity;
void mousePressed(){
  systems.add(new ParticleSystem(new PVector(mouseX, mouseY)));
  gravity = new PVector(0, 0.1);
}
void setup(){
  size(800, 800);
  systems = new ArrayList<ParticleSystem>();
}
void draw(){
 background(0);
 Iterator<ParticleSystem> it = systems.iterator();
 while(it.hasNext()){
   ParticleSystem p = it.next();
   gravity = new PVector(random(-0.1, 0.1), random(-0.1, 0.2));
   p.applyForce(gravity);
   p.run();
   p.addParticle();
   if(p.isDead()){
     it.remove();
   }
 }
}
