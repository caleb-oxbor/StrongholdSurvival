// this is what u run to play the game

Game game;

void setup() {
  game = new Game(3);  // you can pass an int here to set lives. default is 5
  size(960, 540);
  background(0);
}

void draw() {
  background(0);
  game.update();
  game.display(); 
}

void mousePressed() {
  game.handleMousePressed(); 
}

void keyPressed() {
  game.handleKeyPressed(key, keyCode);
}

void keyReleased() {
  game.handleKeyReleased(key, keyCode);
}
