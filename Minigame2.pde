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
  
  ZombieDefense() {
    yPos = height/2 + 85;
    fired = false;
    ammo = 10000;
    firedBullets = new Bullet[ammo];
    numZombies = 0;
    maxZombies = 3;
    zombies = new Zombie[maxZombies];
  }

  voidStopPlayer() {
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
      }
      if(dead) {
        if(i + 1 != numZombies) {
          zombies[i] = zombies[i+1];
        }
        else if(i == numZombies - 1){
          zombies[i] = null;
          dead = false;
          numZombies--;
          return -1;
        }
      }
    }
    dead = false;
    
    if(numZombies != maxZombies) {
      int chance = int(random(1, 5));
      if(chance == 1) {
        float ZombieYPos = random(85, height - 50);
        Zombie zombie = new Zombie(float(width-30), ZombieYPos);
        zombies[numZombies] = zombie;
        numZombies++;
      }
    }
    return 0;
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
      return color(0, 255, 0);
      //return color(255, 255, 0);
      //return color(255, 0, 0);
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
  
  Zombie(float x, float y) {
    xPos = x;
    yPos = y;
    vx = 20;
  }
  
  void moveZombie() {
    xPos -= vx;
  }
}
