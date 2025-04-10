// this is what u run to play the game

Game game;
void setup() {
  game = new Game(this, 3);  // you can pass an int here to set lives. default is 5
  size(960, 540);
  background(30, 60, 90);
}

void draw() {
  background(150);
  game.update();
  game.display(); 
}

void mousePressed() {
  game.handleMousePressed(); 
}

void mouseDragged() {
  game.handleMouseDragged();
}

void mouseReleased() {
  game.handleMouseReleased();
}

void keyPressed() {
  if (game.shop != null) {
    if (key == 'c' || key == 'C') {
      game.shop.addCoins(5);
    }
    if (key == 'r' || key == 'R') {
      game.shop.shopOpen = true;
      print("shop open true");
    }
  }
  game.handleKeyPressed(key, keyCode);
}

void keyReleased() {
  game.handleKeyReleased(key, keyCode);
}
