// gas pump or smth easy

class GasPump {
  float fuelPercentage;
  float decreaseRate;
  int   increaseRate;
  
  GasPump() {
    fuelPercentage = 100;
    decreaseRate = -0.5;
    increaseRate = 8;
  }
  
  GasPump(float startingPercentage) {
    fuelPercentage = startingPercentage;
    decreaseRate = -0.5;
    increaseRate = 8;
  }
  
  int tick() {
    // returns -1 if life lost, 0 otherwise
    fuelPercentage -= decreaseRate;
    if (fuelPercentage <= 0) {
      fuelPercentage = 66;
      return -1;
    }
    return 0;
  }
  
  void handleMousePressed() {
    // first make sure they're actually clicking the button
    fuelPercentage += increaseRate;
    if (fuelPercentage >= 100) {
      fuelPercentage = 100;
    }
  }
  
  void display() {
    rectMode(CENTER);
    fill(255);
    rect(width/2, height/2 + 45, 50, 300);
    
    rectMode(CORNER);
    fill(230, 172, 39); // this is a good gasoline color according to Google
    rect((width/2 - 25), (height/2 + 195), 50, -(fuelPercentage * 3));
  }
  
  color getColor() {
    if (fuelPercentage >= 66) {
      return color(0, 255, 0);
    } else if (fuelPercentage >= 33) {
      return color(255, 255, 0);
    } else {
      return color(255, 0, 0);
    }
  }
  
}
