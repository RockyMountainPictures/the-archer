// Plasma: The project that enemies use to fight against the player.

class Plasma extends Projectile {
  
  PImage spriteCurrent;
  PImage[] activeFrames;
  int currFrame = 0;
  int animationRate = 5;
  
  Plasma(PVector pos, PVector vel, int dmg, float rot) {
    super(pos, vel, dmg, rot, new PVector(10, 38), new PVector[]{new PVector(10, 38), new PVector(0,0)});
    this.activeFrames = sprPlasma;
    this.spriteCurrent = sprPlasma[0];
  }
  
  void renderSprite() {
    pushMatrix();
    translate(pos.x, pos.y);
    tint(255, alpha);
    image(handleSpriteStates(), 0, 0);
    popMatrix();
  }
  
  // Handle its basic animation
  PImage handleSpriteStates() {
    // Check health to change sprite accordingly
    if (!paused) { // Lock sprite position when paused
      if(frameCount % animationRate == 0) {
        if(currFrame < activeFrames.length-1)
          currFrame++;
        else
          currFrame = 0;
        spriteCurrent = activeFrames[currFrame];
      }
    }
    return spriteCurrent;
  }
  
  // Kill it slowly if it's not alive
  void handleDeath() {
    if(!isAlive && dying) {
      if(dyingTimer > 0)
        dyingTimer--;
      if(dyingTimer <= 60 && dyingTimer >= 0)
        alpha--;
    }
    else if(!isAlive && !dying) {
      dyingTimer += 30;
      dying = true;
      println("ENTITY: Plasma is dying...");
    }
  }
  
}
