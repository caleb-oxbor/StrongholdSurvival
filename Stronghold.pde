import processing.sound.*;
// overall game class
class Game {
  
  // general game logic vars
  int lives;
  int score = 0;
  boolean started = false;
  int roomID = 0; // 0 is main room, 1 is gas pump
  PImage heart = loadImage("heart1.png");
  
  // start menu vars
  int startButtonSize = 50;
  
  // minigames and their timers
  GasPump minigame1;
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
  
  Game() {
    minigame1 = new GasPump();
    lives = 5;
  }
  
  Game(int livesArg) {
    minigame1 = new GasPump();
    lives = livesArg;
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
  
  void display() {
    if (started) {
      fill(255);
      rectMode(CORNER);
      rect(-5, -5, width + 5, 90); // top bar overlay
      
      // hearts
      int heartCorner = 0;
      for (int i = 0; i < lives; i++) {
        image(heart, heartCorner, -5, 100, 100);
        heartCorner += 85;
      }
      
      if (roomID == 0) {  // in main room
        noStroke();
        
        // player
        updatePlayerPos();
        fill(255, 0, 0);
        rectMode(CORNER);
        rect(playerX, playerY, 20, 20);
      } else if (roomID == 1) {
        minigame1.display();
      }
      
    } else {  // display game start menu
      if (mouseX >= width/2 - startButtonSize/2 && mouseX <= width/2 + startButtonSize/2 && mouseY >= height/2 - startButtonSize/2 && mouseY <= height/2 + startButtonSize/2) {
        fill(255, 255, 0);
      } else {
        fill(0, 255, 0);
      } // logic for changing start buttons color when being hovered over
      //rectMode(CENTER); IF YOU UNCOMMENT THIS, FIX THE HIGHLIGHT AND CLICK FUNCTIONALITY TO GO ON THE BUTTON CORRECTLY
      rectMode(CORNER);
      rect(width/2 - startButtonSize/2, height/2 - startButtonSize/2, startButtonSize, startButtonSize);
      rectMode(CORNER);
    }
  }
  
  void handleMousePressed() {
    if (started) {
      // check roomID and do stuff based on what room user is in
      if (roomID == 1) {
        minigame1.handleMousePressed();
      }
    } else {
      // we are at the starting menu, check if they click start button
      if (mouseX >= width/2 - startButtonSize/2 && mouseX <= width/2 + startButtonSize/2 && mouseY >= height/2 - startButtonSize/2 && mouseY <= height/2 + startButtonSize/2) {
        // start button was clicked
        started = true;
      }
    }
  }
  
  void handleKeyPressed(char key, int keyCode) {
    if (started) {
      if (roomID == 0) {
        
        if (key == 'j') { // FOR DEBUGGING, DELETE LATER
          roomID = 1;
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
      } else if (roomID == 1) {
        if (key == 32) {// space bar to exit minigame
          roomID = 0;
        }
      }
    }
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
    }
  }
  
  void update() {
  // if started, update all minigames based on their own timers
  // if a minigame's timer is going off, tick it and check for important info
    if (started) {
      if (millis() - minigame1_lastTime >= minigame1_interval) {
        minigame1.tick();
        minigame1_lastTime = millis();
      }
    }
  }
  
}
