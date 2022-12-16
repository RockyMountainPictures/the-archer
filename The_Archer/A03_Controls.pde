// --- Constants --- //
// Key Codes for each key
final int leftKey = 65;           // A
final int rightKey = 68;          // D
final int jumpKey = 32;           // Space
final int runKey = 16;            // Shift
final int shootKey = LEFT;        // Left Mouse Button
final int interactKey = 69;       // E
final int trajectoryKey = RIGHT;  // Right Mouse Button
//final int inventoryKey = 9;       // Tab (decomissioned)
final int pauseKey = 27;          // Esc

// --- Variables --- //
boolean left, right, jump, run, shoot, interact, trajectory, inventory, paused;  // Pressed key
boolean interactKeyHeldDown, inventoryKeyHeldDown, pauseKeyHeldDown;             // Key held down

// --- Methods --- //
void keyPressed() {
  //println(keyCode);
  if(!paused) {  // Ensure no gameplay button is pressed when paused
    if (keyCode == leftKey)
      left = true;
    if (keyCode == rightKey)
      right = true;
    if (keyCode == jumpKey)
      jump = true;
    if (keyCode == runKey)
      run = true;
    if (keyCode == interactKey)
        interact = true;
    //if (keyCode == inventoryKey) {
    //  if (!inventoryKeyHeldDown) {
    //    inventory =! inventory;
    //    if (inventory)
    //      println("UI: Showing inventory...");
    //    else
    //      println("UI: Hiding inventory...");
    //  }
    //  inventoryKeyHeldDown = true;
    //}
  }
  // Pause only when in game
  if (keyCode == pauseKey) {
    if (!pauseKeyHeldDown && state != START && state != WON && state != LOST) {
      paused =! paused;
      if (paused) {
        player.vel = new PVector(0, 0);
        prevState = state;
        state = PAUSE;
        println("UI: Pausing game...");
      }
      else {
        handleUnpause();
      }
    }
    pauseKeyHeldDown = true;
    key = 0;  // Override default action of Esc key in Processing (quit program)
  }
}

// Set all keys to false when released
void keyReleased() {
  if (keyCode == leftKey)
    left = false;
  if (keyCode == rightKey)
    right = false;
  if (keyCode == jumpKey)
    jump = false;
  if (keyCode == runKey)
    run = false;
  if (keyCode == interactKey) {
    switching = false;
    interact = false;
  }
  //if (keyCode == inventoryKey)
  //  inventoryKeyHeldDown = false;
  if (keyCode == pauseKey)
    pauseKeyHeldDown = false;
}

// Draw bow
void mousePressed() {
  if (mouseButton == shootKey && !paused && state == GAMEPLAY && player.shootCooldown <= 0)
    shoot = true;
}

// Shoot arrow and toggle arrow trajectory arc
void mouseReleased() {
  if (mouseButton == shootKey && !paused && state == GAMEPLAY) {
    player.shoot();  // Finally shoot the arrow
    shoot = false;
  }
  if (mouseButton == trajectoryKey && !paused && state == GAMEPLAY)
    trajectory =! trajectory;
}
