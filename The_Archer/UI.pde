// UI: Grouping all screens into a UI class just because I can :>

class UI {
  Char p;
  float winAlpha = 0;  // The alpha value for fading in the win screen
  
  UI(Char p) {
    this.p = p;
  }
  
  // Pause Screen
  void renderPauseScreen() {
    pushMatrix();
    rectMode(CORNER);
    noStroke();
    fill(0, 20);
    rect(0, 0, width, height);
    translate(200, 250);
    textAlign(LEFT, BOTTOM);
    textFont(fontBold);
    textSize(72);
    fill(250);
    text("PAUSED", 0, 0);
    translate(385, -72/1.75);
    tint(255, 60);
    image(spritesOther[0], 0, 0);
    popMatrix();
    if(showControls)
      renderControlScreen();
  }
  
  // Win Screen
  void renderWinScreen() {
    if(winAlpha < 60)
      winAlpha += 0.33;
    pushMatrix();
    translate(width/2, height/4);
    textAlign(CENTER, CENTER);
    textFont(fontBold);
    textSize(96);
    fill(255, winAlpha);
    text("You won!", 0, 0);
    popMatrix();
    
    if(winAlpha >= 60 && state == WON) {  // Show buttons after fade-in
      quit.show();
      menu.show();
    }
    else {
      restartLevel.hide();
      restart.hide();
      quit.hide();
      menu.hide();
    }
  }
  
  // Lose Screen
  void renderLoseScreen() {
    pushMatrix();
    translate(width/2, height/4);
    textAlign(CENTER, CENTER);
    textFont(fontBold);
    textSize(96);
    if(level == LVL_2)
      fill(0, 60 - player.alpha);
    else
      fill(255, 60 - player.alpha);
    text("You Died.", 0, 0);
    popMatrix();
    
    // Show buttons after fade-in
    if(player.alpha <= 0 && !player.isAlive) {  //Fade-in is based off of the player's own alpha value  
      restartLevel.show();
      restart.show();
    }
    else {
      restartLevel.hide();
      restart.hide();
    }
  }
  
  // Health & Shield bar
  void renderHUD() {
    pushMatrix();
    rectMode(CORNER);
    translate(50, 50);
    fill(map(p.health.x, 0, p.maxHealth.x, 100, 255), 0, 0);  // Health bar
    noStroke();
    int rectWidth = int(map(p.health.x, 0, p.maxHealth.x, 0, 500));
    rect(0, 0, rectWidth, 50);
    
    // Health bar outline 
    noFill();
    strokeWeight(5);
    if(level == LVL_3)
      stroke(255);
    else
      stroke(0);
    rect(0, 0, 500, 50);
    
    translate(0, 75);
    fill(#6AEAFF);
    noStroke();
    rectWidth = int(map(p.health.y, 0, p.maxHealth.y, 0, 500));  // Shield bar
    rect(0, 0, rectWidth, 50);
    
    // Shield bar outline
    noFill();
    strokeWeight(5);
    if(level == LVL_3)
      stroke(255);
    else
      stroke(0);
    rect(0, 0, 500, 50);
    popMatrix();
  }
  
  // Start screen
  void renderStartScreen() {
    renderBackground();
    pushMatrix();
    translate(200, 250);
    textAlign(LEFT, BOTTOM);
    textFont(fontBold);
    textSize(72);
    fill(250);
    text("The Archer", 0, 0);
    translate(450, -72/1.5);
    tint(255, 60);
    image(spritesOther[0], 0, 0);
    popMatrix();
    if(showControls)
      renderControlScreen();
  }
  
  // Controls image
  void renderControlScreen() {
    pushMatrix();
    translate(width-73-spritesUI[0].width, 73);
    imageMode(CORNER);
    image(spritesUI[0], 0, 0);
    translate(spritesUI[0].width/2, 50);
    popMatrix();
  }
  
  // Render the dialogue with the title, the content, and the positions. Was going to do a fade animation but ran out of time
  void renderNarrative(String speaker, String text, PVector pos, PVector dim, int padding, int alpha) {
    renderTextBox(pos, dim, padding, alpha);
    writeTitle(pos, dim, speaker, padding, alpha);
    writeText(pos, dim, text, padding, alpha);
  }
  
  // Render the text box
  void renderTextBox(PVector pos, PVector dim, int padding, int alpha) {
    fill(255, alpha);
    stroke(0, alpha);
    strokeWeight(4);
    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rect(0, 0, dim.x, dim.y);
    popMatrix();
  }
  
  // Render the title/speaker
  void writeTitle(PVector pos, PVector dim, String speaker, int padding, int alpha) {
    textAlign(LEFT, TOP);
    textFont(fontBold);
    textSize(36);
    fill(0, alpha);
    pushMatrix();
    translate(pos.x - dim.x/2 + padding, pos.y - dim.y/2 + padding);
    text(speaker, 0, 0);
    popMatrix();
  }
  
  // Render the dialogue
  void writeText(PVector pos, PVector dim, String text, int padding, int alpha) {
    textAlign(LEFT, TOP);
    textFont(font);
    textSize(24);
    fill(0, alpha);
    pushMatrix();
    translate(pos.x - dim.x/2 + padding, pos.y - dim.y/2 + padding*2 + 36);
    text(text, 0, 0);
    popMatrix();
  }
  
  // Show the button to advance the dialogue. Alpha value shows when you can press it.
  void showKeyE(int alpha) {
    pushMatrix();
    imageMode(CORNER);
    translate(width - spritesUI[1].width - narrPadding, narrPadding);
    tint(255, alpha);
    image(spritesUI[1], 0, 0);
    popMatrix();
  }
  
}
