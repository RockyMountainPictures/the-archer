// Portal Piece: An item you can't put in your inventory, but pick up and fix the portal with!

class PortalPiece extends Item {
  
  boolean onMouse;
  
  PortalPiece(PVector pos, PVector dim, PImage sprite, int range) {
    super(pos, dim, sprite, range);
  }
  
  // Update literally everything
  void update() {
    moveWithChar();
    isNear(player, range);
    if(onMouse)  // If the player is trying to move the piece
      moveWithMouse();
    else {  // Otherwise, just do regular item things
      move();
      grounded();
      handleGravity();
    }
    if(isClickedNotNear())  // Check for the mouse
      onMouse = true;
    else
      onMouse = false;
  }
  
  // Move the portal piece relative to the player's mouse
  void moveWithMouse() {
    pos = new PVector(mouseX, mouseY);  
  } 
}
