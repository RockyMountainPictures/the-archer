// Interactable: Something that the player can interact with. 
// Actual interactables should be subclasses as they have unique properties

class Interactable {
  
  PVector pos, dim;
  color outlineWhite = color(255, 255, 255);
  color outlineYellow = color(255, 220, 41);
  PImage sprite, spriteNear, spriteHover;
  float range;
  boolean isNear;
  int alpha = 60;
  
  Interactable(PVector pos, PVector dim, PImage sprite, float range) {
    this.pos = pos;
    this.dim = dim;
    this.range = range;
    this.sprite = sprite;
    //sprite.resize(int(dim.x), int(dim.y));
    spriteNear = createSpriteOutline(sprite, outlineWhite, 3);
    spriteHover = createSpriteOutline(sprite, outlineYellow, 3);
  }
  
  void update() {
    moveWithChar();
    isNear(player, range);
  }
  
  void moveWithChar() {
    if(!player.nearWall)
      pos.x -= player.vel.x * bgSpeed;
  }
  
  // Checks if character is near the object
  void isNear(MovingObject c, float range) {
    PVector relLoc = new PVector(abs(pos.x - c.pos.x), abs(pos.y - c.pos.y));
    PVector isNearRange = new PVector(dim.x/2 + c.dim.x/2 + range, dim.y/2 + c.dim.y/2 + range);
    if (relLoc.x < isNearRange.x && relLoc.y < isNearRange.y)
      isNear = true;
    else
      isNear = false;
  }
  
  // A boolean version of the method above
  boolean isNearBool(MovingObject c, float range) {
    PVector relLoc = new PVector(abs(pos.x - c.pos.x), abs(pos.y - c.pos.y));
    PVector isNearRange = new PVector(dim.x/2 + c.dim.x/2 + range, dim.y/2 + c.dim.y/2 + range);
    return relLoc.x < isNearRange.x && relLoc.y < isNearRange.y; 
  }
  
  // A version that uses interactables instead of characters
  boolean isNearInteractableBool(Interactable c, float range) {
    PVector relLoc = new PVector(abs(pos.x - c.pos.x), abs(pos.y - c.pos.y));
    PVector isNearRange = new PVector(dim.x/2 + c.dim.x/2 + range, dim.y/2 + c.dim.y/2 + range);
    return relLoc.x < isNearRange.x && relLoc.y < isNearRange.y; 
  }
  
  // Is the mouse hovering over the interactable
  boolean isHover() {
    int mx = mouseX;
    int my = mouseY;
    return abs(pos.x - mx) < dim.x/2 && abs(pos.y - my) < dim.y/2;
  }
  
  // Did the player click on the interactable
  boolean isClicked() {
    return isHover() && interact && isNear; 
  }
  
  // Did the player click on the interactable but doesn't need to be near it (for portal piece)
  boolean isClickedNotNear() {
    return isHover() && interact; 
  }
  
  // Render the beautile object
  void renderSprite() {
    pushMatrix();
    translate(pos.x, pos.y);
    //rectMode(CENTER);
    //fill(255, alpha);
    //stroke(0, alpha);
    //strokeWeight(3);
    //rect(0, 0, 100, 100);
    imageMode(CENTER);
    tint(255, alpha);
    image(handleSpriteStates(), 0, 0);
    popMatrix();
  }
  
  // Handle the different states of the sprites
  PImage handleSpriteStates() {
    PImage sprite = this.sprite;
    if(isNear)
      sprite = spriteNear;
    if(isHover())
      sprite = spriteHover;
    return sprite; 
  }
  
  // Create an outlined version of the sprite with whatever color and thickness (pixels)
  PImage createSpriteOutline(PImage img, color c, int weight) {
     PImage imgCopy = createImage(img.width + weight * 2, img.height + weight * 2, ARGB);
     imgCopy.copy(img, 0, 0, img.width, img.height, weight, weight, imgCopy.width - weight*2, imgCopy.height - weight*2);
     imgCopy.loadPixels();
     setPixelOutline(imgCopy, 0, weight, c);
     imgCopy.updatePixels();
     return imgCopy;
   }
  
  // The painstaking process of adding the outline pixel by pixel (this also took a day to make :>)
  PImage setPixelOutline(PImage img, int line, int w, color c) { // Per row of pixels
    int imgW = img.width;
    int imgH = img.height;
    
    for(int j = 0; j < dim.x; j++) {  // Each pixel on the row
      int pixel = j + (line + 1) * imgW;  // Calc pos of pixel in full image array 
      
      if(pixel < dim.x * imgH) {  // Ensure it is on the row
        int r = int(red(img.pixels[pixel]));
        int g = int(green(img.pixels[pixel]));
        int b = int(blue(img.pixels[pixel]));
        int a = getAlpha(img, pixel);
        color rgb = color(r, g, b);
        
        if(a != 0 && rgb != c) {  // Filled pixel
          if((pixel - w >= 0 && alpha(img.pixels[pixel - 1]) == 0))  // If pixel behind is empty...
            for(int i = 0; i < w; i++)
              img.pixels[pixel - i - 1] = color(c);
           
          if(pixel + w <= imgW * (ceil(float(pixel)/float(imgW))) && getAlpha(img, pixel + 1) == 0)  // If next pixel is empty...
            for(int i = 0; i < w; i++)
              img.pixels[pixel + i + 1] = color(c);
           
          if(pixel - imgW * w >= 0 && getAlpha(img, pixel - imgW) == 0)  // If pixel above is empty...
            for(int i = 0; i < w; i++)
              img.pixels[pixel - i * imgW] = color(c);
           
          if(pixel + imgW * w <= imgW * imgH && getAlpha(img, pixel + imgW) == 0) // If pixel below is empty...
            for(int i = 0; i < w; i++)
              img.pixels[pixel + i*imgW] = color(c);
        }
      }
    }
    if(line < imgH)  // Go to next line if not finished
      return setPixelOutline(img, line + 1, w, c);
    else
      return img;  // Returned outlined image
  }
  
  // Get the alpha value of a certain pixel from a certain image
  int getAlpha(PImage img, int pixel) {
    return int(alpha(img.pixels[pixel]));
  }
}
