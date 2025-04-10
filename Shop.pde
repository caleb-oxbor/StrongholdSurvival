class Shop {
  Game game;
  int itemCost;
  boolean shopOpen = false;
  
  Shop(Game g, int cost) {
    game = g;
    itemCost = cost;
  }

  boolean buyItem() {
    if (game.coins >= itemCost) {
      game.coins -= itemCost;
      println("Item bought! Coins left: " + game.coins);
      return true;
    } else {
      println("Not enough coins!");
      return false;
    }
  }

  void display() {
    fill(255);
    text("Coins: " + game.coins, 10, 20);
    text("Press 'B' to buy item (" + itemCost + " coins)", 10, 40);
  }

  void addCoins(int amount) {
    game.coins += amount;
    println("Picked up " + amount + " coins. Total: " + game.coins);
  }
}
