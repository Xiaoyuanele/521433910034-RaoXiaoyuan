class Plant extends Creature {
  Plant(PVector pos, DNA initDNA) {
    super(pos, initDNA);

    float lifetime = getLifetime();
    float speed = getMaxspeed();
    float size = getSize();

    lifetime = map(lifetime, 0, 1, 0.5, 1); //limit
    speed = map(speed, 0, 1, 0.5, 1);
    size = map(size, 0, 1, 0.5, 1);
    setLifetime(lifetime*7);
    setMaxspeed(speed*0.5);
    setSize(size*100);
    health = 100;

    maxLifetime=getLifetime();
    maxSize = getSize();
    maxHealth = health;

    breedProbability = 0.004;
  }

  @Override
    void display() {
    ellipseMode(CENTER);
    //stroke(0,lifetime);
    //stroke(0);
    noStroke();

    float alpha = map(health, 0, maxHealth, 100, 255);//touming

    r=map(lifetime, maxLifetime, 0, 0, 2*maxSize);
    if (r>maxSize) {
      r = maxSize;
    }
    strokeWeight(8);
    stroke(#508932);
    fill(#7BC156, alpha);
    //green
    ellipse(position.x, position.y, r, r);

  }

  @Override
    Plant breed() {
    if (r==maxSize&&random(1) < breedProbability) {
      DNA childDNA = dna.dnaCopy();
      childDNA.mutate(0.01); //mutate
      PVector childPosition = new PVector(random(position.x-100, position.x+100), 
        random(position.y-100, position.y+100));
      return new Plant(childPosition, childDNA);
    } else {
      return null;
    }
  }

  @Override
    void move() {
    float vx = map(noise(xoff), 0, 1, -maxspeed, maxspeed);
    float vy = map(noise(yoff), 0, 1, -maxspeed, maxspeed);
    velocity = new PVector(vx, vy); 
    xoff += 0.01;
    yoff += 0.01;

    //velocity.limit(maxspeed);

    //println(velocity);
    velocity.add(acceleration); 
    velocity.limit(maxspeed); 
    //println(velocity);
    position.add(velocity); 

    acceleration.mult(0);
  }

  @Override
    boolean dead() {
    if (lifetime<0.0 || health<0.0) {
      return true;
    } else {
      return false;
    }
  }
}
