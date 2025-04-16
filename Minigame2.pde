// Defend minigame

// Main minigame class driver
class ZombieDefense {
  // Player and mingame attributes
  float yPos;
  boolean playerMovingUp = false;
  boolean playerMovingDown = false;
  int minigameCoins = 0;
  boolean quotePrimed;
  
  // Gun attributes
  boolean fire;
  boolean fired;
  int ammo;
  Bullet[] firedBullets;
  
  // Zombie attributes
  int numZombies;
  int maxZombies;
  Zombie[] zombies;
  boolean dead = false;
  int numBreached;
  
  // Door color
  color c;
  
  // Constructor
  ZombieDefense() {
    // set default pos to be in middle
    yPos = height/2 + 85;
    fired = false;
    ammo = 10000;
    firedBullets = new Bullet[ammo];
    // Set the max number of zombies to be 10
    numZombies = 0;
    maxZombies = 10;
    zombies = new Zombie[maxZombies];
    numBreached = 0;
    // Set color to be green at the start
    c = color(0, 255, 0);
    quotePrimed = false;
  }

  // Stop the player from moving when leaving the game
  void stopPlayer() {
    playerMovingUp = false;
    playerMovingDown = false;
  }

  // Update the player positoion based on if they were moving up or down
  void updatePlayerPos() {
    if(playerMovingUp && yPos > 165) {
      yPos -= 2;
    }
    if(playerMovingDown && yPos < height - 10) {
      yPos += 2;
    }
  }
  
  // Tick that handles the zombie logic
  int tick() {
    color initColor = c;
    float closestZombie = width;
    for(int i = 0; i < numZombies; i++) {
      zombies[i].moveZombie();
      // Check if a zombie has breached the stronghold
      if (zombies[i].xPos <= 95) {
        dead = true;
        numBreached++;
      }
      
      // Get the pos of closest zombie
      if (zombies[i].xPos <= closestZombie) {
        closestZombie = zombies[i].xPos;
      }
      
      // Breach logic (Clears zombie)
      if(dead) {
        if(i + 1 != numZombies) {
          zombies[i] = zombies[i+1];
        }
        else if(i == numZombies - 1){
          zombies[i] = null;
          dead = false;
          numZombies--;
          if(numBreached == 5) {
            numBreached = 0;
            return -1;
          }
        }
      }
    }
    
      // Sets door color
      if(closestZombie <= 300) {
        c = color(255, 0, 0);
      } else if(closestZombie <= 575) {
        c = color(255, 255, 0);
      } else {
        c = color(0, 255, 0);
      }
      
      if (c == color(255, 0, 0) && initColor != color(255, 0, 0)) {
        quotePrimed = true;  
      }
    
    dead = false;
    
    // Creates a zombie if the capacity isn't exceeded
    if(numZombies != maxZombies) {
      // 1 in 20 chance to spawn every tick
      int chance = int(random(1, 20));
      if(chance == 1) {
        float ZombieYPos = random(125, height - 50);
        // Random chance for gold zombie
        int rand = int(random(1, 51));
        boolean gold = false;
        if(rand == 1) {
          gold = true;
        }
        Zombie zombie = new Zombie(float(width-30), ZombieYPos, gold);
        zombies[numZombies] = zombie;
        numZombies++;
      }
    }
    return 0;
  }
  
  // Tick that handles the bullet logic
  void tick2() {
    for(int i = 0; i < 10000 - ammo; i++) {
       firedBullets[i].moveBullet();
       for(int j = 0; j < numZombies; j++) {
         //Collision logic
         if(firedBullets[i].xPos + 15 >= zombies[j].xPos && firedBullets[i].yPos - 30 <= zombies[j].yPos
         && firedBullets[i].yPos + 30 >= zombies[j].yPos + 30 && firedBullets[i].xPos < width) {
           firedBullets[i].xPos = width * 2;
           dead = true;
           if(zombies[j].golden) {
             minigameCoins++;
           }
         }
         // Clear zombie
         if(dead) {
           if(j + 1 != numZombies) {
             zombies[j] = zombies[j+1];
              }
            else if(j == numZombies - 1){
              zombies[j] = null;
              dead = false;
              numZombies--;
            }
         }
       }
    }
    return;
  }
  
  // Handles key presses from player
  void handleKeyPressed(char key, int keyCode) {
    // Fire gun
    if(key == 'e' || key == 'E') {
      fire = true;
    }
    // Move up
    if(key == 'w' || key == 'W' || keyCode == UP) {
      playerMovingUp = true;
    }
    if(key == 's' || key == 'S' || keyCode == DOWN) {
      playerMovingDown = true;
    }
  }
  
    // Handles key releases from player
    void handleKeyReleased(char key, int keyCode) {
    // Fire gun
    if((key == 'e' || key == 'E') && fire) {
      fired = true;
    }
    // Move up
    if(key == 'w' || key == 'W' || keyCode == UP) {
      playerMovingUp = false;
    }
    if(key == 's' || key == 'S' || keyCode == DOWN) {
      playerMovingDown = false;
    }
  }
  
  // Sends minigame coins to main stronghold
  int getCoins() {
    int temp = minigameCoins;
    minigameCoins = 0;
    return temp;
  }
  
  // Main display for minigame
  void display() {
    noStroke();
    // dirt
    fill(#75532d);
    rect(0, 85, width, height);
    // bunker
    fill(150);
    rect(0, 85, 96, height);
    // barrier
    fill(0);
    rect(90, 85, 6, height);
    // player
    updatePlayerPos();
    stroke(0);
    fill(0, 0, 255);
    rect(10, yPos - 70, 70, 70);
    // Display zombies
    for(int i = 0; i < numZombies; i++) {
      fill(#487042);
      if(zombies[i].golden) {
        fill(#f2d45c);
      }
      float xPos = zombies[i].xPos;
      float yZombie = zombies[i].yPos;
      rect(xPos, yZombie, 30, 30);
    }
    
    // Display bullets
    for(int i = 0; i < 10000 - ammo; i++) {
      fill(35);
      float xPos = firedBullets[i].xPos;
      float yBullet = firedBullets[i].yPos;
      ellipse(xPos, yBullet, 30, 30);
      firedBullets[i].moveBullet();
    }
    if(fired) {
      if(ammo != 0) {
        Bullet bullet = new Bullet(yPos);
        firedBullets[10000 - ammo] = bullet;
        ammo--;
      }
      fired = false;
    }
  }
  
  // Getters
  color getColor() {
      return c;
  }
  
  float getYPos() {
    return yPos;
  }
  
}


// Bullet class
class Bullet {
  // Holds position and speed
  float xPos;
  float yPos;
  float vx;
  
  Bullet(float yInitial) {
    xPos = 100;
    yPos = yInitial - 30;
    vx = 5;
  }
  
  // Function to move the bullet
  void moveBullet() {
    xPos += vx;
  }
}

// Zombie class
class Zombie {
  // Holds postion, speed, and golden status
  float xPos;
  float yPos;
  float vx;
  boolean golden;
  
  Zombie(float x, float y, boolean state) {
    xPos = x;
    yPos = y;
    vx = 2;
    golden = state;
  }
  
  // Moves the zombie;
  void moveZombie() {
    xPos -= vx;
  }
}
