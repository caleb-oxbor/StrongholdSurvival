class Coin {
  int x, y;
  int size = 30;
  
  Coin(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  void draw() {
    imageMode(CENTER);
    image(game.coinSprite, x, y, size, size);
  }
  
  boolean isCollected(int px, int py) {
    return dist(px, py, x, y) < 30;
  }
}
