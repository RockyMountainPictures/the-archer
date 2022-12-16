// Gem: a cool shiny item that helps player progress to Level Three

class Gem extends Item {
  
  PImage[] spriteAnim, spriteAnimNear, spriteAnimHover;
  int spriteState;
  int spriteStatePrev;
  PImage spriteCurrent;
  
  PImage[] activeFrames;
  int currFrame = 0;
  int animationRate = 10;
  
  Gem(PVector pos, PVector dim, PImage[] sprite, int range) {
    super(pos, dim, sprite[0], range);
    this.spriteAnim = sprite;
    this.spriteCurrent = sprite[0];
    this.activeFrames = sprite;
    this.spriteAnimNear = new PImage[sprite.length];
    this.spriteAnimHover = new PImage[sprite.length];
    for (int i = 0; i < sprite.length; i++) {
      this.spriteAnimNear[i] = createSpriteOutline(spriteAnim[i], outlineWhite, 3);
      this.spriteAnimHover[i] = createSpriteOutline(spriteAnim[i], outlineYellow, 3);
    }
  }
  
  // Handle animation states and animation frames
  PImage handleSpriteStates() {
    activeFrames = spriteAnim;
    if(isNear)
      activeFrames = spriteAnimNear;
    if(isHover())
      activeFrames = spriteAnimHover;
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
  
  // Adds sound to pickup
  void pickUp(Char c) {
    c.inventory.add(this);
    playSound(sfxGem[0]);
    interactables.remove(this);
  }
}
