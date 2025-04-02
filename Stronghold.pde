import processing.sound.*;
// overall game class
class Game {
  
  // general game logic vars
  int lives = 3;
  int score = 0;
  boolean started = false;
  int roomID = 0; // 0 is main room, 1 is gas pump, 2 is zombie defend
  PImage heart = loadImage("heart1.png");
  PImage settings = loadImage("gear.png");
  
  // transition vars
  int transitionAlpha = 0;
  int transitionSpeed = 10;
  boolean transitioning = false;
  boolean fadingToBlack = true;
  int transitionDest = 0;
  
  // game state for menu navigation
  int gameState = 0; // 0=main menu, 1=game, 2=settings 
  String difficulty = "medium"; // "easy", "medium", "hard"
  
  // timer variables
  int gameTimeTotal; // total time to survive in milliseconds
  int gameStartTime; // when the game started
  int timeLeft; // time left in milliseconds
  
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
  int minigame1_interval = 500; // 500 ms
  int minigame1_lastTime = 0;
  
  
  // main room vars
  int playerX = width/4;
  int playerY = height/2;
  int playerSpeed = 2;
  boolean playerMovingUp = false;
  boolean playerMovingDown = false;
  boolean playerMovingLeft = false;
  boolean playerMovingRight = false;
  
  int minigame1X = 200;
  int minigame1Y = 300;
  int minigame2X = width - 200;
  int minigame2Y = 300;
  
  Game() {
    minigame1 = new GasPump();
    minigame2 = new ZombieDefense();
    lives = 5;
    setupDifficulty("medium");
  }
  
  Game(int livesArg) {
    minigame1 = new GasPump();
    minigame2 = new ZombieDefense();
    lives = livesArg;
    setupDifficulty("medium");
  }
  
  void setupDifficulty(String diff) {
    difficulty = diff;
    lives = 3; // Always 3 lives regardless of difficulty
    
    if (difficulty.equals("easy")) {
      gameTimeTotal = 60 * 1000; // 1 minute in milliseconds
      minigame1_interval = 600;
      minigame1.decreaseRate = 0.3;
      minigame1.increaseRate = 10;
    } 
    else if (difficulty.equals("medium")) {
      gameTimeTotal = 3 * 60 * 1000; // 3 minutes in milliseconds
      minigame1_interval = 500;
      minigame1.decreaseRate = 0.5;
      minigame1.increaseRate = 8;
    } 
    else if (difficulty.equals("hard")) {
      gameTimeTotal = 5 * 60 * 1000; // 5 minutes in milliseconds
      minigame1_interval = 400;
      minigame1.decreaseRate = 0.7;
      minigame1.increaseRate = 6;
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
  
  void display() {
    if (started) {
      // Update and check timer
      timeLeft = gameTimeTotal - (millis() - gameStartTime);
      
      if (timeLeft <= 0 && lives > 0) {
        // You win! Game completed successfully
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
        // you lost :(
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
      
      // White top bar overlay
      fill(255);
      rectMode(CORNER);
      rect(-5, -5, width + 5, 90);
      
      // Hearts
      imageMode(CORNER);
      int heartCorner = 0;
      for (int i = 0; i < lives; i++) {
        image(heart, heartCorner, -5, 100, 100);
        heartCorner += 85;
      }
      
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
        rect(minigame1X, minigame1Y, 50, 50);
        strokeWeight(1);
        stroke(0);
        
        if (playerX >= minigame2X && playerX + 20 <= minigame2X + 50 && playerY >= minigame2Y && playerY + 20 <= minigame2Y + 50) {
          // we are on the minigame1 door
          strokeWeight(2);
          stroke(255);
        }
        fill(minigame2.getColor());
        rectMode(CORNER);
        rect(minigame2X, minigame2Y, 50, 50);
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
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(50);
    text("STRONGHOLD SURVIVAL", width/2, height/5);
    
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
    if (difficulty.equals("easy")) {
      text("Survive for 1 minute", width/2, height - 20);
    } else if (difficulty.equals("medium")) {
      text("Survive for 3 minutes", width/2, height - 20);
    } else if (difficulty.equals("hard")) {
      text("Survive for 5 minutes", width/2, height - 20);
    }
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
    
    // Back button
    textAlign(CENTER, CENTER);
    rectMode(CORNER);
    int buttonY = height - 100;
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
  
  boolean isMouseOverRect(float x, float y, float w, float h) {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }
  
  void handleMousePressed() {
    if (started) {
      // check roomID and do stuff based on what room user is in
      if (roomID == 1) {
        minigame1.handleMousePressed();
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
          gameStartTime = millis();
        }
        
        // Medium button
        buttonY += buttonSpacing;
        if (isMouseOverRect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight)) {
          setupDifficulty("medium");
          started = true;
          gameStartTime = millis();
        }
        
        // Hard button
        buttonY += buttonSpacing;
        if (isMouseOverRect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight)) {
          setupDifficulty("hard");
          started = true;
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
        }
        
        // Back button
        int buttonY = height - 100;
        if (isMouseOverRect(width/2 - menuButtonWidth/2, buttonY, menuButtonWidth, menuButtonHeight)) {
          gameState = 0; // Return to main menu
        }
      }
    }
  }
  
  void handleKeyPressed(char key, int keyCode) {
    if (started) {
      if (lives <= 0 && (key == 'r' || key == 'R')) {
        // Reset game and return to menu
        resetGame();
        return;
      }
      
      if (roomID == 0) {
        if (key == 'e' || key == 'E') {
          // trying to transition to room, check which one
          if (playerX >= minigame1X && playerX + 20 <= minigame1X + 50 && playerY >= minigame1Y && playerY + 20 <= minigame1Y + 50) {
            transitioning = true;
            transitionDest = 1;
          }
          else if (playerX >= minigame2X && playerX + 20 <= minigame2X + 50 && playerY >= minigame2Y && playerY + 20 <= minigame2Y + 50){
            transitioning = true;
            transitionDest = 2;
          }
        }
        
        if (key == 'p' || key == 'P') { // Pause or settings
          started = false;
          gameState = 2; // Go to settings
          return;
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
      } else if (roomID == 1|| roomID == 2) {
        if (key == 32) {// space bar to exit minigame
          transitioning = true;
          transitionDest = 0;
        }
        if (roomID == 2) {
          minigame2.handleKeyPressed(key, keyCode);
        }
      }
    } else {
      // In menu
      if (key == 27) { // ESC key
        if (gameState == 2) { // In settings
          gameState = 0; // Return to main menu
        }
      }
    }
  }
  
  void resetGame() {
    started = false;
    gameState = 0;
    lives = 3;
    roomID = 0;
    playerX = width/4;
    playerY = height/2;
    minigame1 = new GasPump();
    minigame2 = new ZombieDefense();
    setupDifficulty(difficulty);
    
    // Reset player movement
    playerMovingUp = false;
    playerMovingDown = false;
    playerMovingLeft = false;
    playerMovingRight = false;
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
  
  void update() {
  // if started, update all minigames based on their own timers
  // if a minigame's timer is going off, tick it and check for important info
    if (started) {
      if (millis() - minigame1_lastTime >= minigame1_interval) {
        lives += minigame1.tick();
        minigame1_lastTime = millis();
      }
    }
  }
  
}
