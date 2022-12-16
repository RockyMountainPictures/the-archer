// Initialize Sprites
void initSprites() {
  println("MESSAGE: Initializing sprites...");
  
  // Character Sprites
  sprCharIdle = new PImage[2];
  sprCharMove = new PImage[8];
  sprCharJump = new PImage[10];
  sprCharAtk1 = new PImage[11];
  sprCharAtk2 = new PImage[11];
  loadSpriteFrames(sprCharIdle, "Char/Idle/CharIdle_");
  loadSpriteFrames(sprCharMove, "Char/Move/CharMove_");
  loadSpriteFrames(sprCharJump, "Char/Jump/CharJump_");
  loadSpriteFrames(sprCharAtk1, "Char/Atk1/CharAtk1_");
  loadSpriteFrames(sprCharAtk2, "Char/Atk2/CharAtk2_");
  
  // Character Sprites - Red Bow
  sprCharRedIdle = new PImage[2];
  sprCharRedMove = new PImage[8];
  sprCharRedJump = new PImage[10];
  loadSpriteFrames(sprCharRedIdle, "Char/RedBow/Idle/CharIdle_");
  loadSpriteFrames(sprCharRedMove, "Char/RedBow/Move/CharMove_");
  loadSpriteFrames(sprCharRedJump, "Char/RedBow/Jump/CharJump_");
  
  // Monster Sprites
  sprWitchIdle = new PImage[7];
  sprWitchMove = new PImage[8];
  sprWitchAtk = new PImage[14];
  sprWitchDie = new PImage[12];
  loadSpriteFrames(sprWitchIdle, "Enemies/Witch/Idle/WitchIdle_");
  loadSpriteFrames(sprWitchMove, "Enemies/Witch/Move/WitchMove_");
  loadSpriteFrames(sprWitchAtk, "Enemies/Witch/Atk/WitchAttack_");
  loadSpriteFrames(sprWitchDie, "Enemies/Witch/Die/WitchDie_");
  
  // Projectile Sprites
  sprPlasma = new PImage[4];
  sprArrow = new PImage[1];
  loadSpriteFrames(sprPlasma, "Projectiles/Plasma/Plasma_");
  loadSpriteFrames(sprArrow, "Projectiles/Arrows/Arrow_");
  
  // Gem Sprites
  sprGem = new PImage[5];
  loadSpriteFrames(sprGem, "Items/Gem/Gem_");
  
  // Portal Sprites - Green/Level One
  sprPortalGreenOpen = new PImage[15];
  sprPortalGreenIdle = new PImage[5];
  sprPortalGreenFrame = new PImage[4];
  loadSpriteFrames(sprPortalGreenFrame, "Portals/Green/Frame/PortalFrame_");
  loadSpriteFrames(sprPortalGreenOpen, "Portals/Green/Open/PortalOpen_");
  loadSpriteFrames(sprPortalGreenIdle, "Portals/Green/Idle/PortalIdle_");
  
  // Portal Sprites - Blue/Level Two
  sprPortalBlueOpen = new PImage[15];
  sprPortalBlueIdle = new PImage[5];
  sprPortalBlueFrame = new PImage[4];
  loadSpriteFrames(sprPortalBlueFrame, "Portals/Blue/Frame/PortalFrame_");
  loadSpriteFrames(sprPortalBlueOpen, "Portals/Blue/Open/PortalOpen_");
  loadSpriteFrames(sprPortalBlueIdle, "Portals/Blue/Idle/PortalIdle_");
  
  // Miscellaneous Sprites
  spritesUI = new PImage[2];
  spritesOther = new PImage[1];
  spritesEnviro = new PImage[3];
  loadSpriteFrames(spritesEnviro, "Backgrounds/bg_");  // Backgrounds for each level
  spritesUI[0] = loadImage("GUI/Controls.png");  // Control scheme
  spritesUI[1] = loadImage("GUI/Key_E.png");  // For letting player know how to advance dialogue
  spritesOther[0] = loadImage("Projectiles/Arrows/Arrow_Big.png");  // For start/pause screen
  
  bgWidth = spritesEnviro[0].width;  // Hold pixel width of background images
  
  println("MESSAGE: Sprite initialization successful.");
}

// Initialize Sounds
void initSounds() {
  println("MESSAGE: Initializing SFX...");
  
  minim = new Minim(this);
  
  // Load all sounds 
  sfxShoot = new AudioPlayer[9];
  sfxChar = new AudioPlayer[4];
  sfxGem = new AudioPlayer[1];
  sfxPortal = new AudioPlayer[2];
  sfxBackground = new AudioPlayer[1];
  loadSounds(sfxShoot, "Sounds/Bow_");
  loadSounds(sfxChar, "Sounds/Char_");
  loadSounds(sfxGem, "Sounds/Gem_");
  loadSounds(sfxPortal, "Sounds/Portal_");
  loadSounds(sfxBackground, "Sounds/bg_");
  
  // Adjust volumes
  sfxBackground[0].setGain(-15);
  sfxPortal[0].setGain(-10);
  for(int i = 0; i < sfxChar.length; i++)
    sfxChar[i].setGain(-20);
  for(int i = 0; i < sfxShoot.length; i++)
    sfxShoot[i].setGain(-10);
  for(int i = 0; i < sfxGem.length; i++)
    sfxGem[i].setGain(-10);
  
  // Start background music
  playSound(sfxBackground[0]);
  sfxBackground[0].loop(99);  // Loops for 16.5 hours :>
  
  println("MESSAGE: SFX initialization successful.");
}

// Initialize Character
void initChar() {
  println("MESSAGE: Initializing player...");
  PVector vel = new PVector(0, 0);
  PVector dim = new PVector(100, 132);
  PVector pos = new PVector(200, height - groundLevel - dim.y/2);
  PVector[] bb = {new PVector(44, 132), new PVector(-14.5, 0)};
  PVector health = new PVector(5, 4);
  PVector maxHealth = new PVector(5, 4);
  player = new Char(pos, vel, dim, bb, health, maxHealth);
  println("MESSAGE: Player initialization successful.");
}

// Initialize Interactables (camp, tent);
void initInteractables() {
  println("MESSAGE: Initializing interactable objects...");
  // Load campground
  PImage sprite = loadImage("camp.png");
  PVector dim = new PVector(sprite.width, sprite.height);
  PVector pos = new PVector(width, height - groundLevel - sprite.height/2 + 7);
  int range = 100;
  interactables.add(new Checkpoint(pos, dim, sprite, range));
  
  // Load first portal
  PVector portalPos = new PVector(5500, height - groundLevel - sprPortalGreenFrame[0].height/2);
  PVector portalDim = new PVector(256, 256);
  interactables.add(new Portal(portalPos, portalDim, sprPortalGreenFrame, sprPortalGreenOpen, sprPortalGreenIdle));
  println("MESSAGE: Object initialization successful.");
}

// Initialize Other Assets/Variables
void initOther() {
  println("MESSAGE: Initializing other items...");
  // Fonts
  font = loadFont("BookmanOldStyle-120.vlw");
  fontBold = loadFont("BookmanOldStyle-Bold-120.vlw");
  fontItalic = loadFont("BookmanOldStyle-Italic-120.vlw");
  fontBoldItalic = loadFont("BookmanOldStyle-BoldItalic-120.vlw");
  
  // Miscellaneous
  ui = new UI(player);
  currBG = spritesEnviro[0];
  trajectory = true;
  
  // Set varibles for dialogue boxes
  narrPadding = 25;
  narrAlpha = 60;
  narrDim = new PVector(650, 200);
  narrPos = new PVector(width - spritesUI[1].width - narrPadding*2 - narrDim.x/2, narrPadding + narrDim.y/2);
  println("MESSAGE: Other items initialization successful.");
}

// Initialize Enemies - Called after narration. Not in setup.
// PVector Range: Where to position the enemies relative to the player. x = min value, y = max value
void initEnemies(int numEnemies, PVector range) {
  println("MESSAGE: Initializing enemies...");
  for (int i = 0; i < numEnemies; i++) {
    PVector vel = new PVector(random(15, 30), 0);
    PVector dim = new PVector(50, 50);
    PVector pos = new PVector(random(dim.x + range.x, range.y - dim.x), height - groundLevel - dim.y/2);
    PVector[] bb = {new PVector(50, 50), new PVector(0, 0)};
    PVector health = new PVector(3, 1);
    int dmg = 1;
    enemies.add(new Enemy(pos, vel, dim, bb, health, dmg));
  }
  println("MESSAGE: Enemy initialization successful.");
}

// Initialize Buttons - Oh so many buttons
void initButtons() {
  println("MESSAGE: Initializing buttons...");
  color c1 = color(250);  // Text colour
  color c = color(0, 0, 0, .24);  // Button background colour 
  
  controlP5 = new ControlP5(this);
  
  // Play button
  play = controlP5.addButton("Play", 0, 200, 300, 195, 70);
  play.getCaptionLabel().setFont(font);  // Font
  play.setColorLabel(c1);                // Font colour
  play.setColorForeground(c);            // Can't remember
  play.setColorBackground(c);            // Regular button colour
  play.setColorActive(c);                // Hover button colour
  play.getCaptionLabel().setSize(72);    // Font size
  play.getCaptionLabel().alignX(ControlP5.LEFT);  // Font alignment
  // When hovering...
  play.onEnter(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    play.setColorLabel(#9c5b30);
  } } );
  // When leaving button...
  play.onLeave(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    play.setColorLabel(color(250));
  } } );
  // When clicked... play the game
  play.onClick(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    play.hide();
    controls.hide();
    quit.hide();
    state = GAMEPLAY;
  } } );
  
  // Quit button
  quit = controlP5.addButton("Quit", 0, 200, 372 + 20 + 72, 195, 70);
  quit.getCaptionLabel().setFont(font);
  quit.setColorLabel(c1);
  quit.setColorForeground(c);
  quit.setColorBackground(c);
  quit.setColorActive(c);
  quit.getCaptionLabel().setSize(72);
  quit.getCaptionLabel().alignX(ControlP5.LEFT);
  // When hovering...
  quit.onEnter(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    quit.setColorLabel(#9c5b30);
  } } );
  // When leaving button...
  quit.onLeave(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    quit.setColorLabel(color(250));
  } } );
  // When clicked... close the program
  quit.onClick(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    exit();
  } } );
  
  // Restart button
  restart = controlP5.addButton("Restart", 0, 200, 372 + 20 + 72, 345, 70);
  restart.getCaptionLabel().setFont(font);
  restart.setColorLabel(c1);
  restart.setColorForeground(c);
  restart.setColorBackground(c);
  restart.setColorActive(c);
  restart.getCaptionLabel().setSize(72);
  restart.getCaptionLabel().alignX(ControlP5.LEFT);
  // When hovering...
  restart.onEnter(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    restart.setColorLabel(#9c5b30);
  } } );
  // When leaving button...
  restart.onLeave(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    restart.setColorLabel(color(250));
  } } );
  // When clicked... restart the game
  restart.onClick(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    restart.setColorLabel(color(250));
    handleRestart();
    prevState = PAUSE;
  } } );
  restart.hide();  // Hide initially as it is only displayed on the pause/lose/win screen
  
  // Restart level button
  restartLevel = controlP5.addButton("Restart From Checkpoint", 0, 200, 372 + 40 + 72 + 72, 1111, 70);
  restartLevel.getCaptionLabel().setFont(font);
  restartLevel.setColorLabel(c1);
  restartLevel.setColorForeground(c);
  restartLevel.setColorBackground(c); 
  restartLevel.setColorActive(c);
  restartLevel.getCaptionLabel().setSize(72);
  restartLevel.getCaptionLabel().alignX(ControlP5.LEFT);
  // When hovering...
  restartLevel.onEnter(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    restartLevel.setColorLabel(#9c5b30);
  } } );
  // When leaving button...
  restartLevel.onLeave(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    restartLevel.setColorLabel(color(250));
  } } );
  // When clicked...restart the level
  restartLevel.onClick(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    restartLevel.setColorLabel(color(250));
    handleRestartLevel();
    prevState = LOST;
  } } );
  restartLevel.hide();  // Hide initially as it is only displayed on the lose screen
  
  // Go to start button (basically restart)
  menu = controlP5.addButton("Menu", 0, 200, 372 + 10, 195, 70);
  menu.getCaptionLabel().setFont(font);
  menu.setColorLabel(c1);
  menu.setColorForeground(c);
  menu.setColorBackground(c);
  menu.setColorActive(c);
  menu.getCaptionLabel().setSize(72);
  menu.getCaptionLabel().alignX(ControlP5.LEFT);
  // When hovering...
  menu.onEnter(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    menu.setColorLabel(#9c5b30);
  } } );
  // When leaving button...
  menu.onLeave(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    menu.setColorLabel(color(250));
  } } );
  // When clicked... go the start screen (reset game, different name);
  menu.onClick(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    menu.setColorLabel(color(250));
    handleRestart();
    prevState = PAUSE;
  } } );
  menu.hide();  // Hide initially as it is only displayed on the win screen
  
  // Controls button
  controls = controlP5.addButton("Controls", 0, 200, 372 + 10, 420, 70);
  controls.getCaptionLabel().setFont(font);               
  controls.setColorLabel(c1);   
  controls.setColorForeground(c);         
  controls.setColorBackground(c);       
  controls.setColorActive(c);
  controls.getCaptionLabel().setSize(72);
  controls.getCaptionLabel().alignX(ControlP5.LEFT);
  // When hovering...
  controls.onEnter(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    controls.setColorLabel(#9c5b30);
  } } );
  // When leaving button... set secondary color if enabled 
  controls.onLeave(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    if(showControls)
      controls.setColorLabel(#C16F3C);
    else
      controls.setColorLabel(color(250));
  } } );
  // When clicked... toggle viewing the controls
  controls.onClick(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    showControls =! showControls;
  } } );
  
  // Resume button
  resume = controlP5.addButton("Resume", 0, 200, 300, 335, 70);
  resume.getCaptionLabel().setFont(font);               
  resume.setColorLabel(c1);   
  resume.setColorForeground(c);         
  resume.setColorBackground(c);        
  resume.setColorActive(c);
  resume.getCaptionLabel().setSize(72);
  resume.getCaptionLabel().alignX(ControlP5.LEFT);
  // When hovering...
  resume.onEnter(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    resume.setColorLabel(#9c5b30);
  } } );
  // When leaving button...
  resume.onLeave(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    resume.setColorLabel(color(250));
  } } );
  // When clicked... Resume game
  resume.onClick(new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
    handleUnpause();
  } } );
  resume.hide();  // Hide initially as it is only displayed on the pause screen
  println("MESSAGE: Button initialization successful.");
}

// Load sequential sprites into given array by their name
void loadSpriteFrames(PImage[] array, String name) {
  for(int i = 0; i < array.length; i++)
      array[i] = loadImage(name + i + ".png");
}

// Load sequential sounds into given array by their name
void loadSounds(AudioPlayer[] array, String name) {
  for(int i = 0; i < array.length; i++)
      array[i] = minim.loadFile(name + i + ".wav");
}
