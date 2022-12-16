// Item: An interactable that can be picked up by the character
// Used for creating the gem, but can be used for other enemy drops, health packs, etc.

class Item extends Interactable {
  
  final PVector acclGravity = new PVector(0, 1);
  PVector vel = new PVector(0, 0);
  PVector acclSpawn = new PVector(0, -5);
  boolean grounded;
  
  Item(PVector pos, PVector dim, PImage sprite, int range) {
    super(pos, dim, sprite, range);
    spawn();
  }
  
  void update() {
    super.update();
    move();
    grounded();
    handleGravity();
    if(isClicked())
      pickUp(player);
  }
  
  // Add a little fun to the spawning of the item
  void spawn() {
    accl(acclSpawn);
  }
  
  void move() {
    pos.add(vel);
  }
  
  void accl(PVector force) {
    vel.add(force);
  }
  
  // Make the items have gravity so the player can pick them up
  void handleGravity() {
    if (grounded) {
      vel.y = 0;
      this.pos.y = height - dim.y/2 - groundLevel; 
    }
    else
      accl(acclGravity);
  }
  
  // Check if item is on the ground for correcting y pos
  void grounded() {
    if(pos.y + dim.y/2 + groundLevel >= height)
      grounded = true;
    else
      grounded = false;
  }
  
  // The character adds it to their inventory
  void pickUp(Char c) {
    c.inventory.add(this);
    interactables.remove(this);  // Delete it from the map
  }
  
  // Remove it from the character's inventory
  void removeMe(Char c) {
    c.inventory.remove(this);
  }
  
  
  
  
}
