class Particle
{
  PVector loc, vel, acc;
  int lifeSpan, passedLife;
  boolean dead;
  float alpha, weight, weightRange, decay, xOfst, yOfst;
  color c;
  
  Particle(float x, float y, float xOfst, float yOfst)
  {
    loc = new PVector(x, y);
    
    float randDegrees = random(360);
    vel = new PVector(cos(radians(randDegrees)), sin(radians(randDegrees)));
    vel.mult(random(5));
    
    acc = new PVector(0,0);
    lifeSpan = int(random(60,90));
    decay = random(0.75, 0.9);
    c = color(random(255),random(255),255);
    weightRange = random(3,50);
    
    this.xOfst = xOfst;
    this.yOfst = yOfst;
  }
  
  void update()
  {
    if(passedLife>=lifeSpan)
    {
      dead = true;
    }else{
      passedLife++;
    }
    
    alpha = float(lifeSpan-passedLife)/lifeSpan * 70+50;
    weight = float(lifeSpan-passedLife)/lifeSpan * weightRange;
    
    acc.set(0,0);
    
    float rn = (noise((loc.x+frameCount+xOfst)*.01, (loc.y+frameCount+yOfst)*.01)-.5)*TWO_PI*4;
    float mag = noise((loc.y-frameCount)*.01, (loc.x-frameCount)*.01);
    PVector dir = new PVector(cos(rn),sin(rn));
    acc.add(dir);
    acc.mult(mag);
    
    float randRn = random(TWO_PI);
    PVector randV = new PVector(cos(randRn), sin(randRn));
    randV.mult(.25);
    acc.add(randV);
    
    vel.add(acc);
    vel.mult(decay);
    vel.limit(3);
    loc.add(vel);
  }
  
  void display()
  {
    strokeWeight(weight+0.05);
    stroke(0, alpha);
    point(loc.x, loc.y);
    
    strokeWeight(weight);
    stroke(c);
    point(loc.x, loc.y);
  }
}
