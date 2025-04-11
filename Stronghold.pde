import processing.sound.*;
// overall game class

class Game {
  Shop shop;
  // general game logic vars
  int lives = 3;
  int score = 0;
  int coins = 0;
  boolean started = false;
  boolean shopOpen = false;
  int roomID = 0; // 0 is main room, 1 is gas pump, 2 is zombie defend
  
  // images 
  PImage heart = loadImage("heart2.png");
  PImage settings = loadImage("gear.png");
  PImage door = loadImage("door2.png");
  PImage healthPot = loadImage("health pot.png");
  PImage title = loadImage("strongholdTitle.png");
  
  // transition vars
  int transitionAlpha = 0;
  int transitionSpeed = 10;
  boolean transitioning = false;
  boolean fadingToBlack = true;
  int transitionDest = 0;
  
  // game state for menu navigation
  int gameState = 0; // 0=main menu, 1=game, 2=settings, 3=win/loss screen
  String difficulty = "medium"; // "easy", "medium", "hard"
  
  // timer variables
  int gameTimeTotal; // total time to survive in milliseconds
  int gameStartTime; // when the game started
  int timeLeft; // time left in milliseconds
  int quoteTimer; // for spacing out voicelines
  
  // start menu vars
  int startButtonSize = 50;
  int menuButtonWidth = 200;
  int menuButtonHeight = 60;
  int buttonSpacing = 80;
  int settingsButtonSize = 75;
  float soundVolume = 0.5;
  
  // minigames and their timers
  GasPump minigame1;
  ZombieDefense minigame2;
  CrankGenerator minigame3;
  int minigame1_interval = 500; // 500 ms
  int minigame2_interval_1 = 45; // Zombie
  int minigame2_interval_2 = 1; // Bullet
  int minigame3_interval = 30; // Crank Light
  int minigame1_lastTime = 0;
  int minigame2_lastTime_1 = 0;
  int minigame2_lastTime_2 = 0;
  int minigame3_lastTime = 0;
  
  // SFX
  PApplet parent;
  SoundFile winSound;
  SoundFile loseSound;
  SoundFile helpAlmostHereSound;
  SoundFile gasLowSound;
  SoundFile zombieDoorstepSound;
  boolean endQuotePlayed = false;
  boolean helpAlmostHerePlayed = false;
  
  SoundFile[] hurtSound;
  
  // main room vars
  int playerX = width/4;
  int playerY = height/2;
  int playerSpeed = 2;
  boolean playerMovingUp = false;
  boolean playerMovingDown = false;
  boolean playerMovingLeft = false;
  boolean playerMovingRight = false;
  
  int minigame1X = 200;
  int minigame1Y = 200;
  int minigame2X = width - 200;
  int minigame2Y = 200;
  int minigame3X = width/2;
  int minigame3Y = 380;
  
  Game(PApplet p) {
    parent = p;
    minigame1 = new GasPump();
    minigame2 = new ZombieDefense();
    minigame3 = new CrankGenerator();
    lives = 5;
    setupDifficulty("medium");
    
    winSound = new SoundFile(parent, "Win.mp3");
    loseSound = new SoundFile(parent, "Lose.mp3");
    hurtSound = new SoundFile[3];
    hurtSound[0] = new SoundFile(parent, "Hurt1.mp3");
    hurtSound[1] = new SoundFile(parent, "Hurt2.mp3");
    hurtSound[2] = new SoundFile(parent, "Hurt3.mp3");
    helpAlmostHereSound = new SoundFile(parent, "HelpAlmostHere.mp3");
    gasLowSound = new SoundFile(parent, "gasLow.mp3");
    zombieDoorstepSound = new SoundFile(parent, "ZombieDoorstep.mp3");
  }
  
  Game(PApplet p, int livesArg) {
    parent = p;
    minigame1 = new GasPump();
    minigame2 = new ZombieDefense();
    minigame3 = new CrankGenerator();
    lives = livesArg;
    setupDifficulty("medium");
    winSound = new SoundFile(parent, "Win.mp3");
    loseSound = new SoundFile(parent, "Lose.mp3");
    hurtSound = new SoundFile[3];
    hurtSound[0] = new SoundFile(parent, "Hurt1.mp3");
    hurtSound[1] = new SoundFile(parent, "Hurt2.mp3");
    hurtSound[2] = new SoundFile(parent, "Hurt3.mp3");
    helpAlmostHereSound = new SoundFile(parent, "HelpAlmostHere.mp3");
    gasLowSound = new SoundFile(parent, "GasLow.mp3");
    zombieDoorstepSound = new SoundFile(parent, "ZombieDoorstep.mp3");
  }
  
  void setupDifficulty(String diff) {
    difficulty = diff;
    lives = 3; // Always 3 lives regardless of difficulty
    
    if (difficulty.equals("easy")) {
      gameTimeTotal = 60 * 1000; // 1 minute in milliseconds
      minigame1_interval = 600;
      minigame1.decreaseRate = 0.3;
      minigame1.increaseRate = 10;
      minigame3.decreaseRate = 0.15;
    } 
    else if (difficulty.equals("medium")) {
      gameTimeTotal = 3 * 60 * 1000; // 3 minutes in milliseconds
      minigame1_interval = 500;
      minigame1.decreaseRate = 0.5;
      minigame1.increaseRate = 8;
      minigame3.decreaseRate = 0.25;
    } 
    else if (difficulty.equals("hard")) {
      gameTimeTotal = 5 * 60 * 1000; // 5 minutes in milliseconds
      minigame1_interval = 400;
      minigame1.decreaseRate = 0.7;
      minigame1.increaseRate = 6;
      minigame3.decreaseRate = 0.4;
    }
  }
  
  void updatePlayerPos() {
    if (playerMovingUp && playerY >= 87) // W
      playerY -= playerSpeed;
    if (playerMovingLeft && playerX >= 0) // A
      playerX -= playerSpeed;
    if (playerMovingDown && playerY <= height - 20) // S
      playerY += playerSpeed;
    if (playerMovingRight && playerX <= width - 20) // D
      playerX += playerSpeed;
  }
  
  void stopPlayer() {
    playerMovingUp = false;
    playerMovingDown = false;
    playerMovingLeft = false;
    playerMovingRight = false;
  }
  
  void roomTransition(int newRoom) {
    fill(0, transitionAlpha);
    rect(0, 85, width, height);
    if (fadingToBlack) {
      transitionAlpha += transitionSpeed;
      if (transitionAlpha >= 255) {
        transitionAlpha = 255;
        roomID = newRoom;
        fadingToBlack = false;
      }
    } else {
      transitionAlpha -= transitionSpeed;
      if (transitionAlpha <= 0) {
        transitionAlpha = 0;
        transitioning = false;
        fadingToBlack = true;
      }
    }
  }
  
  // draws the shop when opened
  void drawShopOverlay() {
    fill(30, 30, 30, 220);
    rect(width / 2 - 200, height / 2 - 150, 400, 300, 20);
  
    fill(255);
    textAlign(CENTER);
    textSize(24);
    text("Shop", width / 2, height / 2 - 100);
    image(healthPot, width/3, height/3, 100, 100);
    image(healthPot, (width/3) +110, height/3, 100, 100);
    image(healthPot, (width/3) + 220, height/3, 100, 100);
    textSize(16);
    text("Press 'B' to buy an health potion for " + shop.itemCost + " coins!", width / 2, height / 2+ 20);
    text("You currently have " + coins + " coins.", width / 2, height / 2 + 60);
    text("Press 'R' to exit", width / 2, height / 2 + 100);
}

  void display() {
    if (started) {
      // Update and check timer
      timeLeft = gameTimeTotal - (millis() - gameStartTime);
      
      if (timeLeft <= 0 && lives > 0) {
        // You win! Game completed successfully
        if (!winSound.isPlaying() && !endQuotePlayed) {
          winSound.play();
          endQuotePlayed = true;
        }
        
        gameState = 3;
        
        fill(0, 150, 0);
        rect(-5, -5, width + 5, height + 5);
        
        fill(255);
        textAlign(CENTER, CENTER);
        textSize(40);
        text("YOU SURVIVED!", width/2, height/2 - 50);
        textSize(28);
        text("Congratulations!", width/2, height/2);
        
        textSize(24);
        text("Press R to return to menu", width/2, height/2 + 50);
        return;
      }
      
      if (lives <= 0) {
        if (!loseSound.isPlaying() && !endQuotePlayed) {
          loseSound.play();
          endQuotePlayed = true;
        }
        
        gameState = 3;
        fill(0, 0, 255);
        rect(-5, -5, width + 5, height + 5);
        
        fill(255);
        textAlign(CENTER, CENTER);
        textSize(40);
        text("GAME OVER", width/2, height/2 - 50);
        
        textSize(24);
        text("Press R to return to menu", width/2, height/2 + 50);
        return;
      }
      // shop initialization; bool handled in main
      shop = new Shop(this, 20);
      
      // White top bar overlay
      fill(255);
      rectMode(CORNER);
      rect(-5, -5, width + 5, 90);
      
      // Hearts
      imageMode(CORNER);
      int heartCorner = 0;
      for (int i = 0; i < lives; i++) {
        image(heart, heartCorner, -30, 150, 150);
        heartCorner += 85;
      }
      
      // coins
      fill(200, 200, 0);
      rect(width/2 - 10, 30, 20, 20);
      textAlign(RIGHT, CENTER);
      textSize(40);
      text(coins, width/2 + 50, 40);
      
      // Display timer
      fill(0);
      textAlign(RIGHT, CENTER);
      textSize(30);
      
      // Format time as MM:SS
      int secondsLeft = timeLeft / 1000;
      int minutes = secondsLeft / 60;
      int seconds = secondsLeft % 60;
      
      String timeString = nf(minutes, 2) + ":" + nf(seconds, 2);
      
      // Change color when time is running low (less than 30 seconds)
      if (secondsLeft < 30) {
        fill(255, 0, 0);
        if (!helpAlmostHerePlayed) {
          helpAlmostHereSound.play();
          helpAlmostHerePlayed = true;
        }
      }
      
      text(timeString, width - 20, 45);
      
      if (roomID == 0) {  // in main room
        // noStroke();
        
        // minigame1
        if (playerX >= minigame1X && playerX + 20 <= minigame1X + 50 && playerY >= minigame1Y && playerY + 20 <= minigame1Y + 50) {
          // we are on the minigame1 door
          strokeWeight(2);
          stroke(255);
        } 
        fill(minigame1.getColor());
        rectMode(CORNER);
        rect(minigame1X+40, minigame1Y+15, 30, 60);
        image(door, minigame1X, minigame1Y, 100, 100);
        strokeWeight(1);
        stroke(0);
        
        if (playerX >= minigame2X && playerX + 20 <= minigame2X + 50 && playerY >= minigame2Y && playerY + 20 <= minigame2Y + 50) {
          // we are on the minigame2 door
          strokeWeight(2);
          stroke(255);
        }
        fill(minigame2.getColor());
        rectMode(CORNER);
        rect(minigame2X+40, minigame2Y+15, 30, 60);
        image(door, minigame2X, minigame2Y, 100, 100);
        strokeWeight(1);
        stroke(0);
        
        if (playerX >= minigame3X && playerX + 20 <= minigame3X + 50 && playerY >= minigame3Y && playerY + 20 <= minigame3Y + 50) {
          // we are on the minigame3 door
          strokeWeight(2);
          stroke(255);
        }
        fill(minigame3.getColor());
        rectMode(CORNER);
         rect(minigame3X+40, minigame3Y+15, 30, 60);
        image(door, minigame3X, minigame3Y, 100, 100);
        strokeWeight(1);
        stroke(0);
        
        // player
        updatePlayerPos();
        fill(0, 0, 255);
        rectMode(CORNER);
        rect(playerX, playerY, 20, 20);
        
      } else if (roomID == 1) {
        minigame1.display();
      }
      else if (roomID == 2){
        minigame2.display();
      }
      else if (roomID == 3){
        minigame3.display();
      }
    } 
      else {  // Not started, display menus
        if (gameState == 0) {
          mainMenu();
        } else if (gameState == 2) {
          settingsMenu();
        }
    }
    
    if (transitioning) {
      roomTransition(transitionDest);
    }
  }
  
  void mainMenu() {
    background(30, 60, 90);
    
    // Title
    //fill(255);
    //textAlign(CENTER, CENTER);
    //textSize(50);
    //text("STRONGHOLD SURVIVAL", width/2, height/5);
    image(title, width/2, height/5, 500, 200);
    
    // Difficulty buttons
    rectMode(CORNER);
    int buttonY = height/2 - 100;
    
    // Easy button (1 minute)
    if (isMouseOverRect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight)) {
      fill(100, 200, 100);
    } else {
      fill(60, 160, 60);
    }
    rect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight, 10);
    fill(255);
    textSize(24);
    text("Easy (1 min)", width/2, buttonY + menuButtonHeight/2);
    
    // Medium button (3 minutes)
    buttonY += buttonSpacing;
    if (isMouseOverRect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight)) {
      fill(200, 200, 100);
    } else {
      fill(160, 160, 60);
    }
    rect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight, 10);
    fill(255);
    text("Medium (3 min)", width/2, buttonY + menuButtonHeight/2);
    
    // Hard button (5 minutes)
    buttonY += buttonSpacing;
    if (isMouseOverRect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight)) {
      fill(200, 100, 100);
    } else {
      fill(160, 60, 60);
    }
    rect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight, 10);
    fill(255);
    text("Hard (5 min)", width/2, buttonY + menuButtonHeight/2);
    
    // Settings button (circular in bottom right)
    float settingsX = width - settingsButtonSize - 20;
    float settingsY = height - settingsButtonSize - 20;
    
    if (dist(mouseX, mouseY, settingsX + settingsButtonSize/2, settingsY + settingsButtonSize/2) < settingsButtonSize/2) {
      fill(120, 120, 200);
    } else {
      fill(80, 80, 160);
    }
    // Draw gear icon using the settings image
    imageMode(CENTER);
    image(settings, settingsX + settingsButtonSize/2, settingsY + settingsButtonSize/2, settingsButtonSize * 0.7, settingsButtonSize * 0.7);
    
    // Show time to survive for selected difficulty
    fill(255);
    textAlign(CENTER, BOTTOM);
    textSize(16);
    text("Survive until help arrives!", width/2, height - 20);
  }
  
  void settingsMenu() {
    background(40, 40, 60);
    
    // Title
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(40);
    text("SETTINGS", width/2, height/5);
    
    // Volume slider
    textSize(24);
    text("Sound Volume", width/2, height/3);
    
    fill(100);
    rect(width/2 - 150, height/3 + 40, 300, 20, 10);
    
    fill(200, 200, 0);
    ellipse(width/2 - 150 + (300 * soundVolume), height/3 + 50, 30, 30);
    
    // Controls display
    fill(255);
    textSize(30);
    text("Controls", width/2, height/2);
    
    textSize(20);
    textAlign(LEFT, CENTER);
    text("Move: WASD or Arrow Keys", width/2 - 250, height/2 + 40);
    text("Exit Minigame: SPACE", width/2 - 250, height/2 + 70);
    text("Interact: MOUSE", width/2 - 250, height/2 + 100);
    
    // Buttons at bottom - horizontal layout
    textAlign(CENTER, CENTER);
    rectMode(CORNER);
    
    int buttonY = height - 100;
    int smallButtonWidth = 180;
    int buttonSpacing = 20;
    
    // If we came from the game, show a "Resume Game" button and Main Menu side by side
    if (timeLeft > 0) {
      // Resume Game button (left)
      if (isMouseOverRect(width/2 - smallButtonWidth - buttonSpacing/2, buttonY, smallButtonWidth, menuButtonHeight)) {
        fill(100, 200, 100);
      } else {
        fill(60, 160, 60);
      }
      rect(width/2 - smallButtonWidth - buttonSpacing/2, buttonY, smallButtonWidth, menuButtonHeight, 10);
      fill(255);
      textSize(24);
      text("Resume Game", width/2 - smallButtonWidth/2 - buttonSpacing/2, buttonY + menuButtonHeight/2);
      
      // Main Menu button (right)
      if (isMouseOverRect(width/2 + buttonSpacing/2, buttonY, smallButtonWidth, menuButtonHeight)) {
        fill(100, 100, 200);
      } else {
        fill(60, 60, 160);
      }
      rect(width/2 + buttonSpacing/2, buttonY, smallButtonWidth, menuButtonHeight, 10);
      fill(255);
      textSize(24);
      text("Main Menu", width/2 + smallButtonWidth/2 + buttonSpacing/2, buttonY + menuButtonHeight/2);
    } else {
      // Just show one centered "Back to Menu" button if not in game
      if (isMouseOverRect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight)) {
        fill(100, 100, 200);
      } else {
        fill(60, 60, 160);
      }
      rect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight, 10);
      fill(255);
      textSize(24);
      text("Back to Menu", width/2, buttonY + menuButtonHeight/2);
    }
  }
  
  boolean isMouseOverRect(float x, float y, float w, float h) {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }
  
  void updateCoins() {
    coins += minigame2.getCoins();
  }
  
  boolean isDraggingSlider = false;
  
  void handleMousePressed() {
    if (started) {
      // check roomID and do stuff based on what room user is in
      if (roomID == 1) {
        minigame1.handleMousePressed();
      }
      else if (roomID == 3) {
        minigame3.handleMousePressed();
      }
    } 
    else {
      // Handle menu interactions
      if (gameState == 0) { // Main menu
        int buttonY = height/2 - 100;
        
        // Easy button
        if (isMouseOverRect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight)) {
          setupDifficulty("easy");
          started = true;
          gameState = 1;
          gameStartTime = millis();
        }
        
        // Medium button
        buttonY += buttonSpacing;
        if (isMouseOverRect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight)) {
          setupDifficulty("medium");
          started = true;
          gameState = 1;
          gameStartTime = millis();
        }
        
        // Hard button
        buttonY += buttonSpacing;
        if (isMouseOverRect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight)) {
          setupDifficulty("hard");
          started = true;
          gameState = 1;
          gameStartTime = millis();
        }
        
        // Settings button (circular in bottom right)
        float settingsX = width - settingsButtonSize - 20;
        float settingsY = height - settingsButtonSize - 20;
        if (dist(mouseX, mouseY, settingsX + settingsButtonSize/2, settingsY + settingsButtonSize/2) < settingsButtonSize/2) {
          gameState = 2; // Go to settings
        }
      } 
      else if (gameState == 2) { // Settings menu
        // Volume slider
        if (mouseY >= height/3 + 30 && mouseY <= height/3 + 70 && 
            mouseX >= width/2 - 150 && mouseX <= width/2 + 150) {
          soundVolume = constrain((mouseX - (width/2 - 150)) / 300.0, 0, 1);
          isDraggingSlider = true;
        }
        
        int buttonY = height - 100;
        int smallButtonWidth = 180;
        int buttonSpacing = 20;
        
        // Check for button clicks based on layout
        if (timeLeft > 0) {
          // Resume Game button (left)
          if (isMouseOverRect(width/2 - smallButtonWidth - buttonSpacing/2, buttonY, smallButtonWidth, menuButtonHeight)) {
            gameState = 1; // Return to game
            started = true; // Resume the game
            return;
          }
          
          // Main Menu button (right)
          if (isMouseOverRect(width/2 + buttonSpacing/2, buttonY, smallButtonWidth, menuButtonHeight)) {
            gameState = 0; // Return to main menu
          }
        } else {
          // Single "Back to Menu" button
          if (isMouseOverRect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight)) {
            gameState = 0; // Return to main menu
          }
        }
      }
    }
  }
  
  void handleKeyPressed(char key, int keyCode) {
    if (started) {
      if (gameState == 3 && (key == 'r' || key == 'R')) {
        // Reset game and return to menu
        resetGame();
        return;
      }
      
      if (key == 'p' || key == 'P') { // Pause or settings
        started = false;
        gameState = 2; // Go to settings
        return;
      }
      
      if (roomID == 0) {
        if (key == 'e' || key == 'E') {
          // trying to transition to room, check which one
          if (playerX >= minigame1X && playerX + 20 <= minigame1X + 50 && playerY >= minigame1Y && playerY + 20 <= minigame1Y + 50) {
            transitioning = true;
            transitionDest = 1;
            stopPlayer();
          }
          else if (playerX >= minigame2X && playerX + 20 <= minigame2X + 50 && playerY >= minigame2Y && playerY + 20 <= minigame2Y + 50){
            stopPlayer();
            transitioning = true;
            transitionDest = 2;
            stopPlayer();
          }
          else if (playerX >= minigame3X && playerX + 20 <= minigame3X + 50 && playerY >= minigame3Y && playerY + 20 <= minigame3Y + 50){
            stopPlayer();
            transitioning = true;
            transitionDest = 3;
            stopPlayer();
          }
        }
        
        // we are in the main room. move the player around
        if ((key == 'w' || key == 'W' || keyCode == UP) && playerY >= 87) { 
          // character can't access the top chunk of the screen because that's where the overlay will go
          playerMovingUp = true;
        }
        if ((key == 'a' || key == 'A' || keyCode == LEFT) && playerX >= 0) {
          playerMovingLeft = true;
        }
        if ((key == 's' || key == 'S' || keyCode == DOWN) && playerY <= height) {
          playerMovingDown = true;
        }
        if ((key == 'd' || key == 'D' || keyCode == RIGHT) && playerX <= width) {
          playerMovingRight = true;
        }
      } else {
        if (key == 32) {// space bar to exit minigame
          transitioning = true;
          transitionDest = 0;
          minigame2.stopPlayer();
        }
        if (roomID == 2) {
          minigame2.handleKeyPressed(key, keyCode);
        }
      }
    } else {
      // In menu
      if (key == 27) { // ESC key
        if (gameState == 2) { // In settings
          if (timeLeft > 0) {
            // If we came from the game, return to it
            gameState = 1; 
            started = true;
          } else {
            // Otherwise return to main menu
            gameState = 0;
          }
        }
      }
    }
  }
  
  void resetGame() {
    started = false;
    gameState = 0;
    lives = 3;
    roomID = 0;
    coins = 0;
    playerX = width/4;
    playerY = height/2;
    minigame1 = new GasPump();
    minigame2 = new ZombieDefense();
    minigame3 = new CrankGenerator();
    setupDifficulty(difficulty);
    
    // Reset player movement
    playerMovingUp = false;
    playerMovingDown = false;
    playerMovingLeft = false;
    playerMovingRight = false;
    
    // sfx reset
    endQuotePlayed = false;
    helpAlmostHerePlayed = false;
  }
  
  void handleKeyReleased(char key, int keyCode) {
    if (started) {
      if (roomID == 0) {
        // we are in the main room. move the player around
        if ((key == 'w' || key == 'W' || keyCode == UP)) {
          // character can't access the top chunk of the screen because that's where the overlay will go
          playerMovingUp = false;
        }
        if ((key == 'a' || key == 'A' || keyCode == LEFT)) {
          playerMovingLeft = false;
        }
        if ((key == 's' || key == 'S' || keyCode == DOWN)) {
          playerMovingDown = false;
        }
        if ((key == 'd' || key == 'D' || keyCode == RIGHT)) {
          playerMovingRight = false;
        }
      }
      else if (roomID == 2) {
        minigame2.handleKeyReleased(key, keyCode);
      }
    }
  }
  
  void handleMouseDragged() {
    if (!started && gameState == 2 && isDraggingSlider) {
      if (mouseX >= width/2 - 150 && mouseX <= width/2 + 150) {
        soundVolume = constrain((mouseX - (width/2 - 150)) / 300.0, 0, 1);
      }
    }
    else if (started && roomID == 3) {
      minigame3.handleMouseDragged();
    }
  }
  
  void handleMouseReleased() {
    isDraggingSlider = false;
    if (started && roomID == 3) {
      minigame3.handleMouseReleased();
    }
  }
  
  void applyVolumeSettings() {
    winSound.amp(soundVolume);
    loseSound.amp(soundVolume);
    helpAlmostHereSound.amp(soundVolume);
    gasLowSound.amp(soundVolume);
    zombieDoorstepSound.amp(soundVolume);
    
    for (int i = 0; i < hurtSound.length; i++) {
      hurtSound[i].amp(soundVolume);
    }
  }
  
  void update() {
  // if started, update all minigames based on their own timers
  // if a minigame's timer is going off, tick it and check for important info
    applyVolumeSettings();
    
    if (started && gameState == 1) {
      if (millis() - minigame1_lastTime >= minigame1_interval) {
        if (minigame1.tick() == -1) {
          lives--;
          if (lives > 0) {
            hurtSound[(int)random(3)].play();
          }
        }
        if (minigame1.quotePrimed) {
          minigame1.quotePrimed = false;
          if (roomID != 1) {
            gasLowSound.play();
          }
        }
        minigame1_lastTime = millis();
      }
      // Zombie
      if (millis() - minigame2_lastTime_1 >= minigame2_interval_1) {
        if (minigame2.tick() == -1) {
          lives--;
          if (lives > 0) {
            hurtSound[(int)random(3)].play();
          }
        }
        if (minigame2.quotePrimed) {
          minigame2.quotePrimed = false;
          if (roomID != 2) {
            zombieDoorstepSound.play();
          }
        }
        minigame2_lastTime_1 = millis();
      }
      //Bullet
      if (millis() - minigame2_lastTime_2 >= minigame2_interval_2) {
        minigame2.tick2();
        minigame2_lastTime_2 = millis();
      }
      
      // Crank Light
      if (millis() - minigame3_lastTime >= minigame3_interval) {
        if (minigame3.tick() == -1) {
          lives--;
          if (lives > 0) {
            hurtSound[(int)random(3)].play();
          }
        }
        if (minigame3.quotePrimed) {
          minigame3.quotePrimed = false;
        }
        minigame3_lastTime = millis();
      }
      
      // coins
      updateCoins();
      
    }
  }
  
}
