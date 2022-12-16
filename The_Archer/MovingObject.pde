/* 
Moving Object: 

The base of the player, projectiles, and enemies.
Has basic physics and methods to help accomplish tasks involving their object in space.
*/

class MovingObject {
  PVector pos, vel, dim, maxVel;
  PVector[] bb = new PVector[2];  // bb[0] = bounding box size | bb[1] = bounding box location relative to center of entity
  final PVector acclGravity = new PVector(0, 1);
  boolean grounded, dying, spriteFlipped;
  boolean isAlive = true;
  float alpha = 60;
  float dyingTimer = 0;
  boolean touchingWall, nearWall;
  
  MovingObject(PVector pos, PVector vel, PVector dim, PVector[] bb) {
    this.pos = pos;
    this.vel = vel;
    this.dim = dim;
    this.bb = bb;
    this.maxVel = new PVector(vel.x * bgSpeed, vel.y);
  }
  
  void update() {
    move();
    grounded();
  }
  
  void move() {
    pos.add(vel);
  }
  
  void moveWithChar() {
    if(!player.nearWall)
      pos.x -= player.vel.x * 4;
  }
  
  void accl(PVector force) {
    vel.add(force);
  }
  
  void grounded() {
    if(pos.y + dim.y/2 + groundLevel >= height)
      grounded = true;
    else
      grounded = false;
  }
  
  // Helps vizualize their hitbox 
  void renderBB() {
    rectMode(CENTER);
    noFill();
    stroke(#FBFF1F, alpha);
    strokeWeight(3);
    rect(bb[1].x, bb[1].y, bb[0].x, bb[0].y); 
  }
  
  // Is the entity hit from another entity?
  boolean isHit(MovingObject obj) {
    return abs(this.pos.x + this.bb[1].x - obj.pos.x - obj.bb[1].x) < this.bb[0].x/2 + obj.bb[0].x/2 && abs(this.pos.y + this.bb[1].y - obj.pos.y - obj.bb[1].y) < this.bb[0].y/2 + obj.bb[0].y/2;
  }
  
  // Is the entity near another entity in a certain range?
  boolean isNear(MovingObject obj, float range) {
    return abs(this.pos.x + this.bb[1].x - obj.pos.x + obj.bb[1].x) < this.bb[0].x/2 + obj.bb[0].x/2 + range && abs(this.pos.y + this.bb[1].y - obj.pos.y + obj.bb[1].y) < this.bb[0].y/2 + obj.bb[0].y/2 + range;
  }
  
  // Check to see if the sprite needs to be flipped
  boolean isSpriteFlipped() {
    if(vel.x > 0)
      spriteFlipped = true;
    else if(vel.x < 0)
      spriteFlipped = false;
    return spriteFlipped;
  }
  
  // Calculate the angle between two points
  float angleBetween(PVector p1, PVector p2) {
    PVector dist = PVector.sub(p1, p2); // Calculating distance between two points
    return atan2(dist.y, dist.x);  // Calculating angle
  } 
}
