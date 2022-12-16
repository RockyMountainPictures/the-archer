/*
Assignment 4 - Archer
By: Max Nielsen
IAT 167 - D102
17-03-2022

Hi Amineh and Others!

--- Backstory (also in the game): ---

Welcome to The Archer, where you play as King Alcinous of Esqueria. 
You are delivering a message of importance to the village Polt, warning them of an attack.
However, the village has disappeared! Your goal is to recover the citizens of Polt and 
defeat the evil that attacked your village.


--- Controls (also in the game): ---

Move - A & D
Run - Hold Shift while moving
Jump - Space
Double Jump - Space
  After jumping while you're accelerating up.
Lunge - Space
  After jumping while you're accelerating down due to gravity and you're moving or running.
Interact - E 
  Hold down to move the broken portal piece in Level One. Otherwise, it's just a tap.
Shoot - Left Mouse Button
  Hold down to draw the bow, let go to shoot. Auto shoots after one second.
Toggle Trajectory - Right Mouse Button
  Tapping RMB toggles the arc shown when drawn, to add a layer of difficulty.
Pause - Esc
  Shows controls, allows you to restart, and resume game with button or pressing Esc again.
Inventory - Tab (Decommissioned)
  Was going to add items, powerups, and statistics that would be displayed here.


With that, enjoy the game!
Cheers,
Max
*/

// --- Libraries --- //
import ddf.minim.*;
import controlP5.*;

// --- Constants --- //
// Highest level game states
final int START = 0;
final int GAMEPLAY = 1;
final int NARRATIVE = 2;
final int SLEEP = 3;
final int WON = 8;
final int LOST = 9;
final int PAUSE = 10;

// Holding game states
int state = START;
int prevState;

// --- Assets --- //
PFont font, fontBold, fontItalic, fontBoldItalic;
PImage[] spritesEnviro, spritesEnemy, spritesProjectiles, spritesInteractables, spritesUI, spritesOther;
PImage[] sprCharIdle, sprCharMove, sprCharJump, sprCharDash, sprCharAtk1, sprCharAtk2, sprCharRedIdle, sprCharRedMove, sprCharRedJump;
PImage[] sprWitchIdle, sprWitchMove, sprWitchAtk, sprWitchDie;
PImage[] sprPlasma, sprArrow;
PImage[] sprGem;
PImage[] sprPortalGreenOpen, sprPortalGreenIdle, sprPortalGreenFrame;
PImage[] sprPortalBlueOpen, sprPortalBlueIdle, sprPortalBlueFrame;
PImage[] sprBackgrounds;
Minim minim;  // Sounds
AudioPlayer[] sfxShoot, sfxChar, sfxGem, sfxPortal, sfxBackground;


// --- Entities --- //
ArrayList<Enemy> enemies = new ArrayList<Enemy>();
ArrayList<Interactable> interactables = new ArrayList<Interactable>();
Char player;

// --- UI/UX Stuff --- //
UI ui;
boolean showControls = false;
// Buttons
ControlP5 controlP5;
Button play, restart, controls, resume, quit, leave, restartLevel, menu;

// --- Background Stuff --- //
PImage currBG;
float groundLevel = 113;
float bgWidth;
float bgSpeed = 4;
float offset = 0;



// ***   Methods   *** //

// Setup: Initializing all the assets, entities, and UI things.
void setup() {
  size(1920, 1080, P2D);
  colorMode(RGB, 255, 255, 255, 60);  // Alpha is set to 60 to match frame rate 
  state = START;  // Starting the game at the start :>
  
  initSprites();
  initChar();
  initInteractables();
  initSounds();
  initOther();
  initButtons();
}

// Draw: Handling the highest level game states. It branches out through the methods in each case
void draw() {
  switch(state) {
    case(START):
      ui.renderStartScreen();
      break;
    case(GAMEPLAY):
      updateGameplay();
      break;
    case(NARRATIVE):
      updateNarrative();
      break;
    case(SLEEP):
      updateSleep();
      break;
    case(WON):
      ui.renderWinScreen();
      break;
    case(LOST):
      updateLoseScreen();
      break;
    case(PAUSE):
      updatePause();
  }
}

// Updates all gameplay elements of entities (movement, health, states, etc.)
void update() {
  player.update();
  updateEnemies();
  updateInteractables();
}

// Updates and renders everything when player is able to move around, kill enemies, etc.
void updateGameplay() {
  update();
  renderBackground();
  renderForeground();
  renderEntities();
  renderUI();
  handleGameplaySwitches();
  handleSwitches();
  player.handleSounds();
}

// Shows a losing screen overlay when player dies
void updateLoseScreen() {
  update();
  renderBackground();
  renderForeground();
  renderEntities();
  ui.renderLoseScreen();
}

// Updates and renders everything during narrative aspects of the game
void updateNarrative() {
  player.handleGravity();
  renderBackground();
  renderForeground();
  renderEntities();
  renderUI();
  handleNarrativeSwitches();
  handleSwitches();
  player.handleSounds();
}

// Updates and renders everything when player sleeps in camp to regain health
void updateSleep() {
  updateInteractables();
  renderBackground();
  renderForeground();
  renderEntities();
  handleSwitches();
}

// Freezes entities and only renders them while paused
void updatePause() {
  // Show buttons
  resume.show();
  controls.show();
  restart.show();
  
  // Render necessary parts
  renderBackground();
  renderForeground();
  renderEntities();
  ui.renderPauseScreen();
  
  // Stop sounds
  sfxChar[0].pause();
  sfxChar[1].pause();
  sfxBackground[0].pause();
}

// Updates movement and health of enemies
void updateEnemies() {
  for (int i = 0; i < enemies.size(); i++)
    enemies.get(i).update();
}

// Updates position and states of interactables
void updateInteractables() {
  for(int i = 0; i < interactables.size(); i++)
    interactables.get(i).update();
}

// Restarts the game completely when button is pressed
void handleRestart() {
  handleUnpause();
  
  // Clear entities, Reset UI
  interactables.clear();
  enemies.clear();
  player = null;
  ui = null;
  showControls = false;
  
  // Re-initialize everything from setup
  initChar();
  initInteractables();
  initOther();
  initButtons();
  
  // Reset all states to defaults
  state = START;
  level = LVL_1;
  resetGameNarrStates();
  
  // Reset odd variables
  groundLevel = 113;
}

// Resets all narration and gameplay stages of each level
void resetGameNarrStates() {
  narrOneLevel = LVL_1;
  narrTwoLevel = LVL_1;
  narrThreeLevel = LVL_1;
  narrFourLevel = LVL_1;
  gameOneLevel = LVL_1;
  gameTwoLevel = LVL_1;
  gameThreeLevel = LVL_1;
  gameFourLevel = LVL_1;
}

// Restarts game from the level you died in
void handleRestartLevel() {
  // Hide buttons and reset colours
  restart.hide();
  restartLevel.hide();
  restart.setColorLabel(color(250));
  restartLevel.setColorLabel(color(250));
  
  // Reset all states except level to defaults
  state = prevState;
  prevState = LOST;
  resetGameNarrStates();
  
  // Clear enemies
  enemies.clear();
  
  // Reset odd variables
  paused = false;
  
  // Handle particular level resets
  switch(level) {
    case(LVL_1):  // Resets everything similar to full reset because it's the first level
      player = null;
      ui = null;
      interactables.clear();
      initInteractables();
      initChar();
      initOther();
      break;
    case(LVL_2):
      groundLevel = 83;
      resetPlayer(new PVector(200, groundLevel));
      
      // Reset positions of set interactables (portals, camp)
      interactables.get(1).pos = new PVector(player.pos.x, height - groundLevel - interactables.get(1).sprite.height/2);
      interactables.get(0).pos = new PVector(width, height - groundLevel + 7 - interactables.get(0).sprite.height/2);
      interactables.get(2).pos = new PVector(5250, height - groundLevel - sprPortalBlueFrame[0].height/2);
      
      // Reset player inventory to the correct amount of gems before Level Two
      if(player.getGemCount() > 1) {
        for(int i = 1; i < player.getGemCount(); i++)
          player.inventory.remove(i);
      }
      break;
    case(LVL_3):
      groundLevel = 145;
      resetPlayer(new PVector(200, groundLevel));
      
      // Reset positions of set interactables (portals, camp)
      interactables.get(1).pos = new PVector(width/2, -5000);
      interactables.get(0).pos = new PVector(width, height - groundLevel + 7 - interactables.get(0).sprite.height/2);
      interactables.get(2).pos = new PVector(player.pos.x, height - groundLevel - interactables.get(2).sprite.height/2);
      break;
  }
  state = GAMEPLAY;
}

// Resets player variables
void resetPlayer(PVector pos) {
  player.pos = pos;
  player.health = new PVector(5, 4);
  player.activeFrames = sprCharIdle;
  player.spriteCurrent = sprCharIdle[0];
  player.isAlive = true;
  player.alpha = 60;
  player.arrows.clear();
}

// Remove buttons and change states back to unpaused
void handleUnpause() {
  // Hide all buttons and reset colours of buttons clicked
  resume.hide();
  controls.hide();
  restart.hide();
  restartLevel.hide();
  menu.hide();
  quit.hide();
  resume.setColorLabel(color(250));
  restart.setColorLabel(color(250));
  menu.setColorLabel(color(250));
  quit.setColorLabel(color(250));
  restartLevel.setColorLabel(color(250));
  if(!showControls)  // Special case for toggleable view of the controls in pause menu
    controls.setColorLabel(color(250));
    
  // Unpause and set state
  paused = false;
  state = prevState;
  prevState = PAUSE;
  println("UI: Resuming game...");
  
  // Restart background sound
  sfxBackground[0].play();
}
