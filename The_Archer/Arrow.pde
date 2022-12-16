/* 
Arrow Class

Mainly for use by the player to shoot arrows at enemies.
Used in an arrayList.
Handles rendering, dying, and gravity movement. 
Other things are handled by the Projectile superclass.
*/ 

class Arrow extends Projectile {
  
  // PVector: Dimensions of arrow sprite
  // PVector[]: Bounding box of arrow 
  Arrow(PVector pos, PVector vel, int dmg, float rot) {
    super(pos, vel, dmg, rot, new PVector(10, 38), new PVector[]{new PVector(10, 38), new PVector(0,0)});
  }
  
  // Render arrow sprite
  void renderSprite() {
    pushMatrix();
    translate(pos.x, pos.y);
    handleSpriteStates();
    tint(255, alpha);
    image(sprArrow[0], 0, 0);
    popMatrix();
  }
  
  // Scale and rotate sprite
  void handleSpriteStates() {
    if(!grounded)
      rot = calcRot() + radians(90);
    rotate(rot);
    if(isSpriteFlipped())
      scale(-1, 1);
  }
  
  // Fade arrow out when it dies
  void handleDeath() {
    if(!isAlive && dying) {
      if(dyingTimer > 0)
        dyingTimer--;
      if(dyingTimer <= 60 && dyingTimer >= 0)  // Fade arrow out for a second
        alpha--;
    }
    else if(!isAlive && !dying) {  // Start dying process
      dyingTimer += 600;
      dying = true;
      println("ENTITY: Arrow is dying...");
    }
  }
  
  // Check if arrow hit the floor
  void handleFloor() {
    if (grounded && isAlive) {
      vel.y = 0;
      vel.x = 0;
      this.pos.y = height - dim.y/2 + 4 - groundLevel;
      int sound = int(random(4, 9));  // Random sound for hitting floor
      playSound(sfxShoot[sound]);
      isAlive = false;
    }
    else if(isAlive)
      accl(acclGravity);  // Add gravity to arrow
  }
}
