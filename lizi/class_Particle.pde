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
    origin = new PVector(mouseX, mouseY);
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
    ellipse(location.x, location.y,35,35);
  }
 }
}
