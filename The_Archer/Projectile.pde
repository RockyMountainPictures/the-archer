/*
Projectile Class:
Something that can hit other entities
*/

class Projectile extends MovingObject {
  
  int dmg;
  float rot;
  
  Projectile(PVector pos, PVector vel, int dmg, float rot, PVector dim, PVector[] bb) {
    super(pos, vel, dim, bb); 
    this.dmg = dmg;
    this.rot = rot;
  }
  
  void update() {
    super.update();
    handleFloor();
    handleDeath();
  }
  
  void move() {
    super.move();
    moveWithChar();
  }
  
  void handleFloor() {
    if (grounded && isAlive) {
      vel.y = 0;
      vel.x = 0;
      this.pos.y = height - dim.y/2 + 4 - groundLevel;
      isAlive = false;
    }
    else if(isAlive)
      accl(acclGravity);
  }
  
  void handleDeath() {
    if(!isAlive && dying) {
      if(dyingTimer > 0)
        dyingTimer--;
      if(dyingTimer <= 60 && dyingTimer >= 0)
        alpha--;
    }
    else if(!isAlive && !dying) {
      dyingTimer += 600;
      dying = true;
      println("ENTITY: Projectile is dying...");
    }
  }
  
  // Ensure proper rotation of the sprite
  float calcRot() {
    return vel.heading();
  }
}
