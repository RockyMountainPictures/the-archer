/* 
Character Class

The class that the player is made from.
Character can:
  Move with the use of controls
  Shoot arrows using arrayList
  Pickup items
  Interact with interactables  
*/ 

class Char extends MovingObject {

  // -- Constants -- //
  // Accelerations
  final PVector acclJump = new PVector(0, -20);
  final PVector acclLunge = new PVector(2.5, -15);
  final PVector acclGravity = new PVector(0, 1);
  final PVector acclLeft = new PVector(-0.25, 0);
  final PVector acclRight = new PVector(0.25, 0);

  // Sprite Constants
  final int IDLE = 0;
  final int WALK = 1;
  final int RUN = 2;
  final int JUMP = 3;
  final int DASH = 4;
  final int ATTACK1 = 5;
  final int ATTACK2 = 6;
  
  final int shootCooldownMax = 20;

  // -- Variables -- //
  PVector health, maxHealth; // x = health | y = shield (regenerative health while not in combat)
  
  // Movement and timers
  boolean touchingWall, nearWall;
  float movementDamp = 0.75;
  int jumpCount = 0;
  int timerArrowVel = 0;
  int shootCooldown = 0;
  int dyingTimer;
  float dmgdTimer;
  
  // Arrows and other entities
  float angleBtwnMouse;
  boolean aiming;  // Is the character drawing the bow?
  PVector arrowPos, arrowVel;
  ArrayList<Arrow> arrows = new ArrayList<Arrow>();   // Arrows
  ArrayList<Item> inventory = new ArrayList<Item>();  // Items (gems)
  
  // Sprites and animations
  PImage spriteCurrent;
  int spriteState;
  int spriteStatePrev;
  PImage[] activeFrames;
  int currFrame = 0;
  int animationRate = 90;
  boolean spriteFlipped;
  
  // Sounds
  boolean walking, running, jumping, doubleJumping;  // Handles sounds when doing these things
  
  // -- Constructor -- //
  Char(PVector pos, PVector vel, PVector dim, PVector[] bb, PVector health, PVector maxHealth) {
    super(pos, vel, dim, bb);
    this.maxHealth = maxHealth;
    this.health = health;
    this.activeFrames = sprCharIdle;
    this.spriteCurrent = sprCharIdle[0];
    this.isAlive = true;
    this.alpha = 60;
  }
  
  // -- Methods -- //
  // Handles controls, health, death, and arrows on top of MovingObject 
  void update() {
    super.update();
    if(isAlive) {
      handleControls();
      handleArrows();
      handleHealth();
    }
    else
      handleDeath();
  }
  
  // Calculate movement of character
  void move() {
    super.move();
    vel.x *= movementDamp;
    vel.y = constrain(vel.y, -20, 60);
    handleWalls();
    handleGravity();
  }
  
  //  Checks for walls and corrects movement when near them
  void handleWalls() {
    touchingWall = false;
    nearWall = false;
    
    // Check for right wall
    if(pos.x + dim.x/2 > width) {
      pos.x = width - dim.y/2;  // Corrects character location
      touchingWall = true;
    }
    // Check for left wall
    if(pos.x - dim.x/2 < 0) {
      pos.x = dim.y/2;
      touchingWall = true;
    }
    
    // Ensure natural movement when background is not scrolling
    // Right wall
    if(pos.x + dim.x/2 > width - 400) {
      if(left) {
        PVector acclRunLeft = acclLeft.copy().mult(bgSpeed);
        accl(acclRunLeft);
      }
      if(right) {
        PVector acclRunRight = acclRight.copy().mult(bgSpeed);
        accl(acclRunRight);
      }
      nearWall = true; 
    }
    // Left wall
    if(pos.x - dim.x/2 < 400) {
      if(left) {
        PVector acclRunLeft = acclLeft.copy().mult(bgSpeed);
        accl(acclRunLeft);
      }
      if(right) {
        PVector acclRunRight = acclRight.copy().mult(bgSpeed);
        accl(acclRunRight);
      }
      nearWall = true;
    }
  }
  
  // Translate controls to actions
  void handleControls() {
    if (mousePressed && mouseButton == shootKey && !paused && state == GAMEPLAY && player.shootCooldown <= 0)  // Draw bow while holding down button constantly
      shoot = true;
    if (left)  // M<ove left
      accl(acclLeft);
    if (right)  // Move right
      accl(acclRight);
    if (jump && grounded || jump && jumpCount < 2  && !grounded)  // Single jump or double jump/lunge
      jump();
    if (grounded)  // Reset jump
      jumpCount = 0;
    if (left && run || right && run)  // Move faster
      run();
    if (shoot && shootCooldown <= 0)  // Draw bow and shoot arrow
      shoot();
    if (interact)  // Interact with interactables
      interact();
  }
  
  // Play walking and running sounds
  void handleSounds() {
    if(isAlive && !paused) {  // Only play when alive and not paused
    if((left || right) && (!walking || !running) && grounded) {
      if(run) {  // When running
        sfxChar[1].play();
        sfxChar[0].pause();
        walking = false;
        running = true;
      }
      else {  // When walking
        sfxChar[0].play();
        sfxChar[1].pause();
        running = false;
        walking = true;
      }
    }
    else if((!left && !right) || !grounded) {  // When idle
      walking = false;
      running = false;
      sfxChar[0].pause();
      sfxChar[1].pause();
    }

    // Loop sounds manually
    if(sfxChar[0].position() == sfxChar[0].length())
      sfxChar[0].rewind();
    if(sfxChar[1].position() == sfxChar[1].length())
      sfxChar[1].rewind();
    }
    else {  // Stop sounds when paused or dead
      sfxChar[0].pause();
      sfxChar[1].pause();
    }
  }

  // Jump!
  void jump() {
    grounded = false;
    jump = false;  // Only jump once
    jumpCount++;
    
    // Jump regularly first
    if (jumpCount == 1) {
      println("PLAYER ACTION: Jumping...");
      accl(acclJump);
      playSound(sfxChar[2]);  // Jump sound could be better :/
    }
    // Either jump again or lunge in a certain direction when double jumping
    else if (jumpCount == 2) {
      println("PLAYER ACTION: Double jumping...");
      PVector acclLungeTemp = acclLunge.copy();
      if(vel.y < 0)   // Still jumping
        acclLungeTemp.x *= 0.25;
      if(vel.y > 0)   // Falling + below
        acclLungeTemp.x *= 2;
      if(vel.y > 15)  // Falling fast
        acclLungeTemp.y *= 2;
      else if(vel.y > 10)  // Falling medium-fast
        acclLungeTemp.y *= 1.75;
      else if(vel.y > 5)   // Falling light
        acclLungeTemp.y *= 1.25;
      if(right)  // If moving right, lunge right
        accl(acclLungeTemp);
      else if(left) {  // If moving left, lunge left
        PVector acclLungeLeft = acclLungeTemp.copy();
        acclLungeLeft.x *= -1;
        accl(acclLungeLeft);
      }
      else {  // If not moving, jump up only
        PVector acclLungeUp = acclLungeTemp.copy();
        acclLungeUp.x = 0;
        accl(acclLungeUp);
      }
      playSound(sfxChar[3]);  // Jump sound could be better :/
    }
  }

  // Increase speed when runnning (doubled) 
  void run() {
    if(left) {
      PVector acclRunLeft = acclLeft.copy().mult(1);
      accl(acclRunLeft);
    }
    if(right) {
      PVector acclRunRight = acclRight.copy().mult(1);
      accl(acclRunRight);
    }
  }

  // Draw bow and shoot arrows
  void shoot() {
    PVector mouse;
    int arrowDmg = 1;
    float arrowRot;
    if(mousePressed)
      aiming = true;
    
    // When aiming, calculate arrow trajectory
    if (aiming) {
      if (timerArrowVel <= 1 && shoot) {  // At the start of drawing the bow
        println("PLAYER ACTION: Aiming arrow...");
        playSound(sfxShoot[0]);  // Drawing bow sound 
      }
      
      // Math
      arrowPos = new PVector(this.pos.x, this.pos.y);  // Initial position of arrow
      mouse = new PVector(mouseX, mouseY);
      float angle = angleBetween(pos, mouse) - PI;  // Initial angle of arrow
      arrowVel = PVector.fromAngle(angle);
      arrowVel.normalize();
      float arrowVelMult = map(timerArrowVel, 0, 60, 10, 75) / 2;  
      arrowVel.mult(arrowVelMult);  // Velocity of arrow
      arrowRot = degrees(angle);    // Calculating sprite rotation
      timerArrowVel++;
      if ((timerArrowVel > 60 || (!mousePressed && timerArrowVel > 1)) && shootCooldown <= 0) {  // Finally shoot arrow
        println("PLAYER ACTION: Shooting arrow...");
        arrows.add(new Arrow(arrowPos, arrowVel, arrowDmg, arrowRot));
        playSound(sfxShoot[1]);  // Arrow shooting sound
        sfxShoot[0].pause();  // Stop drawing bow sound
        shoot = false;
        timerArrowVel = 0;
        shootCooldown = shootCooldownMax;  // Put bow on cooldown (turn red)
      }
    }
  }
  
  // Update arrows movement
  void handleArrows() {
    if(shootCooldown > 0)  // Decrease bow cooldown
      shootCooldown--;
    for (int i = 0; i < arrows.size(); i++) {
      Arrow a = arrows.get(i);
      a.update();
        for(int j = 0; j < enemies.size(); j++) {
          Enemy e = enemies.get(j);
          if(a.isHit(e) && e.isAlive && a.isAlive) {  // If arrow hits an enemy, kill arrow and deal damage
            println("PLAYER ACTION: Arrow hit enemy.");            
            e.decHP(a.dmg);
            if(e.health.x == 0)  // Different sound when killing enemy
              playSound(sfxShoot[3]);
            else
              playSound(sfxShoot[2]);
            a.vel = new PVector(0, 0);
            a.dyingTimer += 600;
            a.isAlive = false;
          }
          if(a.isHit(e) && e.isAlive && !a.isAlive) {  // Latch arrow onto enemy (not the best implementation)
            a.pos.add(e.vel);
          }
          if(a.isHit(e) && !e.isAlive && !a.isAlive && !e.dying) {  // Remove arrow quicker when enemy is dead
            a.dyingTimer = 120;
          }
          if(a.isHit(e) && !e.isAlive && !a.isAlive && e.dying && e.currFrame > 3) {  // Arrows fall off of enemy when enemy dies
            a.accl(acclGravity);
          }
        }
      if(!a.isAlive && a.dyingTimer == 0) {  // Remove arrow when it is time... D:
        arrows.remove(a);
        println("ENTITY: Arrow died.");
      }
    }
  }
  
  // Render player's arrows
  void renderArrows() {
   for (int i = 0; i < arrows.size(); i++)
      arrows.get(i).renderSprite();
  }

  // Handle interactions with interactable objects
  void interact() {
    for(int i = 0; i < interactables.size(); i++) {
      Interactable obj = interactables.get(i);
      obj.isNear(player, obj.range);
    }
  }

  // Create arrow trajectory arc for helping with aiming
  void renderArrowTrajectory(PVector pos, PVector vel, float timerArrowVel) {
    float resolution = 2;
    PVector arrowPos, arrowVel;
    arrowPos = pos;
    arrowVel = vel;
    
    while(arrowPos.y < height - groundLevel * 1.5) {
      for(int i = 0; i < resolution; i++) {
        arrowPos.add(arrowVel);
        arrowVel.add(acclGravity);
      }
      pushMatrix();
      translate(arrowPos.x, arrowPos.y);
      int red = int(map(timerArrowVel, 0, 60, 0, 255));
      int green = int(map(timerArrowVel, 0, 60, 255, 0));
      fill(red, green, 0);
      noStroke();
      circle(0, 0, 10);
      popMatrix();
    }
  }
  
  // Render the inventory - DECOMMISSIONED
  //void renderInventory() {
  //  pushMatrix();
  //  translate(width/2, height/2);
  //  rectMode(CENTER);
  //  fill(255);
  //  stroke(0);
  //  strokeWeight(5);
  //  rect(0, 0, width/2, height/2);
  //  textAlign(CENTER, CENTER);
  //  textFont(fontItalic);
  //  textSize(48);
  //  fill(0);
  //  text("This is the inventory!", 0, 0);
  //  popMatrix();
  //}

  // Render character's sprite
  void renderSprite() {
    pushMatrix();
    translate(pos.x, pos.y);
    if(isAlive) {  // Handle animation and scaling
      isSpriteFlipped();
      updateSpriteStates();
    }
    if(spriteFlipped)
      scale(-1, 1);
    tint(255, alpha);
    image(handleSpriteStates(), 0, 0);
    //renderBB();  // To test bounding box around character
    popMatrix();
  }
  
  // Handle animation
  PImage handleSpriteStates() {
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
  
  // Handle animation states
  void updateSpriteStates() {
    float angle = angleBtwnMouse();
    dim = new PVector(activeFrames[0].width, activeFrames[0].height);
    // Handle animation states
    if(!paused) { // Lock animation state when paused
      spriteState = IDLE;
      if(left || right)
        if(run)
          spriteState = RUN;
        else
          spriteState = WALK;
      if(!grounded)
        spriteState = JUMP;
      if(shoot && shootCooldown <= 0)
        spriteState = ATTACK1;
      if(shoot && (angle < -30 && angle > -120) && shootCooldown <= 0)
        spriteState = ATTACK2;
    }
    // Handle animation states when changing states
    if(spriteState != spriteStatePrev) {
      switch(spriteState) {
        case(IDLE):
          if(shootCooldown <= 0)
            activeFrames = sprCharIdle;
          else
            activeFrames = sprCharRedIdle;
          animationRate = 90;
          currFrame = 0;
          spriteCurrent = activeFrames[currFrame];
          break;
        case(WALK):
          if(shootCooldown <= 0)
            activeFrames = sprCharMove;
          else
            activeFrames = sprCharRedMove;
          animationRate = 8;
          if(spriteStatePrev != RUN)
            currFrame = 0;
          spriteCurrent = activeFrames[currFrame];
          break;
        case(RUN):
          if(shootCooldown <= 0)
            activeFrames = sprCharMove;
          else
            activeFrames = sprCharRedMove;
          animationRate = 5;
          if(spriteStatePrev != WALK)
            currFrame = 0;
          spriteCurrent = activeFrames[currFrame];
          break;
        case(JUMP):
          if(shootCooldown <= 0)
            activeFrames = sprCharJump;
          else
            activeFrames = sprCharRedJump;
          animationRate = 10;
          currFrame = 0;
          spriteCurrent = activeFrames[currFrame];
          break;
        case(ATTACK1):
          activeFrames = sprCharAtk1;
          animationRate = 8;
          dim = new PVector(activeFrames[0].width, activeFrames[0].height);
          if(spriteStatePrev != ATTACK2)
            currFrame = 0;
          spriteCurrent = activeFrames[currFrame];
          break;
        case(ATTACK2):
          activeFrames = sprCharAtk2;
          animationRate = 8;
          if(spriteStatePrev != ATTACK1)
            currFrame = 0;
          spriteCurrent = activeFrames[currFrame];
          break;        
      }
      spriteStatePrev = spriteState;
    }
    // Handle frame by frame animation states (bounding boxes, bow cooldown, etc)
    switch(spriteState) {
      case(IDLE):
        if(shootCooldown <= 0)
          activeFrames = sprCharIdle;
        else
          activeFrames = sprCharRedIdle;  // Changes bow colour when on bow cooldown
        bb[0] = new PVector(44, 132);
        bb[1] = new PVector(-15, 0);
        break;
      case(WALK):
        if(shootCooldown <= 0)
          activeFrames = sprCharMove;
        else
          activeFrames = sprCharRedMove;
        bb[0] = new PVector(activeFrames[currFrame].width/2, activeFrames[currFrame].height);
        bb[1] = new PVector(5, 0);    
        break;
      case(RUN):
        if(shootCooldown <= 0)
          activeFrames = sprCharMove;
        else
          activeFrames = sprCharRedMove;
        bb[0] = new PVector(activeFrames[currFrame].width/2, activeFrames[currFrame].height);
        bb[1] = new PVector(5, 0);
        break;
      case(JUMP):
        if(shootCooldown <= 0)
          activeFrames = sprCharJump;
        else
          activeFrames = sprCharRedJump;
        bb[0] = new PVector(activeFrames[currFrame].width/2, activeFrames[currFrame].height);
        bb[1] = new PVector(15, 0); 
        break;
      case(ATTACK1):
        bb[0] = new PVector(44, 132);
        bb[1] = new PVector(-15, (activeFrames[currFrame].height - 132) / 2);
        break;
      case(ATTACK2):
        bb[0] = new PVector(44, 132);
        bb[1] = new PVector(-15, (activeFrames[currFrame].height - 132) / 2);
        break;        
    }
  }
  
  // Handle sprite scaling
  boolean isSpriteFlipped() {
    if(!paused) {
      float angle = angleBtwnMouse();
      if(vel.x > 0)
        spriteFlipped = false;
      if(vel.x < 0)
        spriteFlipped = true;
      if((angle > 90 || angle < -90) && shoot)
        spriteFlipped = false;
      if(angle < 90 && angle > -90 && shoot)
        spriteFlipped = true;
    }
    return spriteFlipped;
  }
  
  // Calculates angle between the mouse and the character's center
  float angleBtwnMouse() {
    return degrees(angleBetween(pos, new PVector(mouseX, mouseY))) * -1;
  }
  
  // Character gravity
  void handleGravity() {
    if (grounded) {  // Correct character position when on the ground
      vel.y = 0;
      this.pos.y = height - dim.y/2 - groundLevel; 
    }
    else if(state == GAMEPLAY)
      accl(acclGravity);  // Let the character fall!
  }
  
  // Calculate the health of the character
  float healthPercentage(boolean accountForShield) {
    if(accountForShield) {
    float totalHealth = health.x + health.y;
    float totalMaxHealth = maxHealth.x + maxHealth.y;
    return totalHealth / totalMaxHealth * 100;
    }
    else
      return health.x / maxHealth.x * 100;
  }

  // Handle health related things
  void handleHealth() {
    dmgdTimer++;
    // Regen shield when not hit after 6 seconds 
    if (dmgdTimer > 360 && health.y < maxHealth.y && dmgdTimer % 60 == 0)
      health.y += 1;
    if(health.x <= 0)  // Kill character
      isAlive = false;
  }

  // Deal damage to character
  void decHP(int dmg) { 
    if (health.y - dmg >= 0) {  // Remove shield health first
      health.y -= dmg;
      println(health.y);
    }
    else if (health.y - dmg < 0 && health.y > 0) {  // Remove remaining shield health, then remove regular health
      while (health.y > 0) {
        health.y--;
        dmg--;
      }
      health.x -= dmg;
    }
    else  // Remove regular health
      health.x -= dmg;
    dmgdTimer = 0;  // Reset damaged timer to (shield regen)
  }
  
  // Get the amount of gems in the player's inventory. Useful when character might eventually have other things in their inventory 
  int getGemCount() {
    int gemCount = 0;
    for (int i = 0; i < inventory.size(); i++) {
      if(inventory.get(i).sprite == sprGem[0]);
        gemCount++;
    }
    return gemCount;
  }
  
  // Fade away when dead...
  void handleDeath() {
    if(alpha > 0)
      alpha -= 0.33;
    vel = new PVector(0, 0);
  }
}
