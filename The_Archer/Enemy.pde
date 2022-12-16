/*
Enemy Class:

Chases character and throws balls of something that deal damage.
This was a pain in the arse to code their projectiles.
But I am proud of the product, if a bit scuffed.
*/

class Enemy extends MovingObject{
  
  // Sprite Constants - Animations
  final int IDLE = 0;
  final int WALK = 1;
  final int ATTACK = 2;
  final int DIE = 3;
  
  PVector health, maxHealth;
  int dmg, dmgTimer, attackRecoverTimer;
  PImage spriteCurrent;
  boolean shooting;
  PVector maxVel;
  ArrayList<Plasma> plasmaBalls = new ArrayList<Plasma>();
  float vel1;
  
  int spriteState;
  int spriteStatePrev;
  
  PImage[] activeFrames;
  int currFrame = 0;
  int animationRate = 90;

  
  Enemy(PVector pos, PVector vel, PVector dim, PVector[] bb, PVector health, int dmg) {
    super(pos, vel, dim, bb);
    this.health = health;
    this.maxHealth = health;
    this.dmg = dmg;
    this.maxVel = vel;
    this.activeFrames = sprWitchIdle;
    this.spriteCurrent = sprWitchIdle[0];
    dmgTimer = int(random(30, 120));
  }
  
  // Movement, health, etc.
  void update() {
    if(isAlive) {
      move();
      grounded();
      handleHealth();
      handleAttack();
    }
    else
      handleDeath();
    handlePlasmas();
  }
  
  // Calc. movement trajectory
  void move() {
    pos.add(vel);
    vel.x = PVector.fromAngle(angleBetween(player.pos, this.pos)).x;
    vel.x *= 2;
    moveWithChar();
    
    vel.y = constrain(vel.y, -20, 60);
    //handleWalls();  // is free to move around!
    handleGravity();
  }
  
  // Quick dash towards the player
  void dash() {
    if(dmgTimer > -15) {
    // Need to configure
    float force = PVector.fromAngle(angleBetween(player.pos, this.pos)).x;
    force *= 25;
    println(force);
    accl(new PVector(force, vel.y));
    dmgTimer--;
    }
    else {
      attackRecoverTimer = 60;
      dmgTimer = 120;
    }
  }
  
  // Attack the player using either dash or shooting magic balls
  void handleAttack() {
     if (dmgTimer <= 0) {
      // if near, dash into player and try to hit them and damage them
      // otherwise, shoot player
      if(isNear(player, 500)) {
        println("ENTITY ACTION: Enemy dashing...");
        dash();
      }
      else if(isNear(player, 1920)) {
        shoot();
      }
     }
     else if(attackRecoverTimer > 0 && vel.x < 5) {  // Recovery time, it's a big workout to attack the player!
       //vel = new PVector(0, 0);
       attackRecoverTimer--;
     }
     else if(attackRecoverTimer == 0)  // Reset velocity after recovery time is over
       vel = maxVel;
     if(attackRecoverTimer <= 0 && dmgTimer >= 0)  // Deal damage every someodd seconds
       dmgTimer--;
     handleDash();
  }
  
  // Shoot magic/plasma balls
  void shoot() {
    if(dmgTimer > -30) {  // Stand still to act like enemy is charging up plasma ball
      vel = new PVector(0, 0);
      shooting = true;
      dmgTimer--;
    }
    else {  // Shoot the plasma
      println("ENTITY ACTION: Shooting plasma...");
      PVector plasmaPos = new PVector(this.pos.x, this.pos.y);
      // Calculating velocity
      PVector plasmaVel = PVector.fromAngle(calcPlasmaAngle());
      plasmaVel.mult(vel1);
      if(playerRightOfEnemy()) {
        plasmaVel.y = -plasmaVel.y;
        println("Player is right of enemy, flipping plasma velocity..."); 
      }
      if(playerAboveEnemy() && playerRightOfEnemy()) {
        plasmaVel.y = -plasmaVel.y;
        plasmaVel.x = plasmaVel.x;
        println("Player is above enemy, flipping plasma velocity..."); 
      }
      int plasmaDmg = 1;
      float plasmaRot = degrees(angleBetween(this.pos, player.pos));  // Calculating sprite rotation
      plasmaBalls.add(new Plasma(plasmaPos, plasmaVel, plasmaDmg, plasmaRot));
      dmgTimer = 240;
      attackRecoverTimer = 30;
      shooting = false;
    }
  }
  
  // Update movement of plasma and deal damage to player if it hits
  void handlePlasmas() {
    for (int i = 0; i < plasmaBalls.size(); i++) {
      Plasma p = plasmaBalls.get(i);
      p.update();
        
      if(p.isHit(player) && player.isAlive && p.isAlive) {
        println("ENTITY ACTION: Plasma hit player.");
        player.decHP(p.dmg);
        p.vel = new PVector(0, 0);
        p.dyingTimer += 30;
        p.isAlive = false;
      }
      if(p.isHit(player) && player.isAlive && !p.isAlive) {
        p.pos.add(player.vel);
      }
      if(p.isHit(player) && !player.isAlive && !p.isAlive && !player.dying) {
        p.dyingTimer = 30;
      }

      if(!p.isAlive && p.dyingTimer == 0) {
        plasmaBalls.remove(p);
        println("ENTITY: Plasma died.");
      }
    }
  }
  
  // Decrease player health if enemy dash was successful!
  void handleDash() {
    if(isNear(player, 0) && player.dmgdTimer > 90)
      player.decHP(1);
  }
  
  // Render the plasma ball sprite
  void renderPlasma() {
   for (int i = 0; i < plasmaBalls.size(); i++) {
      plasmaBalls.get(i).renderSprite();
   }
  }
  
  // Calculate the trajectory of the plasma (this took me an entire day to get it consistent)
  float calcPlasmaAngle() {
    float theta;
    float g = acclGravity.y;
    // Bottom middle
    PVector pPos = new PVector(player.pos.x, player.pos.y + player.dim.y/2);
    PVector ePos = new PVector(this.pos.x, this.pos.y + this.dim.y/2);
    PVector dist = PVector.sub(pPos, ePos);
    PVector deltaDist = new PVector(abs(dist.x), abs(dist.y));  // Overall dist between player and enemy
    dist.y = dist.y * -1;
    println(dist);
    
    // Set a certain velocity for the ball depending on deltaDist
    float deltaDistTotal = deltaDist.x + deltaDist.y;
    if (deltaDistTotal > 1000)
      vel1 = 45;
    else if (deltaDistTotal > 900)
      vel1 = 42.5;
    else if (deltaDistTotal > 800)
      vel1 = 40;
    else if (deltaDistTotal > 700)
      vel1 = 35;
    else if (deltaDistTotal > 600)
      vel1 = 32.5;
    else if (deltaDistTotal > 500)
      vel1 = 30;
    else if (deltaDistTotal > 400)
      vel1 = 25;
    else if (deltaDistTotal > 300)
      vel1 = 22.5;
    else if (deltaDistTotal > 200)
      vel1 = 20;
    else if (deltaDistTotal > 100)
      vel1 = 17.5;
    else if (deltaDistTotal < 100)
      vel1 = 15;
    
    // Some projectile motion physics stuff
    float a = (-g * pow(dist.x, 2) / pow(vel1, 2)) - dist.y;
    float b = sqrt(pow(dist.y, 2) + pow(dist.x, 2));
    theta = (acos(a/b) - atan(dist.x/dist.y)) / 2;
    float gamma = degrees(angleBetween(pPos, ePos));
    if(playerRightOfEnemy()) {  // Ensure plasma is going in the right direction :>
      gamma = map(gamma, 90, 180, 0, 90);
      return theta + radians(gamma);
    }
    else  // just do it if it's on the left!
      return theta - radians(gamma);
  }
  
  // Determines where the enemy is in relation to the player
  boolean playerBelowEnemy() {
    return player.pos.y + dim.y/2 - this.pos.y + dim.y/2 > 0;  
  }
  
  boolean playerAboveEnemy() {
    return player.pos.y + dim.y/2 - this.pos.y + dim.y/2 < 0;  
  }
  
  boolean playerLeftOfEnemy() {
    return player.pos.x - this.pos.x < 0;
  }
  
  boolean playerRightOfEnemy() {
    return player.pos.x - this.pos.x > 0;
  }

  // Kills enemy
  void handleDeath() {
    // Despawn timer
    // Fade away
    // Change sprite?
    vel = new PVector(0, 0);

    if(!isAlive && dying) {
      moveWithChar();
      if(dyingTimer >= 0)
        dyingTimer--;
      if(dyingTimer <= 30 && dyingTimer > 0)
        alpha -= 2;
      if(dyingTimer == 30 && (level == LVL_1 || level == LVL_2) && !checkAliveEnemies()) {
        PImage[] gemSprite = sprGem;
        PVector dim = new PVector(gemSprite[0].width, gemSprite[0].height);
        PVector pos = new PVector(this.pos.x, this.pos.y);
        int range = 50;
        interactables.add(new Gem(pos, dim, gemSprite, range));
      }
      if(dyingTimer <= 0) {
        println("ENTITY: Enemy is dead. Removing from ArrayList...");
        enemies.remove(this);
      }
    }
    else if(!isAlive && !dying) {
      dyingTimer += 120;
      dying = true;
      println("ENTITY: Enemy is dying...");
    }
  }
  
  // Kills enemy before handleDeath :>
  void handleHealth() {
    if(health.x <= 0)
      isAlive = false;
  }
  
  // Sticks the enemy to the ground
  void handleGravity() {
    if (grounded) {
      vel.y = 0;
      this.pos.y = height - dim.y/2 - groundLevel; 
    }
    else
      accl(acclGravity);
  }
  
  // Shows the enemy
  void renderSprite() {
    pushMatrix();
    translate(pos.x, pos.y);
    isSpriteFlipped();
    updateSpriteStates();
    if(!spriteFlipped)
      scale(-1, 1);
    tint(255, alpha);
    image(handleSpriteStates(), 0, 0);
    //renderBB();
    popMatrix();
  }
  
  // Handles animation
  PImage handleSpriteStates() {
    if (!paused) { // Lock sprite position when paused
      if(frameCount % animationRate == 0) {
        if(currFrame < activeFrames.length-1)
          if(spriteState == DIE && currFrame == activeFrames.length - 2)
            return spriteCurrent;
          else
            currFrame++;
        else
          currFrame = 0;
        spriteCurrent = activeFrames[currFrame];
      }
    }
    return spriteCurrent;
  }
  
  // Handles different animation states - similar to character (see character comments)
  void updateSpriteStates() {
    dim = new PVector(activeFrames[0].width, activeFrames[0].height);
    spriteState = IDLE;
    if(vel.x != 0)
      spriteState = WALK;
    if(shooting || (spriteStatePrev == ATTACK && currFrame != sprWitchAtk.length - 1 && attackRecoverTimer > 0))
      spriteState = ATTACK;
    if(!isAlive)
      spriteState = DIE;
          
    if(spriteState != spriteStatePrev) {
      switch(spriteState) {
        case(IDLE):
          activeFrames = sprWitchIdle;
          animationRate = 30;
          currFrame = 0;
          spriteCurrent = activeFrames[currFrame];
          break;
        case(WALK):
          activeFrames = sprWitchMove;
          animationRate = 8;
          currFrame = 0;
          spriteCurrent = activeFrames[currFrame];
          break;
        case(ATTACK):
          activeFrames = sprWitchAtk;
          animationRate = 3;
          dim = new PVector(activeFrames[0].width, activeFrames[0].height);
          currFrame = 0;
          spriteCurrent = activeFrames[currFrame];
          break;
        case(DIE):
          activeFrames = sprWitchDie;
          animationRate = 8;
          currFrame = 0;
          spriteCurrent = activeFrames[currFrame];
          break;        
      }
      spriteStatePrev = spriteState;
    }
    
    switch(spriteState) {
      case(IDLE):
        bb[0] = new PVector(activeFrames[currFrame].width, activeFrames[currFrame].height);
        bb[1] = new PVector(0, 0);
        break;
      case(WALK):
        bb[0] = new PVector(activeFrames[currFrame].width/1.5, activeFrames[currFrame].height);
        bb[1] = new PVector(0, 0);    
        break;
      case(ATTACK):
        bb[0] = new PVector(44, 128);
        bb[1] = new PVector(0, 0);
        break;
      case(DIE):
        bb[0] = new PVector(activeFrames[currFrame].width, activeFrames[currFrame].height);
        bb[1] = new PVector(0, 0);
        break;        
    }
  }
  
  
  float healthPercentage(boolean accountForShield) {
    if(accountForShield) {
      float totalHealth = health.x + health.y;
      float totalMaxHealth = maxHealth.x + maxHealth.y;
      return totalHealth / totalMaxHealth * 100;
    }
    else
      return health.x / maxHealth.x * 100;
  }
  
  void decHP(int dmg) {  // Decreases character's health
    if (health.y - dmg > 0)
      health.y -= dmg;
    else if (health.y - dmg < 0 && health.y > 0) {
      while (health.y > 0) {
        health.y--;
        dmg--;
      }
      health.x -= dmg;
    } 
    else
      health.x -= dmg;
  }
  
  // Fixes a bug where gem drops twice when two enemies are killed from the same arrow in the same frame
  boolean checkAliveEnemies() {
    for(int i = 0; i < enemies.size(); i++) {
      if(enemies.get(i).dyingTimer > this.dyingTimer || !enemies.get(i).dying)
        return true;
    }
    return false;
  }
}
