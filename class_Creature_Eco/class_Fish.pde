class Fish extends Creature {

  Fish(PVector pos, DNA initDNA) {
    super(pos, initDNA);

    health = 100;
    maxHealth = 100;

    breedProbability = 0.01; 
    matingProbability = 0.01;  

    float lifetime = getLifetime();
    float speed = getMaxspeed();
    float size = getSize();

    lifetime = map(lifetime, 0, 1, 0.5, 1); //limit size
    speed = map(speed, 0, 1, 0.5, 1);
    size = map(size, 0, 1, 0.5, 1);

    setLifetime(lifetime*100);
    setMaxspeed(speed*15);
    setSize(size*150);

    maxLifetime=getLifetime();
    maxSize = getSize();

    velocity = new PVector(random(-maxspeed, maxspeed), random(-maxspeed, maxspeed));
    velocity = velocity.limit(maxspeed);

    if (random(1)<0.5) {
      gender = true;
    } else {
      gender = false;
    }

    if (gender) {
      col = color(#F05D2C); 
      //red
    } else {
      col = color(#FF7F1C);
      //organge
    }

    separateWeight = 2;
    alignWeight = 0;
    cohesionWeight = 0;

    isRut = false;
  }

  @Override
    void update() {
    rut();
    move();
    //println(position.x);
    borders();
    //eat();
    display();

    health -= 0.1; 
    lifetime-=0.01;
    if (health<maxHealth/2) {
      isRut = false;
    }
  }

  @Override
    void display() {
    r = map(lifetime, maxLifetime, 0, 0, 2*maxSize);
    if (r>=maxSize) {
      r = maxSize;
    }
    float theta = velocity.heading2D() + radians(90);
    float alpha = map(health, 0, maxHealth, 100, 255);
    fill(col,alpha);
    strokeWeight(1);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    quad(0-r/2, 0, 0, 0-r, 0+r/2, 0, 0, 0+r);
    triangle(0, 0+r, 0+r/2, 0+r+r/2, 0-r/2, 0+r+r/2);
    fill(0);
    ellipse(0, 0-r/2, r/10, r/10);//eye
    popMatrix();
  }



  @Override   
    Fish breed() {
    if (isPregnancy && random(1) < breedProbability) {
      DNA childDNA = dna.dnaCross(fatherDNA);
      childDNA.mutate(0.01); 
      return new Fish(position, childDNA);
      //return null;
    } else {
      return null;
    }
  }

  @Override 
    void flock(ArrayList<? extends Creature> Creatures) {
    if (isRut) {
      PVector mat = mating(Creatures);
      PVector sep = separate(Creatures);   // Separation
      PVector ali = align(Creatures);      // Alignment
      PVector coh = cohesion(Creatures);   // Cohesion

      mat.mult(5);
      sep.mult(separateWeight);
      ali.mult(alignWeight);
      coh.mult(cohesionWeight);

      applyForce(mat);
      applyForce(sep);
      applyForce(ali);
      applyForce(coh);
    } else {
      PVector sep = separate(Creatures);   // Separation
      PVector ali = align(Creatures);      // Alignment
      PVector coh = cohesion(Creatures);   // Cohesion

      sep.mult(separateWeight);
      ali.mult(alignWeight);
      coh.mult(cohesionWeight);

      // Add the force vectors to acceleration
      applyForce(sep);
      applyForce(ali);
      applyForce(coh);
    }
  }

  void moveForaging(ArrayList<Flea> fleas) {
    PVector fora = foraging(fleas);

    fora.mult(5);

    applyForce(fora);
  }

  @Override
    void move() {

    velocity.add(acceleration); 
    velocity.limit(maxspeed);
    //println(velocity);
    position.add(velocity);  

    acceleration.mult(0);   
    //acceleration = new PVector(random(-maxspeed, maxspeed), random(-maxspeed, maxspeed));
    //acceleration.limit(maxforce);
    ////println(acceleration);
  }

  void eat(ArrayList<Flea> fleas) {
    //ArrayList<Plant> plants = P.getPlants();
    if (health<100) {
      for (Flea f : fleas) {
        float d = PVector.dist(position, f.position);
        if (d<r && r>f.r/2 &&f.r>r/6) {
          f.health-=100;
          health+=5;
          break;
        }
      }
    }
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
