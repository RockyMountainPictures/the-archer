/*
Checkpoint Class:

The camp. You can sleep in it when there isn't any monsters around.
Regens your health + shield to full.
Useful midbattle. Can back away to camp to heal.
The one sprite I made from scratch :>
*/

class Checkpoint extends Interactable {
  
  boolean canSleep, isSleeping;
  float alpha = 0;
  float timer = 120;
  
  Checkpoint(PVector pos, PVector dim, PImage sprite, int range) {
    super(pos, dim, sprite, range);
  }
  
  // Check if player is going to sleep
  void update() {
    super.update();
    if((isClicked() && !interactKeyHeldDown) || isSleeping) {
      handleSleep();
      println("Sleeping...");
    }
    if(isClickedNotNear() && !interactKeyHeldDown)
      println("Cannot sleep. Please come closer to the camp");
  }
  
  // Ensures you can sleep
  void handleSleep() {
    canSleep = true;
    for(int i = 0; i < enemies.size(); i++) {  // Checks for enemies around the camp
      isNear(enemies.get(i), range * 2);
      if(isNear && !isSleeping) {
        canSleep = false;
        break;
      }
    }
    if(canSleep)
      sleep();
    else
      cannotSleep();
  }
  
  // Handle the actual sleeping process
  void sleep() {
    isSleeping = true;
    timer--;
    if (isSleeping && alpha <= 60 && timer >= 0) {  // Fade away things
      for (int i = 0; i < enemies.size(); i++)
        enemies.get(i).alpha--;
      player.alpha--;
      alpha++;
    }
    if (timer <= 0) {  // Bring entities back
      for (int i = 0; i < enemies.size(); i++)
        enemies.get(i).alpha += 5;
      player.alpha += 5;
      alpha -= 5;
      timer--;
    }
    if (timer <= 0 && alpha <= 0) {  // After slept
      // Ensure alpha values are reset properly
      alpha = 0;
      timer = 120;
      player.alpha = 60;
      for (int i = 0; i < enemies.size(); i++)
        enemies.get(i).alpha = 60;
      isSleeping = false;
      // Set health, shield to max after slept
      while(player.health.x < player.maxHealth.x)
        player.health.x++;
      while(player.health.y < player.maxHealth.y)
        player.health.y++;
      println("Slept..."); 
    }
  }
  
  // Let player know they cannot sleep
  void cannotSleep() {
    println("Enemies are nearby... You cannot sleep now");
    // Insert text box that pops up. Did not have time
  }
  
  // Render campground
  void renderSprite() {
    super.renderSprite();
    pushMatrix();
    translate(width/2, height/2);
    rectMode(CENTER);
    fill(0, alpha);
    noStroke();
    rect(0, 0, width, height);
    popMatrix();
  }
  
  
}
