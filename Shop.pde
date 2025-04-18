class Shop {
  Game game;
  int itemCostSpeed;
  int itemCostHealth;

  PImage speedBoostIcon;
  PImage healthBoostIcon;

  Shop(Game g, int speedCost, int healthCost) {
    game = g;
    itemCostSpeed = speedCost;
    itemCostHealth = healthCost;

    speedBoostIcon = loadImage("health pot.png"); 
    healthBoostIcon = loadImage("healthUp.png");
  }

  void checkPurchase(int mx, int my) {
    if (mx >= width/2 - 140 && mx <= width/2 - 60 &&
        my >= height/2 - 60 && my <= height/2 + 20) {
      buySpeedBoost();
    }
    if (mx >= width/2 + 60 && mx <= width/2 + 140 &&
        my >= height/2 - 60 && my <= height/2 + 20) {
      buyHealthBoost();
    }
  }

  boolean buySpeedBoost() {
    if (game.coins >= itemCostSpeed) {
      game.coins -= itemCostSpeed;
      game.playerSpeed += 1;
      println("Bought Speed Boost! New speed: " + game.playerSpeed);
      return true;
    } else {
      println("Not enough coins for Speed Boost!");
      return false;
    }
  }

  boolean buyHealthBoost() {
    if (game.coins >= itemCostHealth) {
      game.coins -= itemCostHealth;
      game.lives += 1;
      game.lives = min(game.lives, 4);
      println("Bought Health Boost! Lives: " + game.lives);
      return true;
    } else {
      println("Not enough coins for Health Boost!");
      return false;
    }
  }
}
