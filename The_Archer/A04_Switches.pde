// --- Constants --- //
// Standard levels for substates of gameplay and narrative 
final int LVL_1 = 0;
final int LVL_2 = 1;
final int LVL_3 = 2;
final int LVL_4 = 3;
final int LVL_5 = 4;
final int LVL_6 = 5;
final int LVL_7 = 6;
final int LVL_8 = 7;
final int LVL_9 = 8;
final int LVL_10 = 9;

// --- Variables --- //
boolean switching;  // Switching narrative level
int narrTimer = 0;  // Timer to ensure player doesn't spam through the dialogue

// Default states
int level = LVL_1;
int narrOneLevel = LVL_1;
int narrTwoLevel = LVL_1;
int narrThreeLevel = LVL_1;
int narrFourLevel = LVL_1;
int gameOneLevel = LVL_1;
int gameTwoLevel = LVL_1;
int gameThreeLevel = LVL_1;
int gameFourLevel = LVL_1;

// Characters
String strNarr = "Narrator";
String strInfo = "Note";
String strPlayer = "Alcinous";
String strEnemy = "Enemy";
String strBoss = "Invisible Boss";

// Dialogue - Level One
String narrOneLevelOne = "Deep in the woods of Esqueria, Alcinous delivers\nan urgent message to the nearby village of Polt.";
String narrOneLevelTwo = "The message urges the village to prepare\nfor an incoming invasion from unknown forces.";
String narrOneLevelThree = "Press E while you hover over the tent to\nsleep and tend to your wounds.";
String narrOneLevelFour = "Where did the village go???\nPolt is supposed to be right here!";
String narrOneLevelFive = "Those monsters must have had a hand in\nuprooting Polt. I must defeat them\nand save the survivors!";

// Dialogue - Level Two
String narrTwoLevelOne = "What kind of magic is this?\nWhere am I?";
String narrTwoLevelTwo = "Nonetheless, I must trudge forward to\nsave my people.";
String narrTwoLevelThree = "Phew, how many monsters are there?\nCome out evil! I will defeat you all!";
String narrTwoLevelFour = "Ha! In your dreams human!"; //<>//
String narrTwoLevelFive = "There must be another portal nearby...";

// Dialogue - Level Three
String narrThreeLevelOne = "Who dares enter my realm???";
String narrThreeLevelTwo = "You shall pay for disturbing me!\nMinions, ATTACK!";
String narrThreeLevelThree = "ARGH! YOU LITTLE BRAT, COME HERE!";
String narrThreeLevelFour = "NOW DIE!!!";
String narrThreeLevelFive = "The people of Polt are free!\nAll thanks to you :>";

// Dialogue Box Variables
int narrPadding;
int narrAlpha;
PVector narrPos;
PVector narrDim;

// Switch between losing and winning each level
void handleSwitches() {
  if(hasLost())
    startLose();
    
  if (hasWon())
    if(level == LVL_3)  // Check if on last level
      startWin();
    else {
      level++;  // Go to next level
      handleLevelChange();
    }
}

// Gameplay states for each level
void handleGameplaySwitches() {
  switch(level) {
    case(LVL_1):
      handleLevelOneGameplaySwitches();
      break;
    case(LVL_2):
      handleLevelTwoGameplaySwitches();
      break;
    case(LVL_3):
      handleLevelThreeGameplaySwitches();
      break;
  }
  handleLowestLevelSwitches();  // Event Triggers 
  //println(enemies.size());
  //println("Gameplay: " + gameThreeLevel);
  //println("Narration: " + narrThreeLevel);
}

// Narrative states for each level
void handleNarrativeSwitches() {
  switch(level) {
    case(LVL_1):
      handleLevelOneNarrativeSwitches();
      break;
    case(LVL_2):
      handleLevelTwoNarrativeSwitches();
      break;
    case(LVL_3):
      handleLevelThreeNarrativeSwitches();
      break;
  }
  // Show interaction disabled for first second of dialogue appearing
  if(narrTimer < 60) {
    narrTimer++;
    ui.showKeyE(20);
  }
  else
    ui.showKeyE(60);
  handleLowestLevelSwitches();
  //println(enemies.size());
  //println("Gameplay: " + gameThreeLevel);
  //println("Narration: " + narrThreeLevel);
}

// Level One narration
void handleLevelOneNarrativeSwitches() {
  switch(narrOneLevel) {
    case(LVL_1):
      ui.renderNarrative(strNarr, narrOneLevelOne, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_2):
      ui.renderNarrative(strNarr, narrOneLevelTwo, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_3):
      ui.renderNarrative(strInfo, narrOneLevelThree, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_4):
      ui.renderNarrative(strPlayer, narrOneLevelFour, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_5):
      ui.renderNarrative(strPlayer, narrOneLevelFive, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_6):
      break;
  }
}

// Level Two narration
void handleLevelTwoNarrativeSwitches() {
  switch(narrTwoLevel) {
    case(LVL_1):
      ui.renderNarrative(strPlayer, narrTwoLevelOne, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_2):
      ui.renderNarrative(strPlayer, narrTwoLevelTwo, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_3):
      ui.renderNarrative(strPlayer, narrTwoLevelThree, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_4):
      ui.renderNarrative(strEnemy, narrTwoLevelFour, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_5):
      ui.renderNarrative(strPlayer, narrTwoLevelFive, narrPos, narrDim, narrPadding, narrAlpha);
      break;
  }
}

// Level Three narration
void handleLevelThreeNarrativeSwitches() {
  player.vel = new PVector(0, 0);
  switch(narrThreeLevel) {
    case(LVL_1):
      ui.renderNarrative(strBoss, narrThreeLevelOne, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_2):
      ui.renderNarrative(strBoss, narrThreeLevelTwo, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_3):
      ui.renderNarrative(strBoss, narrThreeLevelThree, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_4):
      ui.renderNarrative(strBoss, narrThreeLevelFour, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_5):
      if(state != WON)
        ui.renderNarrative(strNarr, narrThreeLevelFive, narrPos, narrDim, narrPadding, narrAlpha);
      break;
    case(LVL_6):
      break;
  }
}

// Level One gameplay
void handleLevelOneGameplaySwitches() {
  switch(gameOneLevel) {
    case(LVL_1):
      break;
    case(LVL_2):
      break;
    case(LVL_3):
      break;
    case(LVL_4):
      break;
    case(LVL_5):
      break;
    case(LVL_6):
      break;
  }
}

// Level Two gameplay
void handleLevelTwoGameplaySwitches() {
  switch(gameTwoLevel) {
    case(LVL_1):
      break;
    case(LVL_2):
      break;
    case(LVL_3):
      break;
    case(LVL_4):
      break;
  }
}

// Level Three gameplay
void handleLevelThreeGameplaySwitches() {
  switch(gameThreeLevel) {
    case(LVL_1):
      break;
    case(LVL_2):
      break;
    case(LVL_3):
      break;
    case(LVL_4):
      break;
    case(LVL_5):
      break;
    case(LVL_6):
      break;
  }
}

// Checking if player has reached the end of each level
boolean hasWon() {
  if(state == GAMEPLAY) {
    if(gameOneLevel == LVL_6) {
      gameOneLevel = LVL_5;
      return true;
    }
    
    if(gameTwoLevel == LVL_6){
      gameTwoLevel = LVL_5;
      return true;
    }
      
    if(gameThreeLevel == LVL_5){
      gameThreeLevel = LVL_4;
      return true;
    }
  }
  return false;
}

// Change state when won
void startWin() {
  state = WON; 
}

// Check if player has died
boolean hasLost() {
  return !player.isAlive;
}

// Change state when lost
void startLose() {
  state = LOST;
}

// Each event that switches narration and gameplay
void handleLowestLevelSwitches() {
  // Changes to next narration
  if (state == NARRATIVE && interact && !switching && narrTimer >= 60) {
    switch(level) {
      case(LVL_1):
        narrOneLevel++;
        break;
      case(LVL_2):
        narrTwoLevel++;
        break;
      case(LVL_3):
        narrThreeLevel++;
        break;
    }
    
    switching = true;  // Ensure this happens only once
    narrTimer = 0;  // Reset dialogue timer
    
    // Level One narrative-to-gameplay switches
    if(level == LVL_1 && (narrOneLevel == LVL_3 || narrOneLevel == LVL_4 || narrOneLevel == LVL_5 || narrOneLevel == LVL_6)) {
      state = GAMEPLAY;    
      if(narrOneLevel == LVL_5) {
        initEnemies(3, new PVector(0, width));
      }
    }
    
    // Level Two narrative-to-gameplay switches
    if(level == LVL_2 && (narrTwoLevel == LVL_3 || narrTwoLevel == LVL_4 || narrTwoLevel == LVL_5 || narrTwoLevel == LVL_6)) {
      state = GAMEPLAY;
      if(narrTwoLevel == LVL_3)
        initEnemies(4, new PVector(width/2, width));
      if(narrTwoLevel == LVL_4)
        initEnemies(5, new PVector(width * 2, width * 3));
    }
    
    // Level Three narrative-to-gameplay switches
    if(level == LVL_3 && (narrThreeLevel == LVL_3 || narrThreeLevel == LVL_5 || narrThreeLevel == LVL_6)) {
      state = GAMEPLAY;
      if(narrThreeLevel == LVL_3)
        initEnemies(5, new PVector(width/2, width * 1.5));
      if(narrThreeLevel == LVL_5)
        initEnemies(7, new PVector(-width, width * 2));
    }
  }
  
  // Level One gameplay-to-narrative switches
  if (state == GAMEPLAY && level == LVL_1) {
    if(!player.nearWall && gameOneLevel == LVL_1) // Leaves wall
      switchToNarr();
    
    if(interactables.get(0).pos.x <= player.pos.x && gameOneLevel == LVL_2)  // Approaches camp
      switchToNarr();
    
    if(player.pos.x >= width/1.5 && gameOneLevel == LVL_3)  // Near "town"
      switchToNarr();
    
    if(gameOneLevel == LVL_4 && player.getGemCount() >= 1)  // Obtains gem
          switchToNarr();
    
    if(gameOneLevel == LVL_5 && interactables.get(1).isClicked())  // Enters green portal
      gameOneLevel++;
  }
  
  // Level Two gameplay-to-narrative switches
  if (state == GAMEPLAY && level == LVL_2) {
    if(!player.nearWall && gameTwoLevel == LVL_1)  // Leaves wall
      switchToNarr();
    
    if(gameTwoLevel == LVL_2 && player.getGemCount() >= 2 && enemies.size() == 0)  // Kills enemies and obtains 2nd gem
      switchToNarr();
    
    if(gameTwoLevel == LVL_3 && enemies.size() > 0)  // Loads enemies after enemy dialogue
      switchToNarr();
    
    if(gameTwoLevel == LVL_4 && player.getGemCount() >= 3 && enemies.size() == 0)  // Kills enemies and obtains 3rd gem
      switchToNarr();
    
    if(gameTwoLevel == LVL_5 && interactables.get(2).isClicked())  // Enters blue portal
      gameTwoLevel++;
  }
  
  // Level Three gameplay-to-narrative switches
  if (state == GAMEPLAY && level == LVL_3) {
    if(!player.nearWall && gameThreeLevel == LVL_1)  // Leaves wall
      switchToNarr();
    
    if(gameThreeLevel == LVL_2 && enemies.size() == 0) {  // Kill enemies
      // Invisible boss forces player into the center of the map
      if(player.pos.x < width/2 - 5)
        player.accl(new PVector(1, 0));
      else if(player.pos.x > width/2 + 5)
        player.accl(new PVector(-1, 0));
      else {
        switchToNarr();
      }
    }
    
    if(gameThreeLevel == LVL_3 && enemies.size() == 0 && narrThreeLevel == LVL_5 )  // Kills enemies
      switchToNarr();
    
    if(gameThreeLevel == LVL_4 && narrThreeLevel == LVL_6)  // Finish narration
      gameThreeLevel++;
  }
}

// Switches to narration
void switchToNarr() {
  state = NARRATIVE;
  // Changes to next gameplay
  switch(level) {
      case(LVL_1):
        gameOneLevel++;
        break;
      case(LVL_2):
        gameTwoLevel++;
        break;
      case(LVL_3):
        gameThreeLevel++;
        break;
    }
  player.vel = new PVector(0, 0);
}

// Switching between levels One, Two, Three
void handleLevelChange() {
  currBG = spritesEnviro[level];  // Change background
  player.arrows.clear();  // Clean the field
  
  if(level == LVL_1) {  // Shouldn't happen
    groundLevel = 113;
    interactables.get(1).pos.x = 0;
    player.pos.x = 1375;
  }
  if(level == LVL_2) {  // Add blue portal, shifts player and portal around 
    groundLevel = 83;
    player.pos.x = 200;
    interactables.get(1).pos = new PVector(player.pos.x, height - groundLevel - interactables.get(1).sprite.height/2);  // Green portal 
    interactables.get(0).pos = new PVector(width, height - groundLevel + 7 - interactables.get(0).sprite.height/2);  // Camp
    PVector levelTwoPortalPos = new PVector(5250, height - groundLevel - sprPortalBlueFrame[0].height/2);
    PVector levelTwoPortalDim = new PVector(256, 256);
    interactables.add(new Portal(levelTwoPortalPos, levelTwoPortalDim, sprPortalBlueFrame, sprPortalBlueOpen, sprPortalBlueIdle));  // Blue portal
  }
  if(level == LVL_3) {  // Shifts player and portals around
    groundLevel = 145;
    player.pos.x = 200;
    interactables.get(1).pos = new PVector(width/2, -5000);  // Ensure you can't see green portal
    interactables.get(0).pos = new PVector(width, height - groundLevel + 7 - interactables.get(0).sprite.height/2);  // Camp
    interactables.get(2).pos = new PVector(player.pos.x, height - groundLevel - interactables.get(2).sprite.height/2);  // Blue portal
  }
}
