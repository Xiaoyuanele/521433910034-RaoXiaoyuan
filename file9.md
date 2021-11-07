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

World world;

Boolean isOpenIntroduce;
void setup() {
  size(800, 800);
  frameRate(60);

  world = new World(150, 50, 10);
  textFont(createFont("KaiTi-48.vlw", 48));
  isOpenIntroduce = true;
}

void draw() {
  //background(200);    grey
  background(#8EB7D8);
  //blue

  world.update();

  textSize(15);
  fill(50);
  text("Plants:" + (int)world.getPlantNum(), 20, 20);
  text("Fishes:" + (int)world.getFishNum(), 20, 40);
  text("Fleas:" + (int)world.getFleaNum(), 20, 60);
  rect(100, 7, 20, 12);
  rect(100, 27, 20, 12);
  rect(100, 47, 20, 12);
  fill(250);
  rect(105, 12, 10, 3);
  rect(105, 32, 10, 3);
  rect(105, 52, 10, 3);

//Inroduction
  if (isOpenIntroduce) {
    fill(0, 200);
    stroke(#82AD71);
    strokeWeight(5);
    rect(width/4, height/4, width/1.9, height/3, 20);
    textSize(30);
    fill(250);
    text("说明", width/2-30, height/4+40);
    textSize(20);
    text("按 “ i ” 退出/显示说明界面", width/4+20, height/4+70);
    text("左上角表示示植物、水蚤、鱼数量", width/4+20, height/4+100);
    text("鼠标单击左键生成鱼，右键水蚤，中键植物", width/4+20, height/4+130);
    text("鼠标拖拽持续生成",width/4+20,height/4+160);
    text("鼠标单击左上角“-”减少",width/4+20,height/4+190);
    text("鼠标在左上角“-”处拖拽持续减少",width/4+20,height/4+220);
}
}

void mouseDragged() {
  //print(0);
  if (mouseX>100&&mouseX<120&&mouseY>7&&mouseY<19) {
    world.reducePlant();
  } else if (mouseX>100&&mouseX<120&&mouseY>27&&mouseY<39) {
    world.reduceFish();
  } else if (mouseX>100&&mouseX<120&&mouseY>47&&mouseY<59) {
    world.reduceFlea();
  } else {
    if (mouseButton == LEFT) {
      print(1);
      world.addFish(new PVector(mouseX, mouseY));
    } else if (mouseButton == RIGHT) {
      world.addFlea(new PVector(mouseX, mouseY));
    } else if (mouseButton == CENTER) {
      world.addPlant(new PVector(mouseX, mouseY));
    }
  }
}

void mouseClicked() {
  //print(0);
  if (mouseX>100&&mouseX<120&&mouseY>7&&mouseY<19) {
    world.reducePlant();
  } else if (mouseX>100&&mouseX<120&&mouseY>27&&mouseY<39) {
    world.reduceFish();
  } else if (mouseX>100&&mouseX<120&&mouseY>47&&mouseY<59) {
    world.reduceFlea();
  } else {
    if (mouseButton == LEFT) {
      print(1);
      world.addFish(new PVector(mouseX, mouseY));
    } else if (mouseButton == RIGHT) {
      world.addFlea(new PVector(mouseX, mouseY));
    } else if (mouseButton == CENTER) {
      world.addPlant(new PVector(mouseX, mouseY));
    }
  }
}

void keyPressed() {
  if (key == 'i') {
    if (isOpenIntroduce) {
      isOpenIntroduce = false;
    } else {
      isOpenIntroduce = true;
    }
  }
}

class DNA {

  private HashMap<String, Float> genes=new HashMap<String,Float>();

  DNA() {
    genes.put("lifetime", random(0, 1.0));
    genes.put("speed", random(0, 1.0));
    genes.put("size", random(0, 1.0));
  }

  DNA(HashMap newgenes) {
    genes=newgenes;
  }

  public DNA dnaCopy() {
    HashMap<String, Float> childGenes = (HashMap<String,Float>)genes.clone();
    
    return new DNA(childGenes);
  }
  
  //交叉
  public DNA dnaCross(DNA fatherDNA){
    HashMap<String, Float> childGenes = (HashMap<String,Float>)genes.clone();
    HashMap<String, Float> fatherGenes = fatherDNA.genes;
    float lifetime = (fatherGenes.get("lifetime") + genes.get("lifetime"))/2;
    childGenes.put("lifetime",lifetime);
    float speed = (fatherGenes.get("speed") + genes.get("speed"))/2;
    childGenes.put("speed",speed);
    float size = (fatherGenes.get("size") + genes.get("size"))/2;
    childGenes.put("size",size);
    
    return new DNA(childGenes);
  }

  public void mutate(float m) {
    for (String key : genes.keySet()) {
      if (random(1)<m) {
        genes.put(key, random(0, 1));
      }
    }
  }
}


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

class World {
  ArrayList<Flea> fleas;
  ArrayList<Plant> plants;
  ArrayList<Fish> fishes;

  World(int plantsNum, int fleasNum, int fishNum) {
    plants = new ArrayList<Plant>();
    for (int i=0; i<plantsNum; i++) {
      PVector pos = new PVector(random(width), random(height));
      plants.add(new Plant(pos, new DNA()));
    }

    fleas = new ArrayList<Flea>();
    for (int i=0; i<fleasNum; i++) {
      PVector pos = new PVector(random(width), random(height));
      fleas.add(new Flea(pos, new DNA()));
    }

    fishes = new ArrayList<Fish>();
    for (int i=0; i<fishNum; i++) {
      PVector pos = new PVector(random(width), random(height));
      fishes.add(new Fish(pos, new DNA()));
    }
  }

  void update() {
    for (int i = plants.size()-1; i >= 0; i--) {
      Plant p = plants.get(i);
      p.update();
      if (p.dead()) {
        plants.remove(i);
      }
      Plant newP = p.breed();
      if (newP!=null) {
        plants.add(newP);
      }
    }


    for (Flea f : fleas) {
      f.flock(fleas);
      f.moveElude(fishes);
    }
    for (int i = fleas.size()-1; i >= 0; i--) {
      // All bloops run and eat
      Flea f = fleas.get(i);
      f.update();
      f.eat(plants);
      if (f.dead()) {
        fleas.remove(i);
      }
      Flea newP = f.breed();
      if (newP!=null) {
        fleas.add(newP);
      }
    }

    for (Fish f : fishes) {
      f.flock(fishes);
      f.moveForaging(fleas);
    }
    for (int i = fishes.size()-1; i >= 0; i--) {
      // All bloops run and eat
      Fish f = fishes.get(i);
      f.update();
      f.eat(fleas);
      if (f.dead()) {
        fishes.remove(i);
      }
      Fish newP = f.breed();
      if (newP!=null) {
        fishes.add(newP);
      }
    }
  }

  float getFishNum() {
    return fishes.size();
  }

  float getFleaNum() {
    return fleas.size();
  }

  float getPlantNum() {
    return plants.size();
  }

  void addFish(PVector pvector) {
    fishes.add(new Fish(pvector, new DNA()));
  }

  void addFlea(PVector pvector) {
    fleas.add(new Flea(pvector, new DNA()));
  }

  void addPlant(PVector pvector) {
    plants.add(new Plant(pvector, new DNA()));
  }

  void reduceFish() {
    fishes.remove(0);
  }
  void reducePlant() {
    plants.remove(0);
  }
  void reduceFlea() {
    fleas.remove(0);
  }
}
