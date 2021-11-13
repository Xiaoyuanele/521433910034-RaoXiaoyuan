class Creature {
  PVector position;
  PVector acceleration; 
  PVector velocity; 

  float lifetime;    
  float maxspeed;    
  float maxforce;   
  float size; 
  float r; 

  float maxLifetime; 
  float maxSize;     
  float health;   
  float maxHealth;

  DNA dna;          
  DNA fatherDNA;

  float separateWeight;
  float cohesionWeight;
  float alignWeight;

  float breedProbability; 
  float matingProbability; 

  float xoff;
  float yoff; 

  float periphery = PI/2; 

  Boolean gender; 
  Boolean isRut;  
  Boolean isPregnancy; 

  color col; 

  Creature(PVector pos, DNA initDNA) {
    position=pos.copy();
    dna = initDNA;

    lifetime = map(dna.genes.get("lifetime"), 0, 1, 0, 1);
    maxspeed = map(dna.genes.get("speed"), 0, 1, 0, 1);
    size = map(dna.genes.get("size"), 0, 1, 0, 1);

    maxforce = 0.05;
    breedProbability = 0.005;
    alignWeight = 1;
    separateWeight = 1;
    cohesionWeight = 1;

    xoff = random(1000);
    yoff = random(1000);
    float vx = map(noise(xoff), 0, 1, -maxspeed, maxspeed);
    float vy = map(noise(yoff), 0, 1, -maxspeed, maxspeed);
    velocity = new PVector(vx, vy);



    //velocity.limit(maxspeed);
    //velocity = new PVector(random(-1, 1), random(-1, 1));

    acceleration = new PVector(0, 0);

    isRut = false;
    isPregnancy = false;
  }

  void update() {
    move();
    //println(position.x);
    borders();
    display();

    lifetime-=0.01;
  }

  void move() {
    velocity.add(acceleration); 
    velocity.limit(maxspeed);  
    //println(velocity);
    position.add(velocity);  

    acceleration.mult(0);
  }

  void display() {
    ellipseMode(CENTER);
    stroke(0);
    fill(0, lifetime);
    ellipse(position.x, position.y, r, r);
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void flock(ArrayList<? extends Creature> Creatures) {

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

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    //Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  // Cohesion 
  PVector cohesion (ArrayList<? extends Creature> creatures) {
    float neighbordist = r * 5; 
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Creature other : creatures) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); 
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);
    } else {
      return new PVector(0, 0);
    }
  }

  PVector separate (ArrayList<? extends Creature> creatures) {
    float desiredseparation = r*1.5; 
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Creature other : creatures) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  PVector align (ArrayList<? extends Creature> creatures) {
    float neighbordist = r * 3;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Creature other : creatures) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
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

  void rut() {
    //if (size == maxSize && !isrut && random(1)<breedProbability) {
    if (r >= maxSize && health>maxHealth/2) {
      //print(0);
      if (!isRut && !isPregnancy) {
        //print(1);
        if (random(1)<matingProbability) {
          //print(2);
          isRut = true;
          if (gender) {
            col = color(100, 0, 0);
            //print(2);
          } else {
            //print(1);
            col = color(0, 100, 0);
          }
        }
      }
    }
  }

  PVector mating(ArrayList<? extends Creature> creatures) {
    float neighbordist = r * 15;
    if (isRut) {
      for (Creature other : creatures) {
        if (other.isRut && gender != other.gender) {

          //PVector comparison = PVector.sub(other.position, position);

          float d = PVector.dist(position, other.position);

          //float  diff = PVector.angleBetween(comparison, velocity);
          if ( (d < neighbordist) && (d>r)) {
            return seek(other.position);
          } else if (d<r) { 
            //print(3);
            isRut = false;
            other.isRut = false;
            if (gender) {
              col = color(#F59E48);
              //organge
              other.col = color(#F56548); 
              //red

              isPregnancy = true;
              fatherDNA = other.dna;
            } else {
              col = color(#F59E48);
              //organge
              other.col = color(#F56548);
              //red

              other.isPregnancy = true;
              other.fatherDNA = dna;
            }
          }
        }
      }
    }
    return new PVector(0, 0);
  }


  PVector foraging(ArrayList<? extends Creature> creatures) {
    float neighbordist = r * 10;
    for (Creature c:creatures) {

      PVector comparison = PVector.sub(c.position, position);

      float d = PVector.dist(position, c.position);

      float  diff = PVector.angleBetween(comparison, velocity);
      if ((diff < periphery) && (d < neighbordist)) {
        return seek(c.position);
      }
    }
    return new PVector(0, 0);
  }

  public Creature  breed() {
    return null;
  };

  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  boolean dead() {
    if (lifetime<0.0) {
      return true;
    } else {
      return false;
    }
  }


  public float getLifetime() {
    return lifetime;
  }

  public void setLifetime(float lifetime) {
    this.lifetime=lifetime;
  }

  public float getMaxspeed() {
    return maxspeed;
  }

  public void setMaxspeed(float speed) {
    maxspeed=speed;
  }

  public float getSize() {
    return size;
  }

  public void setSize(float size) {
    this.size=size;
  }
}
