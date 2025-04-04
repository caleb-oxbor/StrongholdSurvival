// Defend minigame

class ZombieDefense {
  float yPos;
  boolean playerMovingUp = false;
  boolean playerMovingDown = false;
  
  boolean fire;
  boolean fired;
  int ammo;
  Bullet[] firedBullets;
  
  int numZombies;
  int maxZombies;
  Zombie[] zombies;
  boolean dead = false;
  int numBreached;
  
  color c;
  
  ZombieDefense() {
    yPos = height/2 + 85;
    fired = false;
    ammo = 10000;
    firedBullets = new Bullet[ammo];
    numZombies = 0;
    maxZombies = 10;
    zombies = new Zombie[maxZombies];
    numBreached = 0;
    c = color(0, 255, 0);
  }

  void stopPlayer() {
    playerMovingUp = false;
    playerMovingDown = false;
  }

  void updatePlayerPos() {
    if(playerMovingUp && yPos > 165) {
      yPos -= 2;
    }
    if(playerMovingDown && yPos < height - 10) {
      yPos += 2;
    }
  }
  
  int tick() {
    for(int i = 0; i < numZombies; i++) {
      zombies[i].moveZombie();
      if(zombies[i].xPos <= 100) {
        dead = true;
        numBreached++;
      }
      if(zombies[i].xPos <= 575 && (c == color(0, 255, 0))) {
        c = color(255, 255, 0);
      }
      else if(zombies[i].xPos <= 300 && (c == color(255, 255, 0) || c == color(0, 255, 0))) {
        c = color(255, 0, 0);
      }
      else if(c == color(0, 255, 0)){
        c = color(0, 255, 0);
      }
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
    dead = false;
    
    if(numZombies != maxZombies) {
      int chance = int(random(1, 20));
      if(chance == 1) {
        float ZombieYPos = random(125, height - 50);
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
             coins++;
           }
         }
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
    for(int i = 0; i < numZombies; i++) {
      fill(#487042);
      if(zombies[i].golden) {
        fill(#f2d45c);
      }
      float xPos = zombies[i].xPos;
      float yZombie = zombies[i].yPos;
      rect(xPos, yZombie, 30, 30);
    }
    
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
  
  color getColor() {
      return c;
  }
  
  float getYPos() {
    return yPos;
  }
  
}




class Bullet {
  float xPos;
  float yPos;
  float vx;
  
  Bullet(float yInitial) {
    xPos = 126;
    yPos = yInitial - 30;
    vx = 5;
  }
  
  void moveBullet() {
    xPos += vx;
  }
}

class Zombie {
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
  
  void moveZombie() {
    xPos -= vx;
  }
}
