// this is what u run to play the game

Game game;
int openOrCloseShop = 3;
void setup() {
  game = new Game(this, 3);  // you can pass an int here to set lives. default is 5
  size(960, 540);
  background(30, 60, 90);
}

void draw() {
  background(150);
  game.update();
  game.display(); 
  if (game.shopOpen) {
    game.drawShopOverlay();
  }
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
  game.handleKeyPressed(key, keyCode);
}

void keyReleased() {
  game.handleKeyReleased(key, keyCode);
}
