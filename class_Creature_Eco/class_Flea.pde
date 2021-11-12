class Flea extends Creature {
  Flea(PVector pos, DNA initDNA) {
    super(pos, initDNA);

    health = 100;
    maxHealth = 100;

    breedProbability = 0.001; //breed
    matingProbability = 0.01;  //mating

    float lifetime = getLifetime();
    float speed = getMaxspeed();
    float size = getSize();

    lifetime = map(lifetime, 0, 1, 0.5, 1); //limit
    speed = map(speed, 0, 1, 0.5, 1);
    size = map(size, 0, 1, 0.5, 1);

    setLifetime(lifetime*50);
    setMaxspeed(speed*10);
    setSize(size*30);

    maxLifetime=getLifetime();
    maxSize = getSize();


    velocity = new PVector(random(-maxspeed, maxspeed), random(-maxspeed, maxspeed));
    velocity = velocity.limit(maxspeed);

    if (random(0, 1)<= 0.5) {
      gender = true;
    } else {
      gender = false;
    }

    if (gender) {
      col = color(#BCA8A1);
      //grey
    } else {
      col = color(#B4B37C);
      //grey
    }

    separateWeight = 1;
    alignWeight = 2;
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

    health -= 0.15; 
    lifetime-=0.03;

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

    println(health);

    ellipseMode(RADIUS);
    fill(col, alpha);
    strokeWeight(r/30);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);

    ellipse(0, 0, r/2, r);
    fill(0);
    ellipse(0, -r/2, r/10, r/10);//eye

    popMatrix();
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

  void moveElude(ArrayList<Fish> fishes) {
    PVector elu = elude(fishes);

    elu.mult(10);

    applyForce(elu);
  }

  PVector elude(ArrayList<Fish> fishes) {
    float neighbordist = r * 10;
    for (Fish f:fishes) {

      PVector comparison = PVector.sub(f.position, position);

      float d = PVector.dist(position, f.position);

      float  diff = PVector.angleBetween(comparison, velocity);
      if ((diff < periphery) && (d < neighbordist)) {
        PVector result = seek(f.position);
        result = new PVector(-result.x, -result.y);
        return result;
      }
    }
    return new PVector(0, 0);
  }

  @Override 
    Flea breed() {
    if (isPregnancy && random(1) < breedProbability) {
      DNA childDNA = dna.dnaCross(fatherDNA);
      childDNA.mutate(0.01); 
      return new Flea(position, childDNA);
      //return null;
    } else {
      return null;
    }
  }

  @Override
    void move() {
    velocity.add(acceleration); 
    velocity.limit(maxspeed); 
    //println(velocity);
    position.add(velocity); 

    acceleration.mult(0); 
  }

  //
  @Override  //
    PVector align (ArrayList<? extends Creature> creatures) {
    float neighbordist = size * 2;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Creature other : creatures) {

      PVector comparison = PVector.sub(other.position, position);
 
      float d = PVector.dist(position, other.position);

      float  diff = PVector.angleBetween(comparison, velocity);
      if ((diff < periphery) && (d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  void eat(ArrayList<Plant> plants) {
    //ArrayList<Plant> plants = P.getPlants();
    if (health<100) {
      for (Plant p : plants) {
        float d = PVector.dist(position, p.position);
        if (d<r) {
          p.health-=5;
          health+=1;
          break;
        }
      }
    }
  }

  //
  @Override
    boolean dead() {
    if (lifetime<0.0 || health<0.0) {
      return true;
    } else {
      return false;
    }
  }
}
