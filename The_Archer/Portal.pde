/*
Portal:

An interactable object that is a barrier between levels.
The player must put the portal back together with the use 
of the broken portal piece or gems depending on the level.
*/
class Portal extends Interactable {
  
  // States of the portal
  final int BROKEN = 0;
  final int PIECE_NEAR = 1;
  final int PIECE_HOVER = 2;
  final int COMPLETE = 3;
  
  int state;
  boolean opened, handledSound, nextLevel;
  
  PImage spriteCurrent;
  PImage[] activeFrames, sprPortalNear, sprPortalHover;
  PImage[] sprFrame, sprOpen, sprIdle;
  int currFrame = 0;
  int animationRate = 5;
  int currLevel;
  
  PortalPiece portalPiece;
  
  Portal(PVector pos, PVector dim, PImage[] sprFrame, PImage[] sprOpen, PImage[] sprIdle) {
    super(pos, dim, sprFrame[0], 100);
    this.state = BROKEN;
    this.activeFrames = sprOpen;
    this.spriteCurrent = sprOpen[0];
    this.sprFrame = sprFrame;
    this.sprOpen = sprOpen;
    this.sprIdle = sprIdle;
    this.sprPortalNear = new PImage[sprIdle.length];
    this.sprPortalHover = new PImage[sprIdle.length];
    for (int i = 0; i < sprIdle.length; i++) {
      this.sprPortalNear[i] = createSpriteOutline(sprIdle[i], outlineWhite, 5);
      this.sprPortalHover[i] = createSpriteOutline(sprIdle[i], outlineYellow, 5);
    }
    this.currLevel = level;
  }
  
  void update() {
    // Spawn the portal piece at the right moment on Level One
    if(narrOneLevel == LVL_6 && portalPiece == null && state == BROKEN && level == LVL_1)  
      createPortalPiece();
      
    moveWithChar();
    updatePortal();
    handleSonuds();
    isNear(player, range);
    
    // I think this is useless but i'll leave it in just incase it breaks something (as well as the ones in A04_Switches)
    switch(state) {  
      case(BROKEN):
        break;
      case(PIECE_NEAR):
        break;
      case(PIECE_HOVER):
        break;
      case(COMPLETE):
        break;
    }
    
    // Stop the sounds when the level changes and break it again so the player doesn't think they can go back through
    if(currLevel != level && !nextLevel) {
      sfxPortal[0].pause();
      sfxPortal[1].pause();
      state = BROKEN;
      nextLevel = true;
    }
  }
  
  void renderSprite() {
    pushMatrix();
    translate(pos.x, pos.y);
    if(opened)
      updateSpriteStates();
    imageMode(CENTER);
    tint(255, 60);
    if(state == COMPLETE)  // Only animate if it's complete
      image(handlePortalAnimation(), 0, 0);
    else {  // Static images otherwise :<
      image(sprFrame[state], 0, 0);
    }
    popMatrix();
    if(state != COMPLETE && portalPiece != null)
      portalPiece.renderSprite();  // Render the portal piece as well
  }
  
  // Handle the animation states/frames
  PImage handlePortalAnimation() {
    if (!paused) { // Lock sprite position when paused
      if(frameCount % animationRate == 0) {
        if(currFrame < activeFrames.length-1)
          currFrame++;
        else {
          if(activeFrames == sprOpen) {
            activeFrames = sprIdle;
            opened = true; 
          }
          currFrame = 0;
        }
        spriteCurrent = activeFrames[currFrame];
      }
    }
    return spriteCurrent;
  }
  
  // Change to the outlined versions if player is near
  void updateSpriteStates() {
    if(state == COMPLETE) {
      if(isNear)
        activeFrames = sprPortalNear;
      if(isHover())
        activeFrames = sprPortalHover; 
    }
  }
  
  // Handle the sounds for opening and the portal idling
  void handleSonuds() {
    if(state == COMPLETE && !handledSound) {
      playSound(sfxPortal[0]);
      playSound(sfxPortal[1]);
      sfxPortal[1].shiftGain(-50, -5, 7000);
      sfxPortal[1].loop(99); 
      handledSound = true;
    } 
  }
  
  // Handle the states of the portal depending on how it's being put together
  void updatePortal() {
    // The portal piece way 
    if(portalPiece != null) {
      state = BROKEN;
      portalPiece.update();
      if(portalPiece.onMouse)
        state = PIECE_NEAR;
      if(portalPiece.isNearInteractableBool(this, portalPiece.range))
        state = PIECE_HOVER;
      if(isHover() && portalPiece.onMouse) {
        state = COMPLETE;
        portalPiece = null;  // Delete the piece. We don't need you anymore :>
      }
    }
    
    // The gem way
    if(player.getGemCount() >= 2 && gameTwoLevel == LVL_5) {
      state = BROKEN;
      if(isNear)
        state = PIECE_NEAR;
      if(isHover())
        state = PIECE_HOVER;
      if(isHover() && interact && isNear) {
        state = COMPLETE;
        int gemCount = 0;
        for(int i = 0; i < player.inventory.size(); i++) {  // Remove the gems once they get put into the portal
          if(player.inventory.get(i).sprite == sprGem[0]) {
            player.inventory.get(i).removeMe(player);
            gemCount++;
          }
          if(gemCount == 2)
            break;
        }
      }
    }
  }
  
  // Initialize the portal piece
  void createPortalPiece() {
    PVector piecePos = new PVector(pos.x - random(500, 2000), height/2);
    PVector pieceDim = new PVector(184, 64);
    PImage pieceSprite = sprFrame[3];
    int pieceRange = 100;
    portalPiece = new PortalPiece(piecePos, pieceDim, pieceSprite, pieceRange); 
  }
  
  // Ensure the portal is fully opened before going through
  boolean isClicked() {
    return isHover() && interact && isNear && opened; 
  }
  
}
