// Render all entities
void renderEntities() {
  // Render player
  player.renderSprite();
  
  // Render enemies and their projectiles
  for (int i = 0; i < enemies.size(); i++) {
    Enemy e = enemies.get(i);
    e.renderSprite();
    e.renderPlasma();
  }
  
  // Render player's projectiles + aim trajectory 
  player.renderArrows();
  if(shoot && player.shootCooldown <= 0 && trajectory)
    player.renderArrowTrajectory(player.arrowPos, player.arrowVel, player.timerArrowVel);
}

// Render interactables (portals, camp, gems, etc.)
void renderForeground() {
  for(int i = 0; i < interactables.size(); i++) {
    Interactable obj = interactables.get(i);
    obj.renderSprite();
  }
}

// Render backgrond image
void renderBackground() {
  background(220, 60);  // Solid color behind
  imageMode(CORNERS);
  pushMatrix();
  // Stop scrolling if near canvas edge
  if(!player.nearWall)
    offset -= player.vel.x * bgSpeed;
  translate(offset, 0);
  tint(255, 60);
  image(currBG, -bgWidth, 0);  // Render background on either side as well
  tint(255, 60);
  image(currBG, 0, 0);
  tint(255, 60);
  image(currBG, bgWidth, 0);  // Render background on either side as well
  popMatrix();
  if(offset <= -bgWidth || offset >= bgWidth)  // Can't remember
    offset = 0;
}

void renderUI() {
  // DECOMISSIONED - See main tab controls
  //if (inventory)
  //  player.renderInventory();
  
  // Render HUD (health bar)
  if(!paused)  
    ui.renderHUD();
}

// Play sounds
void playSound(AudioPlayer sound) {
  sound.play(0);
}
